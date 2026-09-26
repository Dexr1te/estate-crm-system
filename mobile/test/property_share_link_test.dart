import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_share_link_card.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// A listing's public link: one address a client opens in any browser.
///
/// The card makes the link, copies and shares it, says how often it was
/// opened, and switches it off — the last only for someone allowed to, and
/// only after asking, because it breaks a link already sent.

const _flat = PropertyResponse(
  id: 7,
  title: 'Severny Residence, apartment 84 with a view of the mountains',
  address: 'Severny Residence 12',
  city: 'Almaty',
  price: 28000000,
  rooms: 3,
);

late FakePropertiesRepository _repo;
late FakeShareGateway _share;

void _install({PropertyShareLink? existing}) {
  _repo = FakePropertiesRepository(const [_flat]);
  if (existing != null) _repo.shareLinks[_flat.id] = existing;
  _share = FakeShareGateway();
  Injector.propertiesRepository = _repo;
  Injector.shareGateway = _share;
  Injector.clientsRepository = FakeClientsRepository();
  Injector.dealsRepository = FakeDealsRepository(const []);
  Injector.meetingsRepository = FakeMeetingsRepository(const []);
}

Widget _card({bool canRevoke = true}) => Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: PropertyShareLinkCard(
            propertyId: _flat.id, title: _flat.title, canRevoke: canRevoke),
      ),
    );

Future<void> _show(WidgetTester tester, Widget child,
    {Size size = const Size(390, 844),
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(tester, child,
      size: size, brightness: brightness, textScale: textScale, locale: locale);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

final _opened = PropertyShareLink(
  url: FakePropertiesRepository.shareUrlFor(7),
  viewCount: 3,
  lastViewedAt: DateTime(2026, 9, 24, 18),
  createdAt: DateTime(2026, 9, 20),
);

void main() {
  testWidgets('a listing with no link offers to make one', (tester) async {
    _install();
    await _show(tester, _card());

    expect(find.text('PUBLIC LINK'), findsOneWidget);
    expect(find.textContaining('Opens in any browser'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('share-link-create')));
    await tester.pumpAndSettle();

    expect(_repo.shareLinkRequests, [7]);
    expect(find.text(FakePropertiesRepository.shareUrlFor(7)), findsOneWidget);
    expect(find.text('Not opened yet'), findsOneWidget);
    expect(find.byKey(const ValueKey('share-link-create')), findsNothing);
  });

  testWidgets('an opened link says how often and when', (tester) async {
    _install(existing: _opened);
    await _show(tester, _card());

    expect(find.textContaining('Opened 3 times'), findsOneWidget);
    expect(find.textContaining('Last opened Sep 24, 2026'), findsOneWidget);
  });

  testWidgets('copy puts the address on the clipboard', (tester) async {
    _install(existing: _opened);
    String? copied;
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String?;
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await _show(tester, _card());

    await tester.tap(find.byKey(const ValueKey('share-link-copy')));
    await tester.pump();

    expect(copied, FakePropertiesRepository.shareUrlFor(7));
    expect(find.text('Link copied'), findsOneWidget);
  });

  testWidgets('share hands the title and the address to the share sheet',
      (tester) async {
    _install(existing: _opened);
    await _show(tester, _card());

    await tester.tap(find.byKey(const ValueKey('share-link-share')));
    await tester.pumpAndSettle();

    expect(_share.calls, 1);
    expect(_share.sharedText,
        '${_flat.title}\n${FakePropertiesRepository.shareUrlFor(7)}');
  });

  testWidgets('switching a link off asks first, then offers a new one',
      (tester) async {
    _install(existing: _opened);
    await _show(tester, _card());

    await tester.tap(find.byKey(const ValueKey('share-link-revoke')));
    await tester.pumpAndSettle();
    expect(find.text('Switch off the link?'), findsOneWidget);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(_repo.revokedShareLinks, isEmpty);

    await tester.tap(find.byKey(const ValueKey('share-link-revoke')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Switch off').last);
    await tester.pumpAndSettle();

    expect(_repo.revokedShareLinks, [7]);
    expect(find.byKey(const ValueKey('share-link-create')), findsOneWidget);
    expect(find.text(FakePropertiesRepository.shareUrlFor(7)), findsNothing);
  });

  testWidgets('someone who may not switch it off is not offered to',
      (tester) async {
    _install(existing: _opened);
    await _show(tester, _card(canRevoke: false));

    expect(find.byKey(const ValueKey('share-link-copy')), findsOneWidget);
    expect(find.byKey(const ValueKey('share-link-revoke')), findsNothing);
  });

  testWidgets('the listing screen carries the card', (tester) async {
    _install(existing: _opened);
    await _show(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
          BlocProvider(create: (_) => PropertiesBloc(_repo)),
          BlocProvider(create: (_) => ClientsBloc(FakeClientsRepository())),
        ],
        child: const PropertyDetailScreen(id: 7),
      ),
    );

    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('share-link-card')), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const ValueKey('share-link-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('share-link-revoke')), findsNothing,
        reason: 'nobody is signed in, so nobody may switch it off');
  });

  for (final existing in [null, _opened]) {
    forEachAcceptanceCase(
        'public link card ${existing == null ? 'empty' : 'with a link'}',
        (tester, size, brightness, scale) async {
      _install(existing: existing);
      for (final locale in kAcceptanceLocales) {
        await _show(tester, _card(),
            size: size,
            brightness: brightness,
            textScale: scale,
            locale: locale);
      }
    });
  }
}
