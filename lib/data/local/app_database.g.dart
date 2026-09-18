// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalStudentsTable extends LocalStudents
    with TableInfo<$LocalStudentsTable, LocalStudentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalStudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pseudoCodeMeta = const VerificationMeta(
    'pseudoCode',
  );
  @override
  late final GeneratedColumn<String> pseudoCode = GeneratedColumn<String>(
    'pseudo_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupLabelMeta = const VerificationMeta(
    'groupLabel',
  );
  @override
  late final GeneratedColumn<String> groupLabel = GeneratedColumn<String>(
    'group_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstLanguageMeta = const VerificationMeta(
    'firstLanguage',
  );
  @override
  late final GeneratedColumn<String> firstLanguage = GeneratedColumn<String>(
    'first_language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flscoLevelMeta = const VerificationMeta(
    'flscoLevel',
  );
  @override
  late final GeneratedColumn<int> flscoLevel = GeneratedColumn<int>(
    'flsco_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lastName,
    firstName,
    displayName,
    pseudoCode,
    groupLabel,
    firstLanguage,
    flscoLevel,
    notes,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_students';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalStudentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('pseudo_code')) {
      context.handle(
        _pseudoCodeMeta,
        pseudoCode.isAcceptableOrUnknown(data['pseudo_code']!, _pseudoCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_pseudoCodeMeta);
    }
    if (data.containsKey('group_label')) {
      context.handle(
        _groupLabelMeta,
        groupLabel.isAcceptableOrUnknown(data['group_label']!, _groupLabelMeta),
      );
    }
    if (data.containsKey('first_language')) {
      context.handle(
        _firstLanguageMeta,
        firstLanguage.isAcceptableOrUnknown(
          data['first_language']!,
          _firstLanguageMeta,
        ),
      );
    }
    if (data.containsKey('flsco_level')) {
      context.handle(
        _flscoLevelMeta,
        flscoLevel.isAcceptableOrUnknown(data['flsco_level']!, _flscoLevelMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalStudentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalStudentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      pseudoCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pseudo_code'],
      )!,
      groupLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_label'],
      ),
      firstLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_language'],
      ),
      flscoLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flsco_level'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $LocalStudentsTable createAlias(String alias) {
    return $LocalStudentsTable(attachedDatabase, alias);
  }
}

class LocalStudentRow extends DataClass implements Insertable<LocalStudentRow> {
  final String id;
  final String lastName;
  final String firstName;
  final String displayName;
  final String pseudoCode;
  final String? groupLabel;
  final String? firstLanguage;
  final int? flscoLevel;
  final String? notes;
  final bool isActive;
  const LocalStudentRow({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.displayName,
    required this.pseudoCode,
    this.groupLabel,
    this.firstLanguage,
    this.flscoLevel,
    this.notes,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['last_name'] = Variable<String>(lastName);
    map['first_name'] = Variable<String>(firstName);
    map['display_name'] = Variable<String>(displayName);
    map['pseudo_code'] = Variable<String>(pseudoCode);
    if (!nullToAbsent || groupLabel != null) {
      map['group_label'] = Variable<String>(groupLabel);
    }
    if (!nullToAbsent || firstLanguage != null) {
      map['first_language'] = Variable<String>(firstLanguage);
    }
    if (!nullToAbsent || flscoLevel != null) {
      map['flsco_level'] = Variable<int>(flscoLevel);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  LocalStudentsCompanion toCompanion(bool nullToAbsent) {
    return LocalStudentsCompanion(
      id: Value(id),
      lastName: Value(lastName),
      firstName: Value(firstName),
      displayName: Value(displayName),
      pseudoCode: Value(pseudoCode),
      groupLabel: groupLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(groupLabel),
      firstLanguage: firstLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(firstLanguage),
      flscoLevel: flscoLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(flscoLevel),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
    );
  }

  factory LocalStudentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalStudentRow(
      id: serializer.fromJson<String>(json['id']),
      lastName: serializer.fromJson<String>(json['lastName']),
      firstName: serializer.fromJson<String>(json['firstName']),
      displayName: serializer.fromJson<String>(json['displayName']),
      pseudoCode: serializer.fromJson<String>(json['pseudoCode']),
      groupLabel: serializer.fromJson<String?>(json['groupLabel']),
      firstLanguage: serializer.fromJson<String?>(json['firstLanguage']),
      flscoLevel: serializer.fromJson<int?>(json['flscoLevel']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lastName': serializer.toJson<String>(lastName),
      'firstName': serializer.toJson<String>(firstName),
      'displayName': serializer.toJson<String>(displayName),
      'pseudoCode': serializer.toJson<String>(pseudoCode),
      'groupLabel': serializer.toJson<String?>(groupLabel),
      'firstLanguage': serializer.toJson<String?>(firstLanguage),
      'flscoLevel': serializer.toJson<int?>(flscoLevel),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  LocalStudentRow copyWith({
    String? id,
    String? lastName,
    String? firstName,
    String? displayName,
    String? pseudoCode,
    Value<String?> groupLabel = const Value.absent(),
    Value<String?> firstLanguage = const Value.absent(),
    Value<int?> flscoLevel = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isActive,
  }) => LocalStudentRow(
    id: id ?? this.id,
    lastName: lastName ?? this.lastName,
    firstName: firstName ?? this.firstName,
    displayName: displayName ?? this.displayName,
    pseudoCode: pseudoCode ?? this.pseudoCode,
    groupLabel: groupLabel.present ? groupLabel.value : this.groupLabel,
    firstLanguage: firstLanguage.present
        ? firstLanguage.value
        : this.firstLanguage,
    flscoLevel: flscoLevel.present ? flscoLevel.value : this.flscoLevel,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
  );
  LocalStudentRow copyWithCompanion(LocalStudentsCompanion data) {
    return LocalStudentRow(
      id: data.id.present ? data.id.value : this.id,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      pseudoCode: data.pseudoCode.present
          ? data.pseudoCode.value
          : this.pseudoCode,
      groupLabel: data.groupLabel.present
          ? data.groupLabel.value
          : this.groupLabel,
      firstLanguage: data.firstLanguage.present
          ? data.firstLanguage.value
          : this.firstLanguage,
      flscoLevel: data.flscoLevel.present
          ? data.flscoLevel.value
          : this.flscoLevel,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudentRow(')
          ..write('id: $id, ')
          ..write('lastName: $lastName, ')
          ..write('firstName: $firstName, ')
          ..write('displayName: $displayName, ')
          ..write('pseudoCode: $pseudoCode, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('firstLanguage: $firstLanguage, ')
          ..write('flscoLevel: $flscoLevel, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lastName,
    firstName,
    displayName,
    pseudoCode,
    groupLabel,
    firstLanguage,
    flscoLevel,
    notes,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalStudentRow &&
          other.id == this.id &&
          other.lastName == this.lastName &&
          other.firstName == this.firstName &&
          other.displayName == this.displayName &&
          other.pseudoCode == this.pseudoCode &&
          other.groupLabel == this.groupLabel &&
          other.firstLanguage == this.firstLanguage &&
          other.flscoLevel == this.flscoLevel &&
          other.notes == this.notes &&
          other.isActive == this.isActive);
}

class LocalStudentsCompanion extends UpdateCompanion<LocalStudentRow> {
  final Value<String> id;
  final Value<String> lastName;
  final Value<String> firstName;
  final Value<String> displayName;
  final Value<String> pseudoCode;
  final Value<String?> groupLabel;
  final Value<String?> firstLanguage;
  final Value<int?> flscoLevel;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<int> rowid;
  const LocalStudentsCompanion({
    this.id = const Value.absent(),
    this.lastName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.displayName = const Value.absent(),
    this.pseudoCode = const Value.absent(),
    this.groupLabel = const Value.absent(),
    this.firstLanguage = const Value.absent(),
    this.flscoLevel = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalStudentsCompanion.insert({
    required String id,
    required String lastName,
    required String firstName,
    required String displayName,
    required String pseudoCode,
    this.groupLabel = const Value.absent(),
    this.firstLanguage = const Value.absent(),
    this.flscoLevel = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lastName = Value(lastName),
       firstName = Value(firstName),
       displayName = Value(displayName),
       pseudoCode = Value(pseudoCode);
  static Insertable<LocalStudentRow> custom({
    Expression<String>? id,
    Expression<String>? lastName,
    Expression<String>? firstName,
    Expression<String>? displayName,
    Expression<String>? pseudoCode,
    Expression<String>? groupLabel,
    Expression<String>? firstLanguage,
    Expression<int>? flscoLevel,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastName != null) 'last_name': lastName,
      if (firstName != null) 'first_name': firstName,
      if (displayName != null) 'display_name': displayName,
      if (pseudoCode != null) 'pseudo_code': pseudoCode,
      if (groupLabel != null) 'group_label': groupLabel,
      if (firstLanguage != null) 'first_language': firstLanguage,
      if (flscoLevel != null) 'flsco_level': flscoLevel,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalStudentsCompanion copyWith({
    Value<String>? id,
    Value<String>? lastName,
    Value<String>? firstName,
    Value<String>? displayName,
    Value<String>? pseudoCode,
    Value<String?>? groupLabel,
    Value<String?>? firstLanguage,
    Value<int?>? flscoLevel,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return LocalStudentsCompanion(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      displayName: displayName ?? this.displayName,
      pseudoCode: pseudoCode ?? this.pseudoCode,
      groupLabel: groupLabel ?? this.groupLabel,
      firstLanguage: firstLanguage ?? this.firstLanguage,
      flscoLevel: flscoLevel ?? this.flscoLevel,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (pseudoCode.present) {
      map['pseudo_code'] = Variable<String>(pseudoCode.value);
    }
    if (groupLabel.present) {
      map['group_label'] = Variable<String>(groupLabel.value);
    }
    if (firstLanguage.present) {
      map['first_language'] = Variable<String>(firstLanguage.value);
    }
    if (flscoLevel.present) {
      map['flsco_level'] = Variable<int>(flscoLevel.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudentsCompanion(')
          ..write('id: $id, ')
          ..write('lastName: $lastName, ')
          ..write('firstName: $firstName, ')
          ..write('displayName: $displayName, ')
          ..write('pseudoCode: $pseudoCode, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('firstLanguage: $firstLanguage, ')
          ..write('flscoLevel: $flscoLevel, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAttendanceTable extends LocalAttendance
    with TableInfo<$LocalAttendanceTable, LocalAttendanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAttendanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _halfDayMeta = const VerificationMeta(
    'halfDay',
  );
  @override
  late final GeneratedColumn<String> halfDay = GeneratedColumn<String>(
    'half_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    studentId,
    date,
    halfDay,
    status,
    reason,
    dirty,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_attendance';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAttendanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('half_day')) {
      context.handle(
        _halfDayMeta,
        halfDay.isAcceptableOrUnknown(data['half_day']!, _halfDayMeta),
      );
    } else if (isInserting) {
      context.missing(_halfDayMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {studentId, date, halfDay};
  @override
  LocalAttendanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAttendanceRow(
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      halfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}half_day'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalAttendanceTable createAlias(String alias) {
    return $LocalAttendanceTable(attachedDatabase, alias);
  }
}

class LocalAttendanceRow extends DataClass
    implements Insertable<LocalAttendanceRow> {
  final String studentId;
  final String date;
  final String halfDay;
  final String status;
  final String? reason;
  final bool dirty;
  final DateTime updatedAt;
  const LocalAttendanceRow({
    required this.studentId,
    required this.date,
    required this.halfDay,
    required this.status,
    this.reason,
    required this.dirty,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['student_id'] = Variable<String>(studentId);
    map['date'] = Variable<String>(date);
    map['half_day'] = Variable<String>(halfDay);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['dirty'] = Variable<bool>(dirty);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalAttendanceCompanion toCompanion(bool nullToAbsent) {
    return LocalAttendanceCompanion(
      studentId: Value(studentId),
      date: Value(date),
      halfDay: Value(halfDay),
      status: Value(status),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      dirty: Value(dirty),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalAttendanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAttendanceRow(
      studentId: serializer.fromJson<String>(json['studentId']),
      date: serializer.fromJson<String>(json['date']),
      halfDay: serializer.fromJson<String>(json['halfDay']),
      status: serializer.fromJson<String>(json['status']),
      reason: serializer.fromJson<String?>(json['reason']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'studentId': serializer.toJson<String>(studentId),
      'date': serializer.toJson<String>(date),
      'halfDay': serializer.toJson<String>(halfDay),
      'status': serializer.toJson<String>(status),
      'reason': serializer.toJson<String?>(reason),
      'dirty': serializer.toJson<bool>(dirty),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalAttendanceRow copyWith({
    String? studentId,
    String? date,
    String? halfDay,
    String? status,
    Value<String?> reason = const Value.absent(),
    bool? dirty,
    DateTime? updatedAt,
  }) => LocalAttendanceRow(
    studentId: studentId ?? this.studentId,
    date: date ?? this.date,
    halfDay: halfDay ?? this.halfDay,
    status: status ?? this.status,
    reason: reason.present ? reason.value : this.reason,
    dirty: dirty ?? this.dirty,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalAttendanceRow copyWithCompanion(LocalAttendanceCompanion data) {
    return LocalAttendanceRow(
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      date: data.date.present ? data.date.value : this.date,
      halfDay: data.halfDay.present ? data.halfDay.value : this.halfDay,
      status: data.status.present ? data.status.value : this.status,
      reason: data.reason.present ? data.reason.value : this.reason,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttendanceRow(')
          ..write('studentId: $studentId, ')
          ..write('date: $date, ')
          ..write('halfDay: $halfDay, ')
          ..write('status: $status, ')
          ..write('reason: $reason, ')
          ..write('dirty: $dirty, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(studentId, date, halfDay, status, reason, dirty, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAttendanceRow &&
          other.studentId == this.studentId &&
          other.date == this.date &&
          other.halfDay == this.halfDay &&
          other.status == this.status &&
          other.reason == this.reason &&
          other.dirty == this.dirty &&
          other.updatedAt == this.updatedAt);
}

class LocalAttendanceCompanion extends UpdateCompanion<LocalAttendanceRow> {
  final Value<String> studentId;
  final Value<String> date;
  final Value<String> halfDay;
  final Value<String> status;
  final Value<String?> reason;
  final Value<bool> dirty;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalAttendanceCompanion({
    this.studentId = const Value.absent(),
    this.date = const Value.absent(),
    this.halfDay = const Value.absent(),
    this.status = const Value.absent(),
    this.reason = const Value.absent(),
    this.dirty = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAttendanceCompanion.insert({
    required String studentId,
    required String date,
    required String halfDay,
    required String status,
    this.reason = const Value.absent(),
    this.dirty = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : studentId = Value(studentId),
       date = Value(date),
       halfDay = Value(halfDay),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<LocalAttendanceRow> custom({
    Expression<String>? studentId,
    Expression<String>? date,
    Expression<String>? halfDay,
    Expression<String>? status,
    Expression<String>? reason,
    Expression<bool>? dirty,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (studentId != null) 'student_id': studentId,
      if (date != null) 'date': date,
      if (halfDay != null) 'half_day': halfDay,
      if (status != null) 'status': status,
      if (reason != null) 'reason': reason,
      if (dirty != null) 'dirty': dirty,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAttendanceCompanion copyWith({
    Value<String>? studentId,
    Value<String>? date,
    Value<String>? halfDay,
    Value<String>? status,
    Value<String?>? reason,
    Value<bool>? dirty,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalAttendanceCompanion(
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      halfDay: halfDay ?? this.halfDay,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      dirty: dirty ?? this.dirty,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (halfDay.present) {
      map['half_day'] = Variable<String>(halfDay.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttendanceCompanion(')
          ..write('studentId: $studentId, ')
          ..write('date: $date, ')
          ..write('halfDay: $halfDay, ')
          ..write('status: $status, ')
          ..write('reason: $reason, ')
          ..write('dirty: $dirty, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalObservationsTable extends LocalObservations
    with TableInfo<$LocalObservationsTable, LocalObservationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalObservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentIdsJsonMeta = const VerificationMeta(
    'studentIdsJson',
  );
  @override
  late final GeneratedColumn<String> studentIdsJson = GeneratedColumn<String>(
    'student_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    classId,
    date,
    occurredAt,
    type,
    severity,
    body,
    studentIdsJson,
    dirty,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_observations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalObservationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('student_ids_json')) {
      context.handle(
        _studentIdsJsonMeta,
        studentIdsJson.isAcceptableOrUnknown(
          data['student_ids_json']!,
          _studentIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studentIdsJsonMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalObservationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalObservationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}severity'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      studentIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_ids_json'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalObservationsTable createAlias(String alias) {
    return $LocalObservationsTable(attachedDatabase, alias);
  }
}

class LocalObservationRow extends DataClass
    implements Insertable<LocalObservationRow> {
  final String id;
  final String classId;
  final String date;
  final DateTime occurredAt;
  final String type;
  final int severity;
  final String? body;
  final String studentIdsJson;
  final bool dirty;
  final DateTime createdAt;
  const LocalObservationRow({
    required this.id,
    required this.classId,
    required this.date,
    required this.occurredAt,
    required this.type,
    required this.severity,
    this.body,
    required this.studentIdsJson,
    required this.dirty,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['class_id'] = Variable<String>(classId);
    map['date'] = Variable<String>(date);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['type'] = Variable<String>(type);
    map['severity'] = Variable<int>(severity);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    map['student_ids_json'] = Variable<String>(studentIdsJson);
    map['dirty'] = Variable<bool>(dirty);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalObservationsCompanion toCompanion(bool nullToAbsent) {
    return LocalObservationsCompanion(
      id: Value(id),
      classId: Value(classId),
      date: Value(date),
      occurredAt: Value(occurredAt),
      type: Value(type),
      severity: Value(severity),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      studentIdsJson: Value(studentIdsJson),
      dirty: Value(dirty),
      createdAt: Value(createdAt),
    );
  }

  factory LocalObservationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalObservationRow(
      id: serializer.fromJson<String>(json['id']),
      classId: serializer.fromJson<String>(json['classId']),
      date: serializer.fromJson<String>(json['date']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      type: serializer.fromJson<String>(json['type']),
      severity: serializer.fromJson<int>(json['severity']),
      body: serializer.fromJson<String?>(json['body']),
      studentIdsJson: serializer.fromJson<String>(json['studentIdsJson']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'classId': serializer.toJson<String>(classId),
      'date': serializer.toJson<String>(date),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'type': serializer.toJson<String>(type),
      'severity': serializer.toJson<int>(severity),
      'body': serializer.toJson<String?>(body),
      'studentIdsJson': serializer.toJson<String>(studentIdsJson),
      'dirty': serializer.toJson<bool>(dirty),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalObservationRow copyWith({
    String? id,
    String? classId,
    String? date,
    DateTime? occurredAt,
    String? type,
    int? severity,
    Value<String?> body = const Value.absent(),
    String? studentIdsJson,
    bool? dirty,
    DateTime? createdAt,
  }) => LocalObservationRow(
    id: id ?? this.id,
    classId: classId ?? this.classId,
    date: date ?? this.date,
    occurredAt: occurredAt ?? this.occurredAt,
    type: type ?? this.type,
    severity: severity ?? this.severity,
    body: body.present ? body.value : this.body,
    studentIdsJson: studentIdsJson ?? this.studentIdsJson,
    dirty: dirty ?? this.dirty,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalObservationRow copyWithCompanion(LocalObservationsCompanion data) {
    return LocalObservationRow(
      id: data.id.present ? data.id.value : this.id,
      classId: data.classId.present ? data.classId.value : this.classId,
      date: data.date.present ? data.date.value : this.date,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      type: data.type.present ? data.type.value : this.type,
      severity: data.severity.present ? data.severity.value : this.severity,
      body: data.body.present ? data.body.value : this.body,
      studentIdsJson: data.studentIdsJson.present
          ? data.studentIdsJson.value
          : this.studentIdsJson,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalObservationRow(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('date: $date, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('body: $body, ')
          ..write('studentIdsJson: $studentIdsJson, ')
          ..write('dirty: $dirty, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    classId,
    date,
    occurredAt,
    type,
    severity,
    body,
    studentIdsJson,
    dirty,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalObservationRow &&
          other.id == this.id &&
          other.classId == this.classId &&
          other.date == this.date &&
          other.occurredAt == this.occurredAt &&
          other.type == this.type &&
          other.severity == this.severity &&
          other.body == this.body &&
          other.studentIdsJson == this.studentIdsJson &&
          other.dirty == this.dirty &&
          other.createdAt == this.createdAt);
}

class LocalObservationsCompanion extends UpdateCompanion<LocalObservationRow> {
  final Value<String> id;
  final Value<String> classId;
  final Value<String> date;
  final Value<DateTime> occurredAt;
  final Value<String> type;
  final Value<int> severity;
  final Value<String?> body;
  final Value<String> studentIdsJson;
  final Value<bool> dirty;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalObservationsCompanion({
    this.id = const Value.absent(),
    this.classId = const Value.absent(),
    this.date = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.type = const Value.absent(),
    this.severity = const Value.absent(),
    this.body = const Value.absent(),
    this.studentIdsJson = const Value.absent(),
    this.dirty = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalObservationsCompanion.insert({
    required String id,
    required String classId,
    required String date,
    required DateTime occurredAt,
    required String type,
    required int severity,
    this.body = const Value.absent(),
    required String studentIdsJson,
    this.dirty = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       classId = Value(classId),
       date = Value(date),
       occurredAt = Value(occurredAt),
       type = Value(type),
       severity = Value(severity),
       studentIdsJson = Value(studentIdsJson),
       createdAt = Value(createdAt);
  static Insertable<LocalObservationRow> custom({
    Expression<String>? id,
    Expression<String>? classId,
    Expression<String>? date,
    Expression<DateTime>? occurredAt,
    Expression<String>? type,
    Expression<int>? severity,
    Expression<String>? body,
    Expression<String>? studentIdsJson,
    Expression<bool>? dirty,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classId != null) 'class_id': classId,
      if (date != null) 'date': date,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (type != null) 'type': type,
      if (severity != null) 'severity': severity,
      if (body != null) 'body': body,
      if (studentIdsJson != null) 'student_ids_json': studentIdsJson,
      if (dirty != null) 'dirty': dirty,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalObservationsCompanion copyWith({
    Value<String>? id,
    Value<String>? classId,
    Value<String>? date,
    Value<DateTime>? occurredAt,
    Value<String>? type,
    Value<int>? severity,
    Value<String?>? body,
    Value<String>? studentIdsJson,
    Value<bool>? dirty,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalObservationsCompanion(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      date: date ?? this.date,
      occurredAt: occurredAt ?? this.occurredAt,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      body: body ?? this.body,
      studentIdsJson: studentIdsJson ?? this.studentIdsJson,
      dirty: dirty ?? this.dirty,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (studentIdsJson.present) {
      map['student_ids_json'] = Variable<String>(studentIdsJson.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalObservationsCompanion(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('date: $date, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('body: $body, ')
          ..write('studentIdsJson: $studentIdsJson, ')
          ..write('dirty: $dirty, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalDailyReviewsTable extends LocalDailyReviews
    with TableInfo<$LocalDailyReviewsTable, LocalDailyReviewRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDailyReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<String> dayId = GeneratedColumn<String>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generalNotesMeta = const VerificationMeta(
    'generalNotes',
  );
  @override
  late final GeneratedColumn<String> generalNotes = GeneratedColumn<String>(
    'general_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [dayId, generalNotes, dirty, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_daily_reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDailyReviewRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('general_notes')) {
      context.handle(
        _generalNotesMeta,
        generalNotes.isAcceptableOrUnknown(
          data['general_notes']!,
          _generalNotesMeta,
        ),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayId};
  @override
  LocalDailyReviewRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDailyReviewRow(
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_id'],
      )!,
      generalNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}general_notes'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalDailyReviewsTable createAlias(String alias) {
    return $LocalDailyReviewsTable(attachedDatabase, alias);
  }
}

class LocalDailyReviewRow extends DataClass
    implements Insertable<LocalDailyReviewRow> {
  final String dayId;
  final String? generalNotes;
  final bool dirty;
  final DateTime updatedAt;
  const LocalDailyReviewRow({
    required this.dayId,
    this.generalNotes,
    required this.dirty,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_id'] = Variable<String>(dayId);
    if (!nullToAbsent || generalNotes != null) {
      map['general_notes'] = Variable<String>(generalNotes);
    }
    map['dirty'] = Variable<bool>(dirty);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalDailyReviewsCompanion toCompanion(bool nullToAbsent) {
    return LocalDailyReviewsCompanion(
      dayId: Value(dayId),
      generalNotes: generalNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(generalNotes),
      dirty: Value(dirty),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalDailyReviewRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDailyReviewRow(
      dayId: serializer.fromJson<String>(json['dayId']),
      generalNotes: serializer.fromJson<String?>(json['generalNotes']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayId': serializer.toJson<String>(dayId),
      'generalNotes': serializer.toJson<String?>(generalNotes),
      'dirty': serializer.toJson<bool>(dirty),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalDailyReviewRow copyWith({
    String? dayId,
    Value<String?> generalNotes = const Value.absent(),
    bool? dirty,
    DateTime? updatedAt,
  }) => LocalDailyReviewRow(
    dayId: dayId ?? this.dayId,
    generalNotes: generalNotes.present ? generalNotes.value : this.generalNotes,
    dirty: dirty ?? this.dirty,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalDailyReviewRow copyWithCompanion(LocalDailyReviewsCompanion data) {
    return LocalDailyReviewRow(
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      generalNotes: data.generalNotes.present
          ? data.generalNotes.value
          : this.generalNotes,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDailyReviewRow(')
          ..write('dayId: $dayId, ')
          ..write('generalNotes: $generalNotes, ')
          ..write('dirty: $dirty, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dayId, generalNotes, dirty, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDailyReviewRow &&
          other.dayId == this.dayId &&
          other.generalNotes == this.generalNotes &&
          other.dirty == this.dirty &&
          other.updatedAt == this.updatedAt);
}

class LocalDailyReviewsCompanion extends UpdateCompanion<LocalDailyReviewRow> {
  final Value<String> dayId;
  final Value<String?> generalNotes;
  final Value<bool> dirty;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalDailyReviewsCompanion({
    this.dayId = const Value.absent(),
    this.generalNotes = const Value.absent(),
    this.dirty = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDailyReviewsCompanion.insert({
    required String dayId,
    this.generalNotes = const Value.absent(),
    this.dirty = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : dayId = Value(dayId),
       updatedAt = Value(updatedAt);
  static Insertable<LocalDailyReviewRow> custom({
    Expression<String>? dayId,
    Expression<String>? generalNotes,
    Expression<bool>? dirty,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayId != null) 'day_id': dayId,
      if (generalNotes != null) 'general_notes': generalNotes,
      if (dirty != null) 'dirty': dirty,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDailyReviewsCompanion copyWith({
    Value<String>? dayId,
    Value<String?>? generalNotes,
    Value<bool>? dirty,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalDailyReviewsCompanion(
      dayId: dayId ?? this.dayId,
      generalNotes: generalNotes ?? this.generalNotes,
      dirty: dirty ?? this.dirty,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayId.present) {
      map['day_id'] = Variable<String>(dayId.value);
    }
    if (generalNotes.present) {
      map['general_notes'] = Variable<String>(generalNotes.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDailyReviewsCompanion(')
          ..write('dayId: $dayId, ')
          ..write('generalNotes: $generalNotes, ')
          ..write('dirty: $dirty, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalDailyReviewEntriesTable extends LocalDailyReviewEntries
    with TableInfo<$LocalDailyReviewEntriesTable, LocalDailyReviewEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDailyReviewEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<String> dayId = GeneratedColumn<String>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
    'journal_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    dayId,
    journalEntryId,
    status,
    notes,
    dirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_daily_review_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDailyReviewEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_journalEntryIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayId, journalEntryId};
  @override
  LocalDailyReviewEntryRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDailyReviewEntryRow(
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_id'],
      )!,
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_entry_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
    );
  }

  @override
  $LocalDailyReviewEntriesTable createAlias(String alias) {
    return $LocalDailyReviewEntriesTable(attachedDatabase, alias);
  }
}

class LocalDailyReviewEntryRow extends DataClass
    implements Insertable<LocalDailyReviewEntryRow> {
  final String dayId;
  final String journalEntryId;
  final String status;
  final String? notes;
  final bool dirty;
  const LocalDailyReviewEntryRow({
    required this.dayId,
    required this.journalEntryId,
    required this.status,
    this.notes,
    required this.dirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_id'] = Variable<String>(dayId);
    map['journal_entry_id'] = Variable<String>(journalEntryId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  LocalDailyReviewEntriesCompanion toCompanion(bool nullToAbsent) {
    return LocalDailyReviewEntriesCompanion(
      dayId: Value(dayId),
      journalEntryId: Value(journalEntryId),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      dirty: Value(dirty),
    );
  }

  factory LocalDailyReviewEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDailyReviewEntryRow(
      dayId: serializer.fromJson<String>(json['dayId']),
      journalEntryId: serializer.fromJson<String>(json['journalEntryId']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayId': serializer.toJson<String>(dayId),
      'journalEntryId': serializer.toJson<String>(journalEntryId),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  LocalDailyReviewEntryRow copyWith({
    String? dayId,
    String? journalEntryId,
    String? status,
    Value<String?> notes = const Value.absent(),
    bool? dirty,
  }) => LocalDailyReviewEntryRow(
    dayId: dayId ?? this.dayId,
    journalEntryId: journalEntryId ?? this.journalEntryId,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    dirty: dirty ?? this.dirty,
  );
  LocalDailyReviewEntryRow copyWithCompanion(
    LocalDailyReviewEntriesCompanion data,
  ) {
    return LocalDailyReviewEntryRow(
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDailyReviewEntryRow(')
          ..write('dayId: $dayId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dayId, journalEntryId, status, notes, dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDailyReviewEntryRow &&
          other.dayId == this.dayId &&
          other.journalEntryId == this.journalEntryId &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.dirty == this.dirty);
}

class LocalDailyReviewEntriesCompanion
    extends UpdateCompanion<LocalDailyReviewEntryRow> {
  final Value<String> dayId;
  final Value<String> journalEntryId;
  final Value<String> status;
  final Value<String?> notes;
  final Value<bool> dirty;
  final Value<int> rowid;
  const LocalDailyReviewEntriesCompanion({
    this.dayId = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDailyReviewEntriesCompanion.insert({
    required String dayId,
    required String journalEntryId,
    required String status,
    this.notes = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dayId = Value(dayId),
       journalEntryId = Value(journalEntryId),
       status = Value(status);
  static Insertable<LocalDailyReviewEntryRow> custom({
    Expression<String>? dayId,
    Expression<String>? journalEntryId,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<bool>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayId != null) 'day_id': dayId,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDailyReviewEntriesCompanion copyWith({
    Value<String>? dayId,
    Value<String>? journalEntryId,
    Value<String>? status,
    Value<String?>? notes,
    Value<bool>? dirty,
    Value<int>? rowid,
  }) {
    return LocalDailyReviewEntriesCompanion(
      dayId: dayId ?? this.dayId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayId.present) {
      map['day_id'] = Variable<String>(dayId.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDailyReviewEntriesCompanion(')
          ..write('dayId: $dayId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMetaTable extends LocalMeta
    with TableInfo<$LocalMetaTable, LocalMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $LocalMetaTable createAlias(String alias) {
    return $LocalMetaTable(attachedDatabase, alias);
  }
}

class LocalMetaRow extends DataClass implements Insertable<LocalMetaRow> {
  final String key;
  final String value;
  const LocalMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  LocalMetaCompanion toCompanion(bool nullToAbsent) {
    return LocalMetaCompanion(key: Value(key), value: Value(value));
  }

  factory LocalMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  LocalMetaRow copyWith({String? key, String? value}) =>
      LocalMetaRow(key: key ?? this.key, value: value ?? this.value);
  LocalMetaRow copyWithCompanion(LocalMetaCompanion data) {
    return LocalMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class LocalMetaCompanion extends UpdateCompanion<LocalMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const LocalMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<LocalMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return LocalMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalStudentsTable localStudents = $LocalStudentsTable(this);
  late final $LocalAttendanceTable localAttendance = $LocalAttendanceTable(
    this,
  );
  late final $LocalObservationsTable localObservations =
      $LocalObservationsTable(this);
  late final $LocalDailyReviewsTable localDailyReviews =
      $LocalDailyReviewsTable(this);
  late final $LocalDailyReviewEntriesTable localDailyReviewEntries =
      $LocalDailyReviewEntriesTable(this);
  late final $LocalMetaTable localMeta = $LocalMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localStudents,
    localAttendance,
    localObservations,
    localDailyReviews,
    localDailyReviewEntries,
    localMeta,
  ];
}

typedef $$LocalStudentsTableCreateCompanionBuilder =
    LocalStudentsCompanion Function({
      required String id,
      required String lastName,
      required String firstName,
      required String displayName,
      required String pseudoCode,
      Value<String?> groupLabel,
      Value<String?> firstLanguage,
      Value<int?> flscoLevel,
      Value<String?> notes,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$LocalStudentsTableUpdateCompanionBuilder =
    LocalStudentsCompanion Function({
      Value<String> id,
      Value<String> lastName,
      Value<String> firstName,
      Value<String> displayName,
      Value<String> pseudoCode,
      Value<String?> groupLabel,
      Value<String?> firstLanguage,
      Value<int?> flscoLevel,
      Value<String?> notes,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$LocalStudentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableFilterComposer({
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

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pseudoCode => $composableBuilder(
    column: $table.pseudoCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstLanguage => $composableBuilder(
    column: $table.firstLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flscoLevel => $composableBuilder(
    column: $table.flscoLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalStudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableOrderingComposer({
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

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pseudoCode => $composableBuilder(
    column: $table.pseudoCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstLanguage => $composableBuilder(
    column: $table.firstLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flscoLevel => $composableBuilder(
    column: $table.flscoLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalStudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pseudoCode => $composableBuilder(
    column: $table.pseudoCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstLanguage => $composableBuilder(
    column: $table.firstLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get flscoLevel => $composableBuilder(
    column: $table.flscoLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$LocalStudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalStudentsTable,
          LocalStudentRow,
          $$LocalStudentsTableFilterComposer,
          $$LocalStudentsTableOrderingComposer,
          $$LocalStudentsTableAnnotationComposer,
          $$LocalStudentsTableCreateCompanionBuilder,
          $$LocalStudentsTableUpdateCompanionBuilder,
          (
            LocalStudentRow,
            BaseReferences<_$AppDatabase, $LocalStudentsTable, LocalStudentRow>,
          ),
          LocalStudentRow,
          PrefetchHooks Function()
        > {
  $$LocalStudentsTableTableManager(_$AppDatabase db, $LocalStudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalStudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalStudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalStudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> pseudoCode = const Value.absent(),
                Value<String?> groupLabel = const Value.absent(),
                Value<String?> firstLanguage = const Value.absent(),
                Value<int?> flscoLevel = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalStudentsCompanion(
                id: id,
                lastName: lastName,
                firstName: firstName,
                displayName: displayName,
                pseudoCode: pseudoCode,
                groupLabel: groupLabel,
                firstLanguage: firstLanguage,
                flscoLevel: flscoLevel,
                notes: notes,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lastName,
                required String firstName,
                required String displayName,
                required String pseudoCode,
                Value<String?> groupLabel = const Value.absent(),
                Value<String?> firstLanguage = const Value.absent(),
                Value<int?> flscoLevel = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalStudentsCompanion.insert(
                id: id,
                lastName: lastName,
                firstName: firstName,
                displayName: displayName,
                pseudoCode: pseudoCode,
                groupLabel: groupLabel,
                firstLanguage: firstLanguage,
                flscoLevel: flscoLevel,
                notes: notes,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalStudentsTable, LocalStudentRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalStudentsTable,
                    LocalStudentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalStudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalStudentsTable,
      LocalStudentRow,
      $$LocalStudentsTableFilterComposer,
      $$LocalStudentsTableOrderingComposer,
      $$LocalStudentsTableAnnotationComposer,
      $$LocalStudentsTableCreateCompanionBuilder,
      $$LocalStudentsTableUpdateCompanionBuilder,
      (
        LocalStudentRow,
        BaseReferences<_$AppDatabase, $LocalStudentsTable, LocalStudentRow>,
      ),
      LocalStudentRow,
      PrefetchHooks Function()
    >;
typedef $$LocalAttendanceTableCreateCompanionBuilder =
    LocalAttendanceCompanion Function({
      required String studentId,
      required String date,
      required String halfDay,
      required String status,
      Value<String?> reason,
      Value<bool> dirty,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalAttendanceTableUpdateCompanionBuilder =
    LocalAttendanceCompanion Function({
      Value<String> studentId,
      Value<String> date,
      Value<String> halfDay,
      Value<String> status,
      Value<String?> reason,
      Value<bool> dirty,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalAttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAttendanceTable> {
  $$LocalAttendanceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get halfDay => $composableBuilder(
    column: $table.halfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAttendanceTable> {
  $$LocalAttendanceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get halfDay => $composableBuilder(
    column: $table.halfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAttendanceTable> {
  $$LocalAttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get halfDay =>
      $composableBuilder(column: $table.halfDay, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalAttendanceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAttendanceTable,
          LocalAttendanceRow,
          $$LocalAttendanceTableFilterComposer,
          $$LocalAttendanceTableOrderingComposer,
          $$LocalAttendanceTableAnnotationComposer,
          $$LocalAttendanceTableCreateCompanionBuilder,
          $$LocalAttendanceTableUpdateCompanionBuilder,
          (
            LocalAttendanceRow,
            BaseReferences<
              _$AppDatabase,
              $LocalAttendanceTable,
              LocalAttendanceRow
            >,
          ),
          LocalAttendanceRow,
          PrefetchHooks Function()
        > {
  $$LocalAttendanceTableTableManager(
    _$AppDatabase db,
    $LocalAttendanceTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAttendanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAttendanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAttendanceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> studentId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> halfDay = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAttendanceCompanion(
                studentId: studentId,
                date: date,
                halfDay: halfDay,
                status: status,
                reason: reason,
                dirty: dirty,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String studentId,
                required String date,
                required String halfDay,
                required String status,
                Value<String?> reason = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalAttendanceCompanion.insert(
                studentId: studentId,
                date: date,
                halfDay: halfDay,
                status: status,
                reason: reason,
                dirty: dirty,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalAttendanceTable, LocalAttendanceRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalAttendanceTable,
                    LocalAttendanceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAttendanceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAttendanceTable,
      LocalAttendanceRow,
      $$LocalAttendanceTableFilterComposer,
      $$LocalAttendanceTableOrderingComposer,
      $$LocalAttendanceTableAnnotationComposer,
      $$LocalAttendanceTableCreateCompanionBuilder,
      $$LocalAttendanceTableUpdateCompanionBuilder,
      (
        LocalAttendanceRow,
        BaseReferences<
          _$AppDatabase,
          $LocalAttendanceTable,
          LocalAttendanceRow
        >,
      ),
      LocalAttendanceRow,
      PrefetchHooks Function()
    >;
typedef $$LocalObservationsTableCreateCompanionBuilder =
    LocalObservationsCompanion Function({
      required String id,
      required String classId,
      required String date,
      required DateTime occurredAt,
      required String type,
      required int severity,
      Value<String?> body,
      required String studentIdsJson,
      Value<bool> dirty,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalObservationsTableUpdateCompanionBuilder =
    LocalObservationsCompanion Function({
      Value<String> id,
      Value<String> classId,
      Value<String> date,
      Value<DateTime> occurredAt,
      Value<String> type,
      Value<int> severity,
      Value<String?> body,
      Value<String> studentIdsJson,
      Value<bool> dirty,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalObservationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalObservationsTable> {
  $$LocalObservationsTableFilterComposer({
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

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentIdsJson => $composableBuilder(
    column: $table.studentIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalObservationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalObservationsTable> {
  $$LocalObservationsTableOrderingComposer({
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

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentIdsJson => $composableBuilder(
    column: $table.studentIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalObservationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalObservationsTable> {
  $$LocalObservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get studentIdsJson => $composableBuilder(
    column: $table.studentIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalObservationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalObservationsTable,
          LocalObservationRow,
          $$LocalObservationsTableFilterComposer,
          $$LocalObservationsTableOrderingComposer,
          $$LocalObservationsTableAnnotationComposer,
          $$LocalObservationsTableCreateCompanionBuilder,
          $$LocalObservationsTableUpdateCompanionBuilder,
          (
            LocalObservationRow,
            BaseReferences<
              _$AppDatabase,
              $LocalObservationsTable,
              LocalObservationRow
            >,
          ),
          LocalObservationRow,
          PrefetchHooks Function()
        > {
  $$LocalObservationsTableTableManager(
    _$AppDatabase db,
    $LocalObservationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalObservationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalObservationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalObservationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> classId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> severity = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String> studentIdsJson = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalObservationsCompanion(
                id: id,
                classId: classId,
                date: date,
                occurredAt: occurredAt,
                type: type,
                severity: severity,
                body: body,
                studentIdsJson: studentIdsJson,
                dirty: dirty,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String classId,
                required String date,
                required DateTime occurredAt,
                required String type,
                required int severity,
                Value<String?> body = const Value.absent(),
                required String studentIdsJson,
                Value<bool> dirty = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalObservationsCompanion.insert(
                id: id,
                classId: classId,
                date: date,
                occurredAt: occurredAt,
                type: type,
                severity: severity,
                body: body,
                studentIdsJson: studentIdsJson,
                dirty: dirty,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalObservationsTable, LocalObservationRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalObservationsTable,
                    LocalObservationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalObservationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalObservationsTable,
      LocalObservationRow,
      $$LocalObservationsTableFilterComposer,
      $$LocalObservationsTableOrderingComposer,
      $$LocalObservationsTableAnnotationComposer,
      $$LocalObservationsTableCreateCompanionBuilder,
      $$LocalObservationsTableUpdateCompanionBuilder,
      (
        LocalObservationRow,
        BaseReferences<
          _$AppDatabase,
          $LocalObservationsTable,
          LocalObservationRow
        >,
      ),
      LocalObservationRow,
      PrefetchHooks Function()
    >;
typedef $$LocalDailyReviewsTableCreateCompanionBuilder =
    LocalDailyReviewsCompanion Function({
      required String dayId,
      Value<String?> generalNotes,
      Value<bool> dirty,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalDailyReviewsTableUpdateCompanionBuilder =
    LocalDailyReviewsCompanion Function({
      Value<String> dayId,
      Value<String?> generalNotes,
      Value<bool> dirty,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalDailyReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDailyReviewsTable> {
  $$LocalDailyReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dayId => $composableBuilder(
    column: $table.dayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get generalNotes => $composableBuilder(
    column: $table.generalNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDailyReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDailyReviewsTable> {
  $$LocalDailyReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dayId => $composableBuilder(
    column: $table.dayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get generalNotes => $composableBuilder(
    column: $table.generalNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDailyReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDailyReviewsTable> {
  $$LocalDailyReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dayId =>
      $composableBuilder(column: $table.dayId, builder: (column) => column);

  GeneratedColumn<String> get generalNotes => $composableBuilder(
    column: $table.generalNotes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalDailyReviewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalDailyReviewsTable,
          LocalDailyReviewRow,
          $$LocalDailyReviewsTableFilterComposer,
          $$LocalDailyReviewsTableOrderingComposer,
          $$LocalDailyReviewsTableAnnotationComposer,
          $$LocalDailyReviewsTableCreateCompanionBuilder,
          $$LocalDailyReviewsTableUpdateCompanionBuilder,
          (
            LocalDailyReviewRow,
            BaseReferences<
              _$AppDatabase,
              $LocalDailyReviewsTable,
              LocalDailyReviewRow
            >,
          ),
          LocalDailyReviewRow,
          PrefetchHooks Function()
        > {
  $$LocalDailyReviewsTableTableManager(
    _$AppDatabase db,
    $LocalDailyReviewsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDailyReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDailyReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDailyReviewsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> dayId = const Value.absent(),
                Value<String?> generalNotes = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDailyReviewsCompanion(
                dayId: dayId,
                generalNotes: generalNotes,
                dirty: dirty,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dayId,
                Value<String?> generalNotes = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalDailyReviewsCompanion.insert(
                dayId: dayId,
                generalNotes: generalNotes,
                dirty: dirty,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalDailyReviewsTable, LocalDailyReviewRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalDailyReviewsTable,
                    LocalDailyReviewRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDailyReviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalDailyReviewsTable,
      LocalDailyReviewRow,
      $$LocalDailyReviewsTableFilterComposer,
      $$LocalDailyReviewsTableOrderingComposer,
      $$LocalDailyReviewsTableAnnotationComposer,
      $$LocalDailyReviewsTableCreateCompanionBuilder,
      $$LocalDailyReviewsTableUpdateCompanionBuilder,
      (
        LocalDailyReviewRow,
        BaseReferences<
          _$AppDatabase,
          $LocalDailyReviewsTable,
          LocalDailyReviewRow
        >,
      ),
      LocalDailyReviewRow,
      PrefetchHooks Function()
    >;
typedef $$LocalDailyReviewEntriesTableCreateCompanionBuilder =
    LocalDailyReviewEntriesCompanion Function({
      required String dayId,
      required String journalEntryId,
      required String status,
      Value<String?> notes,
      Value<bool> dirty,
      Value<int> rowid,
    });
typedef $$LocalDailyReviewEntriesTableUpdateCompanionBuilder =
    LocalDailyReviewEntriesCompanion Function({
      Value<String> dayId,
      Value<String> journalEntryId,
      Value<String> status,
      Value<String?> notes,
      Value<bool> dirty,
      Value<int> rowid,
    });

class $$LocalDailyReviewEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDailyReviewEntriesTable> {
  $$LocalDailyReviewEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dayId => $composableBuilder(
    column: $table.dayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDailyReviewEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDailyReviewEntriesTable> {
  $$LocalDailyReviewEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dayId => $composableBuilder(
    column: $table.dayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDailyReviewEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDailyReviewEntriesTable> {
  $$LocalDailyReviewEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dayId =>
      $composableBuilder(column: $table.dayId, builder: (column) => column);

  GeneratedColumn<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$LocalDailyReviewEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalDailyReviewEntriesTable,
          LocalDailyReviewEntryRow,
          $$LocalDailyReviewEntriesTableFilterComposer,
          $$LocalDailyReviewEntriesTableOrderingComposer,
          $$LocalDailyReviewEntriesTableAnnotationComposer,
          $$LocalDailyReviewEntriesTableCreateCompanionBuilder,
          $$LocalDailyReviewEntriesTableUpdateCompanionBuilder,
          (
            LocalDailyReviewEntryRow,
            BaseReferences<
              _$AppDatabase,
              $LocalDailyReviewEntriesTable,
              LocalDailyReviewEntryRow
            >,
          ),
          LocalDailyReviewEntryRow,
          PrefetchHooks Function()
        > {
  $$LocalDailyReviewEntriesTableTableManager(
    _$AppDatabase db,
    $LocalDailyReviewEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDailyReviewEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalDailyReviewEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalDailyReviewEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> dayId = const Value.absent(),
                Value<String> journalEntryId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDailyReviewEntriesCompanion(
                dayId: dayId,
                journalEntryId: journalEntryId,
                status: status,
                notes: notes,
                dirty: dirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dayId,
                required String journalEntryId,
                required String status,
                Value<String?> notes = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDailyReviewEntriesCompanion.insert(
                dayId: dayId,
                journalEntryId: journalEntryId,
                status: status,
                notes: notes,
                dirty: dirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LocalDailyReviewEntriesTable,
                    LocalDailyReviewEntryRow
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalDailyReviewEntriesTable,
                    LocalDailyReviewEntryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDailyReviewEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalDailyReviewEntriesTable,
      LocalDailyReviewEntryRow,
      $$LocalDailyReviewEntriesTableFilterComposer,
      $$LocalDailyReviewEntriesTableOrderingComposer,
      $$LocalDailyReviewEntriesTableAnnotationComposer,
      $$LocalDailyReviewEntriesTableCreateCompanionBuilder,
      $$LocalDailyReviewEntriesTableUpdateCompanionBuilder,
      (
        LocalDailyReviewEntryRow,
        BaseReferences<
          _$AppDatabase,
          $LocalDailyReviewEntriesTable,
          LocalDailyReviewEntryRow
        >,
      ),
      LocalDailyReviewEntryRow,
      PrefetchHooks Function()
    >;
typedef $$LocalMetaTableCreateCompanionBuilder = LocalMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$LocalMetaTableUpdateCompanionBuilder = LocalMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$LocalMetaTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMetaTable> {
  $$LocalMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMetaTable> {
  $$LocalMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMetaTable> {
  $$LocalMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$LocalMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMetaTable,
          LocalMetaRow,
          $$LocalMetaTableFilterComposer,
          $$LocalMetaTableOrderingComposer,
          $$LocalMetaTableAnnotationComposer,
          $$LocalMetaTableCreateCompanionBuilder,
          $$LocalMetaTableUpdateCompanionBuilder,
          (
            LocalMetaRow,
            BaseReferences<_$AppDatabase, $LocalMetaTable, LocalMetaRow>,
          ),
          LocalMetaRow,
          PrefetchHooks Function()
        > {
  $$LocalMetaTableTableManager(_$AppDatabase db, $LocalMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => LocalMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => LocalMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalMetaTable, LocalMetaRow>(table),
                  BaseReferences<_$AppDatabase, $LocalMetaTable, LocalMetaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMetaTable,
      LocalMetaRow,
      $$LocalMetaTableFilterComposer,
      $$LocalMetaTableOrderingComposer,
      $$LocalMetaTableAnnotationComposer,
      $$LocalMetaTableCreateCompanionBuilder,
      $$LocalMetaTableUpdateCompanionBuilder,
      (
        LocalMetaRow,
        BaseReferences<_$AppDatabase, $LocalMetaTable, LocalMetaRow>,
      ),
      LocalMetaRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalStudentsTableTableManager get localStudents =>
      $$LocalStudentsTableTableManager(_db, _db.localStudents);
  $$LocalAttendanceTableTableManager get localAttendance =>
      $$LocalAttendanceTableTableManager(_db, _db.localAttendance);
  $$LocalObservationsTableTableManager get localObservations =>
      $$LocalObservationsTableTableManager(_db, _db.localObservations);
  $$LocalDailyReviewsTableTableManager get localDailyReviews =>
      $$LocalDailyReviewsTableTableManager(_db, _db.localDailyReviews);
  $$LocalDailyReviewEntriesTableTableManager get localDailyReviewEntries =>
      $$LocalDailyReviewEntriesTableTableManager(
        _db,
        _db.localDailyReviewEntries,
      );
  $$LocalMetaTableTableManager get localMeta =>
      $$LocalMetaTableTableManager(_db, _db.localMeta);
}
