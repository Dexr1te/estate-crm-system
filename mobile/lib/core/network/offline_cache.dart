import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:real_estate_crm/core/utils/clock.dart';

/// One answer the server gave earlier, read back from disk.
class CachedResponse {
  final Object? data;
  final int statusCode;
  final DateTime savedAt;

  const CachedResponse(
      {required this.data, required this.statusCode, required this.savedAt});
}

class _Meta {
  int size;
  DateTime usedAt;
  _Meta(this.size, this.usedAt);
}

/// A read-only, size-capped disk cache of the answers to the reads an agent
/// needs when the signal drops: the clients, the flats, the deals, the day.
///
/// Every entry is a JSON file in the app support directory, named by a hash of
/// the request *and* of whose session made it, so one account can never read
/// what another account cached. The whole directory is wiped when the session
/// ends. Entries older than [maxAge] are never served, and when the total grows
/// past [maxBytes] the least recently used entries go first.
class OfflineCache {
  OfflineCache({
    required Future<Directory> Function() directory,
    this.maxBytes = 20 * 1024 * 1024,
    this.maxAge = const Duration(days: 14),
    this.maxEntryBytes = 2 * 1024 * 1024,
  }) : _directory = directory;

  factory OfflineCache.device() => OfflineCache(directory: () async {
        final support = await getApplicationSupportDirectory();
        return Directory('${support.path}/offline_cache');
      });

  final Future<Directory> Function() _directory;
  final int maxBytes;
  final Duration maxAge;
  final int maxEntryBytes;

  Directory? _dir;
  Map<String, _Meta>? _index;
  Future<void> _queue = Future.value();

  static final _cacheable = <RegExp>[
    RegExp(r'^/clients(/with-details|/\d+(/matches|/activities)?)?$'),
    RegExp(
        r'^/properties(/\d+(/photos|/cover|/viewings|/price-history|/price-insight)?)?$'),
    RegExp(r'^/properties/price-insight$'),
    RegExp(r'^/deals(/\d+(/comments(/mentionable)?)?)?$'),
    RegExp(r'^/meetings(/upcoming|/\d+)?$'),
    RegExp(r'^/tasks$'),
    RegExp(r'^/dashboard/summary$'),
  ];

  /// Only reads of the main entities are kept; never a write, never anything
  /// under `/auth`.
  static bool isCacheable(String method, String path) {
    if (method.toUpperCase() != 'GET') return false;
    final clean = path.split('?').first;
    if (clean.startsWith('/auth')) return false;
    return _cacheable.any((r) => r.hasMatch(clean));
  }

  /// The identity of a request made by [scope] — the signed-in user and their
  /// team. Query parameters are sorted so their order does not matter. The
  /// file name is a hash of it; the identity itself is stored in the file and
  /// checked on read, so a hash collision can only ever miss.
  static String keyFor({
    required String method,
    required String path,
    required Map<String, dynamic> query,
    required String scope,
  }) {
    final entries = query.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key}=${e.value}')
        .toList()
      ..sort();
    return '$scope ${method.toUpperCase()} $path?${entries.join('&')}';
  }

  static String fileNameFor(String key) => '${_fnv(key)}.json';

  static String _fnv(String input) {
    var a = 0x811c9dc5;
    var b = 0x050c5d1f;
    for (final unit in utf8.encode(input)) {
      a = ((a ^ unit) * 0x01000193) & 0xffffffff;
      b = ((b ^ unit) * 0x01000193 + 0x9e37) & 0xffffffff;
    }
    return a.toRadixString(16).padLeft(8, '0') +
        b.toRadixString(16).padLeft(8, '0') +
        input.length.toRadixString(16);
  }

  /// The stored answer for [key], or null when there is none, it is too old,
  /// or the disk cannot be read. Never throws.
  Future<CachedResponse?> read(String key) => _serial(() async {
        try {
          final index = await _load();
          final name = fileNameFor(key);
          if (!index.containsKey(name)) return null;
          final file = File('${_dir!.path}/$name');
          final json = jsonDecode(await file.readAsString());
          if (json is! Map || json['key'] != key) return null;

          final savedAt =
              DateTime.fromMillisecondsSinceEpoch(json['savedAt'] as int);
          if (AppClock.now().difference(savedAt) > maxAge) {
            await _remove(name);
            return null;
          }

          final now = AppClock.now();
          index[name]!.usedAt = now;
          try {
            await file.setLastModified(now);
          } catch (_) {}

          final raw = json['data'];
          return CachedResponse(
            data: json['bytes'] == true
                ? Uint8List.fromList(base64Decode(raw as String))
                : raw,
            statusCode: json['status'] as int? ?? 200,
            savedAt: savedAt,
          );
        } catch (_) {
          return null;
        }
      });

  /// Keeps [data] as the answer for [key]. Bytes are kept base64-encoded. An
  /// entry larger than [maxEntryBytes] is not kept at all. Never throws.
  Future<void> write(String key, Object? data, {int statusCode = 200}) =>
      _serial(() async {
        try {
          final bytes = data is List<int>;
          final body = jsonEncode({
            'key': key,
            'savedAt': AppClock.now().millisecondsSinceEpoch,
            'status': statusCode,
            'bytes': bytes,
            'data': bytes ? base64Encode(data) : data,
          });
          final encoded = utf8.encode(body);
          if (encoded.length > maxEntryBytes) return;

          final index = await _load();
          final name = fileNameFor(key);
          final tmp = File('${_dir!.path}/$name.tmp');
          await tmp.writeAsBytes(encoded, flush: true);
          await tmp.rename('${_dir!.path}/$name');
          index[name] = _Meta(encoded.length, AppClock.now());
          await _evict();
        } catch (_) {}
      });

  /// Forgets everything — the session that filled the cache has ended.
  Future<void> wipe() => _serial(() async {
        try {
          final dir = _dir ?? await _directory();
          if (await dir.exists()) await dir.delete(recursive: true);
        } catch (_) {}
        _index = null;
      });

  /// Bytes currently on disk, as the cache accounts for them.
  Future<int> sizeInBytes() => _serial(() async {
        try {
          final index = await _load();
          return index.values.fold<int>(0, (sum, m) => sum + m.size);
        } catch (_) {
          return 0;
        }
      });

  Future<Map<String, _Meta>> _load() async {
    final known = _index;
    if (known != null && _dir != null) return known;
    final dir = _dir ??= await _directory();
    await dir.create(recursive: true);
    final index = <String, _Meta>{};
    await for (final entity in dir.list()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      final stat = await entity.stat();
      index[entity.uri.pathSegments.last] = _Meta(stat.size, stat.modified);
    }
    return _index = index;
  }

  Future<void> _remove(String name) async {
    _index?.remove(name);
    try {
      await File('${_dir!.path}/$name').delete();
    } catch (_) {}
  }

  Future<void> _evict() async {
    final index = _index!;
    var total = index.values.fold<int>(0, (sum, m) => sum + m.size);
    if (total <= maxBytes) return;
    final oldestFirst = index.entries.toList()
      ..sort((a, b) => a.value.usedAt.compareTo(b.value.usedAt));
    for (final entry in oldestFirst) {
      if (total <= maxBytes) break;
      total -= entry.value.size;
      await _remove(entry.key);
    }
  }

  Future<T> _serial<T>(Future<T> Function() task) {
    final result = _queue.then((_) => task());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }
}
