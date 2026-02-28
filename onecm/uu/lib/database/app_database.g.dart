// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BabiesTable extends Babies with TableInfo<$BabiesTable, Baby> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BabiesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
    'date_of_birth',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bloodTypeMeta = const VerificationMeta(
    'bloodType',
  );
  @override
  late final GeneratedColumn<String> bloodType = GeneratedColumn<String>(
    'blood_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    dateOfBirth,
    gender,
    bloodType,
    photoUrl,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'babies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Baby> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateOfBirthMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('blood_type')) {
      context.handle(
        _bloodTypeMeta,
        bloodType.isAcceptableOrUnknown(data['blood_type']!, _bloodTypeMeta),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Baby map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Baby(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_of_birth'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      bloodType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blood_type'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BabiesTable createAlias(String alias) {
    return $BabiesTable(attachedDatabase, alias);
  }
}

class Baby extends DataClass implements Insertable<Baby> {
  final int id;
  final String name;
  final DateTime dateOfBirth;
  final String? gender;
  final String? bloodType;
  final String? photoUrl;
  final DateTime createdAt;
  const Baby({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.photoUrl,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || bloodType != null) {
      map['blood_type'] = Variable<String>(bloodType);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BabiesCompanion toCompanion(bool nullToAbsent) {
    return BabiesCompanion(
      id: Value(id),
      name: Value(name),
      dateOfBirth: Value(dateOfBirth),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      bloodType: bloodType == null && nullToAbsent
          ? const Value.absent()
          : Value(bloodType),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      createdAt: Value(createdAt),
    );
  }

  factory Baby.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Baby(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dateOfBirth: serializer.fromJson<DateTime>(json['dateOfBirth']),
      gender: serializer.fromJson<String?>(json['gender']),
      bloodType: serializer.fromJson<String?>(json['bloodType']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'dateOfBirth': serializer.toJson<DateTime>(dateOfBirth),
      'gender': serializer.toJson<String?>(gender),
      'bloodType': serializer.toJson<String?>(bloodType),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Baby copyWith({
    int? id,
    String? name,
    DateTime? dateOfBirth,
    Value<String?> gender = const Value.absent(),
    Value<String?> bloodType = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    DateTime? createdAt,
  }) => Baby(
    id: id ?? this.id,
    name: name ?? this.name,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    gender: gender.present ? gender.value : this.gender,
    bloodType: bloodType.present ? bloodType.value : this.bloodType,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    createdAt: createdAt ?? this.createdAt,
  );
  Baby copyWithCompanion(BabiesCompanion data) {
    return Baby(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      gender: data.gender.present ? data.gender.value : this.gender,
      bloodType: data.bloodType.present ? data.bloodType.value : this.bloodType,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Baby(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('bloodType: $bloodType, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    dateOfBirth,
    gender,
    bloodType,
    photoUrl,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Baby &&
          other.id == this.id &&
          other.name == this.name &&
          other.dateOfBirth == this.dateOfBirth &&
          other.gender == this.gender &&
          other.bloodType == this.bloodType &&
          other.photoUrl == this.photoUrl &&
          other.createdAt == this.createdAt);
}

class BabiesCompanion extends UpdateCompanion<Baby> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> dateOfBirth;
  final Value<String?> gender;
  final Value<String?> bloodType;
  final Value<String?> photoUrl;
  final Value<DateTime> createdAt;
  const BabiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.gender = const Value.absent(),
    this.bloodType = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BabiesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime dateOfBirth,
    this.gender = const Value.absent(),
    this.bloodType = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       dateOfBirth = Value(dateOfBirth);
  static Insertable<Baby> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? gender,
    Expression<String>? bloodType,
    Expression<String>? photoUrl,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (bloodType != null) 'blood_type': bloodType,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BabiesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? dateOfBirth,
    Value<String?>? gender,
    Value<String?>? bloodType,
    Value<String?>? photoUrl,
    Value<DateTime>? createdAt,
  }) {
    return BabiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (bloodType.present) {
      map['blood_type'] = Variable<String>(bloodType.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BabiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('bloodType: $bloodType, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GrowthRecordsTable extends GrowthRecords
    with TableInfo<$GrowthRecordsTable, GrowthRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrowthRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<int> babyId = GeneratedColumn<int>(
    'baby_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headCircumferenceCmMeta =
      const VerificationMeta('headCircumferenceCm');
  @override
  late final GeneratedColumn<double> headCircumferenceCm =
      GeneratedColumn<double>(
        'head_circumference_cm',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    babyId,
    date,
    weightKg,
    heightCm,
    headCircumferenceCm,
    notes,
    photoUrl,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'growth_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrowthRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('baby_id')) {
      context.handle(
        _babyIdMeta,
        babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_babyIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('head_circumference_cm')) {
      context.handle(
        _headCircumferenceCmMeta,
        headCircumferenceCm.isAcceptableOrUnknown(
          data['head_circumference_cm']!,
          _headCircumferenceCmMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrowthRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrowthRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      babyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baby_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      headCircumferenceCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}head_circumference_cm'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GrowthRecordsTable createAlias(String alias) {
    return $GrowthRecordsTable(attachedDatabase, alias);
  }
}

class GrowthRecord extends DataClass implements Insertable<GrowthRecord> {
  final int id;
  final int babyId;
  final DateTime date;
  final double? weightKg;
  final double? heightCm;
  final double? headCircumferenceCm;
  final String? notes;
  final String? photoUrl;
  final DateTime createdAt;
  const GrowthRecord({
    required this.id,
    required this.babyId,
    required this.date,
    this.weightKg,
    this.heightCm,
    this.headCircumferenceCm,
    this.notes,
    this.photoUrl,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['baby_id'] = Variable<int>(babyId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || headCircumferenceCm != null) {
      map['head_circumference_cm'] = Variable<double>(headCircumferenceCm);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GrowthRecordsCompanion toCompanion(bool nullToAbsent) {
    return GrowthRecordsCompanion(
      id: Value(id),
      babyId: Value(babyId),
      date: Value(date),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      headCircumferenceCm: headCircumferenceCm == null && nullToAbsent
          ? const Value.absent()
          : Value(headCircumferenceCm),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      createdAt: Value(createdAt),
    );
  }

  factory GrowthRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrowthRecord(
      id: serializer.fromJson<int>(json['id']),
      babyId: serializer.fromJson<int>(json['babyId']),
      date: serializer.fromJson<DateTime>(json['date']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      headCircumferenceCm: serializer.fromJson<double?>(
        json['headCircumferenceCm'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'babyId': serializer.toJson<int>(babyId),
      'date': serializer.toJson<DateTime>(date),
      'weightKg': serializer.toJson<double?>(weightKg),
      'heightCm': serializer.toJson<double?>(heightCm),
      'headCircumferenceCm': serializer.toJson<double?>(headCircumferenceCm),
      'notes': serializer.toJson<String?>(notes),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GrowthRecord copyWith({
    int? id,
    int? babyId,
    DateTime? date,
    Value<double?> weightKg = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<double?> headCircumferenceCm = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    DateTime? createdAt,
  }) => GrowthRecord(
    id: id ?? this.id,
    babyId: babyId ?? this.babyId,
    date: date ?? this.date,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    headCircumferenceCm: headCircumferenceCm.present
        ? headCircumferenceCm.value
        : this.headCircumferenceCm,
    notes: notes.present ? notes.value : this.notes,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    createdAt: createdAt ?? this.createdAt,
  );
  GrowthRecord copyWithCompanion(GrowthRecordsCompanion data) {
    return GrowthRecord(
      id: data.id.present ? data.id.value : this.id,
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      date: data.date.present ? data.date.value : this.date,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      headCircumferenceCm: data.headCircumferenceCm.present
          ? data.headCircumferenceCm.value
          : this.headCircumferenceCm,
      notes: data.notes.present ? data.notes.value : this.notes,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrowthRecord(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('headCircumferenceCm: $headCircumferenceCm, ')
          ..write('notes: $notes, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    babyId,
    date,
    weightKg,
    heightCm,
    headCircumferenceCm,
    notes,
    photoUrl,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrowthRecord &&
          other.id == this.id &&
          other.babyId == this.babyId &&
          other.date == this.date &&
          other.weightKg == this.weightKg &&
          other.heightCm == this.heightCm &&
          other.headCircumferenceCm == this.headCircumferenceCm &&
          other.notes == this.notes &&
          other.photoUrl == this.photoUrl &&
          other.createdAt == this.createdAt);
}

class GrowthRecordsCompanion extends UpdateCompanion<GrowthRecord> {
  final Value<int> id;
  final Value<int> babyId;
  final Value<DateTime> date;
  final Value<double?> weightKg;
  final Value<double?> heightCm;
  final Value<double?> headCircumferenceCm;
  final Value<String?> notes;
  final Value<String?> photoUrl;
  final Value<DateTime> createdAt;
  const GrowthRecordsCompanion({
    this.id = const Value.absent(),
    this.babyId = const Value.absent(),
    this.date = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.headCircumferenceCm = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GrowthRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int babyId,
    required DateTime date,
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.headCircumferenceCm = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : babyId = Value(babyId),
       date = Value(date);
  static Insertable<GrowthRecord> custom({
    Expression<int>? id,
    Expression<int>? babyId,
    Expression<DateTime>? date,
    Expression<double>? weightKg,
    Expression<double>? heightCm,
    Expression<double>? headCircumferenceCm,
    Expression<String>? notes,
    Expression<String>? photoUrl,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (babyId != null) 'baby_id': babyId,
      if (date != null) 'date': date,
      if (weightKg != null) 'weight_kg': weightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (headCircumferenceCm != null)
        'head_circumference_cm': headCircumferenceCm,
      if (notes != null) 'notes': notes,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GrowthRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? babyId,
    Value<DateTime>? date,
    Value<double?>? weightKg,
    Value<double?>? heightCm,
    Value<double?>? headCircumferenceCm,
    Value<String?>? notes,
    Value<String?>? photoUrl,
    Value<DateTime>? createdAt,
  }) {
    return GrowthRecordsCompanion(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      headCircumferenceCm: headCircumferenceCm ?? this.headCircumferenceCm,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (babyId.present) {
      map['baby_id'] = Variable<int>(babyId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (headCircumferenceCm.present) {
      map['head_circumference_cm'] = Variable<double>(
        headCircumferenceCm.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrowthRecordsCompanion(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('headCircumferenceCm: $headCircumferenceCm, ')
          ..write('notes: $notes, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyLogsTable extends DailyLogs
    with TableInfo<$DailyLogsTable, DailyLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<int> babyId = GeneratedColumn<int>(
    'baby_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    babyId,
    type,
    startedAt,
    endedAt,
    durationMinutes,
    metadata,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('baby_id')) {
      context.handle(
        _babyIdMeta,
        babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_babyIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      babyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baby_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DailyLogsTable createAlias(String alias) {
    return $DailyLogsTable(attachedDatabase, alias);
  }
}

class DailyLog extends DataClass implements Insertable<DailyLog> {
  final int id;
  final int babyId;
  final String type;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationMinutes;
  final String? metadata;
  final String? notes;
  final DateTime createdAt;
  const DailyLog({
    required this.id,
    required this.babyId,
    required this.type,
    required this.startedAt,
    this.endedAt,
    this.durationMinutes,
    this.metadata,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['baby_id'] = Variable<int>(babyId);
    map['type'] = Variable<String>(type);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailyLogsCompanion toCompanion(bool nullToAbsent) {
    return DailyLogsCompanion(
      id: Value(id),
      babyId: Value(babyId),
      type: Value(type),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory DailyLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyLog(
      id: serializer.fromJson<int>(json['id']),
      babyId: serializer.fromJson<int>(json['babyId']),
      type: serializer.fromJson<String>(json['type']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'babyId': serializer.toJson<int>(babyId),
      'type': serializer.toJson<String>(type),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'metadata': serializer.toJson<String?>(metadata),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyLog copyWith({
    int? id,
    int? babyId,
    String? type,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<int?> durationMinutes = const Value.absent(),
    Value<String?> metadata = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => DailyLog(
    id: id ?? this.id,
    babyId: babyId ?? this.babyId,
    type: type ?? this.type,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationMinutes: durationMinutes.present
        ? durationMinutes.value
        : this.durationMinutes,
    metadata: metadata.present ? metadata.value : this.metadata,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  DailyLog copyWithCompanion(DailyLogsCompanion data) {
    return DailyLog(
      id: data.id.present ? data.id.value : this.id,
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      type: data.type.present ? data.type.value : this.type,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyLog(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('type: $type, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('metadata: $metadata, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    babyId,
    type,
    startedAt,
    endedAt,
    durationMinutes,
    metadata,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyLog &&
          other.id == this.id &&
          other.babyId == this.babyId &&
          other.type == this.type &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationMinutes == this.durationMinutes &&
          other.metadata == this.metadata &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class DailyLogsCompanion extends UpdateCompanion<DailyLog> {
  final Value<int> id;
  final Value<int> babyId;
  final Value<String> type;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int?> durationMinutes;
  final Value<String?> metadata;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const DailyLogsCompanion({
    this.id = const Value.absent(),
    this.babyId = const Value.absent(),
    this.type = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.metadata = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DailyLogsCompanion.insert({
    this.id = const Value.absent(),
    required int babyId,
    required String type,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.metadata = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : babyId = Value(babyId),
       type = Value(type),
       startedAt = Value(startedAt);
  static Insertable<DailyLog> custom({
    Expression<int>? id,
    Expression<int>? babyId,
    Expression<String>? type,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationMinutes,
    Expression<String>? metadata,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (babyId != null) 'baby_id': babyId,
      if (type != null) 'type': type,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (metadata != null) 'metadata': metadata,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DailyLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? babyId,
    Value<String>? type,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int?>? durationMinutes,
    Value<String?>? metadata,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return DailyLogsCompanion(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      type: type ?? this.type,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      metadata: metadata ?? this.metadata,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (babyId.present) {
      map['baby_id'] = Variable<int>(babyId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyLogsCompanion(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('type: $type, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('metadata: $metadata, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NotificationSettingsTable extends NotificationSettings
    with TableInfo<$NotificationSettingsTable, NotificationSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<int> babyId = GeneratedColumn<int>(
    'baby_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _intervalMinutesMeta = const VerificationMeta(
    'intervalMinutes',
  );
  @override
  late final GeneratedColumn<int> intervalMinutes = GeneratedColumn<int>(
    'interval_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(120),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    babyId,
    type,
    enabled,
    intervalMinutes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('baby_id')) {
      context.handle(
        _babyIdMeta,
        babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_babyIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('interval_minutes')) {
      context.handle(
        _intervalMinutesMeta,
        intervalMinutes.isAcceptableOrUnknown(
          data['interval_minutes']!,
          _intervalMinutesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      babyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baby_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      intervalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_minutes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NotificationSettingsTable createAlias(String alias) {
    return $NotificationSettingsTable(attachedDatabase, alias);
  }
}

class NotificationSetting extends DataClass
    implements Insertable<NotificationSetting> {
  final int id;
  final int babyId;
  final String type;
  final bool enabled;
  final int intervalMinutes;
  final DateTime createdAt;
  const NotificationSetting({
    required this.id,
    required this.babyId,
    required this.type,
    required this.enabled,
    required this.intervalMinutes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['baby_id'] = Variable<int>(babyId);
    map['type'] = Variable<String>(type);
    map['enabled'] = Variable<bool>(enabled);
    map['interval_minutes'] = Variable<int>(intervalMinutes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotificationSettingsCompanion toCompanion(bool nullToAbsent) {
    return NotificationSettingsCompanion(
      id: Value(id),
      babyId: Value(babyId),
      type: Value(type),
      enabled: Value(enabled),
      intervalMinutes: Value(intervalMinutes),
      createdAt: Value(createdAt),
    );
  }

  factory NotificationSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationSetting(
      id: serializer.fromJson<int>(json['id']),
      babyId: serializer.fromJson<int>(json['babyId']),
      type: serializer.fromJson<String>(json['type']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      intervalMinutes: serializer.fromJson<int>(json['intervalMinutes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'babyId': serializer.toJson<int>(babyId),
      'type': serializer.toJson<String>(type),
      'enabled': serializer.toJson<bool>(enabled),
      'intervalMinutes': serializer.toJson<int>(intervalMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NotificationSetting copyWith({
    int? id,
    int? babyId,
    String? type,
    bool? enabled,
    int? intervalMinutes,
    DateTime? createdAt,
  }) => NotificationSetting(
    id: id ?? this.id,
    babyId: babyId ?? this.babyId,
    type: type ?? this.type,
    enabled: enabled ?? this.enabled,
    intervalMinutes: intervalMinutes ?? this.intervalMinutes,
    createdAt: createdAt ?? this.createdAt,
  );
  NotificationSetting copyWithCompanion(NotificationSettingsCompanion data) {
    return NotificationSetting(
      id: data.id.present ? data.id.value : this.id,
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      type: data.type.present ? data.type.value : this.type,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      intervalMinutes: data.intervalMinutes.present
          ? data.intervalMinutes.value
          : this.intervalMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSetting(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('type: $type, ')
          ..write('enabled: $enabled, ')
          ..write('intervalMinutes: $intervalMinutes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, babyId, type, enabled, intervalMinutes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationSetting &&
          other.id == this.id &&
          other.babyId == this.babyId &&
          other.type == this.type &&
          other.enabled == this.enabled &&
          other.intervalMinutes == this.intervalMinutes &&
          other.createdAt == this.createdAt);
}

class NotificationSettingsCompanion
    extends UpdateCompanion<NotificationSetting> {
  final Value<int> id;
  final Value<int> babyId;
  final Value<String> type;
  final Value<bool> enabled;
  final Value<int> intervalMinutes;
  final Value<DateTime> createdAt;
  const NotificationSettingsCompanion({
    this.id = const Value.absent(),
    this.babyId = const Value.absent(),
    this.type = const Value.absent(),
    this.enabled = const Value.absent(),
    this.intervalMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NotificationSettingsCompanion.insert({
    this.id = const Value.absent(),
    required int babyId,
    required String type,
    this.enabled = const Value.absent(),
    this.intervalMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : babyId = Value(babyId),
       type = Value(type);
  static Insertable<NotificationSetting> custom({
    Expression<int>? id,
    Expression<int>? babyId,
    Expression<String>? type,
    Expression<bool>? enabled,
    Expression<int>? intervalMinutes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (babyId != null) 'baby_id': babyId,
      if (type != null) 'type': type,
      if (enabled != null) 'enabled': enabled,
      if (intervalMinutes != null) 'interval_minutes': intervalMinutes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NotificationSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? babyId,
    Value<String>? type,
    Value<bool>? enabled,
    Value<int>? intervalMinutes,
    Value<DateTime>? createdAt,
  }) {
    return NotificationSettingsCompanion(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      type: type ?? this.type,
      enabled: enabled ?? this.enabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (babyId.present) {
      map['baby_id'] = Variable<int>(babyId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (intervalMinutes.present) {
      map['interval_minutes'] = Variable<int>(intervalMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSettingsCompanion(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('type: $type, ')
          ..write('enabled: $enabled, ')
          ..write('intervalMinutes: $intervalMinutes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MilestonesTable extends Milestones
    with TableInfo<$MilestonesTable, Milestone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilestonesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<int> babyId = GeneratedColumn<int>(
    'baby_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<DateTime> achievedAt = GeneratedColumn<DateTime>(
    'achieved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedAgeMonthsMeta = const VerificationMeta(
    'expectedAgeMonths',
  );
  @override
  late final GeneratedColumn<int> expectedAgeMonths = GeneratedColumn<int>(
    'expected_age_months',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    babyId,
    category,
    title,
    description,
    achievedAt,
    expectedAgeMonths,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milestones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Milestone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('baby_id')) {
      context.handle(
        _babyIdMeta,
        babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_babyIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    }
    if (data.containsKey('expected_age_months')) {
      context.handle(
        _expectedAgeMonthsMeta,
        expectedAgeMonths.isAcceptableOrUnknown(
          data['expected_age_months']!,
          _expectedAgeMonthsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Milestone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Milestone(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      babyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baby_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}achieved_at'],
      ),
      expectedAgeMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_age_months'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MilestonesTable createAlias(String alias) {
    return $MilestonesTable(attachedDatabase, alias);
  }
}

class Milestone extends DataClass implements Insertable<Milestone> {
  final int id;
  final int babyId;
  final String category;
  final String title;
  final String? description;
  final DateTime? achievedAt;
  final int? expectedAgeMonths;
  final DateTime createdAt;
  const Milestone({
    required this.id,
    required this.babyId,
    required this.category,
    required this.title,
    this.description,
    this.achievedAt,
    this.expectedAgeMonths,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['baby_id'] = Variable<int>(babyId);
    map['category'] = Variable<String>(category);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || achievedAt != null) {
      map['achieved_at'] = Variable<DateTime>(achievedAt);
    }
    if (!nullToAbsent || expectedAgeMonths != null) {
      map['expected_age_months'] = Variable<int>(expectedAgeMonths);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MilestonesCompanion toCompanion(bool nullToAbsent) {
    return MilestonesCompanion(
      id: Value(id),
      babyId: Value(babyId),
      category: Value(category),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      achievedAt: achievedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(achievedAt),
      expectedAgeMonths: expectedAgeMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedAgeMonths),
      createdAt: Value(createdAt),
    );
  }

  factory Milestone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Milestone(
      id: serializer.fromJson<int>(json['id']),
      babyId: serializer.fromJson<int>(json['babyId']),
      category: serializer.fromJson<String>(json['category']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      achievedAt: serializer.fromJson<DateTime?>(json['achievedAt']),
      expectedAgeMonths: serializer.fromJson<int?>(json['expectedAgeMonths']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'babyId': serializer.toJson<int>(babyId),
      'category': serializer.toJson<String>(category),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'achievedAt': serializer.toJson<DateTime?>(achievedAt),
      'expectedAgeMonths': serializer.toJson<int?>(expectedAgeMonths),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Milestone copyWith({
    int? id,
    int? babyId,
    String? category,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<DateTime?> achievedAt = const Value.absent(),
    Value<int?> expectedAgeMonths = const Value.absent(),
    DateTime? createdAt,
  }) => Milestone(
    id: id ?? this.id,
    babyId: babyId ?? this.babyId,
    category: category ?? this.category,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    achievedAt: achievedAt.present ? achievedAt.value : this.achievedAt,
    expectedAgeMonths: expectedAgeMonths.present
        ? expectedAgeMonths.value
        : this.expectedAgeMonths,
    createdAt: createdAt ?? this.createdAt,
  );
  Milestone copyWithCompanion(MilestonesCompanion data) {
    return Milestone(
      id: data.id.present ? data.id.value : this.id,
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      category: data.category.present ? data.category.value : this.category,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
      expectedAgeMonths: data.expectedAgeMonths.present
          ? data.expectedAgeMonths.value
          : this.expectedAgeMonths,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Milestone(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('expectedAgeMonths: $expectedAgeMonths, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    babyId,
    category,
    title,
    description,
    achievedAt,
    expectedAgeMonths,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Milestone &&
          other.id == this.id &&
          other.babyId == this.babyId &&
          other.category == this.category &&
          other.title == this.title &&
          other.description == this.description &&
          other.achievedAt == this.achievedAt &&
          other.expectedAgeMonths == this.expectedAgeMonths &&
          other.createdAt == this.createdAt);
}

class MilestonesCompanion extends UpdateCompanion<Milestone> {
  final Value<int> id;
  final Value<int> babyId;
  final Value<String> category;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime?> achievedAt;
  final Value<int?> expectedAgeMonths;
  final Value<DateTime> createdAt;
  const MilestonesCompanion({
    this.id = const Value.absent(),
    this.babyId = const Value.absent(),
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.expectedAgeMonths = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MilestonesCompanion.insert({
    this.id = const Value.absent(),
    required int babyId,
    required String category,
    required String title,
    this.description = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.expectedAgeMonths = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : babyId = Value(babyId),
       category = Value(category),
       title = Value(title);
  static Insertable<Milestone> custom({
    Expression<int>? id,
    Expression<int>? babyId,
    Expression<String>? category,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? achievedAt,
    Expression<int>? expectedAgeMonths,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (babyId != null) 'baby_id': babyId,
      if (category != null) 'category': category,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (expectedAgeMonths != null) 'expected_age_months': expectedAgeMonths,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MilestonesCompanion copyWith({
    Value<int>? id,
    Value<int>? babyId,
    Value<String>? category,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime?>? achievedAt,
    Value<int?>? expectedAgeMonths,
    Value<DateTime>? createdAt,
  }) {
    return MilestonesCompanion(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      achievedAt: achievedAt ?? this.achievedAt,
      expectedAgeMonths: expectedAgeMonths ?? this.expectedAgeMonths,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (babyId.present) {
      map['baby_id'] = Variable<int>(babyId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<DateTime>(achievedAt.value);
    }
    if (expectedAgeMonths.present) {
      map['expected_age_months'] = Variable<int>(expectedAgeMonths.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilestonesCompanion(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('expectedAgeMonths: $expectedAgeMonths, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VaccinationsTable extends Vaccinations
    with TableInfo<$VaccinationsTable, Vaccination> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaccinationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<int> babyId = GeneratedColumn<int>(
    'baby_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vaccineNameMeta = const VerificationMeta(
    'vaccineName',
  );
  @override
  late final GeneratedColumn<String> vaccineName = GeneratedColumn<String>(
    'vaccine_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseNumberMeta = const VerificationMeta(
    'doseNumber',
  );
  @override
  late final GeneratedColumn<int> doseNumber = GeneratedColumn<int>(
    'dose_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _administeredAtMeta = const VerificationMeta(
    'administeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> administeredAt =
      GeneratedColumn<DateTime>(
        'administered_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nextDueAtMeta = const VerificationMeta(
    'nextDueAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueAt = GeneratedColumn<DateTime>(
    'next_due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    babyId,
    vaccineName,
    doseNumber,
    administeredAt,
    nextDueAt,
    provider,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaccinations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vaccination> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('baby_id')) {
      context.handle(
        _babyIdMeta,
        babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_babyIdMeta);
    }
    if (data.containsKey('vaccine_name')) {
      context.handle(
        _vaccineNameMeta,
        vaccineName.isAcceptableOrUnknown(
          data['vaccine_name']!,
          _vaccineNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vaccineNameMeta);
    }
    if (data.containsKey('dose_number')) {
      context.handle(
        _doseNumberMeta,
        doseNumber.isAcceptableOrUnknown(data['dose_number']!, _doseNumberMeta),
      );
    }
    if (data.containsKey('administered_at')) {
      context.handle(
        _administeredAtMeta,
        administeredAt.isAcceptableOrUnknown(
          data['administered_at']!,
          _administeredAtMeta,
        ),
      );
    }
    if (data.containsKey('next_due_at')) {
      context.handle(
        _nextDueAtMeta,
        nextDueAt.isAcceptableOrUnknown(data['next_due_at']!, _nextDueAtMeta),
      );
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vaccination map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vaccination(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      babyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baby_id'],
      )!,
      vaccineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vaccine_name'],
      )!,
      doseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dose_number'],
      ),
      administeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}administered_at'],
      ),
      nextDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_at'],
      ),
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VaccinationsTable createAlias(String alias) {
    return $VaccinationsTable(attachedDatabase, alias);
  }
}

class Vaccination extends DataClass implements Insertable<Vaccination> {
  final int id;
  final int babyId;
  final String vaccineName;
  final int? doseNumber;
  final DateTime? administeredAt;
  final DateTime? nextDueAt;
  final String? provider;
  final String? notes;
  final DateTime createdAt;
  const Vaccination({
    required this.id,
    required this.babyId,
    required this.vaccineName,
    this.doseNumber,
    this.administeredAt,
    this.nextDueAt,
    this.provider,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['baby_id'] = Variable<int>(babyId);
    map['vaccine_name'] = Variable<String>(vaccineName);
    if (!nullToAbsent || doseNumber != null) {
      map['dose_number'] = Variable<int>(doseNumber);
    }
    if (!nullToAbsent || administeredAt != null) {
      map['administered_at'] = Variable<DateTime>(administeredAt);
    }
    if (!nullToAbsent || nextDueAt != null) {
      map['next_due_at'] = Variable<DateTime>(nextDueAt);
    }
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VaccinationsCompanion toCompanion(bool nullToAbsent) {
    return VaccinationsCompanion(
      id: Value(id),
      babyId: Value(babyId),
      vaccineName: Value(vaccineName),
      doseNumber: doseNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(doseNumber),
      administeredAt: administeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(administeredAt),
      nextDueAt: nextDueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueAt),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Vaccination.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vaccination(
      id: serializer.fromJson<int>(json['id']),
      babyId: serializer.fromJson<int>(json['babyId']),
      vaccineName: serializer.fromJson<String>(json['vaccineName']),
      doseNumber: serializer.fromJson<int?>(json['doseNumber']),
      administeredAt: serializer.fromJson<DateTime?>(json['administeredAt']),
      nextDueAt: serializer.fromJson<DateTime?>(json['nextDueAt']),
      provider: serializer.fromJson<String?>(json['provider']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'babyId': serializer.toJson<int>(babyId),
      'vaccineName': serializer.toJson<String>(vaccineName),
      'doseNumber': serializer.toJson<int?>(doseNumber),
      'administeredAt': serializer.toJson<DateTime?>(administeredAt),
      'nextDueAt': serializer.toJson<DateTime?>(nextDueAt),
      'provider': serializer.toJson<String?>(provider),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Vaccination copyWith({
    int? id,
    int? babyId,
    String? vaccineName,
    Value<int?> doseNumber = const Value.absent(),
    Value<DateTime?> administeredAt = const Value.absent(),
    Value<DateTime?> nextDueAt = const Value.absent(),
    Value<String?> provider = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => Vaccination(
    id: id ?? this.id,
    babyId: babyId ?? this.babyId,
    vaccineName: vaccineName ?? this.vaccineName,
    doseNumber: doseNumber.present ? doseNumber.value : this.doseNumber,
    administeredAt: administeredAt.present
        ? administeredAt.value
        : this.administeredAt,
    nextDueAt: nextDueAt.present ? nextDueAt.value : this.nextDueAt,
    provider: provider.present ? provider.value : this.provider,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Vaccination copyWithCompanion(VaccinationsCompanion data) {
    return Vaccination(
      id: data.id.present ? data.id.value : this.id,
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      vaccineName: data.vaccineName.present
          ? data.vaccineName.value
          : this.vaccineName,
      doseNumber: data.doseNumber.present
          ? data.doseNumber.value
          : this.doseNumber,
      administeredAt: data.administeredAt.present
          ? data.administeredAt.value
          : this.administeredAt,
      nextDueAt: data.nextDueAt.present ? data.nextDueAt.value : this.nextDueAt,
      provider: data.provider.present ? data.provider.value : this.provider,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vaccination(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('doseNumber: $doseNumber, ')
          ..write('administeredAt: $administeredAt, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('provider: $provider, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    babyId,
    vaccineName,
    doseNumber,
    administeredAt,
    nextDueAt,
    provider,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vaccination &&
          other.id == this.id &&
          other.babyId == this.babyId &&
          other.vaccineName == this.vaccineName &&
          other.doseNumber == this.doseNumber &&
          other.administeredAt == this.administeredAt &&
          other.nextDueAt == this.nextDueAt &&
          other.provider == this.provider &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class VaccinationsCompanion extends UpdateCompanion<Vaccination> {
  final Value<int> id;
  final Value<int> babyId;
  final Value<String> vaccineName;
  final Value<int?> doseNumber;
  final Value<DateTime?> administeredAt;
  final Value<DateTime?> nextDueAt;
  final Value<String?> provider;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const VaccinationsCompanion({
    this.id = const Value.absent(),
    this.babyId = const Value.absent(),
    this.vaccineName = const Value.absent(),
    this.doseNumber = const Value.absent(),
    this.administeredAt = const Value.absent(),
    this.nextDueAt = const Value.absent(),
    this.provider = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VaccinationsCompanion.insert({
    this.id = const Value.absent(),
    required int babyId,
    required String vaccineName,
    this.doseNumber = const Value.absent(),
    this.administeredAt = const Value.absent(),
    this.nextDueAt = const Value.absent(),
    this.provider = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : babyId = Value(babyId),
       vaccineName = Value(vaccineName);
  static Insertable<Vaccination> custom({
    Expression<int>? id,
    Expression<int>? babyId,
    Expression<String>? vaccineName,
    Expression<int>? doseNumber,
    Expression<DateTime>? administeredAt,
    Expression<DateTime>? nextDueAt,
    Expression<String>? provider,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (babyId != null) 'baby_id': babyId,
      if (vaccineName != null) 'vaccine_name': vaccineName,
      if (doseNumber != null) 'dose_number': doseNumber,
      if (administeredAt != null) 'administered_at': administeredAt,
      if (nextDueAt != null) 'next_due_at': nextDueAt,
      if (provider != null) 'provider': provider,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VaccinationsCompanion copyWith({
    Value<int>? id,
    Value<int>? babyId,
    Value<String>? vaccineName,
    Value<int?>? doseNumber,
    Value<DateTime?>? administeredAt,
    Value<DateTime?>? nextDueAt,
    Value<String?>? provider,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return VaccinationsCompanion(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      vaccineName: vaccineName ?? this.vaccineName,
      doseNumber: doseNumber ?? this.doseNumber,
      administeredAt: administeredAt ?? this.administeredAt,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      provider: provider ?? this.provider,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (babyId.present) {
      map['baby_id'] = Variable<int>(babyId.value);
    }
    if (vaccineName.present) {
      map['vaccine_name'] = Variable<String>(vaccineName.value);
    }
    if (doseNumber.present) {
      map['dose_number'] = Variable<int>(doseNumber.value);
    }
    if (administeredAt.present) {
      map['administered_at'] = Variable<DateTime>(administeredAt.value);
    }
    if (nextDueAt.present) {
      map['next_due_at'] = Variable<DateTime>(nextDueAt.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaccinationsCompanion(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('doseNumber: $doseNumber, ')
          ..write('administeredAt: $administeredAt, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('provider: $provider, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $HealthEventsTable extends HealthEvents
    with TableInfo<$HealthEventsTable, HealthEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<int> babyId = GeneratedColumn<int>(
    'baby_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    babyId,
    type,
    title,
    description,
    startedAt,
    endedAt,
    metadata,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('baby_id')) {
      context.handle(
        _babyIdMeta,
        babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_babyIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      babyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baby_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HealthEventsTable createAlias(String alias) {
    return $HealthEventsTable(attachedDatabase, alias);
  }
}

class HealthEvent extends DataClass implements Insertable<HealthEvent> {
  final int id;
  final int babyId;
  final String type;
  final String title;
  final String? description;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? metadata;
  final DateTime createdAt;
  const HealthEvent({
    required this.id,
    required this.babyId,
    required this.type,
    required this.title,
    this.description,
    this.startedAt,
    this.endedAt,
    this.metadata,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['baby_id'] = Variable<int>(babyId);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HealthEventsCompanion toCompanion(bool nullToAbsent) {
    return HealthEventsCompanion(
      id: Value(id),
      babyId: Value(babyId),
      type: Value(type),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      createdAt: Value(createdAt),
    );
  }

  factory HealthEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthEvent(
      id: serializer.fromJson<int>(json['id']),
      babyId: serializer.fromJson<int>(json['babyId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'babyId': serializer.toJson<int>(babyId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'metadata': serializer.toJson<String?>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HealthEvent copyWith({
    int? id,
    int? babyId,
    String? type,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> endedAt = const Value.absent(),
    Value<String?> metadata = const Value.absent(),
    DateTime? createdAt,
  }) => HealthEvent(
    id: id ?? this.id,
    babyId: babyId ?? this.babyId,
    type: type ?? this.type,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    metadata: metadata.present ? metadata.value : this.metadata,
    createdAt: createdAt ?? this.createdAt,
  );
  HealthEvent copyWithCompanion(HealthEventsCompanion data) {
    return HealthEvent(
      id: data.id.present ? data.id.value : this.id,
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthEvent(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    babyId,
    type,
    title,
    description,
    startedAt,
    endedAt,
    metadata,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthEvent &&
          other.id == this.id &&
          other.babyId == this.babyId &&
          other.type == this.type &&
          other.title == this.title &&
          other.description == this.description &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt);
}

class HealthEventsCompanion extends UpdateCompanion<HealthEvent> {
  final Value<int> id;
  final Value<int> babyId;
  final Value<String> type;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> metadata;
  final Value<DateTime> createdAt;
  const HealthEventsCompanion({
    this.id = const Value.absent(),
    this.babyId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HealthEventsCompanion.insert({
    this.id = const Value.absent(),
    required int babyId,
    required String type,
    required String title,
    this.description = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : babyId = Value(babyId),
       type = Value(type),
       title = Value(title);
  static Insertable<HealthEvent> custom({
    Expression<int>? id,
    Expression<int>? babyId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (babyId != null) 'baby_id': babyId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HealthEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? babyId,
    Value<String>? type,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String?>? metadata,
    Value<DateTime>? createdAt,
  }) {
    return HealthEventsCompanion(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (babyId.present) {
      map['baby_id'] = Variable<int>(babyId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthEventsCompanion(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FoodIntroductionsTable extends FoodIntroductions
    with TableInfo<$FoodIntroductionsTable, FoodIntroduction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodIntroductionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<int> babyId = GeneratedColumn<int>(
    'baby_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAllergenMeta = const VerificationMeta(
    'isAllergen',
  );
  @override
  late final GeneratedColumn<bool> isAllergen = GeneratedColumn<bool>(
    'is_allergen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_allergen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _firstTriedAtMeta = const VerificationMeta(
    'firstTriedAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstTriedAt = GeneratedColumn<DateTime>(
    'first_tried_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reactionMeta = const VerificationMeta(
    'reaction',
  );
  @override
  late final GeneratedColumn<String> reaction = GeneratedColumn<String>(
    'reaction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reactionSeverityMeta = const VerificationMeta(
    'reactionSeverity',
  );
  @override
  late final GeneratedColumn<String> reactionSeverity = GeneratedColumn<String>(
    'reaction_severity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    babyId,
    foodName,
    category,
    isAllergen,
    firstTriedAt,
    reaction,
    reactionSeverity,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_introductions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodIntroduction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('baby_id')) {
      context.handle(
        _babyIdMeta,
        babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_babyIdMeta);
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('is_allergen')) {
      context.handle(
        _isAllergenMeta,
        isAllergen.isAcceptableOrUnknown(data['is_allergen']!, _isAllergenMeta),
      );
    }
    if (data.containsKey('first_tried_at')) {
      context.handle(
        _firstTriedAtMeta,
        firstTriedAt.isAcceptableOrUnknown(
          data['first_tried_at']!,
          _firstTriedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstTriedAtMeta);
    }
    if (data.containsKey('reaction')) {
      context.handle(
        _reactionMeta,
        reaction.isAcceptableOrUnknown(data['reaction']!, _reactionMeta),
      );
    }
    if (data.containsKey('reaction_severity')) {
      context.handle(
        _reactionSeverityMeta,
        reactionSeverity.isAcceptableOrUnknown(
          data['reaction_severity']!,
          _reactionSeverityMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodIntroduction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodIntroduction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      babyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baby_id'],
      )!,
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      isAllergen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_allergen'],
      )!,
      firstTriedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_tried_at'],
      )!,
      reaction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reaction'],
      ),
      reactionSeverity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reaction_severity'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoodIntroductionsTable createAlias(String alias) {
    return $FoodIntroductionsTable(attachedDatabase, alias);
  }
}

class FoodIntroduction extends DataClass
    implements Insertable<FoodIntroduction> {
  final int id;
  final int babyId;
  final String foodName;
  final String category;
  final bool isAllergen;
  final DateTime firstTriedAt;
  final String? reaction;
  final String? reactionSeverity;
  final String? notes;
  final DateTime createdAt;
  const FoodIntroduction({
    required this.id,
    required this.babyId,
    required this.foodName,
    required this.category,
    required this.isAllergen,
    required this.firstTriedAt,
    this.reaction,
    this.reactionSeverity,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['baby_id'] = Variable<int>(babyId);
    map['food_name'] = Variable<String>(foodName);
    map['category'] = Variable<String>(category);
    map['is_allergen'] = Variable<bool>(isAllergen);
    map['first_tried_at'] = Variable<DateTime>(firstTriedAt);
    if (!nullToAbsent || reaction != null) {
      map['reaction'] = Variable<String>(reaction);
    }
    if (!nullToAbsent || reactionSeverity != null) {
      map['reaction_severity'] = Variable<String>(reactionSeverity);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FoodIntroductionsCompanion toCompanion(bool nullToAbsent) {
    return FoodIntroductionsCompanion(
      id: Value(id),
      babyId: Value(babyId),
      foodName: Value(foodName),
      category: Value(category),
      isAllergen: Value(isAllergen),
      firstTriedAt: Value(firstTriedAt),
      reaction: reaction == null && nullToAbsent
          ? const Value.absent()
          : Value(reaction),
      reactionSeverity: reactionSeverity == null && nullToAbsent
          ? const Value.absent()
          : Value(reactionSeverity),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory FoodIntroduction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodIntroduction(
      id: serializer.fromJson<int>(json['id']),
      babyId: serializer.fromJson<int>(json['babyId']),
      foodName: serializer.fromJson<String>(json['foodName']),
      category: serializer.fromJson<String>(json['category']),
      isAllergen: serializer.fromJson<bool>(json['isAllergen']),
      firstTriedAt: serializer.fromJson<DateTime>(json['firstTriedAt']),
      reaction: serializer.fromJson<String?>(json['reaction']),
      reactionSeverity: serializer.fromJson<String?>(json['reactionSeverity']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'babyId': serializer.toJson<int>(babyId),
      'foodName': serializer.toJson<String>(foodName),
      'category': serializer.toJson<String>(category),
      'isAllergen': serializer.toJson<bool>(isAllergen),
      'firstTriedAt': serializer.toJson<DateTime>(firstTriedAt),
      'reaction': serializer.toJson<String?>(reaction),
      'reactionSeverity': serializer.toJson<String?>(reactionSeverity),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FoodIntroduction copyWith({
    int? id,
    int? babyId,
    String? foodName,
    String? category,
    bool? isAllergen,
    DateTime? firstTriedAt,
    Value<String?> reaction = const Value.absent(),
    Value<String?> reactionSeverity = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => FoodIntroduction(
    id: id ?? this.id,
    babyId: babyId ?? this.babyId,
    foodName: foodName ?? this.foodName,
    category: category ?? this.category,
    isAllergen: isAllergen ?? this.isAllergen,
    firstTriedAt: firstTriedAt ?? this.firstTriedAt,
    reaction: reaction.present ? reaction.value : this.reaction,
    reactionSeverity: reactionSeverity.present
        ? reactionSeverity.value
        : this.reactionSeverity,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  FoodIntroduction copyWithCompanion(FoodIntroductionsCompanion data) {
    return FoodIntroduction(
      id: data.id.present ? data.id.value : this.id,
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      category: data.category.present ? data.category.value : this.category,
      isAllergen: data.isAllergen.present
          ? data.isAllergen.value
          : this.isAllergen,
      firstTriedAt: data.firstTriedAt.present
          ? data.firstTriedAt.value
          : this.firstTriedAt,
      reaction: data.reaction.present ? data.reaction.value : this.reaction,
      reactionSeverity: data.reactionSeverity.present
          ? data.reactionSeverity.value
          : this.reactionSeverity,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodIntroduction(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('foodName: $foodName, ')
          ..write('category: $category, ')
          ..write('isAllergen: $isAllergen, ')
          ..write('firstTriedAt: $firstTriedAt, ')
          ..write('reaction: $reaction, ')
          ..write('reactionSeverity: $reactionSeverity, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    babyId,
    foodName,
    category,
    isAllergen,
    firstTriedAt,
    reaction,
    reactionSeverity,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodIntroduction &&
          other.id == this.id &&
          other.babyId == this.babyId &&
          other.foodName == this.foodName &&
          other.category == this.category &&
          other.isAllergen == this.isAllergen &&
          other.firstTriedAt == this.firstTriedAt &&
          other.reaction == this.reaction &&
          other.reactionSeverity == this.reactionSeverity &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class FoodIntroductionsCompanion extends UpdateCompanion<FoodIntroduction> {
  final Value<int> id;
  final Value<int> babyId;
  final Value<String> foodName;
  final Value<String> category;
  final Value<bool> isAllergen;
  final Value<DateTime> firstTriedAt;
  final Value<String?> reaction;
  final Value<String?> reactionSeverity;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const FoodIntroductionsCompanion({
    this.id = const Value.absent(),
    this.babyId = const Value.absent(),
    this.foodName = const Value.absent(),
    this.category = const Value.absent(),
    this.isAllergen = const Value.absent(),
    this.firstTriedAt = const Value.absent(),
    this.reaction = const Value.absent(),
    this.reactionSeverity = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FoodIntroductionsCompanion.insert({
    this.id = const Value.absent(),
    required int babyId,
    required String foodName,
    required String category,
    this.isAllergen = const Value.absent(),
    required DateTime firstTriedAt,
    this.reaction = const Value.absent(),
    this.reactionSeverity = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : babyId = Value(babyId),
       foodName = Value(foodName),
       category = Value(category),
       firstTriedAt = Value(firstTriedAt);
  static Insertable<FoodIntroduction> custom({
    Expression<int>? id,
    Expression<int>? babyId,
    Expression<String>? foodName,
    Expression<String>? category,
    Expression<bool>? isAllergen,
    Expression<DateTime>? firstTriedAt,
    Expression<String>? reaction,
    Expression<String>? reactionSeverity,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (babyId != null) 'baby_id': babyId,
      if (foodName != null) 'food_name': foodName,
      if (category != null) 'category': category,
      if (isAllergen != null) 'is_allergen': isAllergen,
      if (firstTriedAt != null) 'first_tried_at': firstTriedAt,
      if (reaction != null) 'reaction': reaction,
      if (reactionSeverity != null) 'reaction_severity': reactionSeverity,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FoodIntroductionsCompanion copyWith({
    Value<int>? id,
    Value<int>? babyId,
    Value<String>? foodName,
    Value<String>? category,
    Value<bool>? isAllergen,
    Value<DateTime>? firstTriedAt,
    Value<String?>? reaction,
    Value<String?>? reactionSeverity,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return FoodIntroductionsCompanion(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      foodName: foodName ?? this.foodName,
      category: category ?? this.category,
      isAllergen: isAllergen ?? this.isAllergen,
      firstTriedAt: firstTriedAt ?? this.firstTriedAt,
      reaction: reaction ?? this.reaction,
      reactionSeverity: reactionSeverity ?? this.reactionSeverity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (babyId.present) {
      map['baby_id'] = Variable<int>(babyId.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isAllergen.present) {
      map['is_allergen'] = Variable<bool>(isAllergen.value);
    }
    if (firstTriedAt.present) {
      map['first_tried_at'] = Variable<DateTime>(firstTriedAt.value);
    }
    if (reaction.present) {
      map['reaction'] = Variable<String>(reaction.value);
    }
    if (reactionSeverity.present) {
      map['reaction_severity'] = Variable<String>(reactionSeverity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodIntroductionsCompanion(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('foodName: $foodName, ')
          ..write('category: $category, ')
          ..write('isAllergen: $isAllergen, ')
          ..write('firstTriedAt: $firstTriedAt, ')
          ..write('reaction: $reaction, ')
          ..write('reactionSeverity: $reactionSeverity, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TeethRecordsTable extends TeethRecords
    with TableInfo<$TeethRecordsTable, TeethRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeethRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<int> babyId = GeneratedColumn<int>(
    'baby_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toothPositionMeta = const VerificationMeta(
    'toothPosition',
  );
  @override
  late final GeneratedColumn<String> toothPosition = GeneratedColumn<String>(
    'tooth_position',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eruptedAtMeta = const VerificationMeta(
    'eruptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> eruptedAt = GeneratedColumn<DateTime>(
    'erupted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    babyId,
    toothPosition,
    eruptedAt,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teeth_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeethRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('baby_id')) {
      context.handle(
        _babyIdMeta,
        babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_babyIdMeta);
    }
    if (data.containsKey('tooth_position')) {
      context.handle(
        _toothPositionMeta,
        toothPosition.isAcceptableOrUnknown(
          data['tooth_position']!,
          _toothPositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toothPositionMeta);
    }
    if (data.containsKey('erupted_at')) {
      context.handle(
        _eruptedAtMeta,
        eruptedAt.isAcceptableOrUnknown(data['erupted_at']!, _eruptedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_eruptedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeethRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeethRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      babyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baby_id'],
      )!,
      toothPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tooth_position'],
      )!,
      eruptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}erupted_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TeethRecordsTable createAlias(String alias) {
    return $TeethRecordsTable(attachedDatabase, alias);
  }
}

class TeethRecord extends DataClass implements Insertable<TeethRecord> {
  final int id;
  final int babyId;
  final String toothPosition;
  final DateTime eruptedAt;
  final String? notes;
  final DateTime createdAt;
  const TeethRecord({
    required this.id,
    required this.babyId,
    required this.toothPosition,
    required this.eruptedAt,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['baby_id'] = Variable<int>(babyId);
    map['tooth_position'] = Variable<String>(toothPosition);
    map['erupted_at'] = Variable<DateTime>(eruptedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TeethRecordsCompanion toCompanion(bool nullToAbsent) {
    return TeethRecordsCompanion(
      id: Value(id),
      babyId: Value(babyId),
      toothPosition: Value(toothPosition),
      eruptedAt: Value(eruptedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory TeethRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeethRecord(
      id: serializer.fromJson<int>(json['id']),
      babyId: serializer.fromJson<int>(json['babyId']),
      toothPosition: serializer.fromJson<String>(json['toothPosition']),
      eruptedAt: serializer.fromJson<DateTime>(json['eruptedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'babyId': serializer.toJson<int>(babyId),
      'toothPosition': serializer.toJson<String>(toothPosition),
      'eruptedAt': serializer.toJson<DateTime>(eruptedAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TeethRecord copyWith({
    int? id,
    int? babyId,
    String? toothPosition,
    DateTime? eruptedAt,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => TeethRecord(
    id: id ?? this.id,
    babyId: babyId ?? this.babyId,
    toothPosition: toothPosition ?? this.toothPosition,
    eruptedAt: eruptedAt ?? this.eruptedAt,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  TeethRecord copyWithCompanion(TeethRecordsCompanion data) {
    return TeethRecord(
      id: data.id.present ? data.id.value : this.id,
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      toothPosition: data.toothPosition.present
          ? data.toothPosition.value
          : this.toothPosition,
      eruptedAt: data.eruptedAt.present ? data.eruptedAt.value : this.eruptedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeethRecord(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('toothPosition: $toothPosition, ')
          ..write('eruptedAt: $eruptedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, babyId, toothPosition, eruptedAt, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeethRecord &&
          other.id == this.id &&
          other.babyId == this.babyId &&
          other.toothPosition == this.toothPosition &&
          other.eruptedAt == this.eruptedAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class TeethRecordsCompanion extends UpdateCompanion<TeethRecord> {
  final Value<int> id;
  final Value<int> babyId;
  final Value<String> toothPosition;
  final Value<DateTime> eruptedAt;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const TeethRecordsCompanion({
    this.id = const Value.absent(),
    this.babyId = const Value.absent(),
    this.toothPosition = const Value.absent(),
    this.eruptedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TeethRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int babyId,
    required String toothPosition,
    required DateTime eruptedAt,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : babyId = Value(babyId),
       toothPosition = Value(toothPosition),
       eruptedAt = Value(eruptedAt);
  static Insertable<TeethRecord> custom({
    Expression<int>? id,
    Expression<int>? babyId,
    Expression<String>? toothPosition,
    Expression<DateTime>? eruptedAt,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (babyId != null) 'baby_id': babyId,
      if (toothPosition != null) 'tooth_position': toothPosition,
      if (eruptedAt != null) 'erupted_at': eruptedAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TeethRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? babyId,
    Value<String>? toothPosition,
    Value<DateTime>? eruptedAt,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return TeethRecordsCompanion(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      toothPosition: toothPosition ?? this.toothPosition,
      eruptedAt: eruptedAt ?? this.eruptedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (babyId.present) {
      map['baby_id'] = Variable<int>(babyId.value);
    }
    if (toothPosition.present) {
      map['tooth_position'] = Variable<String>(toothPosition.value);
    }
    if (eruptedAt.present) {
      map['erupted_at'] = Variable<DateTime>(eruptedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeethRecordsCompanion(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('toothPosition: $toothPosition, ')
          ..write('eruptedAt: $eruptedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<int> babyId = GeneratedColumn<int>(
    'baby_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextDataMeta = const VerificationMeta(
    'contextData',
  );
  @override
  late final GeneratedColumn<String> contextData = GeneratedColumn<String>(
    'context_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    babyId,
    role,
    content,
    contextData,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('baby_id')) {
      context.handle(
        _babyIdMeta,
        babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_babyIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('context_data')) {
      context.handle(
        _contextDataMeta,
        contextData.isAcceptableOrUnknown(
          data['context_data']!,
          _contextDataMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      babyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baby_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      contextData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_data'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final int id;
  final int babyId;
  final String role;
  final String content;
  final String? contextData;
  final DateTime createdAt;
  const ChatMessage({
    required this.id,
    required this.babyId,
    required this.role,
    required this.content,
    this.contextData,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['baby_id'] = Variable<int>(babyId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || contextData != null) {
      map['context_data'] = Variable<String>(contextData);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      babyId: Value(babyId),
      role: Value(role),
      content: Value(content),
      contextData: contextData == null && nullToAbsent
          ? const Value.absent()
          : Value(contextData),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<int>(json['id']),
      babyId: serializer.fromJson<int>(json['babyId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      contextData: serializer.fromJson<String?>(json['contextData']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'babyId': serializer.toJson<int>(babyId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'contextData': serializer.toJson<String?>(contextData),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatMessage copyWith({
    int? id,
    int? babyId,
    String? role,
    String? content,
    Value<String?> contextData = const Value.absent(),
    DateTime? createdAt,
  }) => ChatMessage(
    id: id ?? this.id,
    babyId: babyId ?? this.babyId,
    role: role ?? this.role,
    content: content ?? this.content,
    contextData: contextData.present ? contextData.value : this.contextData,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      contextData: data.contextData.present
          ? data.contextData.value
          : this.contextData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('contextData: $contextData, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, babyId, role, content, contextData, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.babyId == this.babyId &&
          other.role == this.role &&
          other.content == this.content &&
          other.contextData == this.contextData &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<int> id;
  final Value<int> babyId;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> contextData;
  final Value<DateTime> createdAt;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.babyId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.contextData = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required int babyId,
    required String role,
    required String content,
    this.contextData = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : babyId = Value(babyId),
       role = Value(role),
       content = Value(content);
  static Insertable<ChatMessage> custom({
    Expression<int>? id,
    Expression<int>? babyId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? contextData,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (babyId != null) 'baby_id': babyId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (contextData != null) 'context_data': contextData,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? babyId,
    Value<String>? role,
    Value<String>? content,
    Value<String?>? contextData,
    Value<DateTime>? createdAt,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      role: role ?? this.role,
      content: content ?? this.content,
      contextData: contextData ?? this.contextData,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (babyId.present) {
      map['baby_id'] = Variable<int>(babyId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (contextData.present) {
      map['context_data'] = Variable<String>(contextData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('contextData: $contextData, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MediaEntriesTable extends MediaEntries
    with TableInfo<$MediaEntriesTable, MediaEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<int> babyId = GeneratedColumn<int>(
    'baby_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storagePathMeta = const VerificationMeta(
    'storagePath',
  );
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
    'storage_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedRecordTypeMeta = const VerificationMeta(
    'linkedRecordType',
  );
  @override
  late final GeneratedColumn<String> linkedRecordType = GeneratedColumn<String>(
    'linked_record_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedRecordIdMeta = const VerificationMeta(
    'linkedRecordId',
  );
  @override
  late final GeneratedColumn<int> linkedRecordId = GeneratedColumn<int>(
    'linked_record_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    babyId,
    type,
    storagePath,
    thumbnailPath,
    caption,
    takenAt,
    linkedRecordType,
    linkedRecordId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('baby_id')) {
      context.handle(
        _babyIdMeta,
        babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_babyIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('storage_path')) {
      context.handle(
        _storagePathMeta,
        storagePath.isAcceptableOrUnknown(
          data['storage_path']!,
          _storagePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storagePathMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    }
    if (data.containsKey('linked_record_type')) {
      context.handle(
        _linkedRecordTypeMeta,
        linkedRecordType.isAcceptableOrUnknown(
          data['linked_record_type']!,
          _linkedRecordTypeMeta,
        ),
      );
    }
    if (data.containsKey('linked_record_id')) {
      context.handle(
        _linkedRecordIdMeta,
        linkedRecordId.isAcceptableOrUnknown(
          data['linked_record_id']!,
          _linkedRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      babyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baby_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      storagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      ),
      linkedRecordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_record_type'],
      ),
      linkedRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_record_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MediaEntriesTable createAlias(String alias) {
    return $MediaEntriesTable(attachedDatabase, alias);
  }
}

class MediaEntry extends DataClass implements Insertable<MediaEntry> {
  final int id;
  final int babyId;
  final String type;
  final String storagePath;
  final String? thumbnailPath;
  final String? caption;
  final DateTime? takenAt;
  final String? linkedRecordType;
  final int? linkedRecordId;
  final DateTime createdAt;
  const MediaEntry({
    required this.id,
    required this.babyId,
    required this.type,
    required this.storagePath,
    this.thumbnailPath,
    this.caption,
    this.takenAt,
    this.linkedRecordType,
    this.linkedRecordId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['baby_id'] = Variable<int>(babyId);
    map['type'] = Variable<String>(type);
    map['storage_path'] = Variable<String>(storagePath);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    if (!nullToAbsent || takenAt != null) {
      map['taken_at'] = Variable<DateTime>(takenAt);
    }
    if (!nullToAbsent || linkedRecordType != null) {
      map['linked_record_type'] = Variable<String>(linkedRecordType);
    }
    if (!nullToAbsent || linkedRecordId != null) {
      map['linked_record_id'] = Variable<int>(linkedRecordId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MediaEntriesCompanion toCompanion(bool nullToAbsent) {
    return MediaEntriesCompanion(
      id: Value(id),
      babyId: Value(babyId),
      type: Value(type),
      storagePath: Value(storagePath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      takenAt: takenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(takenAt),
      linkedRecordType: linkedRecordType == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedRecordType),
      linkedRecordId: linkedRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedRecordId),
      createdAt: Value(createdAt),
    );
  }

  factory MediaEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaEntry(
      id: serializer.fromJson<int>(json['id']),
      babyId: serializer.fromJson<int>(json['babyId']),
      type: serializer.fromJson<String>(json['type']),
      storagePath: serializer.fromJson<String>(json['storagePath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      caption: serializer.fromJson<String?>(json['caption']),
      takenAt: serializer.fromJson<DateTime?>(json['takenAt']),
      linkedRecordType: serializer.fromJson<String?>(json['linkedRecordType']),
      linkedRecordId: serializer.fromJson<int?>(json['linkedRecordId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'babyId': serializer.toJson<int>(babyId),
      'type': serializer.toJson<String>(type),
      'storagePath': serializer.toJson<String>(storagePath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'caption': serializer.toJson<String?>(caption),
      'takenAt': serializer.toJson<DateTime?>(takenAt),
      'linkedRecordType': serializer.toJson<String?>(linkedRecordType),
      'linkedRecordId': serializer.toJson<int?>(linkedRecordId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MediaEntry copyWith({
    int? id,
    int? babyId,
    String? type,
    String? storagePath,
    Value<String?> thumbnailPath = const Value.absent(),
    Value<String?> caption = const Value.absent(),
    Value<DateTime?> takenAt = const Value.absent(),
    Value<String?> linkedRecordType = const Value.absent(),
    Value<int?> linkedRecordId = const Value.absent(),
    DateTime? createdAt,
  }) => MediaEntry(
    id: id ?? this.id,
    babyId: babyId ?? this.babyId,
    type: type ?? this.type,
    storagePath: storagePath ?? this.storagePath,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    caption: caption.present ? caption.value : this.caption,
    takenAt: takenAt.present ? takenAt.value : this.takenAt,
    linkedRecordType: linkedRecordType.present
        ? linkedRecordType.value
        : this.linkedRecordType,
    linkedRecordId: linkedRecordId.present
        ? linkedRecordId.value
        : this.linkedRecordId,
    createdAt: createdAt ?? this.createdAt,
  );
  MediaEntry copyWithCompanion(MediaEntriesCompanion data) {
    return MediaEntry(
      id: data.id.present ? data.id.value : this.id,
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      type: data.type.present ? data.type.value : this.type,
      storagePath: data.storagePath.present
          ? data.storagePath.value
          : this.storagePath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      caption: data.caption.present ? data.caption.value : this.caption,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      linkedRecordType: data.linkedRecordType.present
          ? data.linkedRecordType.value
          : this.linkedRecordType,
      linkedRecordId: data.linkedRecordId.present
          ? data.linkedRecordId.value
          : this.linkedRecordId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaEntry(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('type: $type, ')
          ..write('storagePath: $storagePath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('caption: $caption, ')
          ..write('takenAt: $takenAt, ')
          ..write('linkedRecordType: $linkedRecordType, ')
          ..write('linkedRecordId: $linkedRecordId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    babyId,
    type,
    storagePath,
    thumbnailPath,
    caption,
    takenAt,
    linkedRecordType,
    linkedRecordId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaEntry &&
          other.id == this.id &&
          other.babyId == this.babyId &&
          other.type == this.type &&
          other.storagePath == this.storagePath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.caption == this.caption &&
          other.takenAt == this.takenAt &&
          other.linkedRecordType == this.linkedRecordType &&
          other.linkedRecordId == this.linkedRecordId &&
          other.createdAt == this.createdAt);
}

class MediaEntriesCompanion extends UpdateCompanion<MediaEntry> {
  final Value<int> id;
  final Value<int> babyId;
  final Value<String> type;
  final Value<String> storagePath;
  final Value<String?> thumbnailPath;
  final Value<String?> caption;
  final Value<DateTime?> takenAt;
  final Value<String?> linkedRecordType;
  final Value<int?> linkedRecordId;
  final Value<DateTime> createdAt;
  const MediaEntriesCompanion({
    this.id = const Value.absent(),
    this.babyId = const Value.absent(),
    this.type = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.caption = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.linkedRecordType = const Value.absent(),
    this.linkedRecordId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MediaEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int babyId,
    required String type,
    required String storagePath,
    this.thumbnailPath = const Value.absent(),
    this.caption = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.linkedRecordType = const Value.absent(),
    this.linkedRecordId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : babyId = Value(babyId),
       type = Value(type),
       storagePath = Value(storagePath);
  static Insertable<MediaEntry> custom({
    Expression<int>? id,
    Expression<int>? babyId,
    Expression<String>? type,
    Expression<String>? storagePath,
    Expression<String>? thumbnailPath,
    Expression<String>? caption,
    Expression<DateTime>? takenAt,
    Expression<String>? linkedRecordType,
    Expression<int>? linkedRecordId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (babyId != null) 'baby_id': babyId,
      if (type != null) 'type': type,
      if (storagePath != null) 'storage_path': storagePath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (caption != null) 'caption': caption,
      if (takenAt != null) 'taken_at': takenAt,
      if (linkedRecordType != null) 'linked_record_type': linkedRecordType,
      if (linkedRecordId != null) 'linked_record_id': linkedRecordId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MediaEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? babyId,
    Value<String>? type,
    Value<String>? storagePath,
    Value<String?>? thumbnailPath,
    Value<String?>? caption,
    Value<DateTime?>? takenAt,
    Value<String?>? linkedRecordType,
    Value<int?>? linkedRecordId,
    Value<DateTime>? createdAt,
  }) {
    return MediaEntriesCompanion(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      type: type ?? this.type,
      storagePath: storagePath ?? this.storagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      caption: caption ?? this.caption,
      takenAt: takenAt ?? this.takenAt,
      linkedRecordType: linkedRecordType ?? this.linkedRecordType,
      linkedRecordId: linkedRecordId ?? this.linkedRecordId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (babyId.present) {
      map['baby_id'] = Variable<int>(babyId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (linkedRecordType.present) {
      map['linked_record_type'] = Variable<String>(linkedRecordType.value);
    }
    if (linkedRecordId.present) {
      map['linked_record_id'] = Variable<int>(linkedRecordId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaEntriesCompanion(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('type: $type, ')
          ..write('storagePath: $storagePath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('caption: $caption, ')
          ..write('takenAt: $takenAt, ')
          ..write('linkedRecordType: $linkedRecordType, ')
          ..write('linkedRecordId: $linkedRecordId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BabiesTable babies = $BabiesTable(this);
  late final $GrowthRecordsTable growthRecords = $GrowthRecordsTable(this);
  late final $DailyLogsTable dailyLogs = $DailyLogsTable(this);
  late final $NotificationSettingsTable notificationSettings =
      $NotificationSettingsTable(this);
  late final $MilestonesTable milestones = $MilestonesTable(this);
  late final $VaccinationsTable vaccinations = $VaccinationsTable(this);
  late final $HealthEventsTable healthEvents = $HealthEventsTable(this);
  late final $FoodIntroductionsTable foodIntroductions =
      $FoodIntroductionsTable(this);
  late final $TeethRecordsTable teethRecords = $TeethRecordsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $MediaEntriesTable mediaEntries = $MediaEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    babies,
    growthRecords,
    dailyLogs,
    notificationSettings,
    milestones,
    vaccinations,
    healthEvents,
    foodIntroductions,
    teethRecords,
    chatMessages,
    mediaEntries,
  ];
}

typedef $$BabiesTableCreateCompanionBuilder =
    BabiesCompanion Function({
      Value<int> id,
      required String name,
      required DateTime dateOfBirth,
      Value<String?> gender,
      Value<String?> bloodType,
      Value<String?> photoUrl,
      Value<DateTime> createdAt,
    });
typedef $$BabiesTableUpdateCompanionBuilder =
    BabiesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> dateOfBirth,
      Value<String?> gender,
      Value<String?> bloodType,
      Value<String?> photoUrl,
      Value<DateTime> createdAt,
    });

class $$BabiesTableFilterComposer
    extends Composer<_$AppDatabase, $BabiesTable> {
  $$BabiesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bloodType => $composableBuilder(
    column: $table.bloodType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BabiesTableOrderingComposer
    extends Composer<_$AppDatabase, $BabiesTable> {
  $$BabiesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bloodType => $composableBuilder(
    column: $table.bloodType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BabiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BabiesTable> {
  $$BabiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get bloodType =>
      $composableBuilder(column: $table.bloodType, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BabiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BabiesTable,
          Baby,
          $$BabiesTableFilterComposer,
          $$BabiesTableOrderingComposer,
          $$BabiesTableAnnotationComposer,
          $$BabiesTableCreateCompanionBuilder,
          $$BabiesTableUpdateCompanionBuilder,
          (Baby, BaseReferences<_$AppDatabase, $BabiesTable, Baby>),
          Baby,
          PrefetchHooks Function()
        > {
  $$BabiesTableTableManager(_$AppDatabase db, $BabiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BabiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BabiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BabiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> dateOfBirth = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> bloodType = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BabiesCompanion(
                id: id,
                name: name,
                dateOfBirth: dateOfBirth,
                gender: gender,
                bloodType: bloodType,
                photoUrl: photoUrl,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime dateOfBirth,
                Value<String?> gender = const Value.absent(),
                Value<String?> bloodType = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BabiesCompanion.insert(
                id: id,
                name: name,
                dateOfBirth: dateOfBirth,
                gender: gender,
                bloodType: bloodType,
                photoUrl: photoUrl,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BabiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BabiesTable,
      Baby,
      $$BabiesTableFilterComposer,
      $$BabiesTableOrderingComposer,
      $$BabiesTableAnnotationComposer,
      $$BabiesTableCreateCompanionBuilder,
      $$BabiesTableUpdateCompanionBuilder,
      (Baby, BaseReferences<_$AppDatabase, $BabiesTable, Baby>),
      Baby,
      PrefetchHooks Function()
    >;
typedef $$GrowthRecordsTableCreateCompanionBuilder =
    GrowthRecordsCompanion Function({
      Value<int> id,
      required int babyId,
      required DateTime date,
      Value<double?> weightKg,
      Value<double?> heightCm,
      Value<double?> headCircumferenceCm,
      Value<String?> notes,
      Value<String?> photoUrl,
      Value<DateTime> createdAt,
    });
typedef $$GrowthRecordsTableUpdateCompanionBuilder =
    GrowthRecordsCompanion Function({
      Value<int> id,
      Value<int> babyId,
      Value<DateTime> date,
      Value<double?> weightKg,
      Value<double?> heightCm,
      Value<double?> headCircumferenceCm,
      Value<String?> notes,
      Value<String?> photoUrl,
      Value<DateTime> createdAt,
    });

class $$GrowthRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $GrowthRecordsTable> {
  $$GrowthRecordsTableFilterComposer({
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

  ColumnFilters<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get headCircumferenceCm => $composableBuilder(
    column: $table.headCircumferenceCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GrowthRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $GrowthRecordsTable> {
  $$GrowthRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get headCircumferenceCm => $composableBuilder(
    column: $table.headCircumferenceCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GrowthRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrowthRecordsTable> {
  $$GrowthRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get babyId =>
      $composableBuilder(column: $table.babyId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get headCircumferenceCm => $composableBuilder(
    column: $table.headCircumferenceCm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GrowthRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrowthRecordsTable,
          GrowthRecord,
          $$GrowthRecordsTableFilterComposer,
          $$GrowthRecordsTableOrderingComposer,
          $$GrowthRecordsTableAnnotationComposer,
          $$GrowthRecordsTableCreateCompanionBuilder,
          $$GrowthRecordsTableUpdateCompanionBuilder,
          (
            GrowthRecord,
            BaseReferences<_$AppDatabase, $GrowthRecordsTable, GrowthRecord>,
          ),
          GrowthRecord,
          PrefetchHooks Function()
        > {
  $$GrowthRecordsTableTableManager(_$AppDatabase db, $GrowthRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrowthRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrowthRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrowthRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> babyId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> headCircumferenceCm = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GrowthRecordsCompanion(
                id: id,
                babyId: babyId,
                date: date,
                weightKg: weightKg,
                heightCm: heightCm,
                headCircumferenceCm: headCircumferenceCm,
                notes: notes,
                photoUrl: photoUrl,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int babyId,
                required DateTime date,
                Value<double?> weightKg = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> headCircumferenceCm = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GrowthRecordsCompanion.insert(
                id: id,
                babyId: babyId,
                date: date,
                weightKg: weightKg,
                heightCm: heightCm,
                headCircumferenceCm: headCircumferenceCm,
                notes: notes,
                photoUrl: photoUrl,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GrowthRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrowthRecordsTable,
      GrowthRecord,
      $$GrowthRecordsTableFilterComposer,
      $$GrowthRecordsTableOrderingComposer,
      $$GrowthRecordsTableAnnotationComposer,
      $$GrowthRecordsTableCreateCompanionBuilder,
      $$GrowthRecordsTableUpdateCompanionBuilder,
      (
        GrowthRecord,
        BaseReferences<_$AppDatabase, $GrowthRecordsTable, GrowthRecord>,
      ),
      GrowthRecord,
      PrefetchHooks Function()
    >;
typedef $$DailyLogsTableCreateCompanionBuilder =
    DailyLogsCompanion Function({
      Value<int> id,
      required int babyId,
      required String type,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int?> durationMinutes,
      Value<String?> metadata,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$DailyLogsTableUpdateCompanionBuilder =
    DailyLogsCompanion Function({
      Value<int> id,
      Value<int> babyId,
      Value<String> type,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int?> durationMinutes,
      Value<String?> metadata,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$DailyLogsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableFilterComposer({
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

  ColumnFilters<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableOrderingComposer({
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

  ColumnOrderings<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get babyId =>
      $composableBuilder(column: $table.babyId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DailyLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyLogsTable,
          DailyLog,
          $$DailyLogsTableFilterComposer,
          $$DailyLogsTableOrderingComposer,
          $$DailyLogsTableAnnotationComposer,
          $$DailyLogsTableCreateCompanionBuilder,
          $$DailyLogsTableUpdateCompanionBuilder,
          (DailyLog, BaseReferences<_$AppDatabase, $DailyLogsTable, DailyLog>),
          DailyLog,
          PrefetchHooks Function()
        > {
  $$DailyLogsTableTableManager(_$AppDatabase db, $DailyLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> babyId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DailyLogsCompanion(
                id: id,
                babyId: babyId,
                type: type,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMinutes: durationMinutes,
                metadata: metadata,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int babyId,
                required String type,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DailyLogsCompanion.insert(
                id: id,
                babyId: babyId,
                type: type,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMinutes: durationMinutes,
                metadata: metadata,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyLogsTable,
      DailyLog,
      $$DailyLogsTableFilterComposer,
      $$DailyLogsTableOrderingComposer,
      $$DailyLogsTableAnnotationComposer,
      $$DailyLogsTableCreateCompanionBuilder,
      $$DailyLogsTableUpdateCompanionBuilder,
      (DailyLog, BaseReferences<_$AppDatabase, $DailyLogsTable, DailyLog>),
      DailyLog,
      PrefetchHooks Function()
    >;
typedef $$NotificationSettingsTableCreateCompanionBuilder =
    NotificationSettingsCompanion Function({
      Value<int> id,
      required int babyId,
      required String type,
      Value<bool> enabled,
      Value<int> intervalMinutes,
      Value<DateTime> createdAt,
    });
typedef $$NotificationSettingsTableUpdateCompanionBuilder =
    NotificationSettingsCompanion Function({
      Value<int> id,
      Value<int> babyId,
      Value<String> type,
      Value<bool> enabled,
      Value<int> intervalMinutes,
      Value<DateTime> createdAt,
    });

class $$NotificationSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableFilterComposer({
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

  ColumnFilters<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalMinutes => $composableBuilder(
    column: $table.intervalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableOrderingComposer({
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

  ColumnOrderings<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalMinutes => $composableBuilder(
    column: $table.intervalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get babyId =>
      $composableBuilder(column: $table.babyId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get intervalMinutes => $composableBuilder(
    column: $table.intervalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NotificationSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationSettingsTable,
          NotificationSetting,
          $$NotificationSettingsTableFilterComposer,
          $$NotificationSettingsTableOrderingComposer,
          $$NotificationSettingsTableAnnotationComposer,
          $$NotificationSettingsTableCreateCompanionBuilder,
          $$NotificationSettingsTableUpdateCompanionBuilder,
          (
            NotificationSetting,
            BaseReferences<
              _$AppDatabase,
              $NotificationSettingsTable,
              NotificationSetting
            >,
          ),
          NotificationSetting,
          PrefetchHooks Function()
        > {
  $$NotificationSettingsTableTableManager(
    _$AppDatabase db,
    $NotificationSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> babyId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> intervalMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NotificationSettingsCompanion(
                id: id,
                babyId: babyId,
                type: type,
                enabled: enabled,
                intervalMinutes: intervalMinutes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int babyId,
                required String type,
                Value<bool> enabled = const Value.absent(),
                Value<int> intervalMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NotificationSettingsCompanion.insert(
                id: id,
                babyId: babyId,
                type: type,
                enabled: enabled,
                intervalMinutes: intervalMinutes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationSettingsTable,
      NotificationSetting,
      $$NotificationSettingsTableFilterComposer,
      $$NotificationSettingsTableOrderingComposer,
      $$NotificationSettingsTableAnnotationComposer,
      $$NotificationSettingsTableCreateCompanionBuilder,
      $$NotificationSettingsTableUpdateCompanionBuilder,
      (
        NotificationSetting,
        BaseReferences<
          _$AppDatabase,
          $NotificationSettingsTable,
          NotificationSetting
        >,
      ),
      NotificationSetting,
      PrefetchHooks Function()
    >;
typedef $$MilestonesTableCreateCompanionBuilder =
    MilestonesCompanion Function({
      Value<int> id,
      required int babyId,
      required String category,
      required String title,
      Value<String?> description,
      Value<DateTime?> achievedAt,
      Value<int?> expectedAgeMonths,
      Value<DateTime> createdAt,
    });
typedef $$MilestonesTableUpdateCompanionBuilder =
    MilestonesCompanion Function({
      Value<int> id,
      Value<int> babyId,
      Value<String> category,
      Value<String> title,
      Value<String?> description,
      Value<DateTime?> achievedAt,
      Value<int?> expectedAgeMonths,
      Value<DateTime> createdAt,
    });

class $$MilestonesTableFilterComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableFilterComposer({
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

  ColumnFilters<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedAgeMonths => $composableBuilder(
    column: $table.expectedAgeMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MilestonesTableOrderingComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableOrderingComposer({
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

  ColumnOrderings<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedAgeMonths => $composableBuilder(
    column: $table.expectedAgeMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MilestonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get babyId =>
      $composableBuilder(column: $table.babyId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedAgeMonths => $composableBuilder(
    column: $table.expectedAgeMonths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MilestonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MilestonesTable,
          Milestone,
          $$MilestonesTableFilterComposer,
          $$MilestonesTableOrderingComposer,
          $$MilestonesTableAnnotationComposer,
          $$MilestonesTableCreateCompanionBuilder,
          $$MilestonesTableUpdateCompanionBuilder,
          (
            Milestone,
            BaseReferences<_$AppDatabase, $MilestonesTable, Milestone>,
          ),
          Milestone,
          PrefetchHooks Function()
        > {
  $$MilestonesTableTableManager(_$AppDatabase db, $MilestonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MilestonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MilestonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MilestonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> babyId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime?> achievedAt = const Value.absent(),
                Value<int?> expectedAgeMonths = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MilestonesCompanion(
                id: id,
                babyId: babyId,
                category: category,
                title: title,
                description: description,
                achievedAt: achievedAt,
                expectedAgeMonths: expectedAgeMonths,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int babyId,
                required String category,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<DateTime?> achievedAt = const Value.absent(),
                Value<int?> expectedAgeMonths = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MilestonesCompanion.insert(
                id: id,
                babyId: babyId,
                category: category,
                title: title,
                description: description,
                achievedAt: achievedAt,
                expectedAgeMonths: expectedAgeMonths,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MilestonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MilestonesTable,
      Milestone,
      $$MilestonesTableFilterComposer,
      $$MilestonesTableOrderingComposer,
      $$MilestonesTableAnnotationComposer,
      $$MilestonesTableCreateCompanionBuilder,
      $$MilestonesTableUpdateCompanionBuilder,
      (Milestone, BaseReferences<_$AppDatabase, $MilestonesTable, Milestone>),
      Milestone,
      PrefetchHooks Function()
    >;
typedef $$VaccinationsTableCreateCompanionBuilder =
    VaccinationsCompanion Function({
      Value<int> id,
      required int babyId,
      required String vaccineName,
      Value<int?> doseNumber,
      Value<DateTime?> administeredAt,
      Value<DateTime?> nextDueAt,
      Value<String?> provider,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$VaccinationsTableUpdateCompanionBuilder =
    VaccinationsCompanion Function({
      Value<int> id,
      Value<int> babyId,
      Value<String> vaccineName,
      Value<int?> doseNumber,
      Value<DateTime?> administeredAt,
      Value<DateTime?> nextDueAt,
      Value<String?> provider,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$VaccinationsTableFilterComposer
    extends Composer<_$AppDatabase, $VaccinationsTable> {
  $$VaccinationsTableFilterComposer({
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

  ColumnFilters<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vaccineName => $composableBuilder(
    column: $table.vaccineName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get doseNumber => $composableBuilder(
    column: $table.doseNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get administeredAt => $composableBuilder(
    column: $table.administeredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VaccinationsTableOrderingComposer
    extends Composer<_$AppDatabase, $VaccinationsTable> {
  $$VaccinationsTableOrderingComposer({
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

  ColumnOrderings<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vaccineName => $composableBuilder(
    column: $table.vaccineName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get doseNumber => $composableBuilder(
    column: $table.doseNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get administeredAt => $composableBuilder(
    column: $table.administeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaccinationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaccinationsTable> {
  $$VaccinationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get babyId =>
      $composableBuilder(column: $table.babyId, builder: (column) => column);

  GeneratedColumn<String> get vaccineName => $composableBuilder(
    column: $table.vaccineName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get doseNumber => $composableBuilder(
    column: $table.doseNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get administeredAt => $composableBuilder(
    column: $table.administeredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextDueAt =>
      $composableBuilder(column: $table.nextDueAt, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VaccinationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VaccinationsTable,
          Vaccination,
          $$VaccinationsTableFilterComposer,
          $$VaccinationsTableOrderingComposer,
          $$VaccinationsTableAnnotationComposer,
          $$VaccinationsTableCreateCompanionBuilder,
          $$VaccinationsTableUpdateCompanionBuilder,
          (
            Vaccination,
            BaseReferences<_$AppDatabase, $VaccinationsTable, Vaccination>,
          ),
          Vaccination,
          PrefetchHooks Function()
        > {
  $$VaccinationsTableTableManager(_$AppDatabase db, $VaccinationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaccinationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaccinationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaccinationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> babyId = const Value.absent(),
                Value<String> vaccineName = const Value.absent(),
                Value<int?> doseNumber = const Value.absent(),
                Value<DateTime?> administeredAt = const Value.absent(),
                Value<DateTime?> nextDueAt = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VaccinationsCompanion(
                id: id,
                babyId: babyId,
                vaccineName: vaccineName,
                doseNumber: doseNumber,
                administeredAt: administeredAt,
                nextDueAt: nextDueAt,
                provider: provider,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int babyId,
                required String vaccineName,
                Value<int?> doseNumber = const Value.absent(),
                Value<DateTime?> administeredAt = const Value.absent(),
                Value<DateTime?> nextDueAt = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VaccinationsCompanion.insert(
                id: id,
                babyId: babyId,
                vaccineName: vaccineName,
                doseNumber: doseNumber,
                administeredAt: administeredAt,
                nextDueAt: nextDueAt,
                provider: provider,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VaccinationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VaccinationsTable,
      Vaccination,
      $$VaccinationsTableFilterComposer,
      $$VaccinationsTableOrderingComposer,
      $$VaccinationsTableAnnotationComposer,
      $$VaccinationsTableCreateCompanionBuilder,
      $$VaccinationsTableUpdateCompanionBuilder,
      (
        Vaccination,
        BaseReferences<_$AppDatabase, $VaccinationsTable, Vaccination>,
      ),
      Vaccination,
      PrefetchHooks Function()
    >;
typedef $$HealthEventsTableCreateCompanionBuilder =
    HealthEventsCompanion Function({
      Value<int> id,
      required int babyId,
      required String type,
      required String title,
      Value<String?> description,
      Value<DateTime?> startedAt,
      Value<DateTime?> endedAt,
      Value<String?> metadata,
      Value<DateTime> createdAt,
    });
typedef $$HealthEventsTableUpdateCompanionBuilder =
    HealthEventsCompanion Function({
      Value<int> id,
      Value<int> babyId,
      Value<String> type,
      Value<String> title,
      Value<String?> description,
      Value<DateTime?> startedAt,
      Value<DateTime?> endedAt,
      Value<String?> metadata,
      Value<DateTime> createdAt,
    });

class $$HealthEventsTableFilterComposer
    extends Composer<_$AppDatabase, $HealthEventsTable> {
  $$HealthEventsTableFilterComposer({
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

  ColumnFilters<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthEventsTable> {
  $$HealthEventsTableOrderingComposer({
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

  ColumnOrderings<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthEventsTable> {
  $$HealthEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get babyId =>
      $composableBuilder(column: $table.babyId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HealthEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthEventsTable,
          HealthEvent,
          $$HealthEventsTableFilterComposer,
          $$HealthEventsTableOrderingComposer,
          $$HealthEventsTableAnnotationComposer,
          $$HealthEventsTableCreateCompanionBuilder,
          $$HealthEventsTableUpdateCompanionBuilder,
          (
            HealthEvent,
            BaseReferences<_$AppDatabase, $HealthEventsTable, HealthEvent>,
          ),
          HealthEvent,
          PrefetchHooks Function()
        > {
  $$HealthEventsTableTableManager(_$AppDatabase db, $HealthEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> babyId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HealthEventsCompanion(
                id: id,
                babyId: babyId,
                type: type,
                title: title,
                description: description,
                startedAt: startedAt,
                endedAt: endedAt,
                metadata: metadata,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int babyId,
                required String type,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HealthEventsCompanion.insert(
                id: id,
                babyId: babyId,
                type: type,
                title: title,
                description: description,
                startedAt: startedAt,
                endedAt: endedAt,
                metadata: metadata,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthEventsTable,
      HealthEvent,
      $$HealthEventsTableFilterComposer,
      $$HealthEventsTableOrderingComposer,
      $$HealthEventsTableAnnotationComposer,
      $$HealthEventsTableCreateCompanionBuilder,
      $$HealthEventsTableUpdateCompanionBuilder,
      (
        HealthEvent,
        BaseReferences<_$AppDatabase, $HealthEventsTable, HealthEvent>,
      ),
      HealthEvent,
      PrefetchHooks Function()
    >;
typedef $$FoodIntroductionsTableCreateCompanionBuilder =
    FoodIntroductionsCompanion Function({
      Value<int> id,
      required int babyId,
      required String foodName,
      required String category,
      Value<bool> isAllergen,
      required DateTime firstTriedAt,
      Value<String?> reaction,
      Value<String?> reactionSeverity,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$FoodIntroductionsTableUpdateCompanionBuilder =
    FoodIntroductionsCompanion Function({
      Value<int> id,
      Value<int> babyId,
      Value<String> foodName,
      Value<String> category,
      Value<bool> isAllergen,
      Value<DateTime> firstTriedAt,
      Value<String?> reaction,
      Value<String?> reactionSeverity,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$FoodIntroductionsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodIntroductionsTable> {
  $$FoodIntroductionsTableFilterComposer({
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

  ColumnFilters<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAllergen => $composableBuilder(
    column: $table.isAllergen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstTriedAt => $composableBuilder(
    column: $table.firstTriedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reaction => $composableBuilder(
    column: $table.reaction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reactionSeverity => $composableBuilder(
    column: $table.reactionSeverity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodIntroductionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodIntroductionsTable> {
  $$FoodIntroductionsTableOrderingComposer({
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

  ColumnOrderings<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAllergen => $composableBuilder(
    column: $table.isAllergen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstTriedAt => $composableBuilder(
    column: $table.firstTriedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reaction => $composableBuilder(
    column: $table.reaction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reactionSeverity => $composableBuilder(
    column: $table.reactionSeverity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodIntroductionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodIntroductionsTable> {
  $$FoodIntroductionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get babyId =>
      $composableBuilder(column: $table.babyId, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isAllergen => $composableBuilder(
    column: $table.isAllergen,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstTriedAt => $composableBuilder(
    column: $table.firstTriedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reaction =>
      $composableBuilder(column: $table.reaction, builder: (column) => column);

  GeneratedColumn<String> get reactionSeverity => $composableBuilder(
    column: $table.reactionSeverity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FoodIntroductionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodIntroductionsTable,
          FoodIntroduction,
          $$FoodIntroductionsTableFilterComposer,
          $$FoodIntroductionsTableOrderingComposer,
          $$FoodIntroductionsTableAnnotationComposer,
          $$FoodIntroductionsTableCreateCompanionBuilder,
          $$FoodIntroductionsTableUpdateCompanionBuilder,
          (
            FoodIntroduction,
            BaseReferences<
              _$AppDatabase,
              $FoodIntroductionsTable,
              FoodIntroduction
            >,
          ),
          FoodIntroduction,
          PrefetchHooks Function()
        > {
  $$FoodIntroductionsTableTableManager(
    _$AppDatabase db,
    $FoodIntroductionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodIntroductionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodIntroductionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodIntroductionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> babyId = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isAllergen = const Value.absent(),
                Value<DateTime> firstTriedAt = const Value.absent(),
                Value<String?> reaction = const Value.absent(),
                Value<String?> reactionSeverity = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FoodIntroductionsCompanion(
                id: id,
                babyId: babyId,
                foodName: foodName,
                category: category,
                isAllergen: isAllergen,
                firstTriedAt: firstTriedAt,
                reaction: reaction,
                reactionSeverity: reactionSeverity,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int babyId,
                required String foodName,
                required String category,
                Value<bool> isAllergen = const Value.absent(),
                required DateTime firstTriedAt,
                Value<String?> reaction = const Value.absent(),
                Value<String?> reactionSeverity = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FoodIntroductionsCompanion.insert(
                id: id,
                babyId: babyId,
                foodName: foodName,
                category: category,
                isAllergen: isAllergen,
                firstTriedAt: firstTriedAt,
                reaction: reaction,
                reactionSeverity: reactionSeverity,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodIntroductionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodIntroductionsTable,
      FoodIntroduction,
      $$FoodIntroductionsTableFilterComposer,
      $$FoodIntroductionsTableOrderingComposer,
      $$FoodIntroductionsTableAnnotationComposer,
      $$FoodIntroductionsTableCreateCompanionBuilder,
      $$FoodIntroductionsTableUpdateCompanionBuilder,
      (
        FoodIntroduction,
        BaseReferences<
          _$AppDatabase,
          $FoodIntroductionsTable,
          FoodIntroduction
        >,
      ),
      FoodIntroduction,
      PrefetchHooks Function()
    >;
typedef $$TeethRecordsTableCreateCompanionBuilder =
    TeethRecordsCompanion Function({
      Value<int> id,
      required int babyId,
      required String toothPosition,
      required DateTime eruptedAt,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$TeethRecordsTableUpdateCompanionBuilder =
    TeethRecordsCompanion Function({
      Value<int> id,
      Value<int> babyId,
      Value<String> toothPosition,
      Value<DateTime> eruptedAt,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$TeethRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $TeethRecordsTable> {
  $$TeethRecordsTableFilterComposer({
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

  ColumnFilters<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toothPosition => $composableBuilder(
    column: $table.toothPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eruptedAt => $composableBuilder(
    column: $table.eruptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeethRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $TeethRecordsTable> {
  $$TeethRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toothPosition => $composableBuilder(
    column: $table.toothPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eruptedAt => $composableBuilder(
    column: $table.eruptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeethRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeethRecordsTable> {
  $$TeethRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get babyId =>
      $composableBuilder(column: $table.babyId, builder: (column) => column);

  GeneratedColumn<String> get toothPosition => $composableBuilder(
    column: $table.toothPosition,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eruptedAt =>
      $composableBuilder(column: $table.eruptedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TeethRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeethRecordsTable,
          TeethRecord,
          $$TeethRecordsTableFilterComposer,
          $$TeethRecordsTableOrderingComposer,
          $$TeethRecordsTableAnnotationComposer,
          $$TeethRecordsTableCreateCompanionBuilder,
          $$TeethRecordsTableUpdateCompanionBuilder,
          (
            TeethRecord,
            BaseReferences<_$AppDatabase, $TeethRecordsTable, TeethRecord>,
          ),
          TeethRecord,
          PrefetchHooks Function()
        > {
  $$TeethRecordsTableTableManager(_$AppDatabase db, $TeethRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeethRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeethRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeethRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> babyId = const Value.absent(),
                Value<String> toothPosition = const Value.absent(),
                Value<DateTime> eruptedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TeethRecordsCompanion(
                id: id,
                babyId: babyId,
                toothPosition: toothPosition,
                eruptedAt: eruptedAt,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int babyId,
                required String toothPosition,
                required DateTime eruptedAt,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TeethRecordsCompanion.insert(
                id: id,
                babyId: babyId,
                toothPosition: toothPosition,
                eruptedAt: eruptedAt,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeethRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeethRecordsTable,
      TeethRecord,
      $$TeethRecordsTableFilterComposer,
      $$TeethRecordsTableOrderingComposer,
      $$TeethRecordsTableAnnotationComposer,
      $$TeethRecordsTableCreateCompanionBuilder,
      $$TeethRecordsTableUpdateCompanionBuilder,
      (
        TeethRecord,
        BaseReferences<_$AppDatabase, $TeethRecordsTable, TeethRecord>,
      ),
      TeethRecord,
      PrefetchHooks Function()
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      required int babyId,
      required String role,
      required String content,
      Value<String?> contextData,
      Value<DateTime> createdAt,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      Value<int> babyId,
      Value<String> role,
      Value<String> content,
      Value<String?> contextData,
      Value<DateTime> createdAt,
    });

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
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

  ColumnFilters<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextData => $composableBuilder(
    column: $table.contextData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
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

  ColumnOrderings<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextData => $composableBuilder(
    column: $table.contextData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get babyId =>
      $composableBuilder(column: $table.babyId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get contextData => $composableBuilder(
    column: $table.contextData,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (
            ChatMessage,
            BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>,
          ),
          ChatMessage,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> babyId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> contextData = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                babyId: babyId,
                role: role,
                content: content,
                contextData: contextData,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int babyId,
                required String role,
                required String content,
                Value<String?> contextData = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                babyId: babyId,
                role: role,
                content: content,
                contextData: contextData,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (
        ChatMessage,
        BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>,
      ),
      ChatMessage,
      PrefetchHooks Function()
    >;
typedef $$MediaEntriesTableCreateCompanionBuilder =
    MediaEntriesCompanion Function({
      Value<int> id,
      required int babyId,
      required String type,
      required String storagePath,
      Value<String?> thumbnailPath,
      Value<String?> caption,
      Value<DateTime?> takenAt,
      Value<String?> linkedRecordType,
      Value<int?> linkedRecordId,
      Value<DateTime> createdAt,
    });
typedef $$MediaEntriesTableUpdateCompanionBuilder =
    MediaEntriesCompanion Function({
      Value<int> id,
      Value<int> babyId,
      Value<String> type,
      Value<String> storagePath,
      Value<String?> thumbnailPath,
      Value<String?> caption,
      Value<DateTime?> takenAt,
      Value<String?> linkedRecordType,
      Value<int?> linkedRecordId,
      Value<DateTime> createdAt,
    });

class $$MediaEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MediaEntriesTable> {
  $$MediaEntriesTableFilterComposer({
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

  ColumnFilters<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedRecordType => $composableBuilder(
    column: $table.linkedRecordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedRecordId => $composableBuilder(
    column: $table.linkedRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaEntriesTable> {
  $$MediaEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedRecordType => $composableBuilder(
    column: $table.linkedRecordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedRecordId => $composableBuilder(
    column: $table.linkedRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaEntriesTable> {
  $$MediaEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get babyId =>
      $composableBuilder(column: $table.babyId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get linkedRecordType => $composableBuilder(
    column: $table.linkedRecordType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get linkedRecordId => $composableBuilder(
    column: $table.linkedRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MediaEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaEntriesTable,
          MediaEntry,
          $$MediaEntriesTableFilterComposer,
          $$MediaEntriesTableOrderingComposer,
          $$MediaEntriesTableAnnotationComposer,
          $$MediaEntriesTableCreateCompanionBuilder,
          $$MediaEntriesTableUpdateCompanionBuilder,
          (
            MediaEntry,
            BaseReferences<_$AppDatabase, $MediaEntriesTable, MediaEntry>,
          ),
          MediaEntry,
          PrefetchHooks Function()
        > {
  $$MediaEntriesTableTableManager(_$AppDatabase db, $MediaEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> babyId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> storagePath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<DateTime?> takenAt = const Value.absent(),
                Value<String?> linkedRecordType = const Value.absent(),
                Value<int?> linkedRecordId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MediaEntriesCompanion(
                id: id,
                babyId: babyId,
                type: type,
                storagePath: storagePath,
                thumbnailPath: thumbnailPath,
                caption: caption,
                takenAt: takenAt,
                linkedRecordType: linkedRecordType,
                linkedRecordId: linkedRecordId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int babyId,
                required String type,
                required String storagePath,
                Value<String?> thumbnailPath = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<DateTime?> takenAt = const Value.absent(),
                Value<String?> linkedRecordType = const Value.absent(),
                Value<int?> linkedRecordId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MediaEntriesCompanion.insert(
                id: id,
                babyId: babyId,
                type: type,
                storagePath: storagePath,
                thumbnailPath: thumbnailPath,
                caption: caption,
                takenAt: takenAt,
                linkedRecordType: linkedRecordType,
                linkedRecordId: linkedRecordId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaEntriesTable,
      MediaEntry,
      $$MediaEntriesTableFilterComposer,
      $$MediaEntriesTableOrderingComposer,
      $$MediaEntriesTableAnnotationComposer,
      $$MediaEntriesTableCreateCompanionBuilder,
      $$MediaEntriesTableUpdateCompanionBuilder,
      (
        MediaEntry,
        BaseReferences<_$AppDatabase, $MediaEntriesTable, MediaEntry>,
      ),
      MediaEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BabiesTableTableManager get babies =>
      $$BabiesTableTableManager(_db, _db.babies);
  $$GrowthRecordsTableTableManager get growthRecords =>
      $$GrowthRecordsTableTableManager(_db, _db.growthRecords);
  $$DailyLogsTableTableManager get dailyLogs =>
      $$DailyLogsTableTableManager(_db, _db.dailyLogs);
  $$NotificationSettingsTableTableManager get notificationSettings =>
      $$NotificationSettingsTableTableManager(_db, _db.notificationSettings);
  $$MilestonesTableTableManager get milestones =>
      $$MilestonesTableTableManager(_db, _db.milestones);
  $$VaccinationsTableTableManager get vaccinations =>
      $$VaccinationsTableTableManager(_db, _db.vaccinations);
  $$HealthEventsTableTableManager get healthEvents =>
      $$HealthEventsTableTableManager(_db, _db.healthEvents);
  $$FoodIntroductionsTableTableManager get foodIntroductions =>
      $$FoodIntroductionsTableTableManager(_db, _db.foodIntroductions);
  $$TeethRecordsTableTableManager get teethRecords =>
      $$TeethRecordsTableTableManager(_db, _db.teethRecords);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$MediaEntriesTableTableManager get mediaEntries =>
      $$MediaEntriesTableTableManager(_db, _db.mediaEntries);
}
