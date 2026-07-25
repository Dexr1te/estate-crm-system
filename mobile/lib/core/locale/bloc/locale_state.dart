part of 'locale_bloc.dart';

class LocaleState {
  /// `null` means follow the device/system locale.
  final Locale? locale;
  const LocaleState(this.locale);
}
