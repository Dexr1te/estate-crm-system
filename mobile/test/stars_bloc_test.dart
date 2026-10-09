import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/star_models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/stars/presentation/bloc/stars_bloc.dart';

import 'fakes.dart';

/// The app-wide starred set: read after sign-in, flipped the moment a star is
/// tapped and put back when the server refuses, written once per record at a
/// time however fast the taps come, and emptied at sign-out.

final _now = DateTime(2026, 10, 9, 12, 0);

const _client = StarKey(StarType.client, 1);
const _listing = StarKey(StarType.property, 2);
const _deal = StarKey(StarType.deal, 3);

StarredItem _item(StarKey key, String title, DateTime at, {String? subtitle}) =>
    StarredItem(
        type: key.type,
        id: key.id,
        title: title,
        subtitle: subtitle,
        starredAt: at);

final _listingStar =
    _item(_listing, 'Abay 10, flat 4', _now.subtract(const Duration(days: 1)));
final _dealStar =
    _item(_deal, 'Dana buys Abay 10', _now.subtract(const Duration(days: 2)));

Future<void> _settle() => Future<void>.delayed(Duration.zero);

DioException _status(int code, String method) {
  final options = RequestOptions(path: '/stars', method: method);
  return DioException(
    requestOptions: options,
    response: Response<dynamic>(requestOptions: options, statusCode: code),
  );
}

void main() {
  setUp(() {
    AppClock.freeze(_now);
    addTearDown(AppClock.reset);
  });

  Future<(StarsBloc, FakeStarsRepository)> loaded(
      [List<StarredItem>? items]) async {
    final repo = FakeStarsRepository(
      items: items ?? [_listingStar, _dealStar],
      records: {
        _client: (title: 'Aliya Nurlanovna', subtitle: '+7 701 000 00 01'),
      },
    );
    final bloc = StarsBloc(repo);
    addTearDown(bloc.close);
    bloc.add(StarsLoadEvent());
    await _settle();
    return (bloc, repo);
  }

  test('reads the list newest first and knows what is starred', () async {
    final (bloc, repo) = await loaded();

    expect(bloc.state.status, StarsStatus.loaded);
    expect(bloc.state.items.map((i) => i.key), [_listing, _deal]);
    expect(bloc.state.isStarred(_listing), isTrue);
    expect(bloc.state.isStarred(_client), isFalse);
    expect(bloc.state.ofType(StarType.deal).single.title, 'Dana buys Abay 10');
    expect(repo.reads, 1);
  });

  test('a star shows at once, on top, and takes the server\'s answer',
      () async {
    final (bloc, repo) = await loaded();
    repo.gate = Completer<void>();

    bloc.add(StarsToggleEvent(_client, title: 'Aliya', subtitle: ''));
    await _settle();
    expect(bloc.state.isStarred(_client), isTrue,
        reason: 'the star flips before the server answers');
    expect(bloc.state.items.first.key, _client);
    expect(bloc.state.items.first.subtitle, isNull,
        reason: 'an empty second line is no second line');
    expect(repo.writes, ['PUT CLIENT 1']);

    repo.gate!.complete();
    await _settle();
    expect(bloc.state.isStarred(_client), isTrue);
    expect(bloc.state.items.first.title, 'Aliya Nurlanovna');
    expect(bloc.state.items.first.subtitle, '+7 701 000 00 01');
    expect(bloc.state.writeFailure, isNull);
  });

  test('a refused star goes back, and says which and why', () async {
    final (bloc, repo) = await loaded();
    repo
      ..gate = Completer<void>()
      ..writeError = _status(404, 'PUT');

    bloc.add(StarsToggleEvent(_client, title: 'Aliya'));
    await _settle();
    expect(bloc.state.isStarred(_client), isTrue);

    repo.gate!.complete();
    await _settle();
    expect(bloc.state.isStarred(_client), isFalse);
    expect(bloc.state.items.map((i) => i.key), [_listing, _deal]);
    final failure = bloc.state.writeFailure!;
    expect(failure.key, _client);
    expect(failure.starring, isTrue);
    expect(failure.failure.kind, ApiFailureKind.notFound);
  });

  test('a refused unstar puts the record back where it was', () async {
    final (bloc, repo) = await loaded();
    repo
      ..gate = Completer<void>()
      ..writeError = Exception('offline');

    bloc.add(StarsToggleEvent(_deal, title: 'Dana buys Abay 10'));
    await _settle();
    expect(bloc.state.isStarred(_deal), isFalse,
        reason: 'the star comes off before the server answers');

    repo.gate!.complete();
    await _settle();
    expect(bloc.state.items.map((i) => i.key), [_listing, _deal]);
    expect(bloc.state.writeFailure!.starring, isFalse);
    expect(repo.writes, ['DELETE DEAL 3']);
  });

  test('each refusal is a new one, so a listener hears both', () async {
    final (bloc, repo) = await loaded();
    repo.writeError = Exception('offline');

    bloc.add(StarsToggleEvent(_client, title: 'Aliya'));
    await _settle();
    final first = bloc.state.writeFailure;
    bloc.add(StarsToggleEvent(_client, title: 'Aliya'));
    await _settle();

    expect(first, isNotNull);
    expect(identical(bloc.state.writeFailure, first), isFalse);
    expect(bloc.state.isStarred(_client), isFalse);
  });

  test('taps that land while a write is out are written after it, in turn',
      () async {
    final (bloc, repo) = await loaded();
    repo.gate = Completer<void>();

    bloc.add(StarsToggleEvent(_client, title: 'Aliya'));
    await _settle();
    bloc.add(StarsToggleEvent(_client, title: 'Aliya'));
    await _settle();
    expect(bloc.state.isStarred(_client), isFalse);
    expect(repo.writes, ['PUT CLIENT 1'], reason: 'one write at a time');

    repo.gate!.complete();
    await _settle();
    await _settle();
    expect(repo.writes, ['PUT CLIENT 1', 'DELETE CLIENT 1']);
    expect(bloc.state.isStarred(_client), isFalse);
    expect(repo.items.map((i) => i.key), [_listing, _deal]);
  });

  test('a tap back to what the server holds sends nothing more', () async {
    final (bloc, repo) = await loaded();
    repo.gate = Completer<void>();

    bloc.add(StarsToggleEvent(_deal, title: 'Dana buys Abay 10'));
    bloc.add(StarsToggleEvent(_deal, title: 'Dana buys Abay 10'));
    bloc.add(StarsToggleEvent(_deal, title: 'Dana buys Abay 10'));
    await _settle();
    expect(bloc.state.isStarred(_deal), isFalse);

    repo.gate!.complete();
    await _settle();
    await _settle();
    expect(repo.writes, ['DELETE DEAL 3']);
    expect(bloc.state.isStarred(_deal), isFalse);
  });

  test('a reload while a star is out keeps the star as asked', () async {
    final (bloc, repo) = await loaded();
    final gate = Completer<void>();
    repo.gate = gate;

    bloc.add(StarsToggleEvent(_client, title: 'Aliya'));
    await _settle();
    bloc.add(StarsLoadEvent());
    await _settle();
    expect(bloc.state.isStarred(_client), isTrue,
        reason: 'the server has not heard of it yet; the list keeps it');

    gate.complete();
    await _settle();
    expect(bloc.state.isStarred(_client), isTrue);
  });

  test(
      'a list that cannot be read the first time is a failure; later, the '
      'list stays', () async {
    final repo = FakeStarsRepository()..readError = Exception('offline');
    final bloc = StarsBloc(repo);
    addTearDown(bloc.close);

    bloc.add(StarsLoadEvent());
    await _settle();
    expect(bloc.state.status, StarsStatus.failure);
    expect(bloc.state.loadFailure, isNotNull);

    repo
      ..readError = null
      ..items = [_listingStar];
    bloc.ensureLoaded();
    await _settle();
    expect(bloc.state.status, StarsStatus.loaded);

    repo.readError = Exception('offline');
    bloc.refresh();
    await _settle();
    expect(bloc.state.status, StarsStatus.loaded);
    expect(bloc.state.items.single.key, _listing);
  });

  test('sign-out empties it, and a write that lands afterwards changes nothing',
      () async {
    final (bloc, repo) = await loaded();
    final gate = Completer<void>();
    repo.gate = gate;
    bloc.add(StarsToggleEvent(_client, title: 'Aliya'));
    await _settle();

    bloc.add(StarsResetEvent());
    await _settle();
    expect(bloc.state.status, StarsStatus.initial);
    expect(bloc.state.items, isEmpty);
    expect(bloc.state.isStarred(_listing), isFalse);

    gate.complete();
    await _settle();
    expect(bloc.state.items, isEmpty);
    expect(bloc.state.writeFailure, isNull);

    bloc.refresh();
    await _settle();
    expect(repo.reads, 1, reason: 'nothing is read for nobody');
  });
}
