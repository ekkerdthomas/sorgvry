import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  // TODO: implement daily summary query
  return Response.json(
    body: <String, dynamic>{
      'date': null,
      'meds': <String, dynamic>{},
      'bp': <String, dynamic>{},
      'water': <String, dynamic>{},
      'walk': <String, dynamic>{},
    },
  );
}
