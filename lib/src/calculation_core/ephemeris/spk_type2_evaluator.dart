import 'dart:typed_data';

import 'de440s_daf_parser.dart';

/// Cartesian state from one SPK segment, in the units defined by SPK Type 2:
/// kilometres and kilometres/second.
final class SpkCartesianState {
  const SpkCartesianState({
    required this.xKm,
    required this.yKm,
    required this.zKm,
    required this.vxKmPerSecond,
    required this.vyKmPerSecond,
    required this.vzKmPerSecond,
  });

  final double xKm;
  final double yKm;
  final double zKm;
  final double vxKmPerSecond;
  final double vyKmPerSecond;
  final double vzKmPerSecond;

  SpkCartesianState operator +(SpkCartesianState other) => SpkCartesianState(
        xKm: xKm + other.xKm,
        yKm: yKm + other.yKm,
        zKm: zKm + other.zKm,
        vxKmPerSecond: vxKmPerSecond + other.vxKmPerSecond,
        vyKmPerSecond: vyKmPerSecond + other.vyKmPerSecond,
        vzKmPerSecond: vzKmPerSecond + other.vzKmPerSecond,
      );

  SpkCartesianState operator -() => SpkCartesianState(
        xKm: -xKm,
        yKm: -yKm,
        zKm: -zKm,
        vxKmPerSecond: -vxKmPerSecond,
        vyKmPerSecond: -vyKmPerSecond,
        vzKmPerSecond: -vzKmPerSecond,
      );
}

/// Evaluates NAIF SPK Type 2 segments directly from a DAF/SPK byte payload.
///
/// Type 2 stores Chebyshev position polynomials. The final four words of a
/// segment are INIT, INTLEN, RSIZE and N. Each record starts with MID/RADIUS,
/// followed by equal-sized X/Y/Z coefficient sets. Velocity is obtained by
/// differentiating the Chebyshev series with respect to normalized time and
/// dividing by RADIUS.
///
/// This class deliberately supports Type 2 only. Unsupported SPK types are
/// rejected instead of approximated or silently substituted.
final class SpkType2Evaluator {
  SpkType2Evaluator(this.bytes, this.index)
      : _data = ByteData.sublistView(bytes),
        _endian = switch (index.binaryFormat) {
          'LTL-IEEE' => Endian.little,
          'BIG-IEEE' => Endian.big,
          _ => throw FormatException('Unsupported DAF binary format ${index.binaryFormat}.'),
        };

  final Uint8List bytes;
  final De440sDafIndex index;
  final ByteData _data;
  final Endian _endian;

  /// Returns the direct target-relative-to-center state for the highest
  /// priority matching Type-2 segment (last matching segment in file order).
  SpkCartesianState evaluateDirect({
    required int targetId,
    required int centerId,
    required double etSeconds,
  }) {
    if (!etSeconds.isFinite) {
      throw ArgumentError.value(etSeconds, 'etSeconds', 'must be finite');
    }
    SpkSegmentDescriptor? selected;
    for (final segment in index.segments) {
      if (segment.targetId == targetId &&
          segment.centerId == centerId &&
          segment.containsEt(etSeconds)) {
        selected = segment;
      }
    }
    if (selected == null) {
      throw RangeError(
        'No packaged SPK segment covers target=$targetId center=$centerId at ET=$etSeconds.',
      );
    }
    return evaluateSegment(selected, etSeconds);
  }

  SpkCartesianState evaluateSegment(
    SpkSegmentDescriptor segment,
    double etSeconds,
  ) {
    if (segment.dataType != 2) {
      throw UnsupportedError('SPK data type ${segment.dataType} is not supported; Type 2 is required.');
    }
    if (!segment.containsEt(etSeconds)) {
      throw RangeError('ET=$etSeconds is outside segment coverage ${segment.startEtSeconds}..${segment.endEtSeconds}.');
    }

    final totalWords = segment.endAddress - segment.startAddress + 1;
    if (totalWords < 5) {
      throw const FormatException('SPK Type-2 segment is too short to contain directory metadata.');
    }
    final init = _word(segment.endAddress - 3);
    final intervalLength = _word(segment.endAddress - 2);
    final recordSizeRaw = _word(segment.endAddress - 1);
    final recordCountRaw = _word(segment.endAddress);
    final recordSize = _exactPositiveInteger(recordSizeRaw, 'RSIZE');
    final recordCount = _exactPositiveInteger(recordCountRaw, 'N');
    if (!init.isFinite || !intervalLength.isFinite || intervalLength <= 0) {
      throw const FormatException('Invalid SPK Type-2 INIT/INTLEN directory values.');
    }
    if (recordSize < 5 || (recordSize - 2) % 3 != 0) {
      throw FormatException('Invalid SPK Type-2 RSIZE=$recordSize.');
    }
    final expectedWords = recordSize * recordCount + 4;
    if (expectedWords != totalWords) {
      throw FormatException(
        'SPK Type-2 segment length mismatch: physical=$totalWords words, directory=$expectedWords words.',
      );
    }

    var recordIndex = ((etSeconds - init) / intervalLength).floor();
    // The exact right endpoint belongs to the final record.
    if (recordIndex == recordCount && etSeconds == segment.endEtSeconds) {
      recordIndex = recordCount - 1;
    }
    if (recordIndex < 0 || recordIndex >= recordCount) {
      throw RangeError('ET=$etSeconds does not map to a valid Type-2 record.');
    }

    final recordAddress = segment.startAddress + recordIndex * recordSize;
    final mid = _word(recordAddress);
    final radius = _word(recordAddress + 1);
    if (!mid.isFinite || !radius.isFinite || radius <= 0) {
      throw const FormatException('Invalid SPK Type-2 MID/RADIUS values.');
    }
    final tau = (etSeconds - mid) / radius;
    if (!tau.isFinite || tau < -1.000000000001 || tau > 1.000000000001) {
      throw FormatException('SPK Type-2 record mapping produced out-of-range normalized time $tau.');
    }

    final coefficientCount = (recordSize - 2) ~/ 3;
    final x = _axis(recordAddress + 2, coefficientCount, tau, radius);
    final y = _axis(recordAddress + 2 + coefficientCount, coefficientCount, tau, radius);
    final z = _axis(recordAddress + 2 + 2 * coefficientCount, coefficientCount, tau, radius);
    return SpkCartesianState(
      xKm: x.position,
      yKm: y.position,
      zKm: z.position,
      vxKmPerSecond: x.velocity,
      vyKmPerSecond: y.velocity,
      vzKmPerSecond: z.velocity,
    );
  }

  _AxisValue _axis(int firstAddress, int count, double tau, double radius) {
    final coefficients = List<double>.generate(count, (i) => _word(firstAddress + i), growable: false);
    for (final coefficient in coefficients) {
      if (!coefficient.isFinite) {
        throw const FormatException('SPK Type-2 contains a non-finite Chebyshev coefficient.');
      }
    }

    // Clenshaw evaluation for sum(c_k T_k(tau)).
    var b1 = 0.0;
    var b2 = 0.0;
    for (var k = coefficients.length - 1; k >= 1; k--) {
      final b0 = 2 * tau * b1 - b2 + coefficients[k];
      b2 = b1;
      b1 = b0;
    }
    final position = coefficients[0] + tau * b1 - b2;

    // Derivative: dT_k/dtau = k U_{k-1}(tau). Evaluate U recurrence.
    var derivativeTau = 0.0;
    if (coefficients.length > 1) {
      var uPrevious = 1.0; // U_0
      derivativeTau += coefficients[1];
      if (coefficients.length > 2) {
        var uCurrent = 2 * tau; // U_1
        derivativeTau += 2 * coefficients[2] * uCurrent;
        for (var k = 3; k < coefficients.length; k++) {
          final uNext = 2 * tau * uCurrent - uPrevious;
          derivativeTau += k * coefficients[k] * uNext;
          uPrevious = uCurrent;
          uCurrent = uNext;
        }
      }
    }
    return _AxisValue(position, derivativeTau / radius);
  }

  double _word(int oneBasedAddress) {
    if (oneBasedAddress <= 0) {
      throw FormatException('Invalid DAF word address $oneBasedAddress.');
    }
    final offset = (oneBasedAddress - 1) * 8;
    if (offset < 0 || offset + 8 > bytes.length) {
      throw FormatException('DAF word address $oneBasedAddress extends beyond the physical file.');
    }
    return _data.getFloat64(offset, _endian);
  }

  static int _exactPositiveInteger(double value, String name) {
    if (!value.isFinite || value <= 0 || value != value.roundToDouble()) {
      throw FormatException('SPK Type-2 $name must be an exact positive integer, found $value.');
    }
    return value.toInt();
  }
}

final class _AxisValue {
  const _AxisValue(this.position, this.velocity);

  final double position;
  final double velocity;
}
