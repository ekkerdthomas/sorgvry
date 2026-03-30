import 'package:cronet_http/cronet_http.dart';
import 'package:http/http.dart' as http;

/// Android — use Cronet for native DNS resolution and system proxy support.
http.Client createHttpClient() => CronetClient.defaultCronetEngine();
