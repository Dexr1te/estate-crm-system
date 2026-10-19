import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/config/remote_config.dart';
import 'package:real_estate_crm/core/map/map_tiles.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/session/session_store.dart';

const _tiles = 'https://tiles.example.com/{z}/{x}/{y}.png';

class _FakeSource implements RemoteConfigSource {
  _FakeSource({this.cached = const {}, this.failing = false});

  final Map<String, String> cached;
  final bool failing;
  final fetch = Completer<Map<String, String>>();
  final live = StreamController<Map<String, String>>.broadcast();

  @override
  Future<Map<String, String>> activated() async {
    if (failing) throw StateError('no Firebase');
    return cached;
  }

  @override
  Future<Map<String, String>> fetched() {
    if (failing) return Future.error(StateError('no Firebase'));
    return fetch.future;
  }

  @override
  Stream<Map<String, String>> get updates {
    if (failing) throw StateError('no Firebase');
    return live.stream;
  }
}

void main() {
  group('RemoteSettings', () {
    test('an https address is taken, without its trailing slash', () {
      final settings = RemoteSettings.from(
          {RemoteKeys.apiBaseUrl: ' https://api.example.com/api/ '});

      expect(settings.apiBaseUrl, 'https://api.example.com/api');
    });

    test('anything but an https address keeps the built-in one', () {
      for (final value in [
        'http://api.example.com/api',
        'api.example.com',
        'https://',
        '',
        'not a url',
      ]) {
        expect(RemoteSettings.from({RemoteKeys.apiBaseUrl: value}).apiBaseUrl,
            apiBaseUrl,
            reason: value);
      }
    });

    test('an address given at build time wins over the remote one', () {
      final settings = RemoteSettings.from(
          {RemoteKeys.apiBaseUrl: 'https://api.example.com/api'},
          apiPinned: true);

      expect(settings.apiBaseUrl, apiBaseUrl);
    });

    test('a tile address needs https and all of z, x and y', () {
      expect(RemoteSettings.from({RemoteKeys.mapTileUrl: _tiles}).mapTileUrl,
          _tiles);
      for (final value in [
        'https://tiles.example.com/{z}/{x}.png',
        'http://tiles.example.com/{z}/{x}/{y}.png',
        '',
      ]) {
        expect(RemoteSettings.from({RemoteKeys.mapTileUrl: value}).mapTileUrl,
            MapTiles.openStreetMap,
            reason: value);
      }
    });

    test('a blank attribution keeps OpenStreetMap credited', () {
      expect(
          RemoteSettings.from({RemoteKeys.mapAttribution: '  '}).mapAttribution,
          MapTiles.openStreetMapAttribution);
      expect(
          RemoteSettings.from({RemoteKeys.mapAttribution: ' © Example '})
              .mapAttribution,
          '© Example');
    });

    test('the defaults handed to Firebase are the built-in values', () {
      expect(RemoteSettings.from(RemoteSettings.defaults),
          RemoteSettings.from(const {}));
    });
  });

  group('RemoteConfigSync', () {
    late ApiClient client;

    setUp(() {
      final tiles = MapTiles.urlTemplate;
      final attribution = MapTiles.attribution;
      addTearDown(() {
        ApiEndpoint.baseUrl = apiBaseUrl;
        MapTiles.urlTemplate = tiles;
        MapTiles.attribution = attribution;
      });
      client = ApiClient(SessionStore());
    });

    test('cached values apply at start, a fetch and a live update after',
        () async {
      final source = _FakeSource(cached: {
        RemoteKeys.apiBaseUrl: 'https://cached.example.com/api',
        RemoteKeys.mapTileUrl: _tiles,
        RemoteKeys.mapAttribution: '© Example',
      });
      final sync = RemoteConfigSync(source: source, client: client);
      addTearDown(sync.dispose);

      await sync.start();

      expect(ApiEndpoint.baseUrl, 'https://cached.example.com/api');
      expect(client.dio.options.baseUrl, 'https://cached.example.com/api');
      expect(backendPageUrl('/privacy').toString(),
          'https://cached.example.com/api/privacy');
      expect(MapTiles.urlTemplate, _tiles);
      expect(MapTiles.attribution, '© Example');

      source.fetch
          .complete({RemoteKeys.apiBaseUrl: 'https://fetched.example.com/api'});
      await pumpEventQueue();

      expect(client.dio.options.baseUrl, 'https://fetched.example.com/api');
      expect(MapTiles.urlTemplate, MapTiles.openStreetMap);

      source.live.add({RemoteKeys.apiBaseUrl: 'https://live.example.com/api'});
      await pumpEventQueue();

      expect(ApiEndpoint.baseUrl, 'https://live.example.com/api');
      expect(client.dio.options.baseUrl, 'https://live.example.com/api');
    });

    test('a bad value from Firebase falls back instead of breaking the app',
        () async {
      final source = _FakeSource(
          cached: {RemoteKeys.apiBaseUrl: 'http://insecure.example.com'});
      final sync = RemoteConfigSync(source: source, client: client);
      addTearDown(sync.dispose);

      await sync.start();

      expect(client.dio.options.baseUrl, apiBaseUrl);
    });

    test('without Firebase the built-in values stay', () async {
      final sync =
          RemoteConfigSync(source: _FakeSource(failing: true), client: client);
      addTearDown(sync.dispose);

      await sync.start();
      await pumpEventQueue();

      expect(sync.current, isNull);
      expect(ApiEndpoint.baseUrl, apiBaseUrl);
      expect(client.dio.options.baseUrl, apiBaseUrl);
    });
  });
}
