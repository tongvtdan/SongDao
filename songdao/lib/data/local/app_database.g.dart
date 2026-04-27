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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    sourceRule,
    prompt,
    type,
    priority,
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
  const DailyAction({
    required this.id,
    required this.date,
    required this.sourceRule,
    required this.prompt,
    required this.type,
    required this.priority,
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
    };
  }

  DailyAction copyWith({
    String? id,
    String? date,
    String? sourceRule,
    String? prompt,
    String? type,
    int? priority,
  }) => DailyAction(
    id: id ?? this.id,
    date: date ?? this.date,
    sourceRule: sourceRule ?? this.sourceRule,
    prompt: prompt ?? this.prompt,
    type: type ?? this.type,
    priority: priority ?? this.priority,
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
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, sourceRule, prompt, type, priority);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyAction &&
          other.id == this.id &&
          other.date == this.date &&
          other.sourceRule == this.sourceRule &&
          other.prompt == this.prompt &&
          other.type == this.type &&
          other.priority == this.priority);
}

class DailyActionsCompanion extends UpdateCompanion<DailyAction> {
  final Value<String> id;
  final Value<String> date;
  final Value<String> sourceRule;
  final Value<String> prompt;
  final Value<String> type;
  final Value<int> priority;
  final Value<int> rowid;
  const DailyActionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.sourceRule = const Value.absent(),
    this.prompt = const Value.absent(),
    this.type = const Value.absent(),
    this.priority = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyActionsCompanion.insert({
    required String id,
    required String date,
    required String sourceRule,
    required String prompt,
    required String type,
    required int priority,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       sourceRule = Value(sourceRule),
       prompt = Value(prompt),
       type = Value(type),
       priority = Value(priority);
  static Insertable<DailyAction> custom({
    Expression<String>? id,
    Expression<String>? date,
    Expression<String>? sourceRule,
    Expression<String>? prompt,
    Expression<String>? type,
    Expression<int>? priority,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (sourceRule != null) 'source_rule': sourceRule,
      if (prompt != null) 'prompt': prompt,
      if (type != null) 'type': type,
      if (priority != null) 'priority': priority,
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
    Value<int>? rowid,
  }) {
    return DailyActionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      sourceRule: sourceRule ?? this.sourceRule,
      prompt: prompt ?? this.prompt,
      type: type ?? this.type,
      priority: priority ?? this.priority,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actionId,
    completedAt,
    note,
    selfCheckProofMetadata,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
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
  final DateTime? completedAt;
  final String? note;
  final String? selfCheckProofMetadata;
  const ActionLog({
    required this.id,
    required this.actionId,
    this.completedAt,
    this.note,
    this.selfCheckProofMetadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['action_id'] = Variable<String>(actionId);
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
    return map;
  }

  ActionLogsCompanion toCompanion(bool nullToAbsent) {
    return ActionLogsCompanion(
      id: Value(id),
      actionId: Value(actionId),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      selfCheckProofMetadata: selfCheckProofMetadata == null && nullToAbsent
          ? const Value.absent()
          : Value(selfCheckProofMetadata),
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
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      note: serializer.fromJson<String?>(json['note']),
      selfCheckProofMetadata: serializer.fromJson<String?>(
        json['selfCheckProofMetadata'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'actionId': serializer.toJson<String>(actionId),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'note': serializer.toJson<String?>(note),
      'selfCheckProofMetadata': serializer.toJson<String?>(
        selfCheckProofMetadata,
      ),
    };
  }

  ActionLog copyWith({
    String? id,
    String? actionId,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> selfCheckProofMetadata = const Value.absent(),
  }) => ActionLog(
    id: id ?? this.id,
    actionId: actionId ?? this.actionId,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    note: note.present ? note.value : this.note,
    selfCheckProofMetadata: selfCheckProofMetadata.present
        ? selfCheckProofMetadata.value
        : this.selfCheckProofMetadata,
  );
  ActionLog copyWithCompanion(ActionLogsCompanion data) {
    return ActionLog(
      id: data.id.present ? data.id.value : this.id,
      actionId: data.actionId.present ? data.actionId.value : this.actionId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      note: data.note.present ? data.note.value : this.note,
      selfCheckProofMetadata: data.selfCheckProofMetadata.present
          ? data.selfCheckProofMetadata.value
          : this.selfCheckProofMetadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActionLog(')
          ..write('id: $id, ')
          ..write('actionId: $actionId, ')
          ..write('completedAt: $completedAt, ')
          ..write('note: $note, ')
          ..write('selfCheckProofMetadata: $selfCheckProofMetadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, actionId, completedAt, note, selfCheckProofMetadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionLog &&
          other.id == this.id &&
          other.actionId == this.actionId &&
          other.completedAt == this.completedAt &&
          other.note == this.note &&
          other.selfCheckProofMetadata == this.selfCheckProofMetadata);
}

class ActionLogsCompanion extends UpdateCompanion<ActionLog> {
  final Value<String> id;
  final Value<String> actionId;
  final Value<DateTime?> completedAt;
  final Value<String?> note;
  final Value<String?> selfCheckProofMetadata;
  final Value<int> rowid;
  const ActionLogsCompanion({
    this.id = const Value.absent(),
    this.actionId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.selfCheckProofMetadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActionLogsCompanion.insert({
    required String id,
    required String actionId,
    this.completedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.selfCheckProofMetadata = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       actionId = Value(actionId);
  static Insertable<ActionLog> custom({
    Expression<String>? id,
    Expression<String>? actionId,
    Expression<DateTime>? completedAt,
    Expression<String>? note,
    Expression<String>? selfCheckProofMetadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionId != null) 'action_id': actionId,
      if (completedAt != null) 'completed_at': completedAt,
      if (note != null) 'note': note,
      if (selfCheckProofMetadata != null)
        'self_check_proof_metadata': selfCheckProofMetadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActionLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? actionId,
    Value<DateTime?>? completedAt,
    Value<String?>? note,
    Value<String?>? selfCheckProofMetadata,
    Value<int>? rowid,
  }) {
    return ActionLogsCompanion(
      id: id ?? this.id,
      actionId: actionId ?? this.actionId,
      completedAt: completedAt ?? this.completedAt,
      note: note ?? this.note,
      selfCheckProofMetadata:
          selfCheckProofMetadata ?? this.selfCheckProofMetadata,
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
          ..write('completedAt: $completedAt, ')
          ..write('note: $note, ')
          ..write('selfCheckProofMetadata: $selfCheckProofMetadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CalendarDaysTable calendarDays = $CalendarDaysTable(this);
  late final $DailyActionsTable dailyActions = $DailyActionsTable(this);
  late final $ActionLogsTable actionLogs = $ActionLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    calendarDays,
    dailyActions,
    actionLogs,
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
          PrefetchHooks Function({bool dailyActionsRefs})
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
          prefetchHooksCallback: ({dailyActionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dailyActionsRefs) db.dailyActions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
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
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.date == item.date),
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
      PrefetchHooks Function({bool dailyActionsRefs})
    >;
typedef $$DailyActionsTableCreateCompanionBuilder =
    DailyActionsCompanion Function({
      required String id,
      required String date,
      required String sourceRule,
      required String prompt,
      required String type,
      required int priority,
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
                Value<int> rowid = const Value.absent(),
              }) => DailyActionsCompanion(
                id: id,
                date: date,
                sourceRule: sourceRule,
                prompt: prompt,
                type: type,
                priority: priority,
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
                Value<int> rowid = const Value.absent(),
              }) => DailyActionsCompanion.insert(
                id: id,
                date: date,
                sourceRule: sourceRule,
                prompt: prompt,
                type: type,
                priority: priority,
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
      Value<DateTime?> completedAt,
      Value<String?> note,
      Value<String?> selfCheckProofMetadata,
      Value<int> rowid,
    });
typedef $$ActionLogsTableUpdateCompanionBuilder =
    ActionLogsCompanion Function({
      Value<String> id,
      Value<String> actionId,
      Value<DateTime?> completedAt,
      Value<String?> note,
      Value<String?> selfCheckProofMetadata,
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
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> selfCheckProofMetadata = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionLogsCompanion(
                id: id,
                actionId: actionId,
                completedAt: completedAt,
                note: note,
                selfCheckProofMetadata: selfCheckProofMetadata,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String actionId,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> selfCheckProofMetadata = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionLogsCompanion.insert(
                id: id,
                actionId: actionId,
                completedAt: completedAt,
                note: note,
                selfCheckProofMetadata: selfCheckProofMetadata,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CalendarDaysTableTableManager get calendarDays =>
      $$CalendarDaysTableTableManager(_db, _db.calendarDays);
  $$DailyActionsTableTableManager get dailyActions =>
      $$DailyActionsTableTableManager(_db, _db.dailyActions);
  $$ActionLogsTableTableManager get actionLogs =>
      $$ActionLogsTableTableManager(_db, _db.actionLogs);
}
