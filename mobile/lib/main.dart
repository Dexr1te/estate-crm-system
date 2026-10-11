import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/firebase_options.dart';
import 'package:real_estate_crm/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  // Only confirming a new account's email goes through Firebase, so the rest
  // of the app still starts when it cannot be reached.
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase did not start: $e');
  }
  await Injector.bootstrap();
  runApp(const MyApp());
}
