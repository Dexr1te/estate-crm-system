import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_event.dart';
part 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const _key = 'locale_code';

  /// Languages the user can pick (excludes "system default").
  static const supported = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('kk'),
  ];

  LocaleBloc() : super(const LocaleState(null)) {
    on<LocaleLoadEvent>(_onLoad);
    on<LocaleChangedEvent>(_onChanged);
  }

  Future<void> _onLoad(LocaleLoadEvent e, Emitter<LocaleState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    emit(LocaleState(code == null ? null : Locale(code)));
  }

  Future<void> _onChanged(
      LocaleChangedEvent e, Emitter<LocaleState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    if (e.locale == null) {
      await prefs.remove(_key); // fall back to the device locale
    } else {
      await prefs.setString(_key, e.locale!.languageCode);
    }
    emit(LocaleState(e.locale));
  }
}
