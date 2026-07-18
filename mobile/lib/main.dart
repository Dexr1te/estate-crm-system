import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiService();
  api.init();
  await api.loadAuth();
  runApp(MyApp(api: api));
}

