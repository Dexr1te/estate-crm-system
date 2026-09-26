import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

const _property = PropertyResponse(
  id: 12,
  title: 'Светлая квартира у парка',
  address: 'ул. Абая, 150',
  city: 'Алматы',
  status: PropertyStatus.RESERVED,
  price: 42000000,
  areaSqm: 64,
  rooms: 2,
  floor: 4,
  totalFloors: 9,
  agentId: 5,
  agentName: 'Айгерим Нұрланқызы',
  description: 'Үлкен терезелер, тыныш аула.',
);

late FakePropertiesRepository _repo;
late FakeShareGateway _share;

Widget _wrap() => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(create: (_) => PropertiesBloc(_repo)),
      ],
      child: const PropertyDetailScreen(id: 12),
    );

Future<void> _open(WidgetTester tester,
    {Locale locale = const Locale('ru')}) async {
  await expectNoOverflow(tester, _wrap(),
      size: const Size(390, 844),
      brightness: Brightness.light,
      textScale: 1.0,
      locale: locale);
  await tester.pumpAndSettle();
}

Future<void> _tapBrochure(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('property-brochure'));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  for (var i = 0; i < 200 && _share.calls == 0; i++) {
    await tester.runAsync(() => Future<void>.delayed(
          const Duration(milliseconds: 20),
        ));
    await tester.pump();
  }
  await tester.pump();
}

void main() {
  setUp(() {
    _repo = FakePropertiesRepository([_property]);
    _share = FakeShareGateway();
    Injector.propertiesRepository = _repo;
    Injector.shareGateway = _share;
  });

  testWidgets('the brochure is shared as a PDF named after the listing',
      (tester) async {
    await _open(tester);
    expect(find.text('Буклет (PDF)'), findsOneWidget);

    await _tapBrochure(tester);

    final file = _share.sharedFile;
    expect(file, isNotNull);
    expect(file!.fileName, 'listing-12-svetlaya-kvartira-u-parka.pdf');
    expect(file.mimeType, 'application/pdf');
    expect(ascii.decode(file.bytes.sublist(0, 5)), '%PDF-');
    expect(_share.sharedText, _property.title);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('the listing photos go into the brochure', (tester) async {
    final photo = img.Image(width: 120, height: 80);
    img.fill(photo, color: img.ColorRgb8(30, 60, 120));
    _repo = FakePropertiesRepository([_property],
        photos: const [PropertyPhoto(id: 1, propertyId: 12)],
        photoBytes: img.encodePng(photo));
    Injector.propertiesRepository = _repo;
    await _open(tester);
    await _tapBrochure(tester);
    final withPhoto = _share.sharedFile!.bytes.length;

    _repo.photos = const [];
    _share = FakeShareGateway();
    Injector.shareGateway = _share;
    await _open(tester);
    await _tapBrochure(tester);
    expect(withPhoto, greaterThan(_share.sharedFile!.bytes.length));
  });

  testWidgets('a share that fails says so in a snackbar', (tester) async {
    _share.outcome = ShareOutcome.failed;
    await _open(tester, locale: const Locale('en'));
    await _tapBrochure(tester);
    await tester.pump();

    expect(find.text("Couldn't put the brochure together. Try again."),
        findsOneWidget);
  });

  testWidgets('a dismissed share sheet is not an error', (tester) async {
    _share.outcome = ShareOutcome.dismissed;
    await _open(tester, locale: const Locale('kk'));
    await _tapBrochure(tester);
    await tester.pump();

    expect(_share.calls, 1);
    expect(find.byType(SnackBar), findsNothing);
  });
}
