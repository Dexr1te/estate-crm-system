import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const _key = 'theme_mode';

  static const _legacyKey = 'theme_dark';

  ThemeBloc() : super(const ThemeState(ThemeMode.system)) {
    on<ThemeLoadEvent>(_onLoad);
    on<ThemeChangedEvent>(_onChanged);
    on<ThemeToggleEvent>(_onToggle);
  }

  Future<void> _onLoad(ThemeLoadEvent e, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    final stored = prefs.getString(_key);
    if (stored != null) {
      emit(ThemeState(_modeFromName(stored)));
      return;
    }

    final legacy = prefs.getBool(_legacyKey);
    if (legacy == null) return;
    final mode = legacy ? ThemeMode.dark : ThemeMode.light;
    await prefs.setString(_key, mode.name);
    await prefs.remove(_legacyKey);
    emit(ThemeState(mode));
  }

  Future<void> _onChanged(ThemeChangedEvent e, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, e.mode.name);
    emit(ThemeState(e.mode));
  }

  Future<void> _onToggle(ThemeToggleEvent e, Emitter<ThemeState> emit) =>
      _onChanged(
        ThemeChangedEvent(
            state.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark),
        emit,
      );

  static ThemeMode _modeFromName(String name) => ThemeMode.values.firstWhere(
        (m) => m.name == name,
        orElse: () => ThemeMode.system,
      );
}
