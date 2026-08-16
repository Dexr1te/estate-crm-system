part of 'theme_bloc.dart';

abstract class ThemeEvent {}

class ThemeLoadEvent extends ThemeEvent {}

class ThemeToggleEvent extends ThemeEvent {}

class ThemeChangedEvent extends ThemeEvent {
  final ThemeMode mode;
  ThemeChangedEvent(this.mode);
}
