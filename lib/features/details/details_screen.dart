import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/notifications/notification_service.dart';
import '../../core/widgets/brand_logo.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../domain/models/payment.dart';
import '../../domain/models/subscription.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final subscriptionDetailsProvider = StreamProvider.autoDispose
    .family<Subscription?, String>((ref, id) {
  return ref.watch(subscriptionRepositoryProvider).watchSubscription(id);
});

final subscriptionPaymentsProvider = StreamProvider.autoDispose
    .family<List<Payment>, String>((ref, id) {
  return ref.watch(subscriptionRepositoryProvider).watchPayments(id);
});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Color _parseColor(String hex) {
  var h = hex.startsWith('#') ? hex.substring(1) : hex;
  if (h.length == 6) h = 'FF$h';
  final v = int.tryParse(h, radix: 16);
  return v == null ? Colors.grey : Color(v);
}

Color _onColor(Color bg) =>
    bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String _formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  final period = h >= 12 ? 'PM' : 'AM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} $period';
}

String _formatMoney(double amount, String currency) {
  final isWhole = amount == amount.roundToDouble();
  return '${amount.toStringAsFixed(isWhole ? 0 : 2)} $currency';
}

String _cycleLabel(Subscription s) {
  final unit = s.cycleUnit.name;
  if (s.cycleCount == 1) return 'Every $unit';
  return 'Every ${s.cycleCount} ${unit}s';
}

DateTime _addMonths(DateTime d, int months) {
  final total = d.month - 1 + months;
  final year = d.year + total ~/ 12;
  final month = total % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day; // month ka aakhri din
  return DateTime(year, month, d.day > lastDay ? lastDay : d.day);
}

/// [date] se ek billing cycle aage.
DateTime _addCycle(DateTime date, CycleUnit unit, int count) {
  final c = count < 1 ? 1 : count;
  switch (unit) {
    case CycleUnit.day:
      return DateTime(date.year, date.month, date.day + c);
    case CycleUnit.week:
      return DateTime(date.year, date.month, date.day + 7 * c);
    case CycleUnit.month:
      return _addMonths(date, c);
    case CycleUnit.year:
      return _addMonths(date, 12 * c);
  }
}

/// Approx yearly kharcha.
double _yearlyCost(Subscription s) {
  final c = s.cycleCount < 1 ? 1 : s.cycleCount;
  switch (s.cycleUnit) {
    case CycleUnit.day:
      return s.price * 365 / c;
    case CycleUnit.week:
      return s.price * 52 / c;
    case CycleUnit.month:
      return s.price * 12 / c;
    case CycleUnit.year:
      return s.price / c;
  }
}

String _countdown(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diff = DateTime(date.year, date.month, date.day).difference(today).inDays;
  if (diff < 0) return 'Overdue by ${-diff} day${diff == -1 ? '' : 's'}';
  if (diff == 0) return 'Due today';
  if (diff == 1) return 'Due tomorrow';
  return 'In $diff days';
}

/// Snackbar dikhao: pehle purane saaf karo taake queue na bane, aur 2 second baad hat jaye.
void _showSnack(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
}

/// Purana reminder hatao aur (agar zarurat ho) naya lagao.
Future<void> _syncReminder(NotificationService service, Subscription s) async {
  final id = s.id.hashCode; // add screen / home delete bhi yehi id use karte hain
  await service.cancelNotification(id);
  if (s.remindersEnabled && s.status == SubscriptionStatus.active) {
    await service.scheduleSubscriptionReminder(
      notificationId: id,
      subscriptionName: s.name,
      billingDate: s.nextBillingDate,
      daysBefore: s.reminderDaysBefore,
      timeOfDayMinutes: s.reminderTime,
    );
  }
}

// ---------------------------------------------------------------------------
// Details screen
// ---------------------------------------------------------------------------

class DetailsScreen extends ConsumerWidget {
  final String id;
  const DetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subAsync = ref.watch(subscriptionDetailsProvider(id));

    return subAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
        body: Center(child: Text('Error: $e')),
      ),
      data: (sub) {
        if (sub == null || sub.status == SubscriptionStatus.archived) {
          return Scaffold(
            appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
            body: const Center(child: Text('Subscription not found')),
          );
        }
        return _DetailsBody(subscription: sub);
      },
    );
  }
}

class _DetailsBody extends ConsumerWidget {
  final Subscription subscription;
  const _DetailsBody({required this.subscription});

  Future<void> _markAsPaid(BuildContext context, WidgetRef ref) async {
    final sub = subscription;
    final now = DateTime.now();
    final payment = Payment(
      id: const Uuid().v4(),
      subscriptionId: sub.id,
      amount: sub.price,
      currency: sub.currency,
      paidAt: now,
      updatedAt: now,
    );
    final next = _addCycle(sub.nextBillingDate, sub.cycleUnit, sub.cycleCount);

    await ref.read(subscriptionRepositoryProvider).recordPayment(sub, payment, next);
    await _syncReminder(
      ref.read(notificationServiceProvider),
      sub.copyWith(nextBillingDate: next),
    );

    if (context.mounted) {
      _showSnack(context, 'Payment recorded. Next: ${_formatDate(next)}');
    }
  }

  Future<void> _edit(BuildContext context) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EditSubscriptionScreen(subscription: subscription),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete subscription?'),
        content: Text(
          '${subscription.name} will be removed from your list and its reminder will be cancelled.',
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(subscriptionRepositoryProvider).deleteSubscription(subscription.id);
    await ref
        .read(notificationServiceProvider)
        .cancelNotification(subscription.id.hashCode);

    if (context.mounted) {
      context.canPop() ? context.pop() : context.go('/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = subscription;
    final scheme = Theme.of(context).colorScheme;
    final bg = _parseColor(sub.colorHex);
    final fg = _onColor(bg);
    final paymentsAsync = ref.watch(subscriptionPaymentsProvider(sub.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: bg,
            foregroundColor: fg,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _edit(context),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, ref),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bg.withValues(alpha: 0.8), bg],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: fg.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: BrandLogo(
                          logoAsset: sub.iconKey,
                          name: sub.name,
                          colorHex: sub.colorHex,
                          size: 72,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        sub.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatMoney(sub.price, sub.currency),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: fg.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Status & Action ----
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next Payment',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_countdown(sub.nextBillingDate)} • ${_formatDate(sub.nextBillingDate)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => _markAsPaid(context, ref),
                          icon: const Icon(Icons.check_circle_outline, size: 20),
                          label: const Text('Mark as paid'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(106),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ---- Details Card ----
                    Text(
                      'Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          _InfoTile(
                            icon: Icons.event_repeat_rounded,
                            label: 'Billing cycle',
                            value: _cycleLabel(sub),
                          ),
                          const Divider(height: 1, indent: 56),
                          if (sub.firstBillingDate != null) ...[
                            _InfoTile(
                              icon: Icons.flag_outlined,
                              label: 'First billing date',
                              value: _formatDate(sub.firstBillingDate!),
                            ),
                            const Divider(height: 1, indent: 56),
                          ],
                          _InfoTile(
                            icon: Icons.payments_outlined,
                            label: 'Approx. yearly cost',
                            value: _formatMoney(_yearlyCost(sub), sub.currency),
                          ),
                          if (sub.paymentMethod != null && sub.paymentMethod!.isNotEmpty) ...[
                            const Divider(height: 1, indent: 56),
                            _InfoTile(
                              icon: Icons.credit_card_rounded,
                              label: 'Payment method',
                              value: sub.paymentMethod!,
                            ),
                          ],
                          if (sub.isTrial) ...[
                            const Divider(height: 1, indent: 56),
                            _InfoTile(
                              icon: Icons.hourglass_bottom_rounded,
                              label: 'Free trial ends',
                              value: sub.trialEndDate == null
                                  ? 'Not set'
                                  : _formatDate(sub.trialEndDate!),
                            ),
                          ],
                          const Divider(height: 1, indent: 56),
                          _InfoTile(
                            icon: sub.remindersEnabled
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_off_rounded,
                            label: 'Reminder',
                            value: sub.remindersEnabled
                                ? '${sub.reminderDaysBefore} day${sub.reminderDaysBefore == 1 ? '' : 's'} before at ${_formatMinutes(sub.reminderTime)}'
                                : 'Off',
                          ),
                        ],
                      ),
                    ),

                    // ---- Notes ----
                    if (sub.notes != null && sub.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Notes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          sub.notes!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                        ),
                      ),
                    ],

                    // ---- Payment history ----
                    const SizedBox(height: 32),
                    paymentsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                      data: (payments) {
                        final total = payments.fold<double>(0, (s, p) => s + p.amount);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'History',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (payments.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: scheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Total: ${_formatMoney(total, sub.currency)}',
                                      style: TextStyle(
                                        color: scheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (payments.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      Icon(Icons.history_rounded, size: 48, color: scheme.outlineVariant),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No payments yet.\nTap "Mark as paid" to record one.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: scheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: payments.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final p = payments[index];
                                  return Dismissible(
                                    key: Key(p.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      decoration: BoxDecoration(
                                        color: scheme.error,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Icon(Icons.delete_outline, color: scheme.onError),
                                    ),
                                    onDismissed: (_) => ref
                                        .read(subscriptionRepositoryProvider)
                                        .deletePayment(p.id),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: scheme.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: scheme.shadow.withValues(alpha: 0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: scheme.outlineVariant.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                        leading: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: scheme.secondaryContainer.withValues(alpha: 0.5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            color: scheme.primary,
                                          ),
                                        ),
                                        title: Text(
                                          _formatMoney(p.amount, p.currency),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          _formatDate(p.paidAt),
                                          style: TextStyle(color: scheme.onSurfaceVariant),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: scheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit screen
// ---------------------------------------------------------------------------

class EditSubscriptionScreen extends ConsumerStatefulWidget {
  final Subscription subscription;
  const EditSubscriptionScreen({super.key, required this.subscription});

  @override
  ConsumerState<EditSubscriptionScreen> createState() =>
      _EditSubscriptionScreenState();
}

class _EditSubscriptionScreenState
    extends ConsumerState<EditSubscriptionScreen> {
  static const _palette = [
    '#E50914', '#1DB954', '#2196F3', '#FF9800', '#9C27B0',
    '#009688', '#F44336', '#3F51B5', '#795548', '#212121',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _cycleCount;
  late final TextEditingController _paymentMethod;
  late final TextEditingController _notes;

  late String _currency;
  late CycleUnit _cycleUnit;
  late DateTime _nextBilling;
  late String _colorHex;
  late bool _reminders;
  late int _daysBefore;
  late int _reminderTime;
  late bool _isTrial;
  DateTime? _trialEnd;
  bool _saving = false;

  List<String> get _currencies {
    final base = ['USD', 'EUR', 'GBP', 'INR', 'JPY', 'PKR'];
    if (!base.contains(_currency)) base.add(_currency);
    return base;
  }

  @override
  void initState() {
    super.initState();
    final s = widget.subscription;
    _name = TextEditingController(text: s.name);
    _price = TextEditingController(
      text: s.price == s.price.roundToDouble()
          ? s.price.toStringAsFixed(0)
          : s.price.toString(),
    );
    _cycleCount = TextEditingController(text: s.cycleCount.toString());
    _paymentMethod = TextEditingController(text: s.paymentMethod ?? '');
    _notes = TextEditingController(text: s.notes ?? '');
    _currency = s.currency;
    _cycleUnit = s.cycleUnit;
    _nextBilling = s.nextBillingDate;
    _colorHex = s.colorHex;
    _reminders = s.remindersEnabled;
    _daysBefore = s.reminderDaysBefore;
    _reminderTime = s.reminderTime;
    _isTrial = s.isTrial;
    _trialEnd = s.trialEndDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _cycleCount.dispose();
    _paymentMethod.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate(DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final updated = widget.subscription.copyWith(
      name: _name.text.trim(),
      price: double.parse(_price.text.trim()),
      currency: _currency,
      cycleUnit: _cycleUnit,
      cycleCount: int.parse(_cycleCount.text.trim()),
      nextBillingDate: _nextBilling,
      colorHex: _colorHex,
      paymentMethod: _paymentMethod.text.trim(),
      notes: _notes.text.trim(),
      isTrial: _isTrial,
      trialEndDate: _isTrial ? _trialEnd : widget.subscription.trialEndDate,
      remindersEnabled: _reminders,
      reminderDaysBefore: _daysBefore,
      reminderTime: _reminderTime,
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(subscriptionRepositoryProvider).updateSubscription(updated);
      await _syncReminder(ref.read(notificationServiceProvider), updated);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnack(context, 'Could not save: $e');
    }
  }

  InputDecoration _modernDecoration(String label, {IconData? prefixIcon}) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: scheme.primary) : null,
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Subscription', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilledButton.tonal(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            24,
            20,
            40 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: _modernDecoration('Service Name', prefixIcon: Icons.subscriptions_rounded),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    decoration: _modernDecoration('Price', prefixIcon: Icons.attach_money_rounded),
                    validator: (v) {
                      final n = double.tryParse(v?.trim() ?? '');
                      return n == null || n < 0 ? 'Invalid price' : null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: _modernDecoration('Currency'),
                    dropdownColor: scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _currency = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: _cycleCount,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _modernDecoration('Every'),
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      return n == null || n < 1 ? 'Min 1' : null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: DropdownButtonFormField<CycleUnit>(
                    value: _cycleUnit,
                    decoration: _modernDecoration('Unit'),
                    dropdownColor: scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    items: CycleUnit.values
                        .map((u) => DropdownMenuItem(value: u, child: Text(u.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _cycleUnit = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DateField(
              label: 'Next billing date',
              value: _nextBilling,
              icon: Icons.calendar_month_rounded,
              onTap: () async {
                final d = await _pickDate(_nextBilling);
                if (d != null) setState(() => _nextBilling = d);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _paymentMethod,
              decoration: _modernDecoration('Payment method (optional)', prefixIcon: Icons.credit_card_rounded).copyWith(
                hintText: 'e.g. Visa ••4242',
              ),
            ),

            const SizedBox(height: 32),
            Text('Brand Color', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final hex in _palette)
                  GestureDetector(
                    onTap: () => setState(() => _colorHex = hex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _parseColor(hex),
                        shape: BoxShape.circle,
                        boxShadow: _colorHex.toLowerCase() == hex.toLowerCase()
                            ? [BoxShadow(color: _parseColor(hex).withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 2)]
                            : [],
                        border: Border.all(
                          color: _colorHex.toLowerCase() == hex.toLowerCase()
                              ? scheme.onSurface
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: _colorHex.toLowerCase() == hex.toLowerCase()
                          ? Icon(Icons.check_rounded, size: 24, color: _onColor(_parseColor(hex)))
                          : null,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Free trial', style: TextStyle(fontWeight: FontWeight.w500)),
                    value: _isTrial,
                    activeColor: scheme.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    onChanged: (v) => setState(() => _isTrial = v),
                  ),
                  if (_isTrial) ...[
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _DateField(
                        label: 'Trial ends',
                        value: _trialEnd,
                        icon: Icons.hourglass_bottom_rounded,
                        onTap: () async {
                          final d = await _pickDate(_trialEnd ?? _nextBilling);
                          if (d != null) setState(() => _trialEnd = d);
                        },
                      ),
                    ),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Reminders', style: TextStyle(fontWeight: FontWeight.w500)),
                    value: _reminders,
                    activeColor: scheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: const Radius.circular(20),
                        bottom: _reminders ? Radius.zero : const Radius.circular(20),
                      ),
                    ),
                    onChanged: (v) => setState(() => _reminders = v),
                  ),
                  if (_reminders) ...[
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Expanded(child: Text('Remind me', style: TextStyle(fontWeight: FontWeight.w500))),
                          Container(
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: _daysBefore > 0 ? () => setState(() => _daysBefore--) : null,
                                  icon: const Icon(Icons.remove_rounded, size: 20),
                                  splashRadius: 20,
                                ),
                                Text(
                                  '$_daysBefore day${_daysBefore == 1 ? '' : 's'}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                IconButton(
                                  onPressed: _daysBefore < 30 ? () => setState(() => _daysBefore++) : null,
                                  icon: const Icon(Icons.add_rounded, size: 20),
                                  splashRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      title: const Text('Reminder time', style: TextStyle(fontWeight: FontWeight.w500)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatMinutes(_reminderTime),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                      ),
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: _reminderTime ~/ 60,
                            minute: _reminderTime % 60,
                          ),
                        );
                        if (t != null) {
                          setState(() => _reminderTime = t.hour * 60 + t.minute);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),
            TextFormField(
              controller: _notes,
              maxLines: 4,
              decoration: _modernDecoration('Notes').copyWith(
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final IconData icon;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value == null ? 'Select date' : _formatDate(value!),
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}