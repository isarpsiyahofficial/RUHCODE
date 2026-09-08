import 'dart:typed_data';

enum PdfLocalDeliveryTarget { systemShareSheet, emailApp, messagingApp, deviceFiles }

final class PdfFileNamePolicy {
  const PdfFileNamePolicy();

  String sanitizeBaseName(String raw) {
    var value = raw.trim();
    value = value.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');
    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    value = value.replaceAll(RegExp(r'[. ]+$'), '');
    if (value.isEmpty) value = 'ruh-code-report';
    if (value.length > 120) value = value.substring(0, 120).trimRight();
    return value;
  }

  String allocate({required String requestedBaseName, required Set<String> existingFileNames}) {
    final base = sanitizeBaseName(requestedBaseName);
    final normalizedExisting = existingFileNames.map((name) => name.toLowerCase()).toSet();
    var candidate = '$base.pdf';
    if (!normalizedExisting.contains(candidate.toLowerCase())) return candidate;
    var suffix = 2;
    while (normalizedExisting.contains('$base ($suffix).pdf'.toLowerCase())) {
      suffix += 1;
    }
    candidate = '$base ($suffix).pdf';
    return candidate;
  }
}

final class PdfLocalDeliveryRequest {
  PdfLocalDeliveryRequest({
    required this.fileName,
    required Uint8List pdfBytes,
    required this.target,
  }) : pdfBytes = Uint8List.fromList(pdfBytes) {
    if (!fileName.toLowerCase().endsWith('.pdf') || fileName.trim().isEmpty) {
      throw ArgumentError('Local PDF delivery requires a .pdf file name.');
    }
    if (pdfBytes.isEmpty) {
      throw ArgumentError('Local PDF delivery requires completed non-empty PDF bytes.');
    }
  }

  final String fileName;
  final Uint8List pdfBytes;
  final PdfLocalDeliveryTarget target;
}

final class PdfLocalDeliveryPolicy {
  const PdfLocalDeliveryPolicy();

  bool get requiresInternet => false;
  bool get usesOwnedServer => false;
  bool get acceptsRemotePdfUrl => false;

  void validate(PdfLocalDeliveryRequest request) {
    if (request.pdfBytes.isEmpty) {
      throw const FormatException('Incomplete PDF cannot be delivered.');
    }
    if (!request.fileName.toLowerCase().endsWith('.pdf')) {
      throw const FormatException('Only completed local PDF files can be delivered.');
    }
  }
}
