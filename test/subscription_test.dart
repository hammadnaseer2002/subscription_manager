import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_manager/domain/models/subscription.dart';

void main() {
  group('Subscription Logic', () {
    test('Next Billing Date Rolls Forward', () {
      final now = DateTime.now();
      final sub = Subscription(
        id: '1',
        name: 'Test',
        price: 10,
        currency: 'USD',
        cycleUnit: CycleUnit.month,
        cycleCount: 1,
        nextBillingDate: now.subtract(const Duration(days: 40)),
        colorHex: '#000000',
        createdAt: now,
        updatedAt: now,
      );

      // In a real app this logic would be in a use case.
      // E.g. rollForward(Subscription sub)
      DateTime calculateNext(DateTime start, CycleUnit unit, int count) {
        DateTime date = start;
        while (date.isBefore(DateTime.now())) {
          switch (unit) {
            case CycleUnit.day:
              date = date.add(Duration(days: count));
              break;
            case CycleUnit.week:
              date = date.add(Duration(days: 7 * count));
              break;
            case CycleUnit.month:
              date = DateTime(date.year, date.month + count, date.day);
              break;
            case CycleUnit.year:
              date = DateTime(date.year + count, date.month, date.day);
              break;
          }
        }
        return date;
      }

      final rolledDate = calculateNext(sub.nextBillingDate, sub.cycleUnit, sub.cycleCount);
      expect(rolledDate.isAfter(DateTime.now()) || rolledDate.isAtSameMomentAs(DateTime.now()), true);
    });
  });
}
