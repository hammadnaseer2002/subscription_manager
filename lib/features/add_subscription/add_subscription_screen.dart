import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'service_picker_screen.dart';
import '../../domain/models/subscription.dart' as model;
import '../../data/repositories/subscription_repository.dart';
import '../../core/notifications/notification_service.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  final PredefinedService? initialService;
  const AddSubscriptionScreen({super.key, this.initialService});

  @override
  ConsumerState<AddSubscriptionScreen> createState() =>
      _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;

  String _currency = 'USD';
  model.CycleUnit _cycleUnit = model.CycleUnit.month;
  int _cycleCount = 1;
  DateTime _nextBillingDate = DateTime.now();
  String _colorHex = '#2196F3';
  String? _iconKey;
  bool _remindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialService?.name ?? '',
    );
    _priceController = TextEditingController();
    _notesController = TextEditingController();

    if (widget.initialService != null) {
      _colorHex = widget.initialService!.brandColor;
      _iconKey = widget.initialService!.logoAsset;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final sub = model.Subscription(
      id: const Uuid().v4(),
      name: _nameController.text,
      serviceId: widget.initialService?.id,
      price: double.parse(_priceController.text),
      currency: _currency,
      cycleUnit: _cycleUnit,
      cycleCount: _cycleCount,
      nextBillingDate: _nextBillingDate,
      colorHex: _colorHex,
      iconKey: _iconKey,
      notes: _notesController.text,
      remindersEnabled: _remindersEnabled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(subscriptionRepositoryProvider).addSubscription(sub);

    // Schedule a reminder notification if enabled
    if (sub.remindersEnabled) {
      await ref
          .read(notificationServiceProvider)
          .scheduleSubscriptionReminder(
        notificationId: sub.id.hashCode,
        subscriptionName: sub.name,
        billingDate: sub.nextBillingDate,
        daysBefore: sub.reminderDaysBefore,
        timeOfDayMinutes: sub.reminderTime,
      );
    }

    // ignore: use_build_context_synchronously
    if (mounted) {
      context.go('/');
    }
  }

  // --- HELPER FOR UI ---
  InputDecoration _customInputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 22) : null,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.initialService == null
              ? 'New Subscription'
              : 'Add ${widget.initialService!.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            physics: const BouncingScrollPhysics(),
            children: [
              // --- Service Name Section ---
              Text(
                'Service Details',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                decoration: _customInputDecoration('Subscription Name', Icons.subscriptions_outlined),
                validator: (val) =>
                val == null || val.isEmpty ? 'Please enter a name' : null,
              ),

              const SizedBox(height: 24),

              // --- Pricing Section ---
              Text(
                'Pricing',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _priceController,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      decoration: _customInputDecoration('Amount', Icons.attach_money),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) =>
                      val == null || val.isEmpty || double.tryParse(val) == null
                          ? 'Invalid price'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: _customInputDecoration('Currency', null),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: ['USD', 'EUR', 'GBP', 'INR', 'JPY', 'PKR']
                          .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ))
                          .toList(),
                      onChanged: (val) => setState(() => _currency = val!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- Billing Cycle Section ---
              Text(
                'Billing Cycle',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _nextBillingDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: theme.colorScheme,
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setState(() => _nextBillingDate = date);
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Next Billing Date',
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_nextBillingDate.toLocal()}'.split(' ')[0],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Every',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            initialValue: _cycleCount.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              isDense: true,
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (v) => _cycleCount = int.tryParse(v) ?? 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<model.CycleUnit>(
                            value: _cycleUnit,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              isDense: true,
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            items: model.CycleUnit.values
                                .map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(
                                u.name.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ))
                                .toList(),
                            onChanged: (val) => setState(() => _cycleUnit = val!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Options Section ---
              Text(
                'Additional Options',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  title: const Text('Enable Reminders', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Get notified before the due date', style: theme.textTheme.bodySmall),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.notifications_active_outlined, color: theme.colorScheme.tertiary),
                  ),
                  value: _remindersEnabled,
                  activeColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onChanged: (val) => setState(() => _remindersEnabled = val),
                ),
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: _customInputDecoration('Notes (Optional)', Icons.notes_rounded),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 40),

              // --- Save Button ---
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Subscription',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}