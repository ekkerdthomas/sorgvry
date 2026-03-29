import 'dart:io';
import 'dart:typed_data';

import 'package:minio/minio.dart';

class MinioService {
  MinioService()
    : _client = Minio(
        endPoint:
            Platform.environment['MINIO_ENDPOINT'] ??
            (throw StateError(
              'MINIO_ENDPOINT environment variable is required',
            )),
        accessKey:
            Platform.environment['MINIO_ACCESS_KEY'] ??
            (throw StateError(
              'MINIO_ACCESS_KEY environment variable is required',
            )),
        secretKey:
            Platform.environment['MINIO_SECRET_KEY'] ??
            (throw StateError(
              'MINIO_SECRET_KEY environment variable is required',
            )),
        useSSL: false,
      ),
      _bucket = Platform.environment['MINIO_BUCKET'] ?? 'sorgvry-media';

  final Minio _client;
  final String _bucket;
  bool _bucketReady = false;

  Future<void> _ensureBucket() async {
    if (_bucketReady) return;
    if (!await _client.bucketExists(_bucket)) {
      await _client.makeBucket(_bucket);
    }
    _bucketReady = true;
  }

  Future<String> uploadObject(
    String key,
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    await _ensureBucket();
    await _client.putObject(
      _bucket,
      key,
      Stream<Uint8List>.value(bytes),
    );
    return key;
  }

  Future<MinioByteStream> getObject(String key) {
    return _client.getObject(_bucket, key);
  }
}
