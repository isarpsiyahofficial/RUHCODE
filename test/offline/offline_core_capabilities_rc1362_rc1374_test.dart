import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/offline/offline_core_capabilities.dart';

void main() {
  test('RC-1362..1372 requires every core capability in airplane mode', () {
    expect(OfflineCoreContract.validate, returnsNormally);
    expect(
      OfflineCoreContract.requiredInAirplaneMode,
      containsAll(OfflineCoreCapability.values),
    );
    expect(OfflineCoreContract.requiredInAirplaneMode, hasLength(10));
  });

  test('RC-1373 limits internet-only exceptions to ads store verification and explicit share', () {
    expect(
      OfflineCoreContract.permittedInternetOnly,
      equals({
        InternetOptionalCapability.advertising,
        InternetOptionalCapability.storeVerification,
        InternetOptionalCapability.explicitExternalShare,
      }),
    );
  });

  test('RC-1374 release evidence is fail-closed until all offline core flows are exercised', () {
    final complete = AirplaneModeEvidence(
      airplaneModeEnabled: true,
      releaseArtifact: true,
      exercisedCapabilities: OfflineCoreCapability.values,
      coreCompletedEndToEnd: true,
    );
    expect(complete.validateForRelease, returnsNormally);

    final incomplete = AirplaneModeEvidence(
      airplaneModeEnabled: true,
      releaseArtifact: true,
      exercisedCapabilities: OfflineCoreCapability.values
          .where((e) => e != OfflineCoreCapability.pdfExport),
      coreCompletedEndToEnd: true,
    );
    expect(incomplete.validateForRelease, throwsStateError);

    final onlineOnly = AirplaneModeEvidence(
      airplaneModeEnabled: false,
      releaseArtifact: true,
      exercisedCapabilities: OfflineCoreCapability.values,
      coreCompletedEndToEnd: true,
    );
    expect(onlineOnly.validateForRelease, throwsStateError);
  });
}
