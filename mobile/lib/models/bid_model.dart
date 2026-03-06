
class BidModel {
  final String id;
  final String listingId;
  final String recyclerId;
  final String recyclerName;
  final double amount;
  final String status;
  final String? note;
  final String? collectionPreference;
  final DateTime createdAt;

  BidModel({
    required this.id,
    required this.listingId,
    required this.recyclerId,
    required this.recyclerName,
    required this.amount,
    required this.status,
    this.note,
    this.collectionPreference,
    required this.createdAt,
  });

  // Backward-compatible getters for UI
  String get recyclerCompany => recyclerName;
  String? get message => note;

  Map<String, dynamic> toJson() => {
    'id': id,
    'listingId': listingId,
    'recyclerId': recyclerId,
    'recyclerName': recyclerName,
    'amount': amount,
    'status': status,
    'note': note,
    'collection_preference': collectionPreference,
    'created_at': createdAt.toIso8601String(),
  };

  factory BidModel.fromJson(Map<String, dynamic> json) => BidModel(
    id: json['id'].toString(),
    listingId: json['listing_id'].toString(),
    recyclerId: json['recycler_id'].toString(),
    recyclerName: json['recycler_name'],
    amount: (json['amount'] as num).toDouble(),
    status: json['status'],
    note: json['note'],
    collectionPreference: json['collection_preference'],
    createdAt: DateTime.parse(json['created_at']),
  );
}
