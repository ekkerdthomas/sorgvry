// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MedLogsTable extends MedLogs with TableInfo<$MedLogsTable, MedLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionMeta = const VerificationMeta(
    'session',
  );
  @override
  late final GeneratedColumn<String> session = GeneratedColumn<String>(
    'session',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenMeta = const VerificationMeta('taken');
  @override
  late final GeneratedColumn<bool> taken = GeneratedColumn<bool>(
    'taken',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("taken" IN (0, 1))',
    ),
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    date,
    session,
    taken,
    loggedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'med_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('session')) {
      context.handle(
        _sessionMeta,
        session.isAcceptableOrUnknown(data['session']!, _sessionMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionMeta);
    }
    if (data.containsKey('taken')) {
      context.handle(
        _takenMeta,
        taken.isAcceptableOrUnknown(data['taken']!, _takenMeta),
      );
    } else if (isInserting) {
      context.missing(_takenMeta);
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {deviceId, date, session},
  ];
  @override
  MedLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      session: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session'],
      )!,
      taken: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}taken'],
      )!,
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $MedLogsTable createAlias(String alias) {
    return $MedLogsTable(attachedDatabase, alias);
  }
}

class MedLog extends DataClass implements Insertable<MedLog> {
  final int id;
  final String deviceId;
  final DateTime date;
  final String session;
  final bool taken;
  final DateTime loggedAt;
  final bool synced;
  const MedLog({
    required this.id,
    required this.deviceId,
    required this.date,
    required this.session,
    required this.taken,
    required this.loggedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['date'] = Variable<DateTime>(date);
    map['session'] = Variable<String>(session);
    map['taken'] = Variable<bool>(taken);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  MedLogsCompanion toCompanion(bool nullToAbsent) {
    return MedLogsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      date: Value(date),
      session: Value(session),
      taken: Value(taken),
      loggedAt: Value(loggedAt),
      synced: Value(synced),
    );
  }

  factory MedLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedLog(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      date: serializer.fromJson<DateTime>(json['date']),
      session: serializer.fromJson<String>(json['session']),
      taken: serializer.fromJson<bool>(json['taken']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'date': serializer.toJson<DateTime>(date),
      'session': serializer.toJson<String>(session),
      'taken': serializer.toJson<bool>(taken),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  MedLog copyWith({
    int? id,
    String? deviceId,
    DateTime? date,
    String? session,
    bool? taken,
    DateTime? loggedAt,
    bool? synced,
  }) => MedLog(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    date: date ?? this.date,
    session: session ?? this.session,
    taken: taken ?? this.taken,
    loggedAt: loggedAt ?? this.loggedAt,
    synced: synced ?? this.synced,
  );
  MedLog copyWithCompanion(MedLogsCompanion data) {
    return MedLog(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      date: data.date.present ? data.date.value : this.date,
      session: data.session.present ? data.session.value : this.session,
      taken: data.taken.present ? data.taken.value : this.taken,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedLog(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('date: $date, ')
          ..write('session: $session, ')
          ..write('taken: $taken, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deviceId, date, session, taken, loggedAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedLog &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.date == this.date &&
          other.session == this.session &&
          other.taken == this.taken &&
          other.loggedAt == this.loggedAt &&
          other.synced == this.synced);
}

class MedLogsCompanion extends UpdateCompanion<MedLog> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<DateTime> date;
  final Value<String> session;
  final Value<bool> taken;
  final Value<DateTime> loggedAt;
  final Value<bool> synced;
  const MedLogsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.date = const Value.absent(),
    this.session = const Value.absent(),
    this.taken = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  MedLogsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required DateTime date,
    required String session,
    required bool taken,
    required DateTime loggedAt,
    this.synced = const Value.absent(),
  }) : deviceId = Value(deviceId),
       date = Value(date),
       session = Value(session),
       taken = Value(taken),
       loggedAt = Value(loggedAt);
  static Insertable<MedLog> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? date,
    Expression<String>? session,
    Expression<bool>? taken,
    Expression<DateTime>? loggedAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (date != null) 'date': date,
      if (session != null) 'session': session,
      if (taken != null) 'taken': taken,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (synced != null) 'synced': synced,
    });
  }

  MedLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<DateTime>? date,
    Value<String>? session,
    Value<bool>? taken,
    Value<DateTime>? loggedAt,
    Value<bool>? synced,
  }) {
    return MedLogsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      date: date ?? this.date,
      session: session ?? this.session,
      taken: taken ?? this.taken,
      loggedAt: loggedAt ?? this.loggedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (session.present) {
      map['session'] = Variable<String>(session.value);
    }
    if (taken.present) {
      map['taken'] = Variable<bool>(taken.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedLogsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('date: $date, ')
          ..write('session: $session, ')
          ..write('taken: $taken, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $BpReadingsTable extends BpReadings
    with TableInfo<$BpReadingsTable, BpReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BpReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systolicMeta = const VerificationMeta(
    'systolic',
  );
  @override
  late final GeneratedColumn<int> systolic = GeneratedColumn<int>(
    'systolic',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diastolicMeta = const VerificationMeta(
    'diastolic',
  );
  @override
  late final GeneratedColumn<int> diastolic = GeneratedColumn<int>(
    'diastolic',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meanArterialPressureMeta =
      const VerificationMeta('meanArterialPressure');
  @override
  late final GeneratedColumn<double> meanArterialPressure =
      GeneratedColumn<double>(
        'map',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    date,
    systolic,
    diastolic,
    meanArterialPressure,
    loggedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bp_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<BpReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('systolic')) {
      context.handle(
        _systolicMeta,
        systolic.isAcceptableOrUnknown(data['systolic']!, _systolicMeta),
      );
    } else if (isInserting) {
      context.missing(_systolicMeta);
    }
    if (data.containsKey('diastolic')) {
      context.handle(
        _diastolicMeta,
        diastolic.isAcceptableOrUnknown(data['diastolic']!, _diastolicMeta),
      );
    } else if (isInserting) {
      context.missing(_diastolicMeta);
    }
    if (data.containsKey('map')) {
      context.handle(
        _meanArterialPressureMeta,
        meanArterialPressure.isAcceptableOrUnknown(
          data['map']!,
          _meanArterialPressureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_meanArterialPressureMeta);
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {deviceId, date},
  ];
  @override
  BpReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BpReading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      systolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}systolic'],
      )!,
      diastolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}diastolic'],
      )!,
      meanArterialPressure: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}map'],
      )!,
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $BpReadingsTable createAlias(String alias) {
    return $BpReadingsTable(attachedDatabase, alias);
  }
}

class BpReading extends DataClass implements Insertable<BpReading> {
  final int id;
  final String deviceId;
  final DateTime date;
  final int systolic;
  final int diastolic;
  final double meanArterialPressure;
  final DateTime loggedAt;
  final bool synced;
  const BpReading({
    required this.id,
    required this.deviceId,
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.meanArterialPressure,
    required this.loggedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['date'] = Variable<DateTime>(date);
    map['systolic'] = Variable<int>(systolic);
    map['diastolic'] = Variable<int>(diastolic);
    map['map'] = Variable<double>(meanArterialPressure);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  BpReadingsCompanion toCompanion(bool nullToAbsent) {
    return BpReadingsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      date: Value(date),
      systolic: Value(systolic),
      diastolic: Value(diastolic),
      meanArterialPressure: Value(meanArterialPressure),
      loggedAt: Value(loggedAt),
      synced: Value(synced),
    );
  }

  factory BpReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BpReading(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      date: serializer.fromJson<DateTime>(json['date']),
      systolic: serializer.fromJson<int>(json['systolic']),
      diastolic: serializer.fromJson<int>(json['diastolic']),
      meanArterialPressure: serializer.fromJson<double>(json['map']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'date': serializer.toJson<DateTime>(date),
      'systolic': serializer.toJson<int>(systolic),
      'diastolic': serializer.toJson<int>(diastolic),
      'map': serializer.toJson<double>(meanArterialPressure),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  BpReading copyWith({
    int? id,
    String? deviceId,
    DateTime? date,
    int? systolic,
    int? diastolic,
    double? meanArterialPressure,
    DateTime? loggedAt,
    bool? synced,
  }) => BpReading(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    date: date ?? this.date,
    systolic: systolic ?? this.systolic,
    diastolic: diastolic ?? this.diastolic,
    meanArterialPressure: meanArterialPressure ?? this.meanArterialPressure,
    loggedAt: loggedAt ?? this.loggedAt,
    synced: synced ?? this.synced,
  );
  BpReading copyWithCompanion(BpReadingsCompanion data) {
    return BpReading(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      date: data.date.present ? data.date.value : this.date,
      systolic: data.systolic.present ? data.systolic.value : this.systolic,
      diastolic: data.diastolic.present ? data.diastolic.value : this.diastolic,
      meanArterialPressure: data.meanArterialPressure.present
          ? data.meanArterialPressure.value
          : this.meanArterialPressure,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BpReading(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('date: $date, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('meanArterialPressure: $meanArterialPressure, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    date,
    systolic,
    diastolic,
    meanArterialPressure,
    loggedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BpReading &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.date == this.date &&
          other.systolic == this.systolic &&
          other.diastolic == this.diastolic &&
          other.meanArterialPressure == this.meanArterialPressure &&
          other.loggedAt == this.loggedAt &&
          other.synced == this.synced);
}

class BpReadingsCompanion extends UpdateCompanion<BpReading> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<DateTime> date;
  final Value<int> systolic;
  final Value<int> diastolic;
  final Value<double> meanArterialPressure;
  final Value<DateTime> loggedAt;
  final Value<bool> synced;
  const BpReadingsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.date = const Value.absent(),
    this.systolic = const Value.absent(),
    this.diastolic = const Value.absent(),
    this.meanArterialPressure = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  BpReadingsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required DateTime date,
    required int systolic,
    required int diastolic,
    required double meanArterialPressure,
    required DateTime loggedAt,
    this.synced = const Value.absent(),
  }) : deviceId = Value(deviceId),
       date = Value(date),
       systolic = Value(systolic),
       diastolic = Value(diastolic),
       meanArterialPressure = Value(meanArterialPressure),
       loggedAt = Value(loggedAt);
  static Insertable<BpReading> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? date,
    Expression<int>? systolic,
    Expression<int>? diastolic,
    Expression<double>? meanArterialPressure,
    Expression<DateTime>? loggedAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (date != null) 'date': date,
      if (systolic != null) 'systolic': systolic,
      if (diastolic != null) 'diastolic': diastolic,
      if (meanArterialPressure != null) 'map': meanArterialPressure,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (synced != null) 'synced': synced,
    });
  }

  BpReadingsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<DateTime>? date,
    Value<int>? systolic,
    Value<int>? diastolic,
    Value<double>? meanArterialPressure,
    Value<DateTime>? loggedAt,
    Value<bool>? synced,
  }) {
    return BpReadingsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      date: date ?? this.date,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      meanArterialPressure: meanArterialPressure ?? this.meanArterialPressure,
      loggedAt: loggedAt ?? this.loggedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (systolic.present) {
      map['systolic'] = Variable<int>(systolic.value);
    }
    if (diastolic.present) {
      map['diastolic'] = Variable<int>(diastolic.value);
    }
    if (meanArterialPressure.present) {
      map['map'] = Variable<double>(meanArterialPressure.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BpReadingsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('date: $date, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('meanArterialPressure: $meanArterialPressure, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $WaterLogsTable extends WaterLogs
    with TableInfo<$WaterLogsTable, WaterLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _glassesMeta = const VerificationMeta(
    'glasses',
  );
  @override
  late final GeneratedColumn<int> glasses = GeneratedColumn<int>(
    'glasses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    date,
    glasses,
    loggedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaterLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('glasses')) {
      context.handle(
        _glassesMeta,
        glasses.isAcceptableOrUnknown(data['glasses']!, _glassesMeta),
      );
    } else if (isInserting) {
      context.missing(_glassesMeta);
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {deviceId, date},
  ];
  @override
  WaterLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      glasses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}glasses'],
      )!,
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $WaterLogsTable createAlias(String alias) {
    return $WaterLogsTable(attachedDatabase, alias);
  }
}

class WaterLog extends DataClass implements Insertable<WaterLog> {
  final int id;
  final String deviceId;
  final DateTime date;
  final int glasses;
  final DateTime loggedAt;
  final bool synced;
  const WaterLog({
    required this.id,
    required this.deviceId,
    required this.date,
    required this.glasses,
    required this.loggedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['date'] = Variable<DateTime>(date);
    map['glasses'] = Variable<int>(glasses);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  WaterLogsCompanion toCompanion(bool nullToAbsent) {
    return WaterLogsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      date: Value(date),
      glasses: Value(glasses),
      loggedAt: Value(loggedAt),
      synced: Value(synced),
    );
  }

  factory WaterLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterLog(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      date: serializer.fromJson<DateTime>(json['date']),
      glasses: serializer.fromJson<int>(json['glasses']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'date': serializer.toJson<DateTime>(date),
      'glasses': serializer.toJson<int>(glasses),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  WaterLog copyWith({
    int? id,
    String? deviceId,
    DateTime? date,
    int? glasses,
    DateTime? loggedAt,
    bool? synced,
  }) => WaterLog(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    date: date ?? this.date,
    glasses: glasses ?? this.glasses,
    loggedAt: loggedAt ?? this.loggedAt,
    synced: synced ?? this.synced,
  );
  WaterLog copyWithCompanion(WaterLogsCompanion data) {
    return WaterLog(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      date: data.date.present ? data.date.value : this.date,
      glasses: data.glasses.present ? data.glasses.value : this.glasses,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterLog(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('date: $date, ')
          ..write('glasses: $glasses, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deviceId, date, glasses, loggedAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterLog &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.date == this.date &&
          other.glasses == this.glasses &&
          other.loggedAt == this.loggedAt &&
          other.synced == this.synced);
}

class WaterLogsCompanion extends UpdateCompanion<WaterLog> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<DateTime> date;
  final Value<int> glasses;
  final Value<DateTime> loggedAt;
  final Value<bool> synced;
  const WaterLogsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.date = const Value.absent(),
    this.glasses = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  WaterLogsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required DateTime date,
    required int glasses,
    required DateTime loggedAt,
    this.synced = const Value.absent(),
  }) : deviceId = Value(deviceId),
       date = Value(date),
       glasses = Value(glasses),
       loggedAt = Value(loggedAt);
  static Insertable<WaterLog> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? date,
    Expression<int>? glasses,
    Expression<DateTime>? loggedAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (date != null) 'date': date,
      if (glasses != null) 'glasses': glasses,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (synced != null) 'synced': synced,
    });
  }

  WaterLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<DateTime>? date,
    Value<int>? glasses,
    Value<DateTime>? loggedAt,
    Value<bool>? synced,
  }) {
    return WaterLogsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      date: date ?? this.date,
      glasses: glasses ?? this.glasses,
      loggedAt: loggedAt ?? this.loggedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (glasses.present) {
      map['glasses'] = Variable<int>(glasses.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterLogsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('date: $date, ')
          ..write('glasses: $glasses, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $WalkLogsTable extends WalkLogs with TableInfo<$WalkLogsTable, WalkLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalkLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walkedMeta = const VerificationMeta('walked');
  @override
  late final GeneratedColumn<bool> walked = GeneratedColumn<bool>(
    'walked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("walked" IN (0, 1))',
    ),
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    date,
    walked,
    durationMin,
    loggedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'walk_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalkLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('walked')) {
      context.handle(
        _walkedMeta,
        walked.isAcceptableOrUnknown(data['walked']!, _walkedMeta),
      );
    } else if (isInserting) {
      context.missing(_walkedMeta);
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {deviceId, date},
  ];
  @override
  WalkLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalkLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      walked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}walked'],
      )!,
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      ),
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $WalkLogsTable createAlias(String alias) {
    return $WalkLogsTable(attachedDatabase, alias);
  }
}

class WalkLog extends DataClass implements Insertable<WalkLog> {
  final int id;
  final String deviceId;
  final DateTime date;
  final bool walked;
  final int? durationMin;
  final DateTime loggedAt;
  final bool synced;
  const WalkLog({
    required this.id,
    required this.deviceId,
    required this.date,
    required this.walked,
    this.durationMin,
    required this.loggedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['date'] = Variable<DateTime>(date);
    map['walked'] = Variable<bool>(walked);
    if (!nullToAbsent || durationMin != null) {
      map['duration_min'] = Variable<int>(durationMin);
    }
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  WalkLogsCompanion toCompanion(bool nullToAbsent) {
    return WalkLogsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      date: Value(date),
      walked: Value(walked),
      durationMin: durationMin == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMin),
      loggedAt: Value(loggedAt),
      synced: Value(synced),
    );
  }

  factory WalkLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalkLog(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      date: serializer.fromJson<DateTime>(json['date']),
      walked: serializer.fromJson<bool>(json['walked']),
      durationMin: serializer.fromJson<int?>(json['durationMin']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'date': serializer.toJson<DateTime>(date),
      'walked': serializer.toJson<bool>(walked),
      'durationMin': serializer.toJson<int?>(durationMin),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  WalkLog copyWith({
    int? id,
    String? deviceId,
    DateTime? date,
    bool? walked,
    Value<int?> durationMin = const Value.absent(),
    DateTime? loggedAt,
    bool? synced,
  }) => WalkLog(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    date: date ?? this.date,
    walked: walked ?? this.walked,
    durationMin: durationMin.present ? durationMin.value : this.durationMin,
    loggedAt: loggedAt ?? this.loggedAt,
    synced: synced ?? this.synced,
  );
  WalkLog copyWithCompanion(WalkLogsCompanion data) {
    return WalkLog(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      date: data.date.present ? data.date.value : this.date,
      walked: data.walked.present ? data.walked.value : this.walked,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalkLog(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('date: $date, ')
          ..write('walked: $walked, ')
          ..write('durationMin: $durationMin, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deviceId, date, walked, durationMin, loggedAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalkLog &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.date == this.date &&
          other.walked == this.walked &&
          other.durationMin == this.durationMin &&
          other.loggedAt == this.loggedAt &&
          other.synced == this.synced);
}

class WalkLogsCompanion extends UpdateCompanion<WalkLog> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<DateTime> date;
  final Value<bool> walked;
  final Value<int?> durationMin;
  final Value<DateTime> loggedAt;
  final Value<bool> synced;
  const WalkLogsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.date = const Value.absent(),
    this.walked = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  WalkLogsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required DateTime date,
    required bool walked,
    this.durationMin = const Value.absent(),
    required DateTime loggedAt,
    this.synced = const Value.absent(),
  }) : deviceId = Value(deviceId),
       date = Value(date),
       walked = Value(walked),
       loggedAt = Value(loggedAt);
  static Insertable<WalkLog> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? date,
    Expression<bool>? walked,
    Expression<int>? durationMin,
    Expression<DateTime>? loggedAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (date != null) 'date': date,
      if (walked != null) 'walked': walked,
      if (durationMin != null) 'duration_min': durationMin,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (synced != null) 'synced': synced,
    });
  }

  WalkLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<DateTime>? date,
    Value<bool>? walked,
    Value<int?>? durationMin,
    Value<DateTime>? loggedAt,
    Value<bool>? synced,
  }) {
    return WalkLogsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      date: date ?? this.date,
      walked: walked ?? this.walked,
      durationMin: durationMin ?? this.durationMin,
      loggedAt: loggedAt ?? this.loggedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (walked.present) {
      map['walked'] = Variable<bool>(walked.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalkLogsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('date: $date, ')
          ..write('walked: $walked, ')
          ..write('durationMin: $durationMin, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $MediaAttachmentsTable extends MediaAttachments
    with TableInfo<$MediaAttachmentsTable, MediaAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moduleMeta = const VerificationMeta('module');
  @override
  late final GeneratedColumn<String> module = GeneratedColumn<String>(
    'module',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionMeta = const VerificationMeta(
    'session',
  );
  @override
  late final GeneratedColumn<String> session = GeneratedColumn<String>(
    'session',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _objectKeyMeta = const VerificationMeta(
    'objectKey',
  );
  @override
  late final GeneratedColumn<String> objectKey = GeneratedColumn<String>(
    'object_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    date,
    module,
    session,
    localPath,
    objectKey,
    loggedAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('module')) {
      context.handle(
        _moduleMeta,
        module.isAcceptableOrUnknown(data['module']!, _moduleMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleMeta);
    }
    if (data.containsKey('session')) {
      context.handle(
        _sessionMeta,
        session.isAcceptableOrUnknown(data['session']!, _sessionMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('object_key')) {
      context.handle(
        _objectKeyMeta,
        objectKey.isAcceptableOrUnknown(data['object_key']!, _objectKeyMeta),
      );
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {deviceId, date, module, session},
  ];
  @override
  MediaAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      module: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module'],
      )!,
      session: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      objectKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_key'],
      ),
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $MediaAttachmentsTable createAlias(String alias) {
    return $MediaAttachmentsTable(attachedDatabase, alias);
  }
}

class MediaAttachment extends DataClass implements Insertable<MediaAttachment> {
  final int id;
  final String deviceId;
  final DateTime date;
  final String module;
  final String session;
  final String localPath;
  final String? objectKey;
  final DateTime loggedAt;
  final bool synced;
  const MediaAttachment({
    required this.id,
    required this.deviceId,
    required this.date,
    required this.module,
    required this.session,
    required this.localPath,
    this.objectKey,
    required this.loggedAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['date'] = Variable<DateTime>(date);
    map['module'] = Variable<String>(module);
    map['session'] = Variable<String>(session);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || objectKey != null) {
      map['object_key'] = Variable<String>(objectKey);
    }
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  MediaAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return MediaAttachmentsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      date: Value(date),
      module: Value(module),
      session: Value(session),
      localPath: Value(localPath),
      objectKey: objectKey == null && nullToAbsent
          ? const Value.absent()
          : Value(objectKey),
      loggedAt: Value(loggedAt),
      synced: Value(synced),
    );
  }

  factory MediaAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaAttachment(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      date: serializer.fromJson<DateTime>(json['date']),
      module: serializer.fromJson<String>(json['module']),
      session: serializer.fromJson<String>(json['session']),
      localPath: serializer.fromJson<String>(json['localPath']),
      objectKey: serializer.fromJson<String?>(json['objectKey']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'date': serializer.toJson<DateTime>(date),
      'module': serializer.toJson<String>(module),
      'session': serializer.toJson<String>(session),
      'localPath': serializer.toJson<String>(localPath),
      'objectKey': serializer.toJson<String?>(objectKey),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  MediaAttachment copyWith({
    int? id,
    String? deviceId,
    DateTime? date,
    String? module,
    String? session,
    String? localPath,
    Value<String?> objectKey = const Value.absent(),
    DateTime? loggedAt,
    bool? synced,
  }) => MediaAttachment(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    date: date ?? this.date,
    module: module ?? this.module,
    session: session ?? this.session,
    localPath: localPath ?? this.localPath,
    objectKey: objectKey.present ? objectKey.value : this.objectKey,
    loggedAt: loggedAt ?? this.loggedAt,
    synced: synced ?? this.synced,
  );
  MediaAttachment copyWithCompanion(MediaAttachmentsCompanion data) {
    return MediaAttachment(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      date: data.date.present ? data.date.value : this.date,
      module: data.module.present ? data.module.value : this.module,
      session: data.session.present ? data.session.value : this.session,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      objectKey: data.objectKey.present ? data.objectKey.value : this.objectKey,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaAttachment(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('date: $date, ')
          ..write('module: $module, ')
          ..write('session: $session, ')
          ..write('localPath: $localPath, ')
          ..write('objectKey: $objectKey, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    date,
    module,
    session,
    localPath,
    objectKey,
    loggedAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaAttachment &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.date == this.date &&
          other.module == this.module &&
          other.session == this.session &&
          other.localPath == this.localPath &&
          other.objectKey == this.objectKey &&
          other.loggedAt == this.loggedAt &&
          other.synced == this.synced);
}

class MediaAttachmentsCompanion extends UpdateCompanion<MediaAttachment> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<DateTime> date;
  final Value<String> module;
  final Value<String> session;
  final Value<String> localPath;
  final Value<String?> objectKey;
  final Value<DateTime> loggedAt;
  final Value<bool> synced;
  const MediaAttachmentsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.date = const Value.absent(),
    this.module = const Value.absent(),
    this.session = const Value.absent(),
    this.localPath = const Value.absent(),
    this.objectKey = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  MediaAttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required DateTime date,
    required String module,
    this.session = const Value.absent(),
    required String localPath,
    this.objectKey = const Value.absent(),
    required DateTime loggedAt,
    this.synced = const Value.absent(),
  }) : deviceId = Value(deviceId),
       date = Value(date),
       module = Value(module),
       localPath = Value(localPath),
       loggedAt = Value(loggedAt);
  static Insertable<MediaAttachment> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? date,
    Expression<String>? module,
    Expression<String>? session,
    Expression<String>? localPath,
    Expression<String>? objectKey,
    Expression<DateTime>? loggedAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (date != null) 'date': date,
      if (module != null) 'module': module,
      if (session != null) 'session': session,
      if (localPath != null) 'local_path': localPath,
      if (objectKey != null) 'object_key': objectKey,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (synced != null) 'synced': synced,
    });
  }

  MediaAttachmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<DateTime>? date,
    Value<String>? module,
    Value<String>? session,
    Value<String>? localPath,
    Value<String?>? objectKey,
    Value<DateTime>? loggedAt,
    Value<bool>? synced,
  }) {
    return MediaAttachmentsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      date: date ?? this.date,
      module: module ?? this.module,
      session: session ?? this.session,
      localPath: localPath ?? this.localPath,
      objectKey: objectKey ?? this.objectKey,
      loggedAt: loggedAt ?? this.loggedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (module.present) {
      map['module'] = Variable<String>(module.value);
    }
    if (session.present) {
      map['session'] = Variable<String>(session.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (objectKey.present) {
      map['object_key'] = Variable<String>(objectKey.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('date: $date, ')
          ..write('module: $module, ')
          ..write('session: $session, ')
          ..write('localPath: $localPath, ')
          ..write('objectKey: $objectKey, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientNameMeta = const VerificationMeta(
    'patientName',
  );
  @override
  late final GeneratedColumn<String> patientName = GeneratedColumn<String>(
    'patient_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registeredAtMeta = const VerificationMeta(
    'registeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> registeredAt = GeneratedColumn<DateTime>(
    'registered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientName,
    token,
    registeredAt,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_name')) {
      context.handle(
        _patientNameMeta,
        patientName.isAcceptableOrUnknown(
          data['patient_name']!,
          _patientNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientNameMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('registered_at')) {
      context.handle(
        _registeredAtMeta,
        registeredAt.isAcceptableOrUnknown(
          data['registered_at']!,
          _registeredAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registeredAtMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_name'],
      )!,
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      )!,
      registeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}registered_at'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String id;
  final String patientName;
  final String token;
  final DateTime registeredAt;
  final bool active;
  const Device({
    required this.id,
    required this.patientName,
    required this.token,
    required this.registeredAt,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_name'] = Variable<String>(patientName);
    map['token'] = Variable<String>(token);
    map['registered_at'] = Variable<DateTime>(registeredAt);
    map['active'] = Variable<bool>(active);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      patientName: Value(patientName),
      token: Value(token),
      registeredAt: Value(registeredAt),
      active: Value(active),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<String>(json['id']),
      patientName: serializer.fromJson<String>(json['patientName']),
      token: serializer.fromJson<String>(json['token']),
      registeredAt: serializer.fromJson<DateTime>(json['registeredAt']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientName': serializer.toJson<String>(patientName),
      'token': serializer.toJson<String>(token),
      'registeredAt': serializer.toJson<DateTime>(registeredAt),
      'active': serializer.toJson<bool>(active),
    };
  }

  Device copyWith({
    String? id,
    String? patientName,
    String? token,
    DateTime? registeredAt,
    bool? active,
  }) => Device(
    id: id ?? this.id,
    patientName: patientName ?? this.patientName,
    token: token ?? this.token,
    registeredAt: registeredAt ?? this.registeredAt,
    active: active ?? this.active,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      patientName: data.patientName.present
          ? data.patientName.value
          : this.patientName,
      token: data.token.present ? data.token.value : this.token,
      registeredAt: data.registeredAt.present
          ? data.registeredAt.value
          : this.registeredAt,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('patientName: $patientName, ')
          ..write('token: $token, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, patientName, token, registeredAt, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.patientName == this.patientName &&
          other.token == this.token &&
          other.registeredAt == this.registeredAt &&
          other.active == this.active);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> id;
  final Value<String> patientName;
  final Value<String> token;
  final Value<DateTime> registeredAt;
  final Value<bool> active;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.patientName = const Value.absent(),
    this.token = const Value.absent(),
    this.registeredAt = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String patientName,
    required String token,
    required DateTime registeredAt,
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientName = Value(patientName),
       token = Value(token),
       registeredAt = Value(registeredAt);
  static Insertable<Device> custom({
    Expression<String>? id,
    Expression<String>? patientName,
    Expression<String>? token,
    Expression<DateTime>? registeredAt,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientName != null) 'patient_name': patientName,
      if (token != null) 'token': token,
      if (registeredAt != null) 'registered_at': registeredAt,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? patientName,
    Value<String>? token,
    Value<DateTime>? registeredAt,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      token: token ?? this.token,
      registeredAt: registeredAt ?? this.registeredAt,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientName.present) {
      map['patient_name'] = Variable<String>(patientName.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (registeredAt.present) {
      map['registered_at'] = Variable<DateTime>(registeredAt.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('patientName: $patientName, ')
          ..write('token: $token, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$SorgvryDatabase extends GeneratedDatabase {
  _$SorgvryDatabase(QueryExecutor e) : super(e);
  $SorgvryDatabaseManager get managers => $SorgvryDatabaseManager(this);
  late final $MedLogsTable medLogs = $MedLogsTable(this);
  late final $BpReadingsTable bpReadings = $BpReadingsTable(this);
  late final $WaterLogsTable waterLogs = $WaterLogsTable(this);
  late final $WalkLogsTable walkLogs = $WalkLogsTable(this);
  late final $MediaAttachmentsTable mediaAttachments = $MediaAttachmentsTable(
    this,
  );
  late final $DevicesTable devices = $DevicesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    medLogs,
    bpReadings,
    waterLogs,
    walkLogs,
    mediaAttachments,
    devices,
  ];
}

typedef $$MedLogsTableCreateCompanionBuilder =
    MedLogsCompanion Function({
      Value<int> id,
      required String deviceId,
      required DateTime date,
      required String session,
      required bool taken,
      required DateTime loggedAt,
      Value<bool> synced,
    });
typedef $$MedLogsTableUpdateCompanionBuilder =
    MedLogsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<DateTime> date,
      Value<String> session,
      Value<bool> taken,
      Value<DateTime> loggedAt,
      Value<bool> synced,
    });

class $$MedLogsTableFilterComposer
    extends Composer<_$SorgvryDatabase, $MedLogsTable> {
  $$MedLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get session => $composableBuilder(
    column: $table.session,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get taken => $composableBuilder(
    column: $table.taken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedLogsTableOrderingComposer
    extends Composer<_$SorgvryDatabase, $MedLogsTable> {
  $$MedLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get session => $composableBuilder(
    column: $table.session,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get taken => $composableBuilder(
    column: $table.taken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedLogsTableAnnotationComposer
    extends Composer<_$SorgvryDatabase, $MedLogsTable> {
  $$MedLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get session =>
      $composableBuilder(column: $table.session, builder: (column) => column);

  GeneratedColumn<bool> get taken =>
      $composableBuilder(column: $table.taken, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$MedLogsTableTableManager
    extends
        RootTableManager<
          _$SorgvryDatabase,
          $MedLogsTable,
          MedLog,
          $$MedLogsTableFilterComposer,
          $$MedLogsTableOrderingComposer,
          $$MedLogsTableAnnotationComposer,
          $$MedLogsTableCreateCompanionBuilder,
          $$MedLogsTableUpdateCompanionBuilder,
          (MedLog, BaseReferences<_$SorgvryDatabase, $MedLogsTable, MedLog>),
          MedLog,
          PrefetchHooks Function()
        > {
  $$MedLogsTableTableManager(_$SorgvryDatabase db, $MedLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> session = const Value.absent(),
                Value<bool> taken = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => MedLogsCompanion(
                id: id,
                deviceId: deviceId,
                date: date,
                session: session,
                taken: taken,
                loggedAt: loggedAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required DateTime date,
                required String session,
                required bool taken,
                required DateTime loggedAt,
                Value<bool> synced = const Value.absent(),
              }) => MedLogsCompanion.insert(
                id: id,
                deviceId: deviceId,
                date: date,
                session: session,
                taken: taken,
                loggedAt: loggedAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$SorgvryDatabase,
      $MedLogsTable,
      MedLog,
      $$MedLogsTableFilterComposer,
      $$MedLogsTableOrderingComposer,
      $$MedLogsTableAnnotationComposer,
      $$MedLogsTableCreateCompanionBuilder,
      $$MedLogsTableUpdateCompanionBuilder,
      (MedLog, BaseReferences<_$SorgvryDatabase, $MedLogsTable, MedLog>),
      MedLog,
      PrefetchHooks Function()
    >;
typedef $$BpReadingsTableCreateCompanionBuilder =
    BpReadingsCompanion Function({
      Value<int> id,
      required String deviceId,
      required DateTime date,
      required int systolic,
      required int diastolic,
      required double meanArterialPressure,
      required DateTime loggedAt,
      Value<bool> synced,
    });
typedef $$BpReadingsTableUpdateCompanionBuilder =
    BpReadingsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<DateTime> date,
      Value<int> systolic,
      Value<int> diastolic,
      Value<double> meanArterialPressure,
      Value<DateTime> loggedAt,
      Value<bool> synced,
    });

class $$BpReadingsTableFilterComposer
    extends Composer<_$SorgvryDatabase, $BpReadingsTable> {
  $$BpReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get meanArterialPressure => $composableBuilder(
    column: $table.meanArterialPressure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BpReadingsTableOrderingComposer
    extends Composer<_$SorgvryDatabase, $BpReadingsTable> {
  $$BpReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get meanArterialPressure => $composableBuilder(
    column: $table.meanArterialPressure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BpReadingsTableAnnotationComposer
    extends Composer<_$SorgvryDatabase, $BpReadingsTable> {
  $$BpReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get systolic =>
      $composableBuilder(column: $table.systolic, builder: (column) => column);

  GeneratedColumn<int> get diastolic =>
      $composableBuilder(column: $table.diastolic, builder: (column) => column);

  GeneratedColumn<double> get meanArterialPressure => $composableBuilder(
    column: $table.meanArterialPressure,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$BpReadingsTableTableManager
    extends
        RootTableManager<
          _$SorgvryDatabase,
          $BpReadingsTable,
          BpReading,
          $$BpReadingsTableFilterComposer,
          $$BpReadingsTableOrderingComposer,
          $$BpReadingsTableAnnotationComposer,
          $$BpReadingsTableCreateCompanionBuilder,
          $$BpReadingsTableUpdateCompanionBuilder,
          (
            BpReading,
            BaseReferences<_$SorgvryDatabase, $BpReadingsTable, BpReading>,
          ),
          BpReading,
          PrefetchHooks Function()
        > {
  $$BpReadingsTableTableManager(_$SorgvryDatabase db, $BpReadingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BpReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BpReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BpReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> systolic = const Value.absent(),
                Value<int> diastolic = const Value.absent(),
                Value<double> meanArterialPressure = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => BpReadingsCompanion(
                id: id,
                deviceId: deviceId,
                date: date,
                systolic: systolic,
                diastolic: diastolic,
                meanArterialPressure: meanArterialPressure,
                loggedAt: loggedAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required DateTime date,
                required int systolic,
                required int diastolic,
                required double meanArterialPressure,
                required DateTime loggedAt,
                Value<bool> synced = const Value.absent(),
              }) => BpReadingsCompanion.insert(
                id: id,
                deviceId: deviceId,
                date: date,
                systolic: systolic,
                diastolic: diastolic,
                meanArterialPressure: meanArterialPressure,
                loggedAt: loggedAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BpReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$SorgvryDatabase,
      $BpReadingsTable,
      BpReading,
      $$BpReadingsTableFilterComposer,
      $$BpReadingsTableOrderingComposer,
      $$BpReadingsTableAnnotationComposer,
      $$BpReadingsTableCreateCompanionBuilder,
      $$BpReadingsTableUpdateCompanionBuilder,
      (
        BpReading,
        BaseReferences<_$SorgvryDatabase, $BpReadingsTable, BpReading>,
      ),
      BpReading,
      PrefetchHooks Function()
    >;
typedef $$WaterLogsTableCreateCompanionBuilder =
    WaterLogsCompanion Function({
      Value<int> id,
      required String deviceId,
      required DateTime date,
      required int glasses,
      required DateTime loggedAt,
      Value<bool> synced,
    });
typedef $$WaterLogsTableUpdateCompanionBuilder =
    WaterLogsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<DateTime> date,
      Value<int> glasses,
      Value<DateTime> loggedAt,
      Value<bool> synced,
    });

class $$WaterLogsTableFilterComposer
    extends Composer<_$SorgvryDatabase, $WaterLogsTable> {
  $$WaterLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get glasses => $composableBuilder(
    column: $table.glasses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WaterLogsTableOrderingComposer
    extends Composer<_$SorgvryDatabase, $WaterLogsTable> {
  $$WaterLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get glasses => $composableBuilder(
    column: $table.glasses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WaterLogsTableAnnotationComposer
    extends Composer<_$SorgvryDatabase, $WaterLogsTable> {
  $$WaterLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get glasses =>
      $composableBuilder(column: $table.glasses, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$WaterLogsTableTableManager
    extends
        RootTableManager<
          _$SorgvryDatabase,
          $WaterLogsTable,
          WaterLog,
          $$WaterLogsTableFilterComposer,
          $$WaterLogsTableOrderingComposer,
          $$WaterLogsTableAnnotationComposer,
          $$WaterLogsTableCreateCompanionBuilder,
          $$WaterLogsTableUpdateCompanionBuilder,
          (
            WaterLog,
            BaseReferences<_$SorgvryDatabase, $WaterLogsTable, WaterLog>,
          ),
          WaterLog,
          PrefetchHooks Function()
        > {
  $$WaterLogsTableTableManager(_$SorgvryDatabase db, $WaterLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaterLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaterLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> glasses = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => WaterLogsCompanion(
                id: id,
                deviceId: deviceId,
                date: date,
                glasses: glasses,
                loggedAt: loggedAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required DateTime date,
                required int glasses,
                required DateTime loggedAt,
                Value<bool> synced = const Value.absent(),
              }) => WaterLogsCompanion.insert(
                id: id,
                deviceId: deviceId,
                date: date,
                glasses: glasses,
                loggedAt: loggedAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WaterLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$SorgvryDatabase,
      $WaterLogsTable,
      WaterLog,
      $$WaterLogsTableFilterComposer,
      $$WaterLogsTableOrderingComposer,
      $$WaterLogsTableAnnotationComposer,
      $$WaterLogsTableCreateCompanionBuilder,
      $$WaterLogsTableUpdateCompanionBuilder,
      (WaterLog, BaseReferences<_$SorgvryDatabase, $WaterLogsTable, WaterLog>),
      WaterLog,
      PrefetchHooks Function()
    >;
typedef $$WalkLogsTableCreateCompanionBuilder =
    WalkLogsCompanion Function({
      Value<int> id,
      required String deviceId,
      required DateTime date,
      required bool walked,
      Value<int?> durationMin,
      required DateTime loggedAt,
      Value<bool> synced,
    });
typedef $$WalkLogsTableUpdateCompanionBuilder =
    WalkLogsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<DateTime> date,
      Value<bool> walked,
      Value<int?> durationMin,
      Value<DateTime> loggedAt,
      Value<bool> synced,
    });

class $$WalkLogsTableFilterComposer
    extends Composer<_$SorgvryDatabase, $WalkLogsTable> {
  $$WalkLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get walked => $composableBuilder(
    column: $table.walked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalkLogsTableOrderingComposer
    extends Composer<_$SorgvryDatabase, $WalkLogsTable> {
  $$WalkLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get walked => $composableBuilder(
    column: $table.walked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalkLogsTableAnnotationComposer
    extends Composer<_$SorgvryDatabase, $WalkLogsTable> {
  $$WalkLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get walked =>
      $composableBuilder(column: $table.walked, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$WalkLogsTableTableManager
    extends
        RootTableManager<
          _$SorgvryDatabase,
          $WalkLogsTable,
          WalkLog,
          $$WalkLogsTableFilterComposer,
          $$WalkLogsTableOrderingComposer,
          $$WalkLogsTableAnnotationComposer,
          $$WalkLogsTableCreateCompanionBuilder,
          $$WalkLogsTableUpdateCompanionBuilder,
          (WalkLog, BaseReferences<_$SorgvryDatabase, $WalkLogsTable, WalkLog>),
          WalkLog,
          PrefetchHooks Function()
        > {
  $$WalkLogsTableTableManager(_$SorgvryDatabase db, $WalkLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalkLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalkLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalkLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<bool> walked = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => WalkLogsCompanion(
                id: id,
                deviceId: deviceId,
                date: date,
                walked: walked,
                durationMin: durationMin,
                loggedAt: loggedAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required DateTime date,
                required bool walked,
                Value<int?> durationMin = const Value.absent(),
                required DateTime loggedAt,
                Value<bool> synced = const Value.absent(),
              }) => WalkLogsCompanion.insert(
                id: id,
                deviceId: deviceId,
                date: date,
                walked: walked,
                durationMin: durationMin,
                loggedAt: loggedAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalkLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$SorgvryDatabase,
      $WalkLogsTable,
      WalkLog,
      $$WalkLogsTableFilterComposer,
      $$WalkLogsTableOrderingComposer,
      $$WalkLogsTableAnnotationComposer,
      $$WalkLogsTableCreateCompanionBuilder,
      $$WalkLogsTableUpdateCompanionBuilder,
      (WalkLog, BaseReferences<_$SorgvryDatabase, $WalkLogsTable, WalkLog>),
      WalkLog,
      PrefetchHooks Function()
    >;
typedef $$MediaAttachmentsTableCreateCompanionBuilder =
    MediaAttachmentsCompanion Function({
      Value<int> id,
      required String deviceId,
      required DateTime date,
      required String module,
      Value<String> session,
      required String localPath,
      Value<String?> objectKey,
      required DateTime loggedAt,
      Value<bool> synced,
    });
typedef $$MediaAttachmentsTableUpdateCompanionBuilder =
    MediaAttachmentsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<DateTime> date,
      Value<String> module,
      Value<String> session,
      Value<String> localPath,
      Value<String?> objectKey,
      Value<DateTime> loggedAt,
      Value<bool> synced,
    });

class $$MediaAttachmentsTableFilterComposer
    extends Composer<_$SorgvryDatabase, $MediaAttachmentsTable> {
  $$MediaAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get module => $composableBuilder(
    column: $table.module,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get session => $composableBuilder(
    column: $table.session,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objectKey => $composableBuilder(
    column: $table.objectKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaAttachmentsTableOrderingComposer
    extends Composer<_$SorgvryDatabase, $MediaAttachmentsTable> {
  $$MediaAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get module => $composableBuilder(
    column: $table.module,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get session => $composableBuilder(
    column: $table.session,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objectKey => $composableBuilder(
    column: $table.objectKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaAttachmentsTableAnnotationComposer
    extends Composer<_$SorgvryDatabase, $MediaAttachmentsTable> {
  $$MediaAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get module =>
      $composableBuilder(column: $table.module, builder: (column) => column);

  GeneratedColumn<String> get session =>
      $composableBuilder(column: $table.session, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get objectKey =>
      $composableBuilder(column: $table.objectKey, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$MediaAttachmentsTableTableManager
    extends
        RootTableManager<
          _$SorgvryDatabase,
          $MediaAttachmentsTable,
          MediaAttachment,
          $$MediaAttachmentsTableFilterComposer,
          $$MediaAttachmentsTableOrderingComposer,
          $$MediaAttachmentsTableAnnotationComposer,
          $$MediaAttachmentsTableCreateCompanionBuilder,
          $$MediaAttachmentsTableUpdateCompanionBuilder,
          (
            MediaAttachment,
            BaseReferences<
              _$SorgvryDatabase,
              $MediaAttachmentsTable,
              MediaAttachment
            >,
          ),
          MediaAttachment,
          PrefetchHooks Function()
        > {
  $$MediaAttachmentsTableTableManager(
    _$SorgvryDatabase db,
    $MediaAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaAttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> module = const Value.absent(),
                Value<String> session = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String?> objectKey = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => MediaAttachmentsCompanion(
                id: id,
                deviceId: deviceId,
                date: date,
                module: module,
                session: session,
                localPath: localPath,
                objectKey: objectKey,
                loggedAt: loggedAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required DateTime date,
                required String module,
                Value<String> session = const Value.absent(),
                required String localPath,
                Value<String?> objectKey = const Value.absent(),
                required DateTime loggedAt,
                Value<bool> synced = const Value.absent(),
              }) => MediaAttachmentsCompanion.insert(
                id: id,
                deviceId: deviceId,
                date: date,
                module: module,
                session: session,
                localPath: localPath,
                objectKey: objectKey,
                loggedAt: loggedAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$SorgvryDatabase,
      $MediaAttachmentsTable,
      MediaAttachment,
      $$MediaAttachmentsTableFilterComposer,
      $$MediaAttachmentsTableOrderingComposer,
      $$MediaAttachmentsTableAnnotationComposer,
      $$MediaAttachmentsTableCreateCompanionBuilder,
      $$MediaAttachmentsTableUpdateCompanionBuilder,
      (
        MediaAttachment,
        BaseReferences<
          _$SorgvryDatabase,
          $MediaAttachmentsTable,
          MediaAttachment
        >,
      ),
      MediaAttachment,
      PrefetchHooks Function()
    >;
typedef $$DevicesTableCreateCompanionBuilder =
    DevicesCompanion Function({
      required String id,
      required String patientName,
      required String token,
      required DateTime registeredAt,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<String> id,
      Value<String> patientName,
      Value<String> token,
      Value<DateTime> registeredAt,
      Value<bool> active,
      Value<int> rowid,
    });

class $$DevicesTableFilterComposer
    extends Composer<_$SorgvryDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientName => $composableBuilder(
    column: $table.patientName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableOrderingComposer
    extends Composer<_$SorgvryDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientName => $composableBuilder(
    column: $table.patientName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$SorgvryDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientName => $composableBuilder(
    column: $table.patientName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$SorgvryDatabase,
          $DevicesTable,
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, BaseReferences<_$SorgvryDatabase, $DevicesTable, Device>),
          Device,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableManager(_$SorgvryDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientName = const Value.absent(),
                Value<String> token = const Value.absent(),
                Value<DateTime> registeredAt = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                patientName: patientName,
                token: token,
                registeredAt: registeredAt,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientName,
                required String token,
                required DateTime registeredAt,
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                patientName: patientName,
                token: token,
                registeredAt: registeredAt,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$SorgvryDatabase,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, BaseReferences<_$SorgvryDatabase, $DevicesTable, Device>),
      Device,
      PrefetchHooks Function()
    >;

class $SorgvryDatabaseManager {
  final _$SorgvryDatabase _db;
  $SorgvryDatabaseManager(this._db);
  $$MedLogsTableTableManager get medLogs =>
      $$MedLogsTableTableManager(_db, _db.medLogs);
  $$BpReadingsTableTableManager get bpReadings =>
      $$BpReadingsTableTableManager(_db, _db.bpReadings);
  $$WaterLogsTableTableManager get waterLogs =>
      $$WaterLogsTableTableManager(_db, _db.waterLogs);
  $$WalkLogsTableTableManager get walkLogs =>
      $$WalkLogsTableTableManager(_db, _db.walkLogs);
  $$MediaAttachmentsTableTableManager get mediaAttachments =>
      $$MediaAttachmentsTableTableManager(_db, _db.mediaAttachments);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
}
