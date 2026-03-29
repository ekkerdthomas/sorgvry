import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  // TODO: implement CSV export
  return Response(
    body:
        'date,session,taken,systolic,diastolic,map,glasses,walked,duration_min\n',
    headers: {'content-type': 'text/csv'},
  );
}
