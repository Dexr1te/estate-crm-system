import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:real_estate_crm/core/map/map_tiles.dart';
import 'package:real_estate_crm/core/network/api_client.dart';

const _builtInApiBaseUrl = apiBaseUrl;

class RemoteKeys {
  RemoteKeys._();

  static const apiBaseUrl = 'api_base_url';
  static const mapTileUrl = 'map_tile_url';
  static const mapAttribution = 'map_attribution';
}

class RemoteSettings {
  final String apiBaseUrl;
  final String mapTileUrl;
  final String mapAttribution;

  const RemoteSettings({
    required this.apiBaseUrl,
    required this.mapTileUrl,
    required this.mapAttribution,
  });

  static const defaults = <String, String>{
    RemoteKeys.apiBaseUrl: _builtInApiBaseUrl,
    RemoteKeys.mapTileUrl: MapTiles.openStreetMap,
    RemoteKeys.mapAttribution: MapTiles.openStreetMapAttribution,
  };

  factory RemoteSettings.from(
    Map<String, String> values, {
    bool apiPinned = apiBaseUrlPinned,
  }) =>
      RemoteSettings(
        apiBaseUrl: apiPinned
            ? _builtInApiBaseUrl
            : _apiBaseUrl(values[RemoteKeys.apiBaseUrl]) ?? _builtInApiBaseUrl,
        mapTileUrl:
            _tileUrl(values[RemoteKeys.mapTileUrl]) ?? MapTiles.openStreetMap,
        mapAttribution: _text(values[RemoteKeys.mapAttribution]) ??
            MapTiles.openStreetMapAttribution,
      );

  static String? _apiBaseUrl(String? value) {
    final url = _https(value);
    if (url == null) return null;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static String? _tileUrl(String? value) {
    final url = _https(value);
    if (url == null) return null;
    final complete = ['{z}', '{x}', '{y}'].every(url.contains);
    return complete ? url : null;
  }

  static String? _https(String? value) {
    final text = value?.trim() ?? '';
    final uri = Uri.tryParse(text);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    return text;
  }

  static String? _text(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }

  @override
  bool operator ==(Object other) =>
      other is RemoteSettings &&
      other.apiBaseUrl == apiBaseUrl &&
      other.mapTileUrl == mapTileUrl &&
      other.mapAttribution == mapAttribution;

  @override
  int get hashCode => Object.hash(apiBaseUrl, mapTileUrl, mapAttribution);
}

abstract class RemoteConfigSource {
  Future<Map<String, String>> activated();

  Future<Map<String, String>> fetched();

  Stream<Map<String, String>> get updates;
}

class FirebaseRemoteConfigSource implements RemoteConfigSource {
  FirebaseRemoteConfigSource({
    this.minimumFetchInterval = const Duration(hours: 1),
  });

  final Duration minimumFetchInterval;

  FirebaseRemoteConfig get _config => FirebaseRemoteConfig.instance;

  Future<void>? _ready;

  Future<void> _ensureReady() => _ready ??= _prepare();

  Future<void> _prepare() async {
    await _config.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: kDebugMode ? Duration.zero : minimumFetchInterval,
    ));
    await _config.setDefaults(RemoteSettings.defaults);
  }

  @override
  Future<Map<String, String>> activated() async {
    await _ensureReady();
    await _config.activate();
    return _values();
  }

  @override
  Future<Map<String, String>> fetched() async {
    await _ensureReady();
    await _config.fetchAndActivate();
    return _values();
  }

  @override
  Stream<Map<String, String>> get updates =>
      _config.onConfigUpdated.asyncMap((_) async {
        await _config.activate();
        return _values();
      });

  Map<String, String> _values() =>
      _config.getAll().map((key, value) => MapEntry(key, value.asString()));
}

class RemoteConfigSync {
  RemoteConfigSync({
    required RemoteConfigSource source,
    required ApiClient client,
  })  : _source = source,
        _client = client;

  final RemoteConfigSource _source;
  final ApiClient _client;
  StreamSubscription<Map<String, String>>? _updates;
  RemoteSettings? _current;

  RemoteSettings? get current => _current;

  Future<void> start() async {
    try {
      _apply(await _source.activated());
    } catch (error) {
      debugPrint('[remote-config] cached values unavailable: $error');
    }
    unawaited(_source.fetched().then(_apply, onError: (Object error) {
      debugPrint('[remote-config] fetch failed: $error');
    }));
    try {
      _updates = _source.updates.listen(_apply, onError: (Object error) {
        debugPrint('[remote-config] live updates failed: $error');
      });
    } catch (error) {
      debugPrint('[remote-config] live updates unavailable: $error');
    }
  }

  void _apply(Map<String, String> values) {
    final settings = RemoteSettings.from(values);
    if (settings == _current) return;
    _current = settings;
    ApiEndpoint.baseUrl = settings.apiBaseUrl;
    _client.useBaseUrl(settings.apiBaseUrl);
    MapTiles.urlTemplate = settings.mapTileUrl;
    MapTiles.attribution = settings.mapAttribution;
  }

  Future<void> dispose() async {
    await _updates?.cancel();
    _updates = null;
  }
}
