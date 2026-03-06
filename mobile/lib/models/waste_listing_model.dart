class WasteListing {
  final String id;
  final String hotelId;
  final String hotelName;
  final String wasteType;
  final double volume;
  final String unit;
  final String quality;
  final double minBid;
  final String? location;
  final DateTime createdAt;
  final DateTime? expiresAt;

  // Backward-compatible computed properties
  double get price => minBid;
  String get qualityGrade => quality;
  final String status;

  WasteListing({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.wasteType,
    required this.volume,
    required this.unit,
    required this.quality,
    required this.minBid,
    this.location,
    required this.status,
    required this.createdAt,
    this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'hotelId': hotelId,
    'hotelName': hotelName,
    'wasteType': wasteType,
    'volume': volume,
    'unit': unit,
    'quality': quality,
    'min_bid': minBid,
    'location': location,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
  };

  factory WasteListing.fromJson(Map<String, dynamic> json) => WasteListing(
    id: json['id'].toString(),
    hotelId: json['hotel_id'].toString(),
    hotelName: json['hotel_name'],
    wasteType: json['waste_type'],
    volume: json['volume'].toDouble(),
    unit: json['unit'],
    quality: json['quality'],
    minBid: (json['min_bid'] as num).toDouble(),
    location: json['location'],
    status: json['status'],
    createdAt: DateTime.parse(json['created_at']),
    expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
  );
}
