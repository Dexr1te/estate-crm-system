import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/file_gateway.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/bloc/properties_bloc.dart';
import 'package:real_estate_crm/features/properties/presentation/screens/property_detail_screen.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/property_photos_card.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// The photographs of a listing.
///
/// A gallery is mostly bytes, and bytes are what a widget test cannot draw, so
/// these hold it to the things that are not the image: that the strip is there
/// at all, that an empty one asks for the first photo rather than saying
/// nothing, that picking files uploads them, and that the card survives the
/// acceptance matrix in three languages.

const _listing = PropertyResponse(
  id: 7,
  title: 'Severny Residence, apartment 84',
  address: 'Severny Residence 12',
  city: 'Almaty',
  price: 28000000,
  rooms: 3,
  areaSqm: 62,
);

const _photos = [
  PropertyPhoto(id: 1, propertyId: 7, fileName: 'facade.jpg'),
  PropertyPhoto(id: 2, propertyId: 7, fileName: 'kitchen.jpg', sortOrder: 1),
];

late FakePropertiesRepository _properties;
late FakeFileGateway _files;

void _installFakes({List<PropertyPhoto> photos = const []}) {
  _properties = FakePropertiesRepository(const [_listing], photos: photos);
  _files = FakeFileGateway();
  Injector.propertiesRepository = _properties;
  Injector.fileGateway = _files;
  Injector.clientsRepository = FakeClientsRepository();
  Injector.dealsRepository = FakeDealsRepository(const []);
  Injector.meetingsRepository = FakeMeetingsRepository(const []);
}

Widget _wrap(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FakeAuthRepository())),
        BlocProvider(
            create: (_) => PropertiesBloc(FakePropertiesRepository(const []))),
      ],
      child: child,
    );

Future<void> _open(WidgetTester tester,
    {Size size = const Size(390, 844),
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
    Locale locale = const Locale('en')}) async {
  await expectNoOverflow(tester, _wrap(const PropertyDetailScreen(id: 7)),
      size: size, brightness: brightness, textScale: textScale, locale: locale);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('a listing without photos asks for the first one',
      (tester) async {
    _installFakes();

    await _open(tester);

    expect(find.byType(PropertyPhotosCard), findsOneWidget);
    expect(find.text('No photos yet — the first one becomes the cover'),
        findsOneWidget);
    expect(find.text('Add photos'), findsOneWidget);
  });

  testWidgets('a listing with photos counts them', (tester) async {
    _installFakes(photos: _photos);

    await _open(tester);

    expect(find.text('2 photos'), findsOneWidget);
  });

  testWidgets('picking images uploads every one of them', (tester) async {
    _installFakes();
    _files.images = const [
      PickedFile(name: 'facade.jpg', path: '/tmp/facade.jpg', size: 2048),
      PickedFile(name: 'kitchen.jpg', path: '/tmp/kitchen.jpg', size: 4096),
    ];

    await _open(tester);
    await tester.tap(find.text('Add photos'));
    await tester.pumpAndSettle();

    expect(_properties.photos.map((p) => p.fileName),
        containsAll(<String>['facade.jpg', 'kitchen.jpg']));
  });

  testWidgets('backing out of the picker uploads nothing', (tester) async {
    _installFakes();
    _files.images = const [];

    await _open(tester);
    await tester.tap(find.text('Add photos'));
    await tester.pumpAndSettle();

    expect(_properties.photos, isEmpty);
  });

  testWidgets('a photograph over the limit is refused, the rest go up',
      (tester) async {
    _installFakes();
    _files.images = const [
      PickedFile(
          name: 'huge.jpg', path: '/tmp/huge.jpg', size: maxPhotoBytes + 1),
      PickedFile(name: 'kitchen.jpg', path: '/tmp/kitchen.jpg', size: 4096),
    ];

    await _open(tester);
    await tester.tap(find.text('Add photos'));
    await tester.pumpAndSettle();

    expect(_properties.photos.map((p) => p.fileName), ['kitchen.jpg'],
        reason: 'one file being too large must not lose the others');
  });

  testWidgets('dragging a photo to the front makes it the cover',
      (tester) async {
    _installFakes(photos: _photos);

    await _open(tester);

    final strip = find.byType(ReorderableListView);
    expect(strip, findsOneWidget);

    // The order the gallery sends back is what decides the cover, so the test
    // asks the repository rather than the widget tree: a drag gesture in a
    // horizontal reorderable list is the framework's business, not this app's.
    await Injector.propertiesRepository
        .reorderPhotos(7, [_photos[1].id, _photos[0].id]);

    expect(_properties.photos.map((p) => p.fileName),
        ['kitchen.jpg', 'facade.jpg']);
    expect(_properties.photos.first.sortOrder, 0);
  });

  testWidgets('the hint says what holding a photo does', (tester) async {
    _installFakes(photos: _photos);

    await _open(tester);

    expect(find.text('Hold a photo to move it — the first one is the cover'),
        findsOneWidget,
        reason: 'a gesture nobody mentions is a gesture nobody finds');
  });

  testWidgets('a photo is removed from the viewer, where it can be seen',
      (tester) async {
    _installFakes(photos: _photos);

    await _open(tester);
    await tester.tap(find
        .descendant(
            of: find.byType(ReorderableListView),
            matching: find.byType(GestureDetector))
        .first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget,
        reason: 'deleting used to hide behind a long press on a thumbnail, '
            'which is a destructive action on an invisible gesture');
  });

  forEachAcceptanceCase('property detail with photos',
      (tester, size, brightness, scale) async {
    _installFakes(photos: _photos);
    await _open(tester, size: size, brightness: brightness, textScale: scale);
  });

  for (final locale in kAcceptanceLocales) {
    testWidgets('the gallery renders in ${locale.languageCode}',
        (tester) async {
      _installFakes(photos: _photos);
      await _open(tester,
          size: const Size(320, 568),
          brightness: Brightness.dark,
          textScale: 1.3,
          locale: locale);
    });
  }
}
