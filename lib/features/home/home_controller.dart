import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/subscription.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../core/notifications/notification_service.dart';

final homeControllerProvider = StreamProvider<List<Subscription>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).watchAllActive();
});

class HomeControllerNotifier {
  final Ref ref;
  HomeControllerNotifier(this.ref);

  Future<void> deleteSubscription(String id) async {
    await ref.read(subscriptionRepositoryProvider).deleteSubscription(id);

    // Scheduled reminder bhi cancel karo (same id jo schedule karte waqt use hui thi)
    await ref.read(notificationServiceProvider).cancelNotification(id.hashCode);
  }
}

final homeControllerNotifierProvider = Provider((ref) => HomeControllerNotifier(ref));