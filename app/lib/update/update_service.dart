import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../config.dart';
import 'app_version_info.dart';

/// Checks the backend `/version` endpoint against the installed version.
///
/// Web-safe: uses only `http` + `package_info_plus`. Never throws — network and
/// parse failures fold into [UpdateCheckResult.error]/`.noUpdate` so the caller
/// can render silently.
class UpdateService {
  UpdateService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? backendUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<String> currentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version}+${info.buildNumber}';
    } catch (_) {
      return 'unknown';
    }
  }

  Future<UpdateCheckResult> check() async {
    final current = await currentVersion();
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/version'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        // 404 (no manifest yet) or any other status → nothing to offer.
        return UpdateCheckResult.noUpdate(current);
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final latest = AppVersionInfo.fromJson(json);

      return UpdateCheckResult(
        hasUpdate: latest.isNewerThan(current),
        isCriticalUpdate: latest.isCriticalUpdate,
        isCurrentVersionSupported: latest.isVersionSupported(current),
        latestVersion: latest,
        currentVersion: current,
      );
    } catch (e) {
      return UpdateCheckResult.error(current, '$e');
    }
  }
}
