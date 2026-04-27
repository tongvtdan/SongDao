// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CalendarDaysTable extends CalendarDays
    with TableInfo<$CalendarDaysTable, CalendarDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _liturgicalWeekMeta = const VerificationMeta(
    'liturgicalWeek',
  );
  @override
  late final GeneratedColumn<int> liturgicalWeek = GeneratedColumn<int>(
    'liturgical_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleYearMeta = const VerificationMeta(
    'cycleYear',
  );
  @override
  late final GeneratedColumn<String> cycleYear = GeneratedColumn<String>(
    'cycle_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    season,
    liturgicalWeek,
    color,
    cycleYear,
    locale,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('liturgical_week')) {
      context.handle(
        _liturgicalWeekMeta,
        liturgicalWeek.isAcceptableOrUnknown(
          data['liturgical_week']!,
          _liturgicalWeekMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_liturgicalWeekMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('cycle_year')) {
      context.handle(
        _cycleYearMeta,
        cycleYear.isAcceptableOrUnknown(data['cycle_year']!, _cycleYearMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleYearMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  CalendarDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarDay(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season'],
      )!,
      liturgicalWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}liturgical_week'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      cycleYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_year'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
    );
  }

  @override
  $CalendarDaysTable createAlias(String alias) {
    return $CalendarDaysTable(attachedDatabase, alias);
  }
}

class CalendarDay extends DataClass implements Insertable<CalendarDay> {
  final String date;
  final String season;
  final int liturgicalWeek;
  final String color;
  final String cycleYear;
  final String locale;
  const CalendarDay({
    required this.date,
    required this.season,
    required this.liturgicalWeek,
    required this.color,
    required this.cycleYear,
    required this.locale,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['season'] = Variable<String>(season);
    map['liturgical_week'] = Variable<int>(liturgicalWeek);
    map['color'] = Variable<String>(color);
    map['cycle_year'] = Variable<String>(cycleYear);
    map['locale'] = Variable<String>(locale);
    return map;
  }

  CalendarDaysCompanion toCompanion(bool nullToAbsent) {
    return CalendarDaysCompanion(
      date: Value(date),
      season: Value(season),
      liturgicalWeek: Value(liturgicalWeek),
      color: Value(color),
      cycleYear: Value(cycleYear),
      locale: Value(locale),
    );
  }

  factory CalendarDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarDay(
      date: serializer.fromJson<String>(json['date']),
      season: serializer.fromJson<String>(json['season']),
      liturgicalWeek: serializer.fromJson<int>(json['liturgicalWeek']),
      color: serializer.fromJson<String>(json['color']),
      cycleYear: serializer.fromJson<String>(json['cycleYear']),
      locale: serializer.fromJson<String>(json['locale']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'season': serializer.toJson<String>(season),
      'liturgicalWeek': serializer.toJson<int>(liturgicalWeek),
      'color': serializer.toJson<String>(color),
      'cycleYear': serializer.toJson<String>(cycleYear),
      'locale': serializer.toJson<String>(locale),
    };
  }

  CalendarDay copyWith({
    String? date,
    String? season,
    int? liturgicalWeek,
    String? color,
    String? cycleYear,
    String? locale,
  }) => CalendarDay(
    date: date ?? this.date,
    season: season ?? this.season,
    liturgicalWeek: liturgicalWeek ?? this.liturgicalWeek,
    color: color ?? this.color,
    cycleYear: cycleYear ?? this.cycleYear,
    locale: locale ?? this.locale,
  );
  CalendarDay copyWithCompanion(CalendarDaysCompanion data) {
    return CalendarDay(
      date: data.date.present ? data.date.value : this.date,
      season: data.season.present ? data.season.value : this.season,
      liturgicalWeek: data.liturgicalWeek.present
          ? data.liturgicalWeek.value
          : this.liturgicalWeek,
      color: data.color.present ? data.color.value : this.color,
      cycleYear: data.cycleYear.present ? data.cycleYear.value : this.cycleYear,
      locale: data.locale.present ? data.locale.value : this.locale,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarDay(')
          ..write('date: $date, ')
          ..write('season: $season, ')
          ..write('liturgicalWeek: $liturgicalWeek, ')
          ..write('color: $color, ')
          ..write('cycleYear: $cycleYear, ')
          ..write('locale: $locale')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(date, season, liturgicalWeek, color, cycleYear, locale);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarDay &&
          other.date == this.date &&
          other.season == this.season &&
          other.liturgicalWeek == this.liturgicalWeek &&
          other.color == this.color &&
          other.cycleYear == this.cycleYear &&
          other.locale == this.locale);
}

class CalendarDaysCompanion extends UpdateCompanion<CalendarDay> {
  final Value<String> date;
  final Value<String> season;
  final Value<int> liturgicalWeek;
  final Value<String> color;
  final Value<String> cycleYear;
  final Value<String> locale;
  final Value<int> rowid;
  const CalendarDaysCompanion({
    this.date = const Value.absent(),
    this.season = const Value.absent(),
    this.liturgicalWeek = const Value.absent(),
    this.color = const Value.absent(),
    this.cycleYear = const Value.absent(),
    this.locale = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarDaysCompanion.insert({
    required String date,
    required String season,
    required int liturgicalWeek,
    required String color,
    required String cycleYear,
    required String locale,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       season = Value(season),
       liturgicalWeek = Value(liturgicalWeek),
       color = Value(color),
       cycleYear = Value(cycleYear),
       locale = Value(locale);
  static Insertable<CalendarDay> custom({
    Expression<String>? date,
    Expression<String>? season,
    Expression<int>? liturgicalWeek,
    Expression<String>? color,
    Expression<String>? cycleYear,
    Expression<String>? locale,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (season != null) 'season': season,
      if (liturgicalWeek != null) 'liturgical_week': liturgicalWeek,
      if (color != null) 'color': color,
      if (cycleYear != null) 'cycle_year': cycleYear,
      if (locale != null) 'locale': locale,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarDaysCompanion copyWith({
    Value<String>? date,
    Value<String>? season,
    Value<int>? liturgicalWeek,
    Value<String>? color,
    Value<String>? cycleYear,
    Value<String>? locale,
    Value<int>? rowid,
  }) {
    return CalendarDaysCompanion(
      date: date ?? this.date,
      season: season ?? this.season,
      liturgicalWeek: liturgicalWeek ?? this.liturgicalWeek,
      color: color ?? this.color,
      cycleYear: cycleYear ?? this.cycleYear,
      locale: locale ?? this.locale,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (liturgicalWeek.present) {
      map['liturgical_week'] = Variable<int>(liturgicalWeek.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (cycleYear.present) {
      map['cycle_year'] = Variable<String>(cycleYear.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarDaysCompanion(')
          ..write('date: $date, ')
          ..write('season: $season, ')
          ..write('liturgicalWeek: $liturgicalWeek, ')
          ..write('color: $color, ')
          ..write('cycleYear: $cycleYear, ')
          ..write('locale: $locale, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CelebrationsTable extends Celebrations
    with TableInfo<$CelebrationsTable, Celebration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CelebrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES calendar_days (date)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<String> rank = GeneratedColumn<String>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOptionalMeta = const VerificationMeta(
    'isOptional',
  );
  @override
  late final GeneratedColumn<bool> isOptional = GeneratedColumn<bool>(
    'is_optional',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_optional" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    date,
    name,
    rank,
    isOptional,
    locale,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'celebrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Celebration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    } else if (isInserting) {
      context.missing(_rankMeta);
    }
    if (data.containsKey('is_optional')) {
      context.handle(
        _isOptionalMeta,
        isOptional.isAcceptableOrUnknown(data['is_optional']!, _isOptionalMeta),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    } else if (isInserting) {
      context.missing(_localeMeta);
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
  Celebration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Celebration(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rank'],
      )!,
      isOptional: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_optional'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CelebrationsTable createAlias(String alias) {
    return $CelebrationsTable(attachedDatabase, alias);
  }
}

class Celebration extends DataClass implements Insertable<Celebration> {
  final String id;
  final String date;
  final String name;
  final String rank;
  final bool isOptional;
  final String locale;
  final DateTime createdAt;
  const Celebration({
    required this.id,
    required this.date,
    required this.name,
    required this.rank,
    required this.isOptional,
    required this.locale,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<String>(date);
    map['name'] = Variable<String>(name);
    map['rank'] = Variable<String>(rank);
    map['is_optional'] = Variable<bool>(isOptional);
    map['locale'] = Variable<String>(locale);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CelebrationsCompanion toCompanion(bool nullToAbsent) {
    return CelebrationsCompanion(
      id: Value(id),
      date: Value(date),
      name: Value(name),
      rank: Value(rank),
      isOptional: Value(isOptional),
      locale: Value(locale),
      createdAt: Value(createdAt),
    );
  }

  factory Celebration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Celebration(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      name: serializer.fromJson<String>(json['name']),
      rank: serializer.fromJson<String>(json['rank']),
      isOptional: serializer.fromJson<bool>(json['isOptional']),
      locale: serializer.fromJson<String>(json['locale']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<String>(date),
      'name': serializer.toJson<String>(name),
      'rank': serializer.toJson<String>(rank),
      'isOptional': serializer.toJson<bool>(isOptional),
      'locale': serializer.toJson<String>(locale),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Celebration copyWith({
    String? id,
    String? date,
    String? name,
    String? rank,
    bool? isOptional,
    String? locale,
    DateTime? createdAt,
  }) => Celebration(
    id: id ?? this.id,
    date: date ?? this.date,
    name: name ?? this.name,
    rank: rank ?? this.rank,
    isOptional: isOptional ?? this.isOptional,
    locale: locale ?? this.locale,
    createdAt: createdAt ?? this.createdAt,
  );
  Celebration copyWithCompanion(CelebrationsCompanion data) {
    return Celebration(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      name: data.name.present ? data.name.value : this.name,
      rank: data.rank.present ? data.rank.value : this.rank,
      isOptional: data.isOptional.present
          ? data.isOptional.value
          : this.isOptional,
      locale: data.locale.present ? data.locale.value : this.locale,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Celebration(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('rank: $rank, ')
          ..write('isOptional: $isOptional, ')
          ..write('locale: $locale, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, name, rank, isOptional, locale, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Celebration &&
          other.id == this.id &&
          other.date == this.date &&
          other.name == this.name &&
          other.rank == this.rank &&
          other.isOptional == this.isOptional &&
          other.locale == this.locale &&
          other.createdAt == this.createdAt);
}

class CelebrationsCompanion extends UpdateCompanion<Celebration> {
  final Value<String> id;
  final Value<String> date;
  final Value<String> name;
  final Value<String> rank;
  final Value<bool> isOptional;
  final Value<String> locale;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CelebrationsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.name = const Value.absent(),
    this.rank = const Value.absent(),
    this.isOptional = const Value.absent(),
    this.locale = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CelebrationsCompanion.insert({
    required String id,
    required String date,
    required String name,
    required String rank,
    this.isOptional = const Value.absent(),
    required String locale,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       name = Value(name),
       rank = Value(rank),
       locale = Value(locale);
  static Insertable<Celebration> custom({
    Expression<String>? id,
    Expression<String>? date,
    Expression<String>? name,
    Expression<String>? rank,
    Expression<bool>? isOptional,
    Expression<String>? locale,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (name != null) 'name': name,
      if (rank != null) 'rank': rank,
      if (isOptional != null) 'is_optional': isOptional,
      if (locale != null) 'locale': locale,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CelebrationsCompanion copyWith({
    Value<String>? id,
    Value<String>? date,
    Value<String>? name,
    Value<String>? rank,
    Value<bool>? isOptional,
    Value<String>? locale,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CelebrationsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      name: name ?? this.name,
      rank: rank ?? this.rank,
      isOptional: isOptional ?? this.isOptional,
      locale: locale ?? this.locale,
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
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rank.present) {
      map['rank'] = Variable<String>(rank.value);
    }
    if (isOptional.present) {
      map['is_optional'] = Variable<bool>(isOptional.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
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
    return (StringBuffer('CelebrationsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('rank: $rank, ')
          ..write('isOptional: $isOptional, ')
          ..write('locale: $locale, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingsTable extends Readings with TableInfo<$ReadingsTable, Reading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES calendar_days (date)',
    ),
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
  static const VerificationMeta _citationMeta = const VerificationMeta(
    'citation',
  );
  @override
  late final GeneratedColumn<String> citation = GeneratedColumn<String>(
    'citation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayLabelMeta = const VerificationMeta(
    'displayLabel',
  );
  @override
  late final GeneratedColumn<String> displayLabel = GeneratedColumn<String>(
    'display_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licenseMeta = const VerificationMeta(
    'license',
  );
  @override
  late final GeneratedColumn<String> license = GeneratedColumn<String>(
    'license',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    date,
    type,
    citation,
    displayLabel,
    textContent,
    sourceUrl,
    license,
    locale,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('citation')) {
      context.handle(
        _citationMeta,
        citation.isAcceptableOrUnknown(data['citation']!, _citationMeta),
      );
    } else if (isInserting) {
      context.missing(_citationMeta);
    }
    if (data.containsKey('display_label')) {
      context.handle(
        _displayLabelMeta,
        displayLabel.isAcceptableOrUnknown(
          data['display_label']!,
          _displayLabelMeta,
        ),
      );
    }
    if (data.containsKey('text_content')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(
          data['text_content']!,
          _textContentMeta,
        ),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('license')) {
      context.handle(
        _licenseMeta,
        license.isAcceptableOrUnknown(data['license']!, _licenseMeta),
      );
    } else if (isInserting) {
      context.missing(_licenseMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    } else if (isInserting) {
      context.missing(_localeMeta);
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
  Reading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      citation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}citation'],
      )!,
      displayLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_label'],
      ),
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_content'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      license: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReadingsTable createAlias(String alias) {
    return $ReadingsTable(attachedDatabase, alias);
  }
}

class Reading extends DataClass implements Insertable<Reading> {
  final String id;
  final String date;
  final String type;
  final String citation;
  final String? displayLabel;
  final String? textContent;
  final String? sourceUrl;
  final String license;
  final String locale;
  final DateTime createdAt;
  const Reading({
    required this.id,
    required this.date,
    required this.type,
    required this.citation,
    this.displayLabel,
    this.textContent,
    this.sourceUrl,
    required this.license,
    required this.locale,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<String>(date);
    map['type'] = Variable<String>(type);
    map['citation'] = Variable<String>(citation);
    if (!nullToAbsent || displayLabel != null) {
      map['display_label'] = Variable<String>(displayLabel);
    }
    if (!nullToAbsent || textContent != null) {
      map['text_content'] = Variable<String>(textContent);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    map['license'] = Variable<String>(license);
    map['locale'] = Variable<String>(locale);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReadingsCompanion toCompanion(bool nullToAbsent) {
    return ReadingsCompanion(
      id: Value(id),
      date: Value(date),
      type: Value(type),
      citation: Value(citation),
      displayLabel: displayLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(displayLabel),
      textContent: textContent == null && nullToAbsent
          ? const Value.absent()
          : Value(textContent),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      license: Value(license),
      locale: Value(locale),
      createdAt: Value(createdAt),
    );
  }

  factory Reading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reading(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      citation: serializer.fromJson<String>(json['citation']),
      displayLabel: serializer.fromJson<String?>(json['displayLabel']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      license: serializer.fromJson<String>(json['license']),
      locale: serializer.fromJson<String>(json['locale']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<String>(date),
      'type': serializer.toJson<String>(type),
      'citation': serializer.toJson<String>(citation),
      'displayLabel': serializer.toJson<String?>(displayLabel),
      'textContent': serializer.toJson<String?>(textContent),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'license': serializer.toJson<String>(license),
      'locale': serializer.toJson<String>(locale),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Reading copyWith({
    String? id,
    String? date,
    String? type,
    String? citation,
    Value<String?> displayLabel = const Value.absent(),
    Value<String?> textContent = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    String? license,
    String? locale,
    DateTime? createdAt,
  }) => Reading(
    id: id ?? this.id,
    date: date ?? this.date,
    type: type ?? this.type,
    citation: citation ?? this.citation,
    displayLabel: displayLabel.present ? displayLabel.value : this.displayLabel,
    textContent: textContent.present ? textContent.value : this.textContent,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    license: license ?? this.license,
    locale: locale ?? this.locale,
    createdAt: createdAt ?? this.createdAt,
  );
  Reading copyWithCompanion(ReadingsCompanion data) {
    return Reading(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      citation: data.citation.present ? data.citation.value : this.citation,
      displayLabel: data.displayLabel.present
          ? data.displayLabel.value
          : this.displayLabel,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      license: data.license.present ? data.license.value : this.license,
      locale: data.locale.present ? data.locale.value : this.locale,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reading(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('citation: $citation, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('textContent: $textContent, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('license: $license, ')
          ..write('locale: $locale, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    type,
    citation,
    displayLabel,
    textContent,
    sourceUrl,
    license,
    locale,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reading &&
          other.id == this.id &&
          other.date == this.date &&
          other.type == this.type &&
          other.citation == this.citation &&
          other.displayLabel == this.displayLabel &&
          other.textContent == this.textContent &&
          other.sourceUrl == this.sourceUrl &&
          other.license == this.license &&
          other.locale == this.locale &&
          other.createdAt == this.createdAt);
}

class ReadingsCompanion extends UpdateCompanion<Reading> {
  final Value<String> id;
  final Value<String> date;
  final Value<String> type;
  final Value<String> citation;
  final Value<String?> displayLabel;
  final Value<String?> textContent;
  final Value<String?> sourceUrl;
  final Value<String> license;
  final Value<String> locale;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReadingsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.citation = const Value.absent(),
    this.displayLabel = const Value.absent(),
    this.textContent = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.license = const Value.absent(),
    this.locale = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingsCompanion.insert({
    required String id,
    required String date,
    required String type,
    required String citation,
    this.displayLabel = const Value.absent(),
    this.textContent = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    required String license,
    required String locale,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       type = Value(type),
       citation = Value(citation),
       license = Value(license),
       locale = Value(locale);
  static Insertable<Reading> custom({
    Expression<String>? id,
    Expression<String>? date,
    Expression<String>? type,
    Expression<String>? citation,
    Expression<String>? displayLabel,
    Expression<String>? textContent,
    Expression<String>? sourceUrl,
    Expression<String>? license,
    Expression<String>? locale,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (citation != null) 'citation': citation,
      if (displayLabel != null) 'display_label': displayLabel,
      if (textContent != null) 'text_content': textContent,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (license != null) 'license': license,
      if (locale != null) 'locale': locale,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingsCompanion copyWith({
    Value<String>? id,
    Value<String>? date,
    Value<String>? type,
    Value<String>? citation,
    Value<String?>? displayLabel,
    Value<String?>? textContent,
    Value<String?>? sourceUrl,
    Value<String>? license,
    Value<String>? locale,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ReadingsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      citation: citation ?? this.citation,
      displayLabel: displayLabel ?? this.displayLabel,
      textContent: textContent ?? this.textContent,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      license: license ?? this.license,
      locale: locale ?? this.locale,
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
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (citation.present) {
      map['citation'] = Variable<String>(citation.value);
    }
    if (displayLabel.present) {
      map['display_label'] = Variable<String>(displayLabel.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (license.present) {
      map['license'] = Variable<String>(license.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
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
    return (StringBuffer('ReadingsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('citation: $citation, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('textContent: $textContent, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('license: $license, ')
          ..write('locale: $locale, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActionRulesTable extends ActionRules
    with TableInfo<$ActionRulesTable, ActionRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActionRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _triggerConditionMeta = const VerificationMeta(
    'triggerCondition',
  );
  @override
  late final GeneratedColumn<String> triggerCondition = GeneratedColumn<String>(
    'trigger_condition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templatePromptMeta = const VerificationMeta(
    'templatePrompt',
  );
  @override
  late final GeneratedColumn<String> templatePrompt = GeneratedColumn<String>(
    'template_prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
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
    type,
    triggerCondition,
    templatePrompt,
    priority,
    locale,
    packId,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'action_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActionRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('trigger_condition')) {
      context.handle(
        _triggerConditionMeta,
        triggerCondition.isAcceptableOrUnknown(
          data['trigger_condition']!,
          _triggerConditionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerConditionMeta);
    }
    if (data.containsKey('template_prompt')) {
      context.handle(
        _templatePromptMeta,
        templatePrompt.isAcceptableOrUnknown(
          data['template_prompt']!,
          _templatePromptMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templatePromptMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
  ActionRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActionRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      triggerCondition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_condition'],
      )!,
      templatePrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_prompt'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      ),
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ActionRulesTable createAlias(String alias) {
    return $ActionRulesTable(attachedDatabase, alias);
  }
}

class ActionRule extends DataClass implements Insertable<ActionRule> {
  final String id;
  final String type;
  final String triggerCondition;
  final String templatePrompt;
  final int priority;
  final String? locale;
  final String? packId;
  final bool isActive;
  final DateTime createdAt;
  const ActionRule({
    required this.id,
    required this.type,
    required this.triggerCondition,
    required this.templatePrompt,
    required this.priority,
    this.locale,
    this.packId,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['trigger_condition'] = Variable<String>(triggerCondition);
    map['template_prompt'] = Variable<String>(templatePrompt);
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || locale != null) {
      map['locale'] = Variable<String>(locale);
    }
    if (!nullToAbsent || packId != null) {
      map['pack_id'] = Variable<String>(packId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ActionRulesCompanion toCompanion(bool nullToAbsent) {
    return ActionRulesCompanion(
      id: Value(id),
      type: Value(type),
      triggerCondition: Value(triggerCondition),
      templatePrompt: Value(templatePrompt),
      priority: Value(priority),
      locale: locale == null && nullToAbsent
          ? const Value.absent()
          : Value(locale),
      packId: packId == null && nullToAbsent
          ? const Value.absent()
          : Value(packId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory ActionRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActionRule(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      triggerCondition: serializer.fromJson<String>(json['triggerCondition']),
      templatePrompt: serializer.fromJson<String>(json['templatePrompt']),
      priority: serializer.fromJson<int>(json['priority']),
      locale: serializer.fromJson<String?>(json['locale']),
      packId: serializer.fromJson<String?>(json['packId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'triggerCondition': serializer.toJson<String>(triggerCondition),
      'templatePrompt': serializer.toJson<String>(templatePrompt),
      'priority': serializer.toJson<int>(priority),
      'locale': serializer.toJson<String?>(locale),
      'packId': serializer.toJson<String?>(packId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ActionRule copyWith({
    String? id,
    String? type,
    String? triggerCondition,
    String? templatePrompt,
    int? priority,
    Value<String?> locale = const Value.absent(),
    Value<String?> packId = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => ActionRule(
    id: id ?? this.id,
    type: type ?? this.type,
    triggerCondition: triggerCondition ?? this.triggerCondition,
    templatePrompt: templatePrompt ?? this.templatePrompt,
    priority: priority ?? this.priority,
    locale: locale.present ? locale.value : this.locale,
    packId: packId.present ? packId.value : this.packId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  ActionRule copyWithCompanion(ActionRulesCompanion data) {
    return ActionRule(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      triggerCondition: data.triggerCondition.present
          ? data.triggerCondition.value
          : this.triggerCondition,
      templatePrompt: data.templatePrompt.present
          ? data.templatePrompt.value
          : this.templatePrompt,
      priority: data.priority.present ? data.priority.value : this.priority,
      locale: data.locale.present ? data.locale.value : this.locale,
      packId: data.packId.present ? data.packId.value : this.packId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActionRule(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('triggerCondition: $triggerCondition, ')
          ..write('templatePrompt: $templatePrompt, ')
          ..write('priority: $priority, ')
          ..write('locale: $locale, ')
          ..write('packId: $packId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    triggerCondition,
    templatePrompt,
    priority,
    locale,
    packId,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionRule &&
          other.id == this.id &&
          other.type == this.type &&
          other.triggerCondition == this.triggerCondition &&
          other.templatePrompt == this.templatePrompt &&
          other.priority == this.priority &&
          other.locale == this.locale &&
          other.packId == this.packId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class ActionRulesCompanion extends UpdateCompanion<ActionRule> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> triggerCondition;
  final Value<String> templatePrompt;
  final Value<int> priority;
  final Value<String?> locale;
  final Value<String?> packId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ActionRulesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.triggerCondition = const Value.absent(),
    this.templatePrompt = const Value.absent(),
    this.priority = const Value.absent(),
    this.locale = const Value.absent(),
    this.packId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActionRulesCompanion.insert({
    required String id,
    required String type,
    required String triggerCondition,
    required String templatePrompt,
    required int priority,
    this.locale = const Value.absent(),
    this.packId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       triggerCondition = Value(triggerCondition),
       templatePrompt = Value(templatePrompt),
       priority = Value(priority);
  static Insertable<ActionRule> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? triggerCondition,
    Expression<String>? templatePrompt,
    Expression<int>? priority,
    Expression<String>? locale,
    Expression<String>? packId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (triggerCondition != null) 'trigger_condition': triggerCondition,
      if (templatePrompt != null) 'template_prompt': templatePrompt,
      if (priority != null) 'priority': priority,
      if (locale != null) 'locale': locale,
      if (packId != null) 'pack_id': packId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActionRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? triggerCondition,
    Value<String>? templatePrompt,
    Value<int>? priority,
    Value<String?>? locale,
    Value<String?>? packId,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ActionRulesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      triggerCondition: triggerCondition ?? this.triggerCondition,
      templatePrompt: templatePrompt ?? this.templatePrompt,
      priority: priority ?? this.priority,
      locale: locale ?? this.locale,
      packId: packId ?? this.packId,
      isActive: isActive ?? this.isActive,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (triggerCondition.present) {
      map['trigger_condition'] = Variable<String>(triggerCondition.value);
    }
    if (templatePrompt.present) {
      map['template_prompt'] = Variable<String>(templatePrompt.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return (StringBuffer('ActionRulesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('triggerCondition: $triggerCondition, ')
          ..write('templatePrompt: $templatePrompt, ')
          ..write('priority: $priority, ')
          ..write('locale: $locale, ')
          ..write('packId: $packId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyActionsTable extends DailyActions
    with TableInfo<$DailyActionsTable, DailyAction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES calendar_days (date)',
    ),
  );
  static const VerificationMeta _sourceRuleMeta = const VerificationMeta(
    'sourceRule',
  );
  @override
  late final GeneratedColumn<String> sourceRule = GeneratedColumn<String>(
    'source_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    date,
    sourceRule,
    prompt,
    type,
    priority,
    locale,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyAction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('source_rule')) {
      context.handle(
        _sourceRuleMeta,
        sourceRule.isAcceptableOrUnknown(data['source_rule']!, _sourceRuleMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceRuleMeta);
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    } else if (isInserting) {
      context.missing(_localeMeta);
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
  DailyAction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyAction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      sourceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_rule'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DailyActionsTable createAlias(String alias) {
    return $DailyActionsTable(attachedDatabase, alias);
  }
}

class DailyAction extends DataClass implements Insertable<DailyAction> {
  final String id;
  final String date;
  final String sourceRule;
  final String prompt;
  final String type;
  final int priority;
  final String locale;
  final DateTime createdAt;
  const DailyAction({
    required this.id,
    required this.date,
    required this.sourceRule,
    required this.prompt,
    required this.type,
    required this.priority,
    required this.locale,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<String>(date);
    map['source_rule'] = Variable<String>(sourceRule);
    map['prompt'] = Variable<String>(prompt);
    map['type'] = Variable<String>(type);
    map['priority'] = Variable<int>(priority);
    map['locale'] = Variable<String>(locale);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailyActionsCompanion toCompanion(bool nullToAbsent) {
    return DailyActionsCompanion(
      id: Value(id),
      date: Value(date),
      sourceRule: Value(sourceRule),
      prompt: Value(prompt),
      type: Value(type),
      priority: Value(priority),
      locale: Value(locale),
      createdAt: Value(createdAt),
    );
  }

  factory DailyAction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyAction(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      sourceRule: serializer.fromJson<String>(json['sourceRule']),
      prompt: serializer.fromJson<String>(json['prompt']),
      type: serializer.fromJson<String>(json['type']),
      priority: serializer.fromJson<int>(json['priority']),
      locale: serializer.fromJson<String>(json['locale']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<String>(date),
      'sourceRule': serializer.toJson<String>(sourceRule),
      'prompt': serializer.toJson<String>(prompt),
      'type': serializer.toJson<String>(type),
      'priority': serializer.toJson<int>(priority),
      'locale': serializer.toJson<String>(locale),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyAction copyWith({
    String? id,
    String? date,
    String? sourceRule,
    String? prompt,
    String? type,
    int? priority,
    String? locale,
    DateTime? createdAt,
  }) => DailyAction(
    id: id ?? this.id,
    date: date ?? this.date,
    sourceRule: sourceRule ?? this.sourceRule,
    prompt: prompt ?? this.prompt,
    type: type ?? this.type,
    priority: priority ?? this.priority,
    locale: locale ?? this.locale,
    createdAt: createdAt ?? this.createdAt,
  );
  DailyAction copyWithCompanion(DailyActionsCompanion data) {
    return DailyAction(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      sourceRule: data.sourceRule.present
          ? data.sourceRule.value
          : this.sourceRule,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      type: data.type.present ? data.type.value : this.type,
      priority: data.priority.present ? data.priority.value : this.priority,
      locale: data.locale.present ? data.locale.value : this.locale,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyAction(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('sourceRule: $sourceRule, ')
          ..write('prompt: $prompt, ')
          ..write('type: $type, ')
          ..write('priority: $priority, ')
          ..write('locale: $locale, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    sourceRule,
    prompt,
    type,
    priority,
    locale,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyAction &&
          other.id == this.id &&
          other.date == this.date &&
          other.sourceRule == this.sourceRule &&
          other.prompt == this.prompt &&
          other.type == this.type &&
          other.priority == this.priority &&
          other.locale == this.locale &&
          other.createdAt == this.createdAt);
}

class DailyActionsCompanion extends UpdateCompanion<DailyAction> {
  final Value<String> id;
  final Value<String> date;
  final Value<String> sourceRule;
  final Value<String> prompt;
  final Value<String> type;
  final Value<int> priority;
  final Value<String> locale;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DailyActionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.sourceRule = const Value.absent(),
    this.prompt = const Value.absent(),
    this.type = const Value.absent(),
    this.priority = const Value.absent(),
    this.locale = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyActionsCompanion.insert({
    required String id,
    required String date,
    required String sourceRule,
    required String prompt,
    required String type,
    required int priority,
    required String locale,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       sourceRule = Value(sourceRule),
       prompt = Value(prompt),
       type = Value(type),
       priority = Value(priority),
       locale = Value(locale);
  static Insertable<DailyAction> custom({
    Expression<String>? id,
    Expression<String>? date,
    Expression<String>? sourceRule,
    Expression<String>? prompt,
    Expression<String>? type,
    Expression<int>? priority,
    Expression<String>? locale,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (sourceRule != null) 'source_rule': sourceRule,
      if (prompt != null) 'prompt': prompt,
      if (type != null) 'type': type,
      if (priority != null) 'priority': priority,
      if (locale != null) 'locale': locale,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyActionsCompanion copyWith({
    Value<String>? id,
    Value<String>? date,
    Value<String>? sourceRule,
    Value<String>? prompt,
    Value<String>? type,
    Value<int>? priority,
    Value<String>? locale,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DailyActionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      sourceRule: sourceRule ?? this.sourceRule,
      prompt: prompt ?? this.prompt,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      locale: locale ?? this.locale,
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
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (sourceRule.present) {
      map['source_rule'] = Variable<String>(sourceRule.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
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
    return (StringBuffer('DailyActionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('sourceRule: $sourceRule, ')
          ..write('prompt: $prompt, ')
          ..write('type: $type, ')
          ..write('priority: $priority, ')
          ..write('locale: $locale, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActionLogsTable extends ActionLogs
    with TableInfo<$ActionLogsTable, ActionLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActionLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionIdMeta = const VerificationMeta(
    'actionId',
  );
  @override
  late final GeneratedColumn<String> actionId = GeneratedColumn<String>(
    'action_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES daily_actions (id)',
    ),
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selfCheckProofMetadataMeta =
      const VerificationMeta('selfCheckProofMetadata');
  @override
  late final GeneratedColumn<String> selfCheckProofMetadata =
      GeneratedColumn<String>(
        'self_check_proof_metadata',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actionId,
    date,
    status,
    completedAt,
    note,
    selfCheckProofMetadata,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'action_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActionLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('action_id')) {
      context.handle(
        _actionIdMeta,
        actionId.isAcceptableOrUnknown(data['action_id']!, _actionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actionIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('self_check_proof_metadata')) {
      context.handle(
        _selfCheckProofMetadataMeta,
        selfCheckProofMetadata.isAcceptableOrUnknown(
          data['self_check_proof_metadata']!,
          _selfCheckProofMetadataMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {actionId},
  ];
  @override
  ActionLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActionLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      actionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      selfCheckProofMetadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}self_check_proof_metadata'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ActionLogsTable createAlias(String alias) {
    return $ActionLogsTable(attachedDatabase, alias);
  }
}

class ActionLog extends DataClass implements Insertable<ActionLog> {
  final String id;
  final String actionId;
  final String date;
  final String status;
  final DateTime? completedAt;
  final String? note;
  final String? selfCheckProofMetadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ActionLog({
    required this.id,
    required this.actionId,
    required this.date,
    required this.status,
    this.completedAt,
    this.note,
    this.selfCheckProofMetadata,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['action_id'] = Variable<String>(actionId);
    map['date'] = Variable<String>(date);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || selfCheckProofMetadata != null) {
      map['self_check_proof_metadata'] = Variable<String>(
        selfCheckProofMetadata,
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ActionLogsCompanion toCompanion(bool nullToAbsent) {
    return ActionLogsCompanion(
      id: Value(id),
      actionId: Value(actionId),
      date: Value(date),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      selfCheckProofMetadata: selfCheckProofMetadata == null && nullToAbsent
          ? const Value.absent()
          : Value(selfCheckProofMetadata),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ActionLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActionLog(
      id: serializer.fromJson<String>(json['id']),
      actionId: serializer.fromJson<String>(json['actionId']),
      date: serializer.fromJson<String>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      note: serializer.fromJson<String?>(json['note']),
      selfCheckProofMetadata: serializer.fromJson<String?>(
        json['selfCheckProofMetadata'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'actionId': serializer.toJson<String>(actionId),
      'date': serializer.toJson<String>(date),
      'status': serializer.toJson<String>(status),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'note': serializer.toJson<String?>(note),
      'selfCheckProofMetadata': serializer.toJson<String?>(
        selfCheckProofMetadata,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ActionLog copyWith({
    String? id,
    String? actionId,
    String? date,
    String? status,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> selfCheckProofMetadata = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ActionLog(
    id: id ?? this.id,
    actionId: actionId ?? this.actionId,
    date: date ?? this.date,
    status: status ?? this.status,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    note: note.present ? note.value : this.note,
    selfCheckProofMetadata: selfCheckProofMetadata.present
        ? selfCheckProofMetadata.value
        : this.selfCheckProofMetadata,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ActionLog copyWithCompanion(ActionLogsCompanion data) {
    return ActionLog(
      id: data.id.present ? data.id.value : this.id,
      actionId: data.actionId.present ? data.actionId.value : this.actionId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      note: data.note.present ? data.note.value : this.note,
      selfCheckProofMetadata: data.selfCheckProofMetadata.present
          ? data.selfCheckProofMetadata.value
          : this.selfCheckProofMetadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActionLog(')
          ..write('id: $id, ')
          ..write('actionId: $actionId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('note: $note, ')
          ..write('selfCheckProofMetadata: $selfCheckProofMetadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    actionId,
    date,
    status,
    completedAt,
    note,
    selfCheckProofMetadata,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionLog &&
          other.id == this.id &&
          other.actionId == this.actionId &&
          other.date == this.date &&
          other.status == this.status &&
          other.completedAt == this.completedAt &&
          other.note == this.note &&
          other.selfCheckProofMetadata == this.selfCheckProofMetadata &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ActionLogsCompanion extends UpdateCompanion<ActionLog> {
  final Value<String> id;
  final Value<String> actionId;
  final Value<String> date;
  final Value<String> status;
  final Value<DateTime?> completedAt;
  final Value<String?> note;
  final Value<String?> selfCheckProofMetadata;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ActionLogsCompanion({
    this.id = const Value.absent(),
    this.actionId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.selfCheckProofMetadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActionLogsCompanion.insert({
    required String id,
    required String actionId,
    required String date,
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.selfCheckProofMetadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       actionId = Value(actionId),
       date = Value(date);
  static Insertable<ActionLog> custom({
    Expression<String>? id,
    Expression<String>? actionId,
    Expression<String>? date,
    Expression<String>? status,
    Expression<DateTime>? completedAt,
    Expression<String>? note,
    Expression<String>? selfCheckProofMetadata,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionId != null) 'action_id': actionId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (note != null) 'note': note,
      if (selfCheckProofMetadata != null)
        'self_check_proof_metadata': selfCheckProofMetadata,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActionLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? actionId,
    Value<String>? date,
    Value<String>? status,
    Value<DateTime?>? completedAt,
    Value<String?>? note,
    Value<String?>? selfCheckProofMetadata,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ActionLogsCompanion(
      id: id ?? this.id,
      actionId: actionId ?? this.actionId,
      date: date ?? this.date,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      note: note ?? this.note,
      selfCheckProofMetadata:
          selfCheckProofMetadata ?? this.selfCheckProofMetadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (actionId.present) {
      map['action_id'] = Variable<String>(actionId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (selfCheckProofMetadata.present) {
      map['self_check_proof_metadata'] = Variable<String>(
        selfCheckProofMetadata.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('ActionLogsCompanion(')
          ..write('id: $id, ')
          ..write('actionId: $actionId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('note: $note, ')
          ..write('selfCheckProofMetadata: $selfCheckProofMetadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSetting> instance, {
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const UserSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      UserSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<UserSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
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
    return (StringBuffer('UserSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WidgetSnapshotsTable extends WidgetSnapshots
    with TableInfo<$WidgetSnapshotsTable, WidgetSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WidgetSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [date, payload, generatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'widget_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<WidgetSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  WidgetSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WidgetSnapshot(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
    );
  }

  @override
  $WidgetSnapshotsTable createAlias(String alias) {
    return $WidgetSnapshotsTable(attachedDatabase, alias);
  }
}

class WidgetSnapshot extends DataClass implements Insertable<WidgetSnapshot> {
  final String date;
  final String payload;
  final DateTime generatedAt;
  const WidgetSnapshot({
    required this.date,
    required this.payload,
    required this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['payload'] = Variable<String>(payload);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  WidgetSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return WidgetSnapshotsCompanion(
      date: Value(date),
      payload: Value(payload),
      generatedAt: Value(generatedAt),
    );
  }

  factory WidgetSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WidgetSnapshot(
      date: serializer.fromJson<String>(json['date']),
      payload: serializer.fromJson<String>(json['payload']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'payload': serializer.toJson<String>(payload),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  WidgetSnapshot copyWith({
    String? date,
    String? payload,
    DateTime? generatedAt,
  }) => WidgetSnapshot(
    date: date ?? this.date,
    payload: payload ?? this.payload,
    generatedAt: generatedAt ?? this.generatedAt,
  );
  WidgetSnapshot copyWithCompanion(WidgetSnapshotsCompanion data) {
    return WidgetSnapshot(
      date: data.date.present ? data.date.value : this.date,
      payload: data.payload.present ? data.payload.value : this.payload,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WidgetSnapshot(')
          ..write('date: $date, ')
          ..write('payload: $payload, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, payload, generatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WidgetSnapshot &&
          other.date == this.date &&
          other.payload == this.payload &&
          other.generatedAt == this.generatedAt);
}

class WidgetSnapshotsCompanion extends UpdateCompanion<WidgetSnapshot> {
  final Value<String> date;
  final Value<String> payload;
  final Value<DateTime> generatedAt;
  final Value<int> rowid;
  const WidgetSnapshotsCompanion({
    this.date = const Value.absent(),
    this.payload = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WidgetSnapshotsCompanion.insert({
    required String date,
    required String payload,
    required DateTime generatedAt,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       payload = Value(payload),
       generatedAt = Value(generatedAt);
  static Insertable<WidgetSnapshot> custom({
    Expression<String>? date,
    Expression<String>? payload,
    Expression<DateTime>? generatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (payload != null) 'payload': payload,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WidgetSnapshotsCompanion copyWith({
    Value<String>? date,
    Value<String>? payload,
    Value<DateTime>? generatedAt,
    Value<int>? rowid,
  }) {
    return WidgetSnapshotsCompanion(
      date: date ?? this.date,
      payload: payload ?? this.payload,
      generatedAt: generatedAt ?? this.generatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WidgetSnapshotsCompanion(')
          ..write('date: $date, ')
          ..write('payload: $payload, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CalendarDaysTable calendarDays = $CalendarDaysTable(this);
  late final $CelebrationsTable celebrations = $CelebrationsTable(this);
  late final $ReadingsTable readings = $ReadingsTable(this);
  late final $ActionRulesTable actionRules = $ActionRulesTable(this);
  late final $DailyActionsTable dailyActions = $DailyActionsTable(this);
  late final $ActionLogsTable actionLogs = $ActionLogsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $WidgetSnapshotsTable widgetSnapshots = $WidgetSnapshotsTable(
    this,
  );
  late final TodayDao todayDao = TodayDao(this as AppDatabase);
  late final ActionLogDao actionLogDao = ActionLogDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    calendarDays,
    celebrations,
    readings,
    actionRules,
    dailyActions,
    actionLogs,
    userSettings,
    widgetSnapshots,
  ];
}

typedef $$CalendarDaysTableCreateCompanionBuilder =
    CalendarDaysCompanion Function({
      required String date,
      required String season,
      required int liturgicalWeek,
      required String color,
      required String cycleYear,
      required String locale,
      Value<int> rowid,
    });
typedef $$CalendarDaysTableUpdateCompanionBuilder =
    CalendarDaysCompanion Function({
      Value<String> date,
      Value<String> season,
      Value<int> liturgicalWeek,
      Value<String> color,
      Value<String> cycleYear,
      Value<String> locale,
      Value<int> rowid,
    });

final class $$CalendarDaysTableReferences
    extends BaseReferences<_$AppDatabase, $CalendarDaysTable, CalendarDay> {
  $$CalendarDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CelebrationsTable, List<Celebration>>
  _celebrationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.celebrations,
    aliasName: $_aliasNameGenerator(db.calendarDays.date, db.celebrations.date),
  );

  $$CelebrationsTableProcessedTableManager get celebrationsRefs {
    final manager = $$CelebrationsTableTableManager(
      $_db,
      $_db.celebrations,
    ).filter((f) => f.date.date.sqlEquals($_itemColumn<String>('date')!));

    final cache = $_typedResult.readTableOrNull(_celebrationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadingsTable, List<Reading>> _readingsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.readings,
    aliasName: $_aliasNameGenerator(db.calendarDays.date, db.readings.date),
  );

  $$ReadingsTableProcessedTableManager get readingsRefs {
    final manager = $$ReadingsTableTableManager(
      $_db,
      $_db.readings,
    ).filter((f) => f.date.date.sqlEquals($_itemColumn<String>('date')!));

    final cache = $_typedResult.readTableOrNull(_readingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DailyActionsTable, List<DailyAction>>
  _dailyActionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailyActions,
    aliasName: $_aliasNameGenerator(db.calendarDays.date, db.dailyActions.date),
  );

  $$DailyActionsTableProcessedTableManager get dailyActionsRefs {
    final manager = $$DailyActionsTableTableManager(
      $_db,
      $_db.dailyActions,
    ).filter((f) => f.date.date.sqlEquals($_itemColumn<String>('date')!));

    final cache = $_typedResult.readTableOrNull(_dailyActionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CalendarDaysTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarDaysTable> {
  $$CalendarDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get liturgicalWeek => $composableBuilder(
    column: $table.liturgicalWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycleYear => $composableBuilder(
    column: $table.cycleYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> celebrationsRefs(
    Expression<bool> Function($$CelebrationsTableFilterComposer f) f,
  ) {
    final $$CelebrationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.celebrations,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CelebrationsTableFilterComposer(
            $db: $db,
            $table: $db.celebrations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingsRefs(
    Expression<bool> Function($$ReadingsTableFilterComposer f) f,
  ) {
    final $$ReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.readings,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingsTableFilterComposer(
            $db: $db,
            $table: $db.readings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dailyActionsRefs(
    Expression<bool> Function($$DailyActionsTableFilterComposer f) f,
  ) {
    final $$DailyActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.dailyActions,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyActionsTableFilterComposer(
            $db: $db,
            $table: $db.dailyActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CalendarDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarDaysTable> {
  $$CalendarDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get liturgicalWeek => $composableBuilder(
    column: $table.liturgicalWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycleYear => $composableBuilder(
    column: $table.cycleYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarDaysTable> {
  $$CalendarDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<int> get liturgicalWeek => $composableBuilder(
    column: $table.liturgicalWeek,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get cycleYear =>
      $composableBuilder(column: $table.cycleYear, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  Expression<T> celebrationsRefs<T extends Object>(
    Expression<T> Function($$CelebrationsTableAnnotationComposer a) f,
  ) {
    final $$CelebrationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.celebrations,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CelebrationsTableAnnotationComposer(
            $db: $db,
            $table: $db.celebrations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingsRefs<T extends Object>(
    Expression<T> Function($$ReadingsTableAnnotationComposer a) f,
  ) {
    final $$ReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.readings,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.readings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dailyActionsRefs<T extends Object>(
    Expression<T> Function($$DailyActionsTableAnnotationComposer a) f,
  ) {
    final $$DailyActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.dailyActions,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CalendarDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalendarDaysTable,
          CalendarDay,
          $$CalendarDaysTableFilterComposer,
          $$CalendarDaysTableOrderingComposer,
          $$CalendarDaysTableAnnotationComposer,
          $$CalendarDaysTableCreateCompanionBuilder,
          $$CalendarDaysTableUpdateCompanionBuilder,
          (CalendarDay, $$CalendarDaysTableReferences),
          CalendarDay,
          PrefetchHooks Function({
            bool celebrationsRefs,
            bool readingsRefs,
            bool dailyActionsRefs,
          })
        > {
  $$CalendarDaysTableTableManager(_$AppDatabase db, $CalendarDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<int> liturgicalWeek = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> cycleYear = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarDaysCompanion(
                date: date,
                season: season,
                liturgicalWeek: liturgicalWeek,
                color: color,
                cycleYear: cycleYear,
                locale: locale,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required String season,
                required int liturgicalWeek,
                required String color,
                required String cycleYear,
                required String locale,
                Value<int> rowid = const Value.absent(),
              }) => CalendarDaysCompanion.insert(
                date: date,
                season: season,
                liturgicalWeek: liturgicalWeek,
                color: color,
                cycleYear: cycleYear,
                locale: locale,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CalendarDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                celebrationsRefs = false,
                readingsRefs = false,
                dailyActionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (celebrationsRefs) db.celebrations,
                    if (readingsRefs) db.readings,
                    if (dailyActionsRefs) db.dailyActions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (celebrationsRefs)
                        await $_getPrefetchedData<
                          CalendarDay,
                          $CalendarDaysTable,
                          Celebration
                        >(
                          currentTable: table,
                          referencedTable: $$CalendarDaysTableReferences
                              ._celebrationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CalendarDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).celebrationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.date == item.date,
                              ),
                          typedResults: items,
                        ),
                      if (readingsRefs)
                        await $_getPrefetchedData<
                          CalendarDay,
                          $CalendarDaysTable,
                          Reading
                        >(
                          currentTable: table,
                          referencedTable: $$CalendarDaysTableReferences
                              ._readingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CalendarDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).readingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.date == item.date,
                              ),
                          typedResults: items,
                        ),
                      if (dailyActionsRefs)
                        await $_getPrefetchedData<
                          CalendarDay,
                          $CalendarDaysTable,
                          DailyAction
                        >(
                          currentTable: table,
                          referencedTable: $$CalendarDaysTableReferences
                              ._dailyActionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CalendarDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).dailyActionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.date == item.date,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CalendarDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalendarDaysTable,
      CalendarDay,
      $$CalendarDaysTableFilterComposer,
      $$CalendarDaysTableOrderingComposer,
      $$CalendarDaysTableAnnotationComposer,
      $$CalendarDaysTableCreateCompanionBuilder,
      $$CalendarDaysTableUpdateCompanionBuilder,
      (CalendarDay, $$CalendarDaysTableReferences),
      CalendarDay,
      PrefetchHooks Function({
        bool celebrationsRefs,
        bool readingsRefs,
        bool dailyActionsRefs,
      })
    >;
typedef $$CelebrationsTableCreateCompanionBuilder =
    CelebrationsCompanion Function({
      required String id,
      required String date,
      required String name,
      required String rank,
      Value<bool> isOptional,
      required String locale,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CelebrationsTableUpdateCompanionBuilder =
    CelebrationsCompanion Function({
      Value<String> id,
      Value<String> date,
      Value<String> name,
      Value<String> rank,
      Value<bool> isOptional,
      Value<String> locale,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CelebrationsTableReferences
    extends BaseReferences<_$AppDatabase, $CelebrationsTable, Celebration> {
  $$CelebrationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CalendarDaysTable _dateTable(_$AppDatabase db) =>
      db.calendarDays.createAlias(
        $_aliasNameGenerator(db.celebrations.date, db.calendarDays.date),
      );

  $$CalendarDaysTableProcessedTableManager get date {
    final $_column = $_itemColumn<String>('date')!;

    final manager = $$CalendarDaysTableTableManager(
      $_db,
      $_db.calendarDays,
    ).filter((f) => f.date.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dateTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CelebrationsTableFilterComposer
    extends Composer<_$AppDatabase, $CelebrationsTable> {
  $$CelebrationsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CalendarDaysTableFilterComposer get date {
    final $$CalendarDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.calendarDays,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarDaysTableFilterComposer(
            $db: $db,
            $table: $db.calendarDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CelebrationsTableOrderingComposer
    extends Composer<_$AppDatabase, $CelebrationsTable> {
  $$CelebrationsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CalendarDaysTableOrderingComposer get date {
    final $$CalendarDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.calendarDays,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarDaysTableOrderingComposer(
            $db: $db,
            $table: $db.calendarDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CelebrationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CelebrationsTable> {
  $$CelebrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CalendarDaysTableAnnotationComposer get date {
    final $$CalendarDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.calendarDays,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CelebrationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CelebrationsTable,
          Celebration,
          $$CelebrationsTableFilterComposer,
          $$CelebrationsTableOrderingComposer,
          $$CelebrationsTableAnnotationComposer,
          $$CelebrationsTableCreateCompanionBuilder,
          $$CelebrationsTableUpdateCompanionBuilder,
          (Celebration, $$CelebrationsTableReferences),
          Celebration,
          PrefetchHooks Function({bool date})
        > {
  $$CelebrationsTableTableManager(_$AppDatabase db, $CelebrationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CelebrationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CelebrationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CelebrationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> rank = const Value.absent(),
                Value<bool> isOptional = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CelebrationsCompanion(
                id: id,
                date: date,
                name: name,
                rank: rank,
                isOptional: isOptional,
                locale: locale,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String date,
                required String name,
                required String rank,
                Value<bool> isOptional = const Value.absent(),
                required String locale,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CelebrationsCompanion.insert(
                id: id,
                date: date,
                name: name,
                rank: rank,
                isOptional: isOptional,
                locale: locale,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CelebrationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({date = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (date) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.date,
                                referencedTable: $$CelebrationsTableReferences
                                    ._dateTable(db),
                                referencedColumn: $$CelebrationsTableReferences
                                    ._dateTable(db)
                                    .date,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CelebrationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CelebrationsTable,
      Celebration,
      $$CelebrationsTableFilterComposer,
      $$CelebrationsTableOrderingComposer,
      $$CelebrationsTableAnnotationComposer,
      $$CelebrationsTableCreateCompanionBuilder,
      $$CelebrationsTableUpdateCompanionBuilder,
      (Celebration, $$CelebrationsTableReferences),
      Celebration,
      PrefetchHooks Function({bool date})
    >;
typedef $$ReadingsTableCreateCompanionBuilder =
    ReadingsCompanion Function({
      required String id,
      required String date,
      required String type,
      required String citation,
      Value<String?> displayLabel,
      Value<String?> textContent,
      Value<String?> sourceUrl,
      required String license,
      required String locale,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ReadingsTableUpdateCompanionBuilder =
    ReadingsCompanion Function({
      Value<String> id,
      Value<String> date,
      Value<String> type,
      Value<String> citation,
      Value<String?> displayLabel,
      Value<String?> textContent,
      Value<String?> sourceUrl,
      Value<String> license,
      Value<String> locale,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ReadingsTableReferences
    extends BaseReferences<_$AppDatabase, $ReadingsTable, Reading> {
  $$ReadingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CalendarDaysTable _dateTable(_$AppDatabase db) =>
      db.calendarDays.createAlias(
        $_aliasNameGenerator(db.readings.date, db.calendarDays.date),
      );

  $$CalendarDaysTableProcessedTableManager get date {
    final $_column = $_itemColumn<String>('date')!;

    final manager = $$CalendarDaysTableTableManager(
      $_db,
      $_db.calendarDays,
    ).filter((f) => f.date.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dateTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get citation => $composableBuilder(
    column: $table.citation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CalendarDaysTableFilterComposer get date {
    final $$CalendarDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.calendarDays,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarDaysTableFilterComposer(
            $db: $db,
            $table: $db.calendarDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get citation => $composableBuilder(
    column: $table.citation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CalendarDaysTableOrderingComposer get date {
    final $$CalendarDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.calendarDays,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarDaysTableOrderingComposer(
            $db: $db,
            $table: $db.calendarDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get citation =>
      $composableBuilder(column: $table.citation, builder: (column) => column);

  GeneratedColumn<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get license =>
      $composableBuilder(column: $table.license, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CalendarDaysTableAnnotationComposer get date {
    final $$CalendarDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.calendarDays,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingsTable,
          Reading,
          $$ReadingsTableFilterComposer,
          $$ReadingsTableOrderingComposer,
          $$ReadingsTableAnnotationComposer,
          $$ReadingsTableCreateCompanionBuilder,
          $$ReadingsTableUpdateCompanionBuilder,
          (Reading, $$ReadingsTableReferences),
          Reading,
          PrefetchHooks Function({bool date})
        > {
  $$ReadingsTableTableManager(_$AppDatabase db, $ReadingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> citation = const Value.absent(),
                Value<String?> displayLabel = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String> license = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingsCompanion(
                id: id,
                date: date,
                type: type,
                citation: citation,
                displayLabel: displayLabel,
                textContent: textContent,
                sourceUrl: sourceUrl,
                license: license,
                locale: locale,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String date,
                required String type,
                required String citation,
                Value<String?> displayLabel = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                required String license,
                required String locale,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingsCompanion.insert(
                id: id,
                date: date,
                type: type,
                citation: citation,
                displayLabel: displayLabel,
                textContent: textContent,
                sourceUrl: sourceUrl,
                license: license,
                locale: locale,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReadingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({date = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (date) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.date,
                                referencedTable: $$ReadingsTableReferences
                                    ._dateTable(db),
                                referencedColumn: $$ReadingsTableReferences
                                    ._dateTable(db)
                                    .date,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingsTable,
      Reading,
      $$ReadingsTableFilterComposer,
      $$ReadingsTableOrderingComposer,
      $$ReadingsTableAnnotationComposer,
      $$ReadingsTableCreateCompanionBuilder,
      $$ReadingsTableUpdateCompanionBuilder,
      (Reading, $$ReadingsTableReferences),
      Reading,
      PrefetchHooks Function({bool date})
    >;
typedef $$ActionRulesTableCreateCompanionBuilder =
    ActionRulesCompanion Function({
      required String id,
      required String type,
      required String triggerCondition,
      required String templatePrompt,
      required int priority,
      Value<String?> locale,
      Value<String?> packId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ActionRulesTableUpdateCompanionBuilder =
    ActionRulesCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> triggerCondition,
      Value<String> templatePrompt,
      Value<int> priority,
      Value<String?> locale,
      Value<String?> packId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ActionRulesTableFilterComposer
    extends Composer<_$AppDatabase, $ActionRulesTable> {
  $$ActionRulesTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerCondition => $composableBuilder(
    column: $table.triggerCondition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templatePrompt => $composableBuilder(
    column: $table.templatePrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packId => $composableBuilder(
    column: $table.packId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActionRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActionRulesTable> {
  $$ActionRulesTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerCondition => $composableBuilder(
    column: $table.triggerCondition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templatePrompt => $composableBuilder(
    column: $table.templatePrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packId => $composableBuilder(
    column: $table.packId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActionRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActionRulesTable> {
  $$ActionRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get triggerCondition => $composableBuilder(
    column: $table.triggerCondition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templatePrompt => $composableBuilder(
    column: $table.templatePrompt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get packId =>
      $composableBuilder(column: $table.packId, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ActionRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActionRulesTable,
          ActionRule,
          $$ActionRulesTableFilterComposer,
          $$ActionRulesTableOrderingComposer,
          $$ActionRulesTableAnnotationComposer,
          $$ActionRulesTableCreateCompanionBuilder,
          $$ActionRulesTableUpdateCompanionBuilder,
          (
            ActionRule,
            BaseReferences<_$AppDatabase, $ActionRulesTable, ActionRule>,
          ),
          ActionRule,
          PrefetchHooks Function()
        > {
  $$ActionRulesTableTableManager(_$AppDatabase db, $ActionRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActionRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActionRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActionRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> triggerCondition = const Value.absent(),
                Value<String> templatePrompt = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String?> locale = const Value.absent(),
                Value<String?> packId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionRulesCompanion(
                id: id,
                type: type,
                triggerCondition: triggerCondition,
                templatePrompt: templatePrompt,
                priority: priority,
                locale: locale,
                packId: packId,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String triggerCondition,
                required String templatePrompt,
                required int priority,
                Value<String?> locale = const Value.absent(),
                Value<String?> packId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionRulesCompanion.insert(
                id: id,
                type: type,
                triggerCondition: triggerCondition,
                templatePrompt: templatePrompt,
                priority: priority,
                locale: locale,
                packId: packId,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActionRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActionRulesTable,
      ActionRule,
      $$ActionRulesTableFilterComposer,
      $$ActionRulesTableOrderingComposer,
      $$ActionRulesTableAnnotationComposer,
      $$ActionRulesTableCreateCompanionBuilder,
      $$ActionRulesTableUpdateCompanionBuilder,
      (
        ActionRule,
        BaseReferences<_$AppDatabase, $ActionRulesTable, ActionRule>,
      ),
      ActionRule,
      PrefetchHooks Function()
    >;
typedef $$DailyActionsTableCreateCompanionBuilder =
    DailyActionsCompanion Function({
      required String id,
      required String date,
      required String sourceRule,
      required String prompt,
      required String type,
      required int priority,
      required String locale,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$DailyActionsTableUpdateCompanionBuilder =
    DailyActionsCompanion Function({
      Value<String> id,
      Value<String> date,
      Value<String> sourceRule,
      Value<String> prompt,
      Value<String> type,
      Value<int> priority,
      Value<String> locale,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$DailyActionsTableReferences
    extends BaseReferences<_$AppDatabase, $DailyActionsTable, DailyAction> {
  $$DailyActionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CalendarDaysTable _dateTable(_$AppDatabase db) =>
      db.calendarDays.createAlias(
        $_aliasNameGenerator(db.dailyActions.date, db.calendarDays.date),
      );

  $$CalendarDaysTableProcessedTableManager get date {
    final $_column = $_itemColumn<String>('date')!;

    final manager = $$CalendarDaysTableTableManager(
      $_db,
      $_db.calendarDays,
    ).filter((f) => f.date.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dateTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ActionLogsTable, List<ActionLog>>
  _actionLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.actionLogs,
    aliasName: $_aliasNameGenerator(db.dailyActions.id, db.actionLogs.actionId),
  );

  $$ActionLogsTableProcessedTableManager get actionLogsRefs {
    final manager = $$ActionLogsTableTableManager(
      $_db,
      $_db.actionLogs,
    ).filter((f) => f.actionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_actionLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DailyActionsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyActionsTable> {
  $$DailyActionsTableFilterComposer({
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

  ColumnFilters<String> get sourceRule => $composableBuilder(
    column: $table.sourceRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CalendarDaysTableFilterComposer get date {
    final $$CalendarDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.calendarDays,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarDaysTableFilterComposer(
            $db: $db,
            $table: $db.calendarDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> actionLogsRefs(
    Expression<bool> Function($$ActionLogsTableFilterComposer f) f,
  ) {
    final $$ActionLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.actionLogs,
      getReferencedColumn: (t) => t.actionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActionLogsTableFilterComposer(
            $db: $db,
            $table: $db.actionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DailyActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyActionsTable> {
  $$DailyActionsTableOrderingComposer({
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

  ColumnOrderings<String> get sourceRule => $composableBuilder(
    column: $table.sourceRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CalendarDaysTableOrderingComposer get date {
    final $$CalendarDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.calendarDays,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarDaysTableOrderingComposer(
            $db: $db,
            $table: $db.calendarDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyActionsTable> {
  $$DailyActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceRule => $composableBuilder(
    column: $table.sourceRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CalendarDaysTableAnnotationComposer get date {
    final $$CalendarDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.date,
      referencedTable: $db.calendarDays,
      getReferencedColumn: (t) => t.date,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CalendarDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.calendarDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> actionLogsRefs<T extends Object>(
    Expression<T> Function($$ActionLogsTableAnnotationComposer a) f,
  ) {
    final $$ActionLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.actionLogs,
      getReferencedColumn: (t) => t.actionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActionLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.actionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DailyActionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyActionsTable,
          DailyAction,
          $$DailyActionsTableFilterComposer,
          $$DailyActionsTableOrderingComposer,
          $$DailyActionsTableAnnotationComposer,
          $$DailyActionsTableCreateCompanionBuilder,
          $$DailyActionsTableUpdateCompanionBuilder,
          (DailyAction, $$DailyActionsTableReferences),
          DailyAction,
          PrefetchHooks Function({bool date, bool actionLogsRefs})
        > {
  $$DailyActionsTableTableManager(_$AppDatabase db, $DailyActionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> sourceRule = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyActionsCompanion(
                id: id,
                date: date,
                sourceRule: sourceRule,
                prompt: prompt,
                type: type,
                priority: priority,
                locale: locale,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String date,
                required String sourceRule,
                required String prompt,
                required String type,
                required int priority,
                required String locale,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyActionsCompanion.insert(
                id: id,
                date: date,
                sourceRule: sourceRule,
                prompt: prompt,
                type: type,
                priority: priority,
                locale: locale,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DailyActionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({date = false, actionLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (actionLogsRefs) db.actionLogs],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (date) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.date,
                                referencedTable: $$DailyActionsTableReferences
                                    ._dateTable(db),
                                referencedColumn: $$DailyActionsTableReferences
                                    ._dateTable(db)
                                    .date,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (actionLogsRefs)
                    await $_getPrefetchedData<
                      DailyAction,
                      $DailyActionsTable,
                      ActionLog
                    >(
                      currentTable: table,
                      referencedTable: $$DailyActionsTableReferences
                          ._actionLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DailyActionsTableReferences(
                            db,
                            table,
                            p0,
                          ).actionLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.actionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DailyActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyActionsTable,
      DailyAction,
      $$DailyActionsTableFilterComposer,
      $$DailyActionsTableOrderingComposer,
      $$DailyActionsTableAnnotationComposer,
      $$DailyActionsTableCreateCompanionBuilder,
      $$DailyActionsTableUpdateCompanionBuilder,
      (DailyAction, $$DailyActionsTableReferences),
      DailyAction,
      PrefetchHooks Function({bool date, bool actionLogsRefs})
    >;
typedef $$ActionLogsTableCreateCompanionBuilder =
    ActionLogsCompanion Function({
      required String id,
      required String actionId,
      required String date,
      Value<String> status,
      Value<DateTime?> completedAt,
      Value<String?> note,
      Value<String?> selfCheckProofMetadata,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ActionLogsTableUpdateCompanionBuilder =
    ActionLogsCompanion Function({
      Value<String> id,
      Value<String> actionId,
      Value<String> date,
      Value<String> status,
      Value<DateTime?> completedAt,
      Value<String?> note,
      Value<String?> selfCheckProofMetadata,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ActionLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ActionLogsTable, ActionLog> {
  $$ActionLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DailyActionsTable _actionIdTable(_$AppDatabase db) =>
      db.dailyActions.createAlias(
        $_aliasNameGenerator(db.actionLogs.actionId, db.dailyActions.id),
      );

  $$DailyActionsTableProcessedTableManager get actionId {
    final $_column = $_itemColumn<String>('action_id')!;

    final manager = $$DailyActionsTableTableManager(
      $_db,
      $_db.dailyActions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_actionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActionLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ActionLogsTable> {
  $$ActionLogsTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selfCheckProofMetadata => $composableBuilder(
    column: $table.selfCheckProofMetadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DailyActionsTableFilterComposer get actionId {
    final $$DailyActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionId,
      referencedTable: $db.dailyActions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyActionsTableFilterComposer(
            $db: $db,
            $table: $db.dailyActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActionLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActionLogsTable> {
  $$ActionLogsTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selfCheckProofMetadata => $composableBuilder(
    column: $table.selfCheckProofMetadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DailyActionsTableOrderingComposer get actionId {
    final $$DailyActionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionId,
      referencedTable: $db.dailyActions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyActionsTableOrderingComposer(
            $db: $db,
            $table: $db.dailyActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActionLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActionLogsTable> {
  $$ActionLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get selfCheckProofMetadata => $composableBuilder(
    column: $table.selfCheckProofMetadata,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DailyActionsTableAnnotationComposer get actionId {
    final $$DailyActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionId,
      referencedTable: $db.dailyActions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActionLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActionLogsTable,
          ActionLog,
          $$ActionLogsTableFilterComposer,
          $$ActionLogsTableOrderingComposer,
          $$ActionLogsTableAnnotationComposer,
          $$ActionLogsTableCreateCompanionBuilder,
          $$ActionLogsTableUpdateCompanionBuilder,
          (ActionLog, $$ActionLogsTableReferences),
          ActionLog,
          PrefetchHooks Function({bool actionId})
        > {
  $$ActionLogsTableTableManager(_$AppDatabase db, $ActionLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActionLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActionLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActionLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> actionId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> selfCheckProofMetadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionLogsCompanion(
                id: id,
                actionId: actionId,
                date: date,
                status: status,
                completedAt: completedAt,
                note: note,
                selfCheckProofMetadata: selfCheckProofMetadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String actionId,
                required String date,
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> selfCheckProofMetadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionLogsCompanion.insert(
                id: id,
                actionId: actionId,
                date: date,
                status: status,
                completedAt: completedAt,
                note: note,
                selfCheckProofMetadata: selfCheckProofMetadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActionLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({actionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (actionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.actionId,
                                referencedTable: $$ActionLogsTableReferences
                                    ._actionIdTable(db),
                                referencedColumn: $$ActionLogsTableReferences
                                    ._actionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ActionLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActionLogsTable,
      ActionLog,
      $$ActionLogsTableFilterComposer,
      $$ActionLogsTableOrderingComposer,
      $$ActionLogsTableAnnotationComposer,
      $$ActionLogsTableCreateCompanionBuilder,
      $$ActionLogsTableUpdateCompanionBuilder,
      (ActionLog, $$ActionLogsTableReferences),
      ActionLog,
      PrefetchHooks Function({bool actionId})
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          UserSetting,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            UserSetting,
            BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>,
          ),
          UserSetting,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      UserSetting,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        UserSetting,
        BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>,
      ),
      UserSetting,
      PrefetchHooks Function()
    >;
typedef $$WidgetSnapshotsTableCreateCompanionBuilder =
    WidgetSnapshotsCompanion Function({
      required String date,
      required String payload,
      required DateTime generatedAt,
      Value<int> rowid,
    });
typedef $$WidgetSnapshotsTableUpdateCompanionBuilder =
    WidgetSnapshotsCompanion Function({
      Value<String> date,
      Value<String> payload,
      Value<DateTime> generatedAt,
      Value<int> rowid,
    });

class $$WidgetSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $WidgetSnapshotsTable> {
  $$WidgetSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WidgetSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $WidgetSnapshotsTable> {
  $$WidgetSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WidgetSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WidgetSnapshotsTable> {
  $$WidgetSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );
}

class $$WidgetSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WidgetSnapshotsTable,
          WidgetSnapshot,
          $$WidgetSnapshotsTableFilterComposer,
          $$WidgetSnapshotsTableOrderingComposer,
          $$WidgetSnapshotsTableAnnotationComposer,
          $$WidgetSnapshotsTableCreateCompanionBuilder,
          $$WidgetSnapshotsTableUpdateCompanionBuilder,
          (
            WidgetSnapshot,
            BaseReferences<
              _$AppDatabase,
              $WidgetSnapshotsTable,
              WidgetSnapshot
            >,
          ),
          WidgetSnapshot,
          PrefetchHooks Function()
        > {
  $$WidgetSnapshotsTableTableManager(
    _$AppDatabase db,
    $WidgetSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WidgetSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WidgetSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WidgetSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WidgetSnapshotsCompanion(
                date: date,
                payload: payload,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required String payload,
                required DateTime generatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WidgetSnapshotsCompanion.insert(
                date: date,
                payload: payload,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WidgetSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WidgetSnapshotsTable,
      WidgetSnapshot,
      $$WidgetSnapshotsTableFilterComposer,
      $$WidgetSnapshotsTableOrderingComposer,
      $$WidgetSnapshotsTableAnnotationComposer,
      $$WidgetSnapshotsTableCreateCompanionBuilder,
      $$WidgetSnapshotsTableUpdateCompanionBuilder,
      (
        WidgetSnapshot,
        BaseReferences<_$AppDatabase, $WidgetSnapshotsTable, WidgetSnapshot>,
      ),
      WidgetSnapshot,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CalendarDaysTableTableManager get calendarDays =>
      $$CalendarDaysTableTableManager(_db, _db.calendarDays);
  $$CelebrationsTableTableManager get celebrations =>
      $$CelebrationsTableTableManager(_db, _db.celebrations);
  $$ReadingsTableTableManager get readings =>
      $$ReadingsTableTableManager(_db, _db.readings);
  $$ActionRulesTableTableManager get actionRules =>
      $$ActionRulesTableTableManager(_db, _db.actionRules);
  $$DailyActionsTableTableManager get dailyActions =>
      $$DailyActionsTableTableManager(_db, _db.dailyActions);
  $$ActionLogsTableTableManager get actionLogs =>
      $$ActionLogsTableTableManager(_db, _db.actionLogs);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$WidgetSnapshotsTableTableManager get widgetSnapshots =>
      $$WidgetSnapshotsTableTableManager(_db, _db.widgetSnapshots);
}
