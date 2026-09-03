import 'dart:typed_data';

/// Parsed immutable descriptor for one SPK segment stored in a DAF file.
///
/// This layer intentionally stops at structural indexing. Numerical SPK type
/// evaluation and independent golden-vector accuracy are separate RC-1437
/// gates and are not implied by successfully parsing the segment directory.
final class SpkSegmentDescriptor {
  const SpkSegmentDescriptor({
    required this.startEtSeconds,
    required this.endEtSeconds,
    required this.targetId,
    required this.centerId,
    required this.frameId,
    required this.dataType,
    required this.startAddress,
    required this.endAddress,
    required this.name,
  });

  final double startEtSeconds;
  final double endEtSeconds;
  final int targetId;
  final int centerId;
  final int frameId;
  final int dataType;
  final int startAddress;
  final int endAddress;
  final String name;

  bool containsEt(double etSeconds) =>
      etSeconds.isFinite && etSeconds >= startEtSeconds && etSeconds <= endEtSeconds;
}

final class De440sDafIndex {
  const De440sDafIndex({
    required this.internalName,
    required this.binaryFormat,
    required this.nd,
    required this.ni,
    required this.firstSummaryRecord,
    required this.lastSummaryRecord,
    required this.firstFreeAddress,
    required this.segments,
  });

  static const int recordBytes = 1024;

  final String internalName;
  final String binaryFormat;
  final int nd;
  final int ni;
  final int firstSummaryRecord;
  final int lastSummaryRecord;
  final int firstFreeAddress;
  final List<SpkSegmentDescriptor> segments;

  static De440sDafIndex parse(Uint8List bytes) {
    if (bytes.length < recordBytes) {
      throw const FormatException('DAF/SPK file is shorter than its 1024-byte file record.');
    }
    final idWord = _ascii(bytes, 0, 8).trim();
    if (idWord != 'DAF/SPK') {
      throw FormatException('Expected DAF/SPK identification word, found "$idWord".');
    }

    final format = _ascii(bytes, 88, 8).replaceAll('\u0000', '').trim();
    final endian = switch (format) {
      'LTL-IEEE' => Endian.little,
      'BIG-IEEE' => Endian.big,
      _ => throw FormatException('Unsupported DAF binary format "$format".'),
    };
    final data = ByteData.sublistView(bytes);
    final nd = data.getInt32(8, endian);
    final ni = data.getInt32(12, endian);
    if (nd != 2 || ni != 6) {
      throw FormatException('SPK DAF summary format must be ND=2/NI=6, found ND=$nd/NI=$ni.');
    }
    final firstSummaryRecord = data.getInt32(76, endian);
    final lastSummaryRecord = data.getInt32(80, endian);
    final firstFreeAddress = data.getInt32(84, endian);
    final internalName = _ascii(bytes, 16, 60).replaceAll('\u0000', '').trimRight();
    final physicalRecordCount = bytes.length ~/ recordBytes;
    if (firstSummaryRecord <= 0 || firstSummaryRecord > physicalRecordCount) {
      throw FormatException('Invalid first DAF summary record: $firstSummaryRecord.');
    }
    if (lastSummaryRecord <= 0 || lastSummaryRecord > physicalRecordCount) {
      throw FormatException('Invalid last DAF summary record: $lastSummaryRecord.');
    }
    if (firstFreeAddress <= 0) {
      throw FormatException('Invalid DAF first-free address: $firstFreeAddress.');
    }

    final summaryWords = nd + ((ni + 1) ~/ 2);
    final maxSummaries = 125 ~/ summaryWords;
    final nameChars = 8 * summaryWords;
    final segments = <SpkSegmentDescriptor>[];
    final visited = <int>{};
    var recordNumber = firstSummaryRecord;
    var expectedPrevious = 0;

    while (recordNumber != 0) {
      if (!visited.add(recordNumber)) {
        throw FormatException('DAF summary-record cycle detected at record $recordNumber.');
      }
      if (recordNumber <= 0 || recordNumber > physicalRecordCount) {
        throw FormatException('DAF summary record $recordNumber is outside the physical file.');
      }
      final recordOffset = (recordNumber - 1) * recordBytes;
      final next = _controlInteger(data.getFloat64(recordOffset, endian), 'NEXT');
      final previous = _controlInteger(data.getFloat64(recordOffset + 8, endian), 'PREV');
      final summaryCount = _controlInteger(data.getFloat64(recordOffset + 16, endian), 'NSUM');
      if (previous != expectedPrevious) {
        throw FormatException(
          'DAF summary chain PREV mismatch at record $recordNumber: expected $expectedPrevious, found $previous.',
        );
      }
      if (summaryCount < 0 || summaryCount > maxSummaries) {
        throw FormatException(
          'DAF summary record $recordNumber has invalid NSUM=$summaryCount (max $maxSummaries).',
        );
      }

      final nameRecordNumber = recordNumber + 1;
      if (nameRecordNumber > physicalRecordCount) {
        throw FormatException('Missing DAF name record after summary record $recordNumber.');
      }
      final nameRecordOffset = (nameRecordNumber - 1) * recordBytes;

      for (var i = 0; i < summaryCount; i++) {
        final summaryOffset = recordOffset + 24 + (i * summaryWords * 8);
        final startEt = data.getFloat64(summaryOffset, endian);
        final endEt = data.getFloat64(summaryOffset + 8, endian);
        if (!startEt.isFinite || !endEt.isFinite || startEt > endEt) {
          throw FormatException('Invalid SPK segment ET coverage in summary ${i + 1} of record $recordNumber.');
        }
        final integerOffset = summaryOffset + (nd * 8);
        final target = data.getInt32(integerOffset, endian);
        final center = data.getInt32(integerOffset + 4, endian);
        final frame = data.getInt32(integerOffset + 8, endian);
        final type = data.getInt32(integerOffset + 12, endian);
        final startAddress = data.getInt32(integerOffset + 16, endian);
        final endAddress = data.getInt32(integerOffset + 20, endian);
        if (startAddress <= 0 || endAddress < startAddress || endAddress >= firstFreeAddress) {
          throw FormatException(
            'Invalid SPK data addresses $startAddress..$endAddress in summary ${i + 1} of record $recordNumber.',
          );
        }
        final name = _ascii(bytes, nameRecordOffset + (i * nameChars), nameChars)
            .replaceAll('\u0000', '')
            .trimRight();
        if (name.isEmpty) {
          throw FormatException('SPK segment ${i + 1} of record $recordNumber has an empty name.');
        }
        segments.add(
          SpkSegmentDescriptor(
            startEtSeconds: startEt,
            endEtSeconds: endEt,
            targetId: target,
            centerId: center,
            frameId: frame,
            dataType: type,
            startAddress: startAddress,
            endAddress: endAddress,
            name: name,
          ),
        );
      }

      expectedPrevious = recordNumber;
      recordNumber = next;
      if (recordNumber != 0 && recordNumber > physicalRecordCount) {
        throw FormatException('DAF NEXT summary record points outside the physical file: $recordNumber.');
      }
    }

    if (visited.last != lastSummaryRecord) {
      throw FormatException(
        'DAF final summary record mismatch: header=$lastSummaryRecord, traversed=${visited.last}.',
      );
    }
    if (segments.isEmpty) {
      throw const FormatException('DAF/SPK contains no segment summaries.');
    }

    return De440sDafIndex(
      internalName: internalName,
      binaryFormat: format,
      nd: nd,
      ni: ni,
      firstSummaryRecord: firstSummaryRecord,
      lastSummaryRecord: lastSummaryRecord,
      firstFreeAddress: firstFreeAddress,
      segments: List.unmodifiable(segments),
    );
  }

  static int _controlInteger(double value, String field) {
    if (!value.isFinite || value != value.roundToDouble()) {
      throw FormatException('DAF $field control value is not an exact integer: $value.');
    }
    return value.toInt();
  }

  static String _ascii(Uint8List bytes, int offset, int length) {
    if (offset < 0 || length < 0 || offset + length > bytes.length) {
      throw const FormatException('DAF string field extends beyond the physical file.');
    }
    return String.fromCharCodes(bytes.sublist(offset, offset + length));
  }
}
