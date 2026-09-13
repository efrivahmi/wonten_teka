import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceIdentity {
  final String fingerprint;
  final String name;
  final String osVersion;

  const DeviceIdentity({
    required this.fingerprint,
    required this.name,
    required this.osVersion,
  });
}

class DeviceIdentityService {
  final DeviceInfoPlugin _deviceInfo;

  DeviceIdentityService({DeviceInfoPlugin? deviceInfo})
      : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  Future<DeviceIdentity> getIdentity() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return DeviceIdentity(
        fingerprint: info.id,
        name: '${info.brand} ${info.model}',
        osVersion: 'Android ${info.version.release}',
      );
    }
    if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      return DeviceIdentity(
        fingerprint: info.identifierForVendor ?? info.utsname.machine,
        name: info.utsname.machine,
        osVersion: '${info.systemName} ${info.systemVersion}',
      );
    }
    throw UnsupportedError('Platform perangkat tidak didukung');
  }
}
