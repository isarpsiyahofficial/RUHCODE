import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

const String kRuhCodePdfExtension = '.pdf';
const String kRuhCodePdfMimeType = 'application/pdf';

enum PdfShareStatus { success, dismissed, unavailable }

final class PdfPlatformPolicy {
  const PdfPlatformPolicy({
    this.maxPdfBytes = 128 * 1024 * 1024,
  });

  final int maxPdfBytes;

  Uint8List validateBytes(List<int> bytes) {
    if (maxPdfBytes <= 0) {
      throw StateError('PDF platform size limit must be positive.');
    }
    if (bytes.isEmpty) {
      throw const FormatException('PDF bytes cannot be empty.');
    }
    if (bytes.length > maxPdfBytes) {
      throw FormatException(
        'PDF exceeds platform size limit: ${bytes.length} > $maxPdfBytes.',
      );
    }
    final data = Uint8List.fromList(bytes);
    if (data.length < 5 ||
        data[0] != 0x25 ||
        data[1] != 0x50 ||
        data[2] != 0x44 ||
        data[3] != 0x46 ||
        data[4] != 0x2D) {
      throw const FormatException('Native PDF output must start with %PDF-.');
    }
    return data;
  }

  String validateFileName(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('PDF file name cannot be empty.');
    }
    if (trimmed.contains('/') || trimmed.contains('\\')) {
      throw const FormatException('PDF file name must not contain a path.');
    }
    if (!trimmed.toLowerCase().endsWith(kRuhCodePdfExtension)) {
      throw const FormatException('PDF file name must end with .pdf.');
    }
    return trimmed;
  }
}

abstract interface class PdfPlatformGateway {
  Future<Uri?> savePdf({
    required String suggestedFileName,
    required List<int> bytes,
  });

  Future<PdfShareStatus> sharePdf({
    required String fileName,
    required List<int> bytes,
    String? title,
    String? text,
  });
}

/// Native user-directed PDF delivery adapter.
///
/// This layer does not render or recalculate report data. It only receives PDF
/// bytes that already passed the professional application/output inspection
/// boundary and delegates Save As / share to the operating system.
final class NativePdfPlatformGateway implements PdfPlatformGateway {
  const NativePdfPlatformGateway({
    this.policy = const PdfPlatformPolicy(),
  });

  final PdfPlatformPolicy policy;

  @override
  Future<Uri?> savePdf({
    required String suggestedFileName,
    required List<int> bytes,
  }) async {
    final safeName = policy.validateFileName(suggestedFileName);
    final data = policy.validateBytes(bytes);
    return FilePicker.saveFile(
      dialogTitle: 'Ruh Code PDF raporunu kaydet',
      fileName: safeName,
      bytes: data,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
  }

  @override
  Future<PdfShareStatus> sharePdf({
    required String fileName,
    required List<int> bytes,
    String? title,
    String? text,
  }) async {
    final safeName = policy.validateFileName(fileName);
    final data = policy.validateBytes(bytes);
    final result = await SharePlus.instance.share(
      ShareParams(
        title: title,
        text: text,
        files: <XFile>[
          XFile.fromData(data, mimeType: kRuhCodePdfMimeType),
        ],
        fileNameOverrides: <String>[safeName],
      ),
    );
    return switch (result.status) {
      ShareResultStatus.success => PdfShareStatus.success,
      ShareResultStatus.dismissed => PdfShareStatus.dismissed,
      ShareResultStatus.unavailable => PdfShareStatus.unavailable,
    };
  }
}
