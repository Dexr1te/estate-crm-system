import 'package:latlong2/latlong.dart';

/// Where a map opens when it has no pin to show: the listing's city if it is
/// one of these, otherwise Almaty. There is no geocoder in the app; this is a
/// starting view for dropping a pin, not a position.
class CityCentres {
  const CityCentres._();

  static const almaty = LatLng(43.238949, 76.889709);
  static const _astana = LatLng(51.169392, 71.449074);
  static const _shymkent = LatLng(42.341685, 69.590101);
  static const _karaganda = LatLng(49.806406, 73.085485);
  static const _aktobe = LatLng(50.283933, 57.166978);
  static const _atyrau = LatLng(47.094495, 51.923771);
  static const _aktau = LatLng(43.635588, 51.169255);
  static const _pavlodar = LatLng(52.287303, 76.967402);
  static const _oskemen = LatLng(49.948324, 82.627848);
  static const _kostanay = LatLng(53.214917, 63.631031);
  static const _taraz = LatLng(42.901183, 71.378309);
  static const _moscow = LatLng(55.755826, 37.617300);
  static const _petersburg = LatLng(59.939095, 30.315868);
  static const _novosibirsk = LatLng(55.008353, 82.935733);
  static const _yekaterinburg = LatLng(56.838011, 60.597465);
  static const _kazan = LatLng(55.796127, 49.106405);
  static const _bishkek = LatLng(42.874621, 74.569762);
  static const _tashkent = LatLng(41.299496, 69.240073);

  static const _byName = <String, LatLng>{
    'almaty': almaty,
    'алматы': almaty,
    'алма-ата': almaty,
    'astana': _astana,
    'астана': _astana,
    'nur-sultan': _astana,
    'shymkent': _shymkent,
    'шымкент': _shymkent,
    'karaganda': _karaganda,
    'караганда': _karaganda,
    'қарағанды': _karaganda,
    'aktobe': _aktobe,
    'актобе': _aktobe,
    'ақтөбе': _aktobe,
    'atyrau': _atyrau,
    'атырау': _atyrau,
    'aktau': _aktau,
    'актау': _aktau,
    'ақтау': _aktau,
    'pavlodar': _pavlodar,
    'павлодар': _pavlodar,
    'oskemen': _oskemen,
    'ust-kamenogorsk': _oskemen,
    'усть-каменогорск': _oskemen,
    'өскемен': _oskemen,
    'kostanay': _kostanay,
    'костанай': _kostanay,
    'қостанай': _kostanay,
    'taraz': _taraz,
    'тараз': _taraz,
    'moscow': _moscow,
    'москва': _moscow,
    'saint petersburg': _petersburg,
    'st. petersburg': _petersburg,
    'санкт-петербург': _petersburg,
    'novosibirsk': _novosibirsk,
    'новосибирск': _novosibirsk,
    'yekaterinburg': _yekaterinburg,
    'екатеринбург': _yekaterinburg,
    'kazan': _kazan,
    'казань': _kazan,
    'bishkek': _bishkek,
    'бишкек': _bishkek,
    'tashkent': _tashkent,
    'ташкент': _tashkent,
  };

  /// The centre of [city] if it is known, otherwise Almaty.
  static LatLng forCity(String? city) =>
      _byName[city?.trim().toLowerCase()] ?? almaty;
}
