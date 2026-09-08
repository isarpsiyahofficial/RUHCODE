import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_local_delivery.dart';

void main() {
  test('file name is sanitized and existing report is never silently overwritten', () {
    const policy = PdfFileNamePolicy();
    expect(policy.sanitizeBaseName('Müşteri: Rapor/2026?'), 'Müşteri_ Rapor_2026_');
    expect(
      policy.allocate(
        requestedBaseName: 'Müşteri Raporu',
        existingFileNames: const {'Müşteri Raporu.pdf', 'Müşteri Raporu (2).pdf'},
      ),
      'Müşteri Raporu (3).pdf',
    );
  });

  test('delivery targets include share, email, messaging and device files', () {
    expect(
      PdfLocalDeliveryTarget.values.toSet(),
      containsAll(<PdfLocalDeliveryTarget>{
        PdfLocalDeliveryTarget.systemShareSheet,
        PdfLocalDeliveryTarget.emailApp,
        PdfLocalDeliveryTarget.messagingApp,
        PdfLocalDeliveryTarget.deviceFiles,
      }),
    );
  });

  test('delivery policy is local-first and does not require internet or owned server', () {
    const policy = PdfLocalDeliveryPolicy();
    expect(policy.requiresInternet, isFalse);
    expect(policy.usesOwnedServer, isFalse);
    expect(policy.acceptsRemotePdfUrl, isFalse);

    final request = PdfLocalDeliveryRequest(
      fileName: 'rapor.pdf',
      pdfBytes: Uint8List.fromList(<int>[37, 80, 68, 70, 45, 49, 46, 55]),
      target: PdfLocalDeliveryTarget.systemShareSheet,
    );
    expect(() => policy.validate(request), returnsNormally);
  });

  test('empty or non-pdf local delivery is rejected', () {
    expect(
      () => PdfLocalDeliveryRequest(
        fileName: 'rapor.pdf',
        pdfBytes: Uint8List(0),
        target: PdfLocalDeliveryTarget.deviceFiles,
      ),
      throwsArgumentError,
    );
    expect(
      () => PdfLocalDeliveryRequest(
        fileName: 'rapor.txt',
        pdfBytes: Uint8List.fromList(<int>[1]),
        target: PdfLocalDeliveryTarget.deviceFiles,
      ),
      throwsArgumentError,
    );
  });
}
