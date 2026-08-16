import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

/// Light, dark, or whatever the phone is doing.
///
/// The third option is the one this used to be missing: the profile row has
/// always been captioned "Follow system", and until now the switch underneath
/// it could only say light or dark — so a phone that turns dark at sunset took
/// the app with it only if its owner remembered to flip the switch too.
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const _key = 'theme_mode';

  /// What builds before this one wrote. Read once, to carry a choice over
  /// rather than resetting everyone to "follow system" on update.
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

  /// Kept for the places that only offer two options. Following the system
  /// counts as light for the purpose of "what does flipping this do next".
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
