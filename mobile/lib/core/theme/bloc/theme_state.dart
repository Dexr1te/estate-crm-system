part of 'theme_bloc.dart';

class ThemeState {
  final ThemeMode mode;
  ThemeState(this.mode);
  bool get isDark => mode == ThemeMode.dark;
}
