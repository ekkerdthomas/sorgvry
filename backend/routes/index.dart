import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(body: {'name': 'sorgvry', 'version': '0.1.0'});
}
