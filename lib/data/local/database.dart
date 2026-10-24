import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


part 'database.g.dart';

class CategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get colorHex => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SubscriptionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get serviceId => text().nullable()();
  RealColumn get price => real()();
  TextColumn get currency => text()();
  IntColumn get cycleUnit => integer()();
  IntColumn get cycleCount => integer()();
  DateTimeColumn get nextBillingDate => dateTime()();
  DateTimeColumn get firstBillingDate => dateTime().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get colorHex => text()();
  TextColumn get iconKey => text().nullable()();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isTrial => boolean().withDefault(const Constant(false))();
  DateTimeColumn get trialEndDate => dateTime().nullable()();
  BoolColumn get remindersEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get reminderDaysBefore => integer().withDefault(const Constant(1))();
  IntColumn get reminderTime => integer().withDefault(const Constant(540))();
  IntColumn get status => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PaymentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get subscriptionId => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text()();
  DateTimeColumn get paidAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CategoriesTable, SubscriptionsTable, PaymentsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Insert default categories could go here, or handled by the repository
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
