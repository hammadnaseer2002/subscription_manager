import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'home_controller.dart';
import '../../domain/models/subscription.dart';
import '../../core/widgets/brand_logo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(homeControllerProvider);

    return Scaffold(
      // Analytics aur Settings ab tab bar mein hain, + button bhi tab bar mein hai
      appBar: AppBar(title: const Text('Subscriptions')),
      body: subscriptionsAsync.when(
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
            return _EmptyState(onAdd: () => context.push('/add'));
          }
          return _buildList(context, subscriptions);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

/// Upcoming jaisi list: date ke hisab se sort, aur Overdue / Today / This week /
/// This month / Later ke headers ke saath.
Widget _buildList(BuildContext context, List<Subscription> subscriptions) {
  final cs = Theme.of(context).colorScheme;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  int daysLeft(Subscription s) {
    final d = s.nextBillingDate;
    return DateTime(d.year, d.month, d.day).difference(today).inDays;
  }

  final sorted = [...subscriptions]
    ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));

  // Map ka order wahi rehta hai jo yahan likha hai
  final groups = <String, List<Subscription>>{
    'Overdue': [],
    'Today': [],
    'This week': [],
    'This month': [],
    'Later': [],
  };

  for (final s in sorted) {
    final d = daysLeft(s);
    if (d < 0) {
      groups['Overdue']!.add(s);
    } else if (d == 0) {
      groups['Today']!.add(s);
    } else if (d <= 7) {
      groups['This week']!.add(s);
    } else if (d <= 30) {
      groups['This month']!.add(s);
    } else {
      groups['Later']!.add(s);
    }
  }

  final children = <Widget>[];
  groups.forEach((title, items) {
    if (items.isEmpty) return;
    children.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: title == 'Overdue' ? cs.error : cs.primary,
          ),
        ),
      ),
    );
    for (final s in items) {
      children.add(_SubscriptionCard(subscription: s));
    }
  });

  return ListView(
    // Neeche tab bar ki jagah chhodni hai taake aakhri card na chhupe
    padding: EdgeInsets.only(
      bottom: 16 + MediaQuery.paddingOf(context).bottom,
    ),
    children: children,
  );
}

/// Jab koi subscription na ho tab dikhne wali screen.
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        // Neeche tab bar ki jagah chhodte hain taake content theek beech mein lage
        padding: EdgeInsets.fromLTRB(
          32,
          0,
          32,
          MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 56,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No subscriptions yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your subscriptions to track renewals and get a reminder before you are charged.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add your first subscription'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends ConsumerWidget {
  final Subscription subscription;

  const _SubscriptionCard({required this.subscription});

  // true  = card poora brand rang mein (purana look)
  // false = simple card (theme ka rang), sirf logo par brand rang
  static const bool _coloredCards = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final cardColor = _coloredCards
        ? _parseColor(subscription.colorHex)
        : cs.surfaceContainerLow;
    final textColor = _coloredCards ? _getTextColor(cardColor) : cs.onSurface;

    // Countdown chip ka rang (Upcoming jaisa): jaldi wali payment par zyada nazar aane wala
    final days = _daysLeft(subscription.nextBillingDate);
    Color pillBg;
    Color pillFg;
    if (_coloredCards) {
      pillBg = textColor.withOpacity(0.15);
      pillFg = textColor;
    } else if (days < 0) {
      pillBg = cs.errorContainer;
      pillFg = cs.onErrorContainer;
    } else if (days <= 1) {
      pillBg = cs.tertiaryContainer;
      pillFg = cs.onTertiaryContainer;
    } else {
      pillBg = cs.surfaceContainerHighest;
      pillFg = cs.onSurfaceVariant;
    }

    return Dismissible(
      key: Key(subscription.id),
      direction: DismissDirection.endToStart,
      // Swipe par pehle confirm poocho; Cancel par card wapas apni jagah aa jata hai.
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete subscription?'),
            content: Text(
              'Are you sure you want to delete ${subscription.name}? Its reminder will also be cancelled.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        return confirmed ?? false;
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref
            .read(homeControllerNotifierProvider)
            .deleteSubscription(subscription.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: cardColor,
        elevation: _coloredCards ? null : 0,
        shape: _coloredCards
            ? null
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListTile(
          onTap: () => context.push('/details/${subscription.id}'),
          leading: BrandLogo(
            logoAsset: subscription.iconKey,
            name: subscription.name,
            colorHex: subscription.colorHex,
          ),
          title: Text(
            subscription.name,
            style: TextStyle(color: textColor),
          ),
          subtitle: Text(
            '${_formatDate(subscription.nextBillingDate)}  •  ${subscription.price} ${subscription.currency}',
            style: TextStyle(color: textColor.withOpacity(0.8)),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getCountdown(subscription.nextBillingDate),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: pillFg,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Color _getTextColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  int _daysLeft(DateTime date) {
    final now = DateTime.now();
    return date.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  String _getCountdown(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff < 0) return 'OVERDUE';
    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'TOMORROW';
    if (diff < 30) return '$diff DAYS';
    return '${(diff / 30).floor()} MONTHS';
  }
}