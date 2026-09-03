import 'bundled_earth_orientation.dart';
import 'earth_orientation.dart';

enum EarthOrientationCapabilityStatus {
  available,
  unavailableWithinProductRange,
  outsideProductRange,
}

final class EarthOrientationCapability {
  const EarthOrientationCapability({
    required this.status,
    required this.requestedUtc,
    required this.physicalCoverageStartUtc,
    required this.physicalCoverageEndUtc,
    required this.reasonCode,
    required this.userMessageKey,
  });

  final EarthOrientationCapabilityStatus status;
  final DateTime requestedUtc;
  final DateTime physicalCoverageStartUtc;
  final DateTime physicalCoverageEndUtc;
  final String reasonCode;
  final String userMessageKey;

  bool get isAvailable => status == EarthOrientationCapabilityStatus.available;
}

final class EarthOrientationUnavailableException implements Exception {
  const EarthOrientationUnavailableException(this.capability);

  final EarthOrientationCapability capability;

  @override
  String toString() =>
      'EarthOrientationUnavailableException(${capability.reasonCode}, ${capability.requestedUtc.toIso8601String()})';
}

/// Product-level date support and physical EOP coverage are intentionally
/// separate capabilities. A date may be valid for RUHCODE while UT1-dependent
/// calculations are unavailable because no published EOP sample is bundled.
/// No UTC substitution, nearest-neighbour lookup, or extrapolation is allowed.
final class EarthOrientationCapabilityPolicy {
  const EarthOrientationCapabilityPolicy(this.provider);

  static final DateTime productStartUtc = DateTime.utc(1890, 1, 1);
  static final DateTime productEndExclusiveUtc = DateTime.utc(2111, 1, 1);

  static const String availableReasonCode = 'EOP_AVAILABLE';
  static const String unavailableReasonCode = 'EOP_OUTSIDE_PUBLISHED_COVERAGE';
  static const String outsideProductRangeReasonCode = 'OUTSIDE_PRODUCT_DATE_RANGE';
  static const String unavailableMessageKey =
      'calculation.earth_orientation.unavailable_outside_published_coverage';
  static const String outsideProductRangeMessageKey =
      'calculation.date.outside_supported_product_range';

  final BundledEarthOrientationProvider provider;

  EarthOrientationCapability evaluate(DateTime utcInstant) {
    if (!utcInstant.isUtc) {
      throw ArgumentError.value(utcInstant, 'utcInstant', 'Expected UTC.');
    }

    if (utcInstant.isBefore(productStartUtc) ||
        !utcInstant.isBefore(productEndExclusiveUtc)) {
      return _capability(
        utcInstant,
        EarthOrientationCapabilityStatus.outsideProductRange,
        outsideProductRangeReasonCode,
        outsideProductRangeMessageKey,
      );
    }

    if (utcInstant.isBefore(provider.coverageStartUtc) ||
        utcInstant.isAfter(provider.coverageEndUtc)) {
      return _capability(
        utcInstant,
        EarthOrientationCapabilityStatus.unavailableWithinProductRange,
        unavailableReasonCode,
        unavailableMessageKey,
      );
    }

    return _capability(
      utcInstant,
      EarthOrientationCapabilityStatus.available,
      availableReasonCode,
      '',
    );
  }

  EarthOrientationSample sampleRequiredAt(DateTime utcInstant) {
    final capability = evaluate(utcInstant);
    if (!capability.isAvailable) {
      throw EarthOrientationUnavailableException(capability);
    }
    return provider.sampleAt(utcInstant);
  }

  EarthOrientationCapability _capability(
    DateTime requestedUtc,
    EarthOrientationCapabilityStatus status,
    String reasonCode,
    String userMessageKey,
  ) =>
      EarthOrientationCapability(
        status: status,
        requestedUtc: requestedUtc,
        physicalCoverageStartUtc: provider.coverageStartUtc,
        physicalCoverageEndUtc: provider.coverageEndUtc,
        reasonCode: reasonCode,
        userMessageKey: userMessageKey,
      );
}
