import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await Injector.bootstrap();
  runApp(const MyApp());
}
