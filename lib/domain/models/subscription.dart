enum CycleUnit { day, week, month, year }
enum SubscriptionStatus { active, paused, archived }

class Subscription {
  final String id;
  final String name;
  final String? serviceId;
  final double price;
  final String currency;
  final CycleUnit cycleUnit;
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
  final int reminderTime; // 9:00 AM default
  final SubscriptionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Subscription({
    required this.id,
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
    this.isTrial = false,
    this.trialEndDate,
    this.remindersEnabled = true,
    this.reminderDaysBefore = 1,
    this.reminderTime = 540,
    this.status = SubscriptionStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json['id'] as String,
        name: json['name'] as String,
        serviceId: json['serviceId'] as String?,
        price: (json['price'] as num).toDouble(),
        currency: json['currency'] as String,
        cycleUnit: CycleUnit.values.firstWhere((e) => e.name == json['cycleUnit']),
        cycleCount: json['cycleCount'] as int,
        nextBillingDate: DateTime.parse(json['nextBillingDate'] as String),
        firstBillingDate: json['firstBillingDate'] != null
            ? DateTime.parse(json['firstBillingDate'] as String)
            : null,
        categoryId: json['categoryId'] as String?,
        colorHex: json['colorHex'] as String,
        iconKey: json['iconKey'] as String?,
        paymentMethod: json['paymentMethod'] as String?,
        notes: json['notes'] as String?,
        isTrial: json['isTrial'] as bool? ?? false,
        trialEndDate: json['trialEndDate'] != null
            ? DateTime.parse(json['trialEndDate'] as String)
            : null,
        remindersEnabled: json['remindersEnabled'] as bool? ?? true,
        reminderDaysBefore: json['reminderDaysBefore'] as int? ?? 1,
        reminderTime: json['reminderTime'] as int? ?? 540,
        status: SubscriptionStatus.values.firstWhere(
            (e) => e.name == json['status'],
            orElse: () => SubscriptionStatus.active),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        deletedAt: json['deletedAt'] != null
            ? DateTime.parse(json['deletedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'serviceId': serviceId,
        'price': price,
        'currency': currency,
        'cycleUnit': cycleUnit.name,
        'cycleCount': cycleCount,
        'nextBillingDate': nextBillingDate.toIso8601String(),
        'firstBillingDate': firstBillingDate?.toIso8601String(),
        'categoryId': categoryId,
        'colorHex': colorHex,
        'iconKey': iconKey,
        'paymentMethod': paymentMethod,
        'notes': notes,
        'isTrial': isTrial,
        'trialEndDate': trialEndDate?.toIso8601String(),
        'remindersEnabled': remindersEnabled,
        'reminderDaysBefore': reminderDaysBefore,
        'reminderTime': reminderTime,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };
      
  Subscription copyWith({
    String? id,
    String? name,
    String? serviceId,
    double? price,
    String? currency,
    CycleUnit? cycleUnit,
    int? cycleCount,
    DateTime? nextBillingDate,
    DateTime? firstBillingDate,
    String? categoryId,
    String? colorHex,
    String? iconKey,
    String? paymentMethod,
    String? notes,
    bool? isTrial,
    DateTime? trialEndDate,
    bool? remindersEnabled,
    int? reminderDaysBefore,
    int? reminderTime,
    SubscriptionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Subscription(
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
    );
  }
}
