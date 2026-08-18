import 'package:flutter_timezone/flutter_timezone.dart';

import '../../calculation_core/time/time_zone_runtime.dart';

abstract interface class DeviceTimeZoneProvider {
  Future<String> currentIanaZoneId();
}

final class FlutterDeviceTimeZoneProvider implements DeviceTimeZoneProvider {
  const FlutterDeviceTimeZoneProvider();

  @override
  Future<String> currentIanaZoneId() async {
    final info = await FlutterTimezone.getLocalTimezone();
    final zoneId = info.identifier;
    TimeZoneRuntime.location(zoneId);
    return zoneId;
  }
}
