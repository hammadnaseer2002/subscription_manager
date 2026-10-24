// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTableTable extends CategoriesTable
    with TableInfo<$CategoriesTableTable, CategoriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, colorHex, isDefault, updatedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<CategoriesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoriesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $CategoriesTableTable createAlias(String alias) {
    return $CategoriesTableTable(attachedDatabase, alias);
  }
}

class CategoriesTableData extends DataClass
    implements Insertable<CategoriesTableData> {
  final String id;
  final String name;
  final String colorHex;
  final bool isDefault;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const CategoriesTableData(
      {required this.id,
      required this.name,
      required this.colorHex,
      required this.isDefault,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    map['is_default'] = Variable<bool>(isDefault);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CategoriesTableCompanion toCompanion(bool nullToAbsent) {
    return CategoriesTableCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: Value(colorHex),
      isDefault: Value(isDefault),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CategoriesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoriesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'isDefault': serializer.toJson<bool>(isDefault),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CategoriesTableData copyWith(
          {String? id,
          String? name,
          String? colorHex,
          bool? isDefault,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      CategoriesTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        colorHex: colorHex ?? this.colorHex,
        isDefault: isDefault ?? this.isDefault,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  @override
  String toString() {
    return (StringBuffer('CategoriesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('isDefault: $isDefault, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, colorHex, isDefault, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoriesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.isDefault == this.isDefault &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CategoriesTableCompanion extends UpdateCompanion<CategoriesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<bool> isDefault;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CategoriesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesTableCompanion.insert({
    required String id,
    required String name,
    required String colorHex,
    this.isDefault = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        colorHex = Value(colorHex),
        updatedAt = Value(updatedAt);
  static Insertable<CategoriesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<bool>? isDefault,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (isDefault != null) 'is_default': isDefault,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? colorHex,
      Value<bool>? isDefault,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return CategoriesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      isDefault: isDefault ?? this.isDefault,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('isDefault: $isDefault, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionsTableTable extends SubscriptionsTable
    with TableInfo<$SubscriptionsTableTable, SubscriptionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceIdMeta =
      const VerificationMeta('serviceId');
  @override
  late final GeneratedColumn<String> serviceId = GeneratedColumn<String>(
      'service_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cycleUnitMeta =
      const VerificationMeta('cycleUnit');
  @override
  late final GeneratedColumn<int> cycleUnit = GeneratedColumn<int>(
      'cycle_unit', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cycleCountMeta =
      const VerificationMeta('cycleCount');
  @override
  late final GeneratedColumn<int> cycleCount = GeneratedColumn<int>(
      'cycle_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nextBillingDateMeta =
      const VerificationMeta('nextBillingDate');
  @override
  late final GeneratedColumn<DateTime> nextBillingDate =
      GeneratedColumn<DateTime>('next_billing_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _firstBillingDateMeta =
      const VerificationMeta('firstBillingDate');
  @override
  late final GeneratedColumn<DateTime> firstBillingDate =
      GeneratedColumn<DateTime>('first_billing_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconKeyMeta =
      const VerificationMeta('iconKey');
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
      'icon_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isTrialMeta =
      const VerificationMeta('isTrial');
  @override
  late final GeneratedColumn<bool> isTrial = GeneratedColumn<bool>(
      'is_trial', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_trial" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _trialEndDateMeta =
      const VerificationMeta('trialEndDate');
  @override
  late final GeneratedColumn<DateTime> trialEndDate = GeneratedColumn<DateTime>(
      'trial_end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _remindersEnabledMeta =
      const VerificationMeta('remindersEnabled');
  @override
  late final GeneratedColumn<bool> remindersEnabled = GeneratedColumn<bool>(
      'reminders_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reminders_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _reminderDaysBeforeMeta =
      const VerificationMeta('reminderDaysBefore');
  @override
  late final GeneratedColumn<int> reminderDaysBefore = GeneratedColumn<int>(
      'reminder_days_before', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _reminderTimeMeta =
      const VerificationMeta('reminderTime');
  @override
  late final GeneratedColumn<int> reminderTime = GeneratedColumn<int>(
      'reminder_time', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(540));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        serviceId,
        price,
        currency,
        cycleUnit,
        cycleCount,
        nextBillingDate,
        firstBillingDate,
        categoryId,
        colorHex,
        iconKey,
        paymentMethod,
        notes,
        isTrial,
        trialEndDate,
        remindersEnabled,
        reminderDaysBefore,
        reminderTime,
        status,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<SubscriptionsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('service_id')) {
      context.handle(_serviceIdMeta,
          serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta));
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('cycle_unit')) {
      context.handle(_cycleUnitMeta,
          cycleUnit.isAcceptableOrUnknown(data['cycle_unit']!, _cycleUnitMeta));
    } else if (isInserting) {
      context.missing(_cycleUnitMeta);
    }
    if (data.containsKey('cycle_count')) {
      context.handle(
          _cycleCountMeta,
          cycleCount.isAcceptableOrUnknown(
              data['cycle_count']!, _cycleCountMeta));
    } else if (isInserting) {
      context.missing(_cycleCountMeta);
    }
    if (data.containsKey('next_billing_date')) {
      context.handle(
          _nextBillingDateMeta,
          nextBillingDate.isAcceptableOrUnknown(
              data['next_billing_date']!, _nextBillingDateMeta));
    } else if (isInserting) {
      context.missing(_nextBillingDateMeta);
    }
    if (data.containsKey('first_billing_date')) {
      context.handle(
          _firstBillingDateMeta,
          firstBillingDate.isAcceptableOrUnknown(
              data['first_billing_date']!, _firstBillingDateMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(_iconKeyMeta,
          iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta));
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_trial')) {
      context.handle(_isTrialMeta,
          isTrial.isAcceptableOrUnknown(data['is_trial']!, _isTrialMeta));
    }
    if (data.containsKey('trial_end_date')) {
      context.handle(
          _trialEndDateMeta,
          trialEndDate.isAcceptableOrUnknown(
              data['trial_end_date']!, _trialEndDateMeta));
    }
    if (data.containsKey('reminders_enabled')) {
      context.handle(
          _remindersEnabledMeta,
          remindersEnabled.isAcceptableOrUnknown(
              data['reminders_enabled']!, _remindersEnabledMeta));
    }
    if (data.containsKey('reminder_days_before')) {
      context.handle(
          _reminderDaysBeforeMeta,
          reminderDaysBefore.isAcceptableOrUnknown(
              data['reminder_days_before']!, _reminderDaysBeforeMeta));
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
          _reminderTimeMeta,
          reminderTime.isAcceptableOrUnknown(
              data['reminder_time']!, _reminderTimeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubscriptionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      serviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_id']),
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      cycleUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cycle_unit'])!,
      cycleCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cycle_count'])!,
      nextBillingDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_billing_date'])!,
      firstBillingDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}first_billing_date']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      iconKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_key']),
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isTrial: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_trial'])!,
      trialEndDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}trial_end_date']),
      remindersEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}reminders_enabled'])!,
      reminderDaysBefore: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}reminder_days_before'])!,
      reminderTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reminder_time'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $SubscriptionsTableTable createAlias(String alias) {
    return $SubscriptionsTableTable(attachedDatabase, alias);
  }
}

class SubscriptionsTableData extends DataClass
    implements Insertable<SubscriptionsTableData> {
  final String id;
  final String name;
  final String? serviceId;
  final double price;
  final String currency;
  final int cycleUnit;
  final int cycleCount;
  final DateTime nextBillingDate;
  final DateTime? firstBillingDate;
  final String? categoryId;
  final String colorHex;
  final String? iconKey;
  final String? paymentMethod;
  final String? notes;
  final bool isTrial;
  final DateTime? trialEndDate;
  final bool remindersEnabled;
  final int reminderDaysBefore;
  final int reminderTime;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const SubscriptionsTableData(
      {required this.id,
      required this.name,
      this.serviceId,
      required this.price,
      required this.currency,
      required this.cycleUnit,
      required this.cycleCount,
      required this.nextBillingDate,
      this.firstBillingDate,
      this.categoryId,
      required this.colorHex,
      this.iconKey,
      this.paymentMethod,
      this.notes,
      required this.isTrial,
      this.trialEndDate,
      required this.remindersEnabled,
      required this.reminderDaysBefore,
      required this.reminderTime,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || serviceId != null) {
      map['service_id'] = Variable<String>(serviceId);
    }
    map['price'] = Variable<double>(price);
    map['currency'] = Variable<String>(currency);
    map['cycle_unit'] = Variable<int>(cycleUnit);
    map['cycle_count'] = Variable<int>(cycleCount);
    map['next_billing_date'] = Variable<DateTime>(nextBillingDate);
    if (!nullToAbsent || firstBillingDate != null) {
      map['first_billing_date'] = Variable<DateTime>(firstBillingDate);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['color_hex'] = Variable<String>(colorHex);
    if (!nullToAbsent || iconKey != null) {
      map['icon_key'] = Variable<String>(iconKey);
    }
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_trial'] = Variable<bool>(isTrial);
    if (!nullToAbsent || trialEndDate != null) {
      map['trial_end_date'] = Variable<DateTime>(trialEndDate);
    }
    map['reminders_enabled'] = Variable<bool>(remindersEnabled);
    map['reminder_days_before'] = Variable<int>(reminderDaysBefore);
    map['reminder_time'] = Variable<int>(reminderTime);
    map['status'] = Variable<int>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SubscriptionsTableCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionsTableCompanion(
      id: Value(id),
      name: Value(name),
      serviceId: serviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceId),
      price: Value(price),
      currency: Value(currency),
      cycleUnit: Value(cycleUnit),
      cycleCount: Value(cycleCount),
      nextBillingDate: Value(nextBillingDate),
      firstBillingDate: firstBillingDate == null && nullToAbsent
          ? const Value.absent()
          : Value(firstBillingDate),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      colorHex: Value(colorHex),
      iconKey: iconKey == null && nullToAbsent
          ? const Value.absent()
          : Value(iconKey),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isTrial: Value(isTrial),
      trialEndDate: trialEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(trialEndDate),
      remindersEnabled: Value(remindersEnabled),
      reminderDaysBefore: Value(reminderDaysBefore),
      reminderTime: Value(reminderTime),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SubscriptionsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      serviceId: serializer.fromJson<String?>(json['serviceId']),
      price: serializer.fromJson<double>(json['price']),
      currency: serializer.fromJson<String>(json['currency']),
      cycleUnit: serializer.fromJson<int>(json['cycleUnit']),
      cycleCount: serializer.fromJson<int>(json['cycleCount']),
      nextBillingDate: serializer.fromJson<DateTime>(json['nextBillingDate']),
      firstBillingDate:
          serializer.fromJson<DateTime?>(json['firstBillingDate']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      iconKey: serializer.fromJson<String?>(json['iconKey']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      notes: serializer.fromJson<String?>(json['notes']),
      isTrial: serializer.fromJson<bool>(json['isTrial']),
      trialEndDate: serializer.fromJson<DateTime?>(json['trialEndDate']),
      remindersEnabled: serializer.fromJson<bool>(json['remindersEnabled']),
      reminderDaysBefore: serializer.fromJson<int>(json['reminderDaysBefore']),
      reminderTime: serializer.fromJson<int>(json['reminderTime']),
      status: serializer.fromJson<int>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'serviceId': serializer.toJson<String?>(serviceId),
      'price': serializer.toJson<double>(price),
      'currency': serializer.toJson<String>(currency),
      'cycleUnit': serializer.toJson<int>(cycleUnit),
      'cycleCount': serializer.toJson<int>(cycleCount),
      'nextBillingDate': serializer.toJson<DateTime>(nextBillingDate),
      'firstBillingDate': serializer.toJson<DateTime?>(firstBillingDate),
      'categoryId': serializer.toJson<String?>(categoryId),
      'colorHex': serializer.toJson<String>(colorHex),
      'iconKey': serializer.toJson<String?>(iconKey),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'notes': serializer.toJson<String?>(notes),
      'isTrial': serializer.toJson<bool>(isTrial),
      'trialEndDate': serializer.toJson<DateTime?>(trialEndDate),
      'remindersEnabled': serializer.toJson<bool>(remindersEnabled),
      'reminderDaysBefore': serializer.toJson<int>(reminderDaysBefore),
      'reminderTime': serializer.toJson<int>(reminderTime),
      'status': serializer.toJson<int>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  SubscriptionsTableData copyWith(
          {String? id,
          String? name,
          Value<String?> serviceId = const Value.absent(),
          double? price,
          String? currency,
          int? cycleUnit,
          int? cycleCount,
          DateTime? nextBillingDate,
          Value<DateTime?> firstBillingDate = const Value.absent(),
          Value<String?> categoryId = const Value.absent(),
          String? colorHex,
          Value<String?> iconKey = const Value.absent(),
          Value<String?> paymentMethod = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          bool? isTrial,
          Value<DateTime?> trialEndDate = const Value.absent(),
          bool? remindersEnabled,
          int? reminderDaysBefore,
          int? reminderTime,
          int? status,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      SubscriptionsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        serviceId: serviceId.present ? serviceId.value : this.serviceId,
        price: price ?? this.price,
        currency: currency ?? this.currency,
        cycleUnit: cycleUnit ?? this.cycleUnit,
        cycleCount: cycleCount ?? this.cycleCount,
        nextBillingDate: nextBillingDate ?? this.nextBillingDate,
        firstBillingDate: firstBillingDate.present
            ? firstBillingDate.value
            : this.firstBillingDate,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        colorHex: colorHex ?? this.colorHex,
        iconKey: iconKey.present ? iconKey.value : this.iconKey,
        paymentMethod:
            paymentMethod.present ? paymentMethod.value : this.paymentMethod,
        notes: notes.present ? notes.value : this.notes,
        isTrial: isTrial ?? this.isTrial,
        trialEndDate:
            trialEndDate.present ? trialEndDate.value : this.trialEndDate,
        remindersEnabled: remindersEnabled ?? this.remindersEnabled,
        reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
        reminderTime: reminderTime ?? this.reminderTime,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  @override
  String toString() {
    return (StringBuffer('SubscriptionsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('serviceId: $serviceId, ')
          ..write('price: $price, ')
          ..write('currency: $currency, ')
          ..write('cycleUnit: $cycleUnit, ')
          ..write('cycleCount: $cycleCount, ')
          ..write('nextBillingDate: $nextBillingDate, ')
          ..write('firstBillingDate: $firstBillingDate, ')
          ..write('categoryId: $categoryId, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconKey: $iconKey, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('notes: $notes, ')
          ..write('isTrial: $isTrial, ')
          ..write('trialEndDate: $trialEndDate, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('reminderDaysBefore: $reminderDaysBefore, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        serviceId,
        price,
        currency,
        cycleUnit,
        cycleCount,
        nextBillingDate,
        firstBillingDate,
        categoryId,
        colorHex,
        iconKey,
        paymentMethod,
        notes,
        isTrial,
        trialEndDate,
        remindersEnabled,
        reminderDaysBefore,
        reminderTime,
        status,
        createdAt,
        updatedAt,
        deletedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.serviceId == this.serviceId &&
          other.price == this.price &&
          other.currency == this.currency &&
          other.cycleUnit == this.cycleUnit &&
          other.cycleCount == this.cycleCount &&
          other.nextBillingDate == this.nextBillingDate &&
          other.firstBillingDate == this.firstBillingDate &&
          other.categoryId == this.categoryId &&
          other.colorHex == this.colorHex &&
          other.iconKey == this.iconKey &&
          other.paymentMethod == this.paymentMethod &&
          other.notes == this.notes &&
          other.isTrial == this.isTrial &&
          other.trialEndDate == this.trialEndDate &&
          other.remindersEnabled == this.remindersEnabled &&
          other.reminderDaysBefore == this.reminderDaysBefore &&
          other.reminderTime == this.reminderTime &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class SubscriptionsTableCompanion
    extends UpdateCompanion<SubscriptionsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> serviceId;
  final Value<double> price;
  final Value<String> currency;
  final Value<int> cycleUnit;
  final Value<int> cycleCount;
  final Value<DateTime> nextBillingDate;
  final Value<DateTime?> firstBillingDate;
  final Value<String?> categoryId;
  final Value<String> colorHex;
  final Value<String?> iconKey;
  final Value<String?> paymentMethod;
  final Value<String?> notes;
  final Value<bool> isTrial;
  final Value<DateTime?> trialEndDate;
  final Value<bool> remindersEnabled;
  final Value<int> reminderDaysBefore;
  final Value<int> reminderTime;
  final Value<int> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const SubscriptionsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.price = const Value.absent(),
    this.currency = const Value.absent(),
    this.cycleUnit = const Value.absent(),
    this.cycleCount = const Value.absent(),
    this.nextBillingDate = const Value.absent(),
    this.firstBillingDate = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.notes = const Value.absent(),
    this.isTrial = const Value.absent(),
    this.trialEndDate = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.reminderDaysBefore = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionsTableCompanion.insert({
    required String id,
    required String name,
    this.serviceId = const Value.absent(),
    required double price,
    required String currency,
    required int cycleUnit,
    required int cycleCount,
    required DateTime nextBillingDate,
    this.firstBillingDate = const Value.absent(),
    this.categoryId = const Value.absent(),
    required String colorHex,
    this.iconKey = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.notes = const Value.absent(),
    this.isTrial = const Value.absent(),
    this.trialEndDate = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.reminderDaysBefore = const Value.absent(),
    this.reminderTime = const Value.absent(),
    required int status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        price = Value(price),
        currency = Value(currency),
        cycleUnit = Value(cycleUnit),
        cycleCount = Value(cycleCount),
        nextBillingDate = Value(nextBillingDate),
        colorHex = Value(colorHex),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SubscriptionsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? serviceId,
    Expression<double>? price,
    Expression<String>? currency,
    Expression<int>? cycleUnit,
    Expression<int>? cycleCount,
    Expression<DateTime>? nextBillingDate,
    Expression<DateTime>? firstBillingDate,
    Expression<String>? categoryId,
    Expression<String>? colorHex,
    Expression<String>? iconKey,
    Expression<String>? paymentMethod,
    Expression<String>? notes,
    Expression<bool>? isTrial,
    Expression<DateTime>? trialEndDate,
    Expression<bool>? remindersEnabled,
    Expression<int>? reminderDaysBefore,
    Expression<int>? reminderTime,
    Expression<int>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (serviceId != null) 'service_id': serviceId,
      if (price != null) 'price': price,
      if (currency != null) 'currency': currency,
      if (cycleUnit != null) 'cycle_unit': cycleUnit,
      if (cycleCount != null) 'cycle_count': cycleCount,
      if (nextBillingDate != null) 'next_billing_date': nextBillingDate,
      if (firstBillingDate != null) 'first_billing_date': firstBillingDate,
      if (categoryId != null) 'category_id': categoryId,
      if (colorHex != null) 'color_hex': colorHex,
      if (iconKey != null) 'icon_key': iconKey,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (notes != null) 'notes': notes,
      if (isTrial != null) 'is_trial': isTrial,
      if (trialEndDate != null) 'trial_end_date': trialEndDate,
      if (remindersEnabled != null) 'reminders_enabled': remindersEnabled,
      if (reminderDaysBefore != null)
        'reminder_days_before': reminderDaysBefore,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? serviceId,
      Value<double>? price,
      Value<String>? currency,
      Value<int>? cycleUnit,
      Value<int>? cycleCount,
      Value<DateTime>? nextBillingDate,
      Value<DateTime?>? firstBillingDate,
      Value<String?>? categoryId,
      Value<String>? colorHex,
      Value<String?>? iconKey,
      Value<String?>? paymentMethod,
      Value<String?>? notes,
      Value<bool>? isTrial,
      Value<DateTime?>? trialEndDate,
      Value<bool>? remindersEnabled,
      Value<int>? reminderDaysBefore,
      Value<int>? reminderTime,
      Value<int>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return SubscriptionsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceId: serviceId ?? this.serviceId,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      cycleUnit: cycleUnit ?? this.cycleUnit,
      cycleCount: cycleCount ?? this.cycleCount,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      firstBillingDate: firstBillingDate ?? this.firstBillingDate,
      categoryId: categoryId ?? this.categoryId,
      colorHex: colorHex ?? this.colorHex,
      iconKey: iconKey ?? this.iconKey,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      isTrial: isTrial ?? this.isTrial,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      reminderTime: reminderTime ?? this.reminderTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<String>(serviceId.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (cycleUnit.present) {
      map['cycle_unit'] = Variable<int>(cycleUnit.value);
    }
    if (cycleCount.present) {
      map['cycle_count'] = Variable<int>(cycleCount.value);
    }
    if (nextBillingDate.present) {
      map['next_billing_date'] = Variable<DateTime>(nextBillingDate.value);
    }
    if (firstBillingDate.present) {
      map['first_billing_date'] = Variable<DateTime>(firstBillingDate.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isTrial.present) {
      map['is_trial'] = Variable<bool>(isTrial.value);
    }
    if (trialEndDate.present) {
      map['trial_end_date'] = Variable<DateTime>(trialEndDate.value);
    }
    if (remindersEnabled.present) {
      map['reminders_enabled'] = Variable<bool>(remindersEnabled.value);
    }
    if (reminderDaysBefore.present) {
      map['reminder_days_before'] = Variable<int>(reminderDaysBefore.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<int>(reminderTime.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('serviceId: $serviceId, ')
          ..write('price: $price, ')
          ..write('currency: $currency, ')
          ..write('cycleUnit: $cycleUnit, ')
          ..write('cycleCount: $cycleCount, ')
          ..write('nextBillingDate: $nextBillingDate, ')
          ..write('firstBillingDate: $firstBillingDate, ')
          ..write('categoryId: $categoryId, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconKey: $iconKey, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('notes: $notes, ')
          ..write('isTrial: $isTrial, ')
          ..write('trialEndDate: $trialEndDate, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('reminderDaysBefore: $reminderDaysBefore, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTableTable extends PaymentsTable
    with TableInfo<$PaymentsTableTable, PaymentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subscriptionIdMeta =
      const VerificationMeta('subscriptionId');
  @override
  late final GeneratedColumn<String> subscriptionId = GeneratedColumn<String>(
      'subscription_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
      'paid_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, subscriptionId, amount, currency, paidAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments_table';
  @override
  VerificationContext validateIntegrity(Insertable<PaymentsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subscription_id')) {
      context.handle(
          _subscriptionIdMeta,
          subscriptionId.isAcceptableOrUnknown(
              data['subscription_id']!, _subscriptionIdMeta));
    } else if (isInserting) {
      context.missing(_subscriptionIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('paid_at')) {
      context.handle(_paidAtMeta,
          paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta));
    } else if (isInserting) {
      context.missing(_paidAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subscriptionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}subscription_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      paidAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}paid_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PaymentsTableTable createAlias(String alias) {
    return $PaymentsTableTable(attachedDatabase, alias);
  }
}

class PaymentsTableData extends DataClass
    implements Insertable<PaymentsTableData> {
  final String id;
  final String subscriptionId;
  final double amount;
  final String currency;
  final DateTime paidAt;
  final DateTime updatedAt;
  const PaymentsTableData(
      {required this.id,
      required this.subscriptionId,
      required this.amount,
      required this.currency,
      required this.paidAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subscription_id'] = Variable<String>(subscriptionId);
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    map['paid_at'] = Variable<DateTime>(paidAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PaymentsTableCompanion toCompanion(bool nullToAbsent) {
    return PaymentsTableCompanion(
      id: Value(id),
      subscriptionId: Value(subscriptionId),
      amount: Value(amount),
      currency: Value(currency),
      paidAt: Value(paidAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PaymentsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentsTableData(
      id: serializer.fromJson<String>(json['id']),
      subscriptionId: serializer.fromJson<String>(json['subscriptionId']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subscriptionId': serializer.toJson<String>(subscriptionId),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'paidAt': serializer.toJson<DateTime>(paidAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PaymentsTableData copyWith(
          {String? id,
          String? subscriptionId,
          double? amount,
          String? currency,
          DateTime? paidAt,
          DateTime? updatedAt}) =>
      PaymentsTableData(
        id: id ?? this.id,
        subscriptionId: subscriptionId ?? this.subscriptionId,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        paidAt: paidAt ?? this.paidAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  @override
  String toString() {
    return (StringBuffer('PaymentsTableData(')
          ..write('id: $id, ')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('paidAt: $paidAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, subscriptionId, amount, currency, paidAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentsTableData &&
          other.id == this.id &&
          other.subscriptionId == this.subscriptionId &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.paidAt == this.paidAt &&
          other.updatedAt == this.updatedAt);
}

class PaymentsTableCompanion extends UpdateCompanion<PaymentsTableData> {
  final Value<String> id;
  final Value<String> subscriptionId;
  final Value<double> amount;
  final Value<String> currency;
  final Value<DateTime> paidAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PaymentsTableCompanion({
    this.id = const Value.absent(),
    this.subscriptionId = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsTableCompanion.insert({
    required String id,
    required String subscriptionId,
    required double amount,
    required String currency,
    required DateTime paidAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subscriptionId = Value(subscriptionId),
        amount = Value(amount),
        currency = Value(currency),
        paidAt = Value(paidAt),
        updatedAt = Value(updatedAt);
  static Insertable<PaymentsTableData> custom({
    Expression<String>? id,
    Expression<String>? subscriptionId,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<DateTime>? paidAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subscriptionId != null) 'subscription_id': subscriptionId,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (paidAt != null) 'paid_at': paidAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? subscriptionId,
      Value<double>? amount,
      Value<String>? currency,
      Value<DateTime>? paidAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PaymentsTableCompanion(
      id: id ?? this.id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paidAt: paidAt ?? this.paidAt,
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
    if (subscriptionId.present) {
      map['subscription_id'] = Variable<String>(subscriptionId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
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
    return (StringBuffer('PaymentsTableCompanion(')
          ..write('id: $id, ')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('paidAt: $paidAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $CategoriesTableTable categoriesTable =
      $CategoriesTableTable(this);
  late final $SubscriptionsTableTable subscriptionsTable =
      $SubscriptionsTableTable(this);
  late final $PaymentsTableTable paymentsTable = $PaymentsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [categoriesTable, subscriptionsTable, paymentsTable];
}
