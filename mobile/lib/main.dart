import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Date symbols for every locale — without this `DateFormat` with an explicit
  // ru/kk locale throws and dates render with English month names.
  await initializeDateFormatting();
  await Injector.bootstrap();
  runApp(const MyApp());
}
