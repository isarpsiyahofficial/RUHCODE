enum SupportedInputLocale { tr, en }

enum BirthTimePrecision { unknown, approximate, exact }

enum LocationPermissionState { notRequested, granted, denied, deniedPermanently }

final class BirthDateTimeInput {
  const BirthDateTimeInput({
    required this.date,
    required this.timePrecision,
    this.hour,
    this.minute,
  });

  final DateTime date;
  final BirthTimePrecision timePrecision;
  final int? hour;
  final int? minute;

  void validate() {
    if (timePrecision == BirthTimePrecision.unknown) {
      if (hour != null || minute != null) {
        throw StateError('Unknown birth time must not synthesize clock values.');
      }
      return;
    }
    if (hour == null || minute == null) {
      throw StateError('Approximate/exact birth time requires hour and minute.');
    }
    if (hour! < 0 || hour! > 23 || minute! < 0 || minute! > 59) {
      throw RangeError('Birth time must be a valid local clock time.');
    }
  }

  String timeLabel(SupportedInputLocale locale) {
    if (timePrecision == BirthTimePrecision.unknown) {
      return locale == SupportedInputLocale.tr ? 'Doğum saati bilinmiyor' : 'Birth time unknown';
    }
    final h = hour!.toString().padLeft(2, '0');
    final m = minute!.toString().padLeft(2, '0');
    final suffix = timePrecision == BirthTimePrecision.approximate
        ? (locale == SupportedInputLocale.tr ? ' (yaklaşık)' : ' (approx.)')
        : '';
    return '$h:$m$suffix';
  }

  String dateLabel(SupportedInputLocale locale) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return locale == SupportedInputLocale.tr ? '$day.$month.$year' : '$year-$month-$day';
  }
}

final class RecentLocationStore {
  RecentLocationStore({this.capacity = 8}) {
    if (capacity <= 0) throw ArgumentError.value(capacity, 'capacity');
  }

  final int capacity;
  final List<String> _ids = <String>[];

  List<String> get ids => List<String>.unmodifiable(_ids);

  void record(String stableCityId) {
    final value = stableCityId.trim();
    if (value.isEmpty) throw ArgumentError('City id must not be empty.');
    _ids.remove(value);
    _ids.insert(0, value);
    if (_ids.length > capacity) {
      _ids.removeRange(capacity, _ids.length);
    }
  }
}

final class LocationInputPolicy {
  const LocationInputPolicy();

  bool get gpsRequiredForBirthPlace => false;
  bool get manualCitySelectionAvailable => true;

  bool canUseManualSelection(LocationPermissionState permission) => true;

  bool shouldOfferManualFallback(LocationPermissionState permission) =>
      permission == LocationPermissionState.denied ||
      permission == LocationPermissionState.deniedPermanently;

  String permissionMessage(LocationPermissionState permission, SupportedInputLocale locale) {
    if (!shouldOfferManualFallback(permission)) return '';
    return locale == SupportedInputLocale.tr
        ? 'Konum izni olmadan devam edebilirsiniz. Şehri manuel seçin.'
        : 'You can continue without location permission. Select the city manually.';
  }
}
