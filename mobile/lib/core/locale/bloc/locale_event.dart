part of 'locale_bloc.dart';

abstract class LocaleEvent {}

class LocaleLoadEvent extends LocaleEvent {}

class LocaleChangedEvent extends LocaleEvent {
  /// `null` means follow the device/system locale.
  final Locale? locale;
  LocaleChangedEvent(this.locale);
}
