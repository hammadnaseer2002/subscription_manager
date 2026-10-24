import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/subscription.dart' as model;
import '../../domain/models/payment.dart';
import '../local/database.dart';
import '../local/deleted_ids_store.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(appDatabaseProvider));
});

class SubscriptionRepository {
  final AppDatabase _db;

  SubscriptionRepository(this._db);

  Stream<List<model.Subscription>> watchAllActive() {
    final query = _db.select(_db.subscriptionsTable)
      ..where((tbl) => tbl.status.equals(model.SubscriptionStatus.active.index));
    return query.watch().map((rows) => rows.map((row) => _mapToModel(row)).toList());
  }

  Future<List<model.Subscription>> getAllSubscriptions() async {
    final query = _db.select(_db.subscriptionsTable);
    final rows = await query.get();
    return rows.map((row) => _mapToModel(row)).toList();
  }

  Future<model.Subscription> getSubscription(String id) async {
    final query = _db.select(_db.subscriptionsTable)..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingle();
    return _mapToModel(row);
  }

  Future<void> addSubscription(model.Subscription sub) async {
    await _db.into(_db.subscriptionsTable).insert(_mapToDb(sub));
  }

  Future<void> updateSubscription(model.Subscription sub) async {
    await _db.update(_db.subscriptionsTable).replace(_mapToDb(sub));
  }

  /// Drive se aayi subscriptions phone mein daalo, lekin sirf wo jo phone ki
  /// apni copy se zyada nayi hon (updatedAt). Barabar ho to phone wali rehti hai,
  /// taake restore se phone ke naye changes na mitein.
  Future<void> restoreSubscriptions(List<model.Subscription> subscriptions) async {
    final local = await getAllSubscriptions();
    final localById = {for (final s in local) s.id: s};

    final toWrite = subscriptions.where((s) {
      final mine = localById[s.id];
      return mine == null || s.updatedAt.isAfter(mine.updatedAt);
    }).toList();
    if (toWrite.isEmpty) return;

    await _db.batch((batch) {
      batch.insertAll(
        _db.subscriptionsTable,
        toWrite.map(_mapToDb).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> deleteSubscription(String id) async {
    final query = _db.update(_db.subscriptionsTable)..where((tbl) => tbl.id.equals(id));
    await query.write(SubscriptionsTableCompanion(
      status: Value(model.SubscriptionStatus.archived.index),
      deletedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()), // Drive merge mein delete sahi jeete
    ));
  }

  /// Subscription aur uski payment history hamesha ke liye mita do.
  Future<void> deletePermanently(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.paymentsTable)
        ..where((tbl) => tbl.subscriptionId.equals(id)))
          .go();
      await (_db.delete(_db.subscriptionsTable)
        ..where((tbl) => tbl.id.equals(id)))
          .go();
    });
  }

  /// Delete ki hui (archived) subscriptions, sab se nayi delete pehle.
  Stream<List<model.Subscription>> watchArchived() {
    final query = _db.select(_db.subscriptionsTable)
      ..where((tbl) => tbl.status.equals(model.SubscriptionStatus.archived.index))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.deletedAt)]);
    return query.watch().map((rows) => rows.map((row) => _mapToModel(row)).toList());
  }

  /// Delete ki hui subscription wapas active kar do.
  /// updatedAt abhi ka kiya jata hai taake Drive backup merge mein ye version jeete.
  Future<void> restoreDeleted(String id) async {
    final query = _db.update(_db.subscriptionsTable)..where((tbl) => tbl.id.equals(id));
    await query.write(SubscriptionsTableCompanion(
      status: Value(model.SubscriptionStatus.active.index),
      deletedAt: const Value<DateTime?>(null),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // ---------- Details screen ke liye ----------

  /// Ek subscription ko live watch karta hai (archived bhi, taake screen crash na ho).
  Stream<model.Subscription?> watchSubscription(String id) {
    final query = _db.select(_db.subscriptionsTable)
      ..where((tbl) => tbl.id.equals(id));
    return query
        .watchSingleOrNull()
        .map((row) => row == null ? null : _mapToModel(row));
  }

  /// Payment history, sab se nayi pehle.
  Stream<List<Payment>> watchPayments(String subscriptionId) {
    final query = _db.select(_db.paymentsTable)
      ..where((tbl) => tbl.subscriptionId.equals(subscriptionId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.paidAt)]);
    return query.watch().map(
          (rows) => rows
          .map(
            (r) => Payment(
          id: r.id,
          subscriptionId: r.subscriptionId,
          amount: r.amount,
          currency: r.currency,
          paidAt: r.paidAt,
          updatedAt: r.updatedAt,
        ),
      )
          .toList(),
    );
  }

  /// Payment save karo aur next billing date aage barha do (ek transaction mein).
  Future<void> recordPayment(
      model.Subscription sub,
      Payment payment,
      DateTime newNextBillingDate,
      ) async {
    await _db.transaction(() async {
      await _db.into(_db.paymentsTable).insert(
        PaymentsTableCompanion.insert(
          id: payment.id,
          subscriptionId: payment.subscriptionId,
          amount: payment.amount,
          currency: payment.currency,
          paidAt: payment.paidAt,
          updatedAt: payment.updatedAt,
        ),
      );
      await updateSubscription(
        sub.copyWith(
          nextBillingDate: newNextBillingDate,
          updatedAt: DateTime.now(),
        ),
      );
    });
  }

  Future<void> deletePayment(String id) async {
    // Id yaad rakho taake Drive backup/restore ye payment wapas na laye
    await DeletedIdsStore().add(id);
    await (_db.delete(_db.paymentsTable)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  /// Saari payments (Drive backup ke liye).
  Future<List<Payment>> getAllPayments() async {
    final rows = await _db.select(_db.paymentsTable).get();
    return rows
        .map(
          (r) => Payment(
        id: r.id,
        subscriptionId: r.subscriptionId,
        amount: r.amount,
        currency: r.currency,
        paidAt: r.paidAt,
        updatedAt: r.updatedAt,
      ),
    )
        .toList();
  }

  /// Drive se aayi payments daalo. Jo pehle se hain unhein nahi chheda jata,
  /// aur jin subscriptions ka phone mein wujood nahi unki payments chhod di jati hain.
  Future<void> restorePayments(List<Payment> payments) async {
    if (payments.isEmpty) return;
    final subIds = (await getAllSubscriptions()).map((s) => s.id).toSet();
    final valid = payments.where((p) => subIds.contains(p.subscriptionId));
    await _db.batch((batch) {
      batch.insertAll(
        _db.paymentsTable,
        valid
            .map(
              (p) => PaymentsTableCompanion.insert(
            id: p.id,
            subscriptionId: p.subscriptionId,
            amount: p.amount,
            currency: p.currency,
            paidAt: p.paidAt,
            updatedAt: p.updatedAt,
          ),
        )
            .toList(),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  model.Subscription _mapToModel(SubscriptionsTableData row) {
    return model.Subscription(
      id: row.id,
      name: row.name,
      serviceId: row.serviceId,
      price: row.price,
      currency: row.currency,
      cycleUnit: model.CycleUnit.values[row.cycleUnit],
      cycleCount: row.cycleCount,
      nextBillingDate: row.nextBillingDate,
      firstBillingDate: row.firstBillingDate,
      categoryId: row.categoryId,
      colorHex: row.colorHex,
      iconKey: row.iconKey,
      paymentMethod: row.paymentMethod,
      notes: row.notes,
      isTrial: row.isTrial,
      trialEndDate: row.trialEndDate,
      remindersEnabled: row.remindersEnabled,
      reminderDaysBefore: row.reminderDaysBefore,
      reminderTime: row.reminderTime,
      status: model.SubscriptionStatus.values[row.status],
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  SubscriptionsTableCompanion _mapToDb(model.Subscription model) {
    return SubscriptionsTableCompanion.insert(
      id: model.id,
      name: model.name,
      serviceId: Value(model.serviceId),
      price: model.price,
      currency: model.currency,
      cycleUnit: model.cycleUnit.index,
      cycleCount: model.cycleCount,
      nextBillingDate: model.nextBillingDate,
      firstBillingDate: Value(model.firstBillingDate),
      categoryId: Value(model.categoryId),
      colorHex: model.colorHex,
      iconKey: Value(model.iconKey),
      paymentMethod: Value(model.paymentMethod),
      notes: Value(model.notes),
      isTrial: Value(model.isTrial),
      trialEndDate: Value(model.trialEndDate),
      remindersEnabled: Value(model.remindersEnabled),
      reminderDaysBefore: Value(model.reminderDaysBefore),
      reminderTime: Value(model.reminderTime),
      status: model.status.index,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deletedAt: Value(model.deletedAt),
    );
  }
}