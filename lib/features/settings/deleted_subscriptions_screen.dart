import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/widgets/brand_logo.dart';
import '../../data/local/deleted_ids_store.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../domain/models/subscription.dart';

final deletedSubscriptionsProvider =
StreamProvider.autoDispose<List<Subscription>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).watchArchived();
});

/// Recently deleted: delete ki hui subscriptions. Yahan se wapas la sakte ho
/// (Restore) ya hamesha ke liye mita sakte ho (Delete).
class DeletedSubscriptionsScreen extends ConsumerWidget {
  const DeletedSubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedAsync = ref.watch(deletedSubscriptionsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Recently deleted')),
      body: deletedAsync.when(
        data: (subs) {
          if (subs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete, size: 110, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('No subscriptions deleted yet'),
                ],
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'recently deleted',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              for (final sub in subs) _DeletedCard(subscription: sub),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _DeletedCard extends ConsumerWidget {
  final Subscription subscription;

  const _DeletedCard({required this.subscription});

  Future<void> _restore(WidgetRef ref) async {
    await ref
        .read(subscriptionRepositoryProvider)
        .restoreDeleted(subscription.id);

    // Reminder dobara schedule karo (past ki date ho to khud skip ho jati hai)
    if (subscription.remindersEnabled) {
      try {
        await ref
            .read(notificationServiceProvider)
            .scheduleSubscriptionReminder(
          notificationId: subscription.id.hashCode,
          subscriptionName: subscription.name,
          billingDate: subscription.nextBillingDate,
          daysBefore: subscription.reminderDaysBefore,
          timeOfDayMinutes: subscription.reminderTime,
        );
      } catch (_) {
        // Reminder na lage to bhi restore ho chuki hai
      }
    }

  }

  Future<void> _deleteForever(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text('Delete permanently?'),
          content: Text(
            '"${subscription.name}" will be permanently deleted along with its '
                'payment history. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    // Is subscription ki scheduled reminder bhi cancel karo
    try {
      await ref
          .read(notificationServiceProvider)
          .cancelNotification(subscription.id.hashCode);
    } catch (_) {}

    // Pehle id yaad rakho taake Drive backup/restore ise wapas na laye,
    // phir database se mita do.
    await DeletedIdsStore().add(subscription.id);
    await ref
        .read(subscriptionRepositoryProvider)
        .deletePermanently(subscription.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final deletedAt = subscription.deletedAt;
    final priceText = '${subscription.price} ${subscription.currency}';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BrandLogo(
                  logoAsset: subscription.iconKey,
                  name: subscription.name,
                  colorHex: subscription.colorHex,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        deletedAt == null
                            ? priceText
                            : 'Deleted ${_formatDate(deletedAt)}  •  $priceText',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteForever(context, ref),
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.error.withOpacity(0.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _restore(ref),
                    icon: const Icon(Icons.restore),
                    label: const Text('Restore'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}