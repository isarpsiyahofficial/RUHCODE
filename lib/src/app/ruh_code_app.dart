import 'package:flutter/material.dart';

import '../backup/backup_application_service.dart';
import '../entitlements/feature_access_guard.dart';
import '../ui/navigation/main_navigation_shell.dart';
import '../ui/theme/ruh_design_tokens.dart';

class RuhCodeApp extends StatelessWidget {
  const RuhCodeApp({
    super.key,
    required this.featureAccess,
    required this.backupActions,
  });

  final FeatureAccessGuard featureAccess;
  final BackupApplicationActions backupActions;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruh Code',
      theme: RuhAppTheme.light(),
      home: MainNavigationShell(
        featureAccess: featureAccess,
        backupActions: backupActions,
      ),
    );
  }
}
