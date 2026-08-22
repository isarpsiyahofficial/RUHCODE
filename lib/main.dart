import 'package:flutter/material.dart';

import 'src/app/app_runtime.dart';
import 'src/app/ruh_code_app.dart';
import 'src/calculation_core/time/time_zone_runtime.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TimeZoneRuntime.initialize();
  final runtime = await RuhCodeRuntime.create();
  runApp(
    RuhCodeApp(
      featureAccess: runtime.featureAccess,
      backupActions: runtime.backupActions,
    ),
  );
}