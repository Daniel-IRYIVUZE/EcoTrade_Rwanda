class PaymentModel {
  final String id;
  final String userId;
  final String? collectionId;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? completedAt;

  PaymentModel({
    required this.id,
    required this.userId,
    this.collectionId,
    required this.amount,
    this.currency = 'RWF',
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'userId': userId, 'collectionId': collectionId,
    'amount': amount, 'currency': currency, 'status': status,
    'paymentMethod': paymentMethod, 'transactionId': transactionId,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json['id'].toString(),
    userId: json['user_id'].toString(),
    collectionId: json['collection_id']?.toString(),
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] ?? 'RWF',
    status: json['status'], paymentMethod: json['payment_method'],
    transactionId: json['transaction_id'],
    createdAt: DateTime.parse(json['created_at']),
    completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
  );
}
