import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../domain/models/subscription.dart';
import 'notification_service.dart';

final reminderSyncProvider = Provider<ReminderSync>((ref) {
  return ReminderSync(ref);
});

/// Har subscription ke liye:
///  1. Agar billing date guzar chuki hai to usay agle cycle tak aage barhata hai.
///  2. Reminder dobara schedule karta hai (same id => purana replace ho jata hai).
///  3. Archived / reminders-off subscriptions ki notification cancel karta hai.
class ReminderSync {
  final Ref ref;
  ReminderSync(this.ref);

  Future<void> syncAll() async {
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final notifications = ref.read(notificationServiceProvider);

      final subs = await repo.getAllSubscriptions();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (final sub in subs) {
        final notificationId = sub.id.hashCode;

        // Delete / paused subscriptions ki notification nahi chahiye
        if (sub.status != SubscriptionStatus.active) {
          await notifications.cancelNotification(notificationId);
          continue;
        }

        // 1) Billing date guzar gayi ho to agle cycle tak aage barhao
        var next = sub.nextBillingDate;
        var changed = false;
        var guard = 0;
        while (DateTime(next.year, next.month, next.day).isBefore(today) &&
            guard < 10000) {
          next = _addCycle(next, sub.cycleUnit, sub.cycleCount);
          changed = true;
          guard++;
        }

        var current = sub;
        if (changed) {
          current = sub.copyWith(nextBillingDate: next, updatedAt: DateTime.now());
          await repo.updateSubscription(current);
        }

        // 2) Reminder schedule / cancel
        if (current.remindersEnabled) {
          await notifications.scheduleSubscriptionReminder(
            notificationId: notificationId,
            subscriptionName: current.name,
            billingDate: current.nextBillingDate,
            daysBefore: current.reminderDaysBefore,
            timeOfDayMinutes: current.reminderTime,
          );
        } else {
          await notifications.cancelNotification(notificationId);
        }
      }
    } catch (_) {
      // Sync fail ho to app crash na ho
    }
  }

  DateTime _addCycle(DateTime date, CycleUnit unit, int count) {
    final n = count < 1 ? 1 : count;
    switch (unit) {
      case CycleUnit.day:
        return DateTime(date.year, date.month, date.day + n);
      case CycleUnit.week:
        return DateTime(date.year, date.month, date.day + 7 * n);
      case CycleUnit.month:
        return _addMonths(date, n);
      case CycleUnit.year:
        return _addMonths(date, 12 * n);
    }
  }

  /// Month add karta hai aur din ko mahine ke akhri din tak clamp karta hai
  /// (e.g. 31 Jan + 1 month => 28/29 Feb).
  DateTime _addMonths(DateTime date, int months) {
    final total = date.month - 1 + months;
    final year = date.year + total ~/ 12;
    final month = total % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;
    return DateTime(year, month, day);
  }
}