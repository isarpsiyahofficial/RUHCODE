import 'package:flutter/material.dart';

import 'src/app/ruh_code_app.dart';
import 'src/calculation_core/time/time_zone_runtime.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  TimeZoneRuntime.initialize();
  runApp(const RuhCodeApp());
}
