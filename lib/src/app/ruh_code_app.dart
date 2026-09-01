import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../backup/backup_application_service.dart';
import '../content/daily_messages/daily_message_catalog.dart';
import '../entitlements/feature_access_guard.dart';
import '../ui/navigation/main_navigation_shell.dart';
import '../ui/pdf/combined_pdf_builder_page.dart';
import '../ui/theme/ruh_design_tokens.dart';

class RuhCodeApp extends StatelessWidget {
  const RuhCodeApp({
    super.key,
    required this.featureAccess,
    required this.backupActions,
    required this.dailyMessages,
  });

  static const combinedPdfRoute = '/pdf/combined';

  final FeatureAccessGuard featureAccess;
  final BackupApplicationActions backupActions;
  final DailyMessageCatalog dailyMessages;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruh Code',
      theme: RuhAppTheme.light(),
      supportedLocales: const <Locale>[
        Locale('tr'),
        Locale('en'),
      ],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: <String, WidgetBuilder>{
        combinedPdfRoute: (_) => const CombinedProfessionalPdfBuilderPage(),
      },
      home: MainNavigationShell(
        featureAccess: featureAccess,
        backupActions: backupActions,
        dailyMessages: dailyMessages,
      ),
    );
  }
}
