part of 'locale_bloc.dart';

abstract class LocaleEvent {}

class LocaleLoadEvent extends LocaleEvent {}

class LocaleChangedEvent extends LocaleEvent {
  final Locale? locale;
  LocaleChangedEvent(this.locale);
}
