import 'package:flutter/foundation.dart';

/// Hardcoded dev device ID. Will be replaced with UUID generation +
/// flutter_secure_storage when the auth flow is implemented.
const devDeviceId = 'dev-device-001';

/// Call at app startup in release mode to catch accidental use of dev ID.
void assertNotDevDevice(String deviceId) {
  assert(
    kDebugMode || deviceId != devDeviceId,
    'devDeviceId must not be used in release builds',
  );
}
