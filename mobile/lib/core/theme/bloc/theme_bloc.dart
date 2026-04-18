import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const _key = 'theme_dark';

  ThemeBloc() : super(ThemeState(ThemeMode.light)) {
    on<ThemeLoadEvent>(_onLoad);
    on<ThemeToggleEvent>(_onToggle);
  }

  Future<void> _onLoad(ThemeLoadEvent e, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? false;
    emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> _onToggle(ThemeToggleEvent e, Emitter<ThemeState> emit) async {
    final isDark = !state.isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
    emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
  }
}
