class Payment {
  final String id;
  final String subscriptionId;
  final double amount;
  final String currency;
  final DateTime paidAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.subscriptionId,
    required this.amount,
    required this.currency,
    required this.paidAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as String,
        subscriptionId: json['subscriptionId'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String,
        paidAt: DateTime.parse(json['paidAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'subscriptionId': subscriptionId,
        'amount': amount,
        'currency': currency,
        'paidAt': paidAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
