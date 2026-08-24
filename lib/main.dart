import 'package:flutter/material.dart';

import 'src/app/app_runtime.dart';
import 'src/app/ruh_code_app.dart';
import 'src/calculation_core/time/time_zone_runtime.dart';
import 'src/ui/pdf/combined_professional_pdf_ui_actions.dart';
import 'src/ui/pdf/professional_pdf_ui_actions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TimeZoneRuntime.initialize();
  final runtime = await RuhCodeRuntime.create();
  ProfessionalPdfUiRuntimeBindings.bindRecords(
    ProfessionalPdfCatalogActions(
      catalog: runtime.professionalPdfSnapshotSource,
    ),
  );
  CombinedProfessionalPdfUiRuntimeBindings.bind(
    CombinedProfessionalPdfApplicationActions(
      service: runtime.combinedProfessionalPdf,
      catalog: runtime.professionalPdfSnapshotSource,
    ),
  );
  runApp(
    RuhCodeApp(
      featureAccess: runtime.featureAccess,
      backupActions: runtime.backupActions,
    ),
  );
}
