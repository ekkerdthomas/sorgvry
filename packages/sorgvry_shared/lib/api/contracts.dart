class MedLogRequest {
  final String deviceId;
  final String date;
  final String session;
  final bool taken;
  final String loggedAt;

  const MedLogRequest({
    required this.deviceId,
    required this.date,
    required this.session,
    required this.taken,
    required this.loggedAt,
  });

  factory MedLogRequest.fromJson(Map<String, dynamic> json) {
    return MedLogRequest(
      deviceId: json['deviceId'] as String,
      date: json['date'] as String,
      session: json['session'] as String,
      taken: json['taken'] as bool,
      loggedAt: json['loggedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'date': date,
    'session': session,
    'taken': taken,
    'loggedAt': loggedAt,
  };
}

class BpReadingRequest {
  final String deviceId;
  final String date;
  final int systolic;
  final int diastolic;
  final double map;
  final String loggedAt;

  const BpReadingRequest({
    required this.deviceId,
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.map,
    required this.loggedAt,
  });

  factory BpReadingRequest.fromJson(Map<String, dynamic> json) {
    return BpReadingRequest(
      deviceId: json['deviceId'] as String,
      date: json['date'] as String,
      systolic: json['systolic'] as int,
      diastolic: json['diastolic'] as int,
      map: (json['map'] as num).toDouble(),
      loggedAt: json['loggedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'date': date,
    'systolic': systolic,
    'diastolic': diastolic,
    'map': map,
    'loggedAt': loggedAt,
  };
}

class WaterLogRequest {
  final String deviceId;
  final String date;
  final int glasses;
  final String loggedAt;

  const WaterLogRequest({
    required this.deviceId,
    required this.date,
    required this.glasses,
    required this.loggedAt,
  });

  factory WaterLogRequest.fromJson(Map<String, dynamic> json) {
    return WaterLogRequest(
      deviceId: json['deviceId'] as String,
      date: json['date'] as String,
      glasses: json['glasses'] as int,
      loggedAt: json['loggedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'date': date,
    'glasses': glasses,
    'loggedAt': loggedAt,
  };
}

class WalkLogRequest {
  final String deviceId;
  final String date;
  final bool walked;
  final int? durationMin;
  final String loggedAt;

  const WalkLogRequest({
    required this.deviceId,
    required this.date,
    required this.walked,
    this.durationMin,
    required this.loggedAt,
  });

  factory WalkLogRequest.fromJson(Map<String, dynamic> json) {
    return WalkLogRequest(
      deviceId: json['deviceId'] as String,
      date: json['date'] as String,
      walked: json['walked'] as bool,
      durationMin: json['durationMin'] as int?,
      loggedAt: json['loggedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'date': date,
    'walked': walked,
    'durationMin': durationMin,
    'loggedAt': loggedAt,
  };
}

class RegisterRequest {
  final String deviceId;
  final String patientName;

  const RegisterRequest({required this.deviceId, required this.patientName});

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      deviceId: json['deviceId'] as String,
      patientName: (json['patientName'] as String?) ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'patientName': patientName,
  };
}

class RegisterResponse {
  final String token;
  final String deviceId;

  const RegisterResponse({required this.token, required this.deviceId});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      token: json['token'] as String,
      deviceId: json['deviceId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'token': token, 'deviceId': deviceId};
}

class MediaUploadFields {
  final String deviceId;
  final String date;
  final String module;
  final String? session;
  final String loggedAt;

  const MediaUploadFields({
    required this.deviceId,
    required this.date,
    required this.module,
    this.session,
    required this.loggedAt,
  });

  Map<String, String> toFields() => {
    'deviceId': deviceId,
    'date': date,
    'module': module,
    if (session != null) 'session': session!,
    'loggedAt': loggedAt,
  };

  factory MediaUploadFields.fromFields(Map<String, String> fields) {
    return MediaUploadFields(
      deviceId: fields['deviceId']!,
      date: fields['date']!,
      module: fields['module']!,
      session: fields['session'],
      loggedAt: fields['loggedAt']!,
    );
  }
}

class OkResponse {
  final bool ok;

  const OkResponse({required this.ok});

  factory OkResponse.fromJson(Map<String, dynamic> json) {
    return OkResponse(ok: json['ok'] as bool);
  }

  Map<String, dynamic> toJson() => {'ok': ok};
}
