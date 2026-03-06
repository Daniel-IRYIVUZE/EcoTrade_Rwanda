class CollectionModel {
  final String id;
  final String? listingId;
  final String hotelName;
  final String recyclerName;
  final String driverName;
  final String? driverId;
  final String wasteType;
  final double volume;
  final String status;
  final DateTime scheduledDate;
  final String? scheduledTimeRaw;
  final DateTime? completedAt;
  final double? actualWeight;
  final double? rating;
  final String? notes;
  final String? location;
  final double earnings;

  // Backward-compatible computed properties
  double get scheduledVolume => volume;
  double? get actualVolume => actualWeight;
  double? get driverRating => rating;
  DateTime get scheduledTime {
    if (scheduledTimeRaw != null && scheduledTimeRaw!.isNotEmpty) {
      return DateTime.parse('${scheduledDate.toIso8601String().split('T').first}T$scheduledTimeRaw');
    }
    return scheduledDate;
  }

  CollectionModel({
    required this.id,
    this.listingId,
    required this.hotelName,
    required this.recyclerName,
    required this.driverName,
    this.driverId,
    required this.wasteType,
    required this.volume,
    required this.status,
    required this.scheduledDate,
    this.scheduledTimeRaw,
    this.completedAt,
    this.actualWeight,
    this.rating,
    this.notes,
    this.location,
    required this.earnings,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'listing_id': listingId,
    'hotelName': hotelName,
    'recyclerName': recyclerName,
    'driverName': driverName,
    'driverId': driverId,
    'wasteType': wasteType,
    'volume': volume,
    'actual_weight': actualWeight,
    'status': status,
    'scheduled_date': scheduledDate.toIso8601String(),
    'scheduled_time': scheduledTimeRaw,
    'completed_at': completedAt?.toIso8601String(),
    'rating': rating,
    'notes': notes,
    'location': location,
    'earnings': earnings,
  };

  factory CollectionModel.fromJson(Map<String, dynamic> json) => CollectionModel(
    id: json['id'].toString(),
    listingId: json['listing_id']?.toString(),
    hotelName: json['hotel_name'],
    recyclerName: json['recycler_name'],
    driverName: json['driver_name'],
    driverId: json['driver_id']?.toString(),
    wasteType: json['waste_type'],
    volume: (json['volume'] as num).toDouble(),
    status: json['status'],
    scheduledDate: DateTime.parse(json['scheduled_date']),
    scheduledTimeRaw: json['scheduled_time'],
    completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    actualWeight: json['actual_weight'] != null ? (json['actual_weight'] as num).toDouble() : null,
    rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    notes: json['notes'],
    location: json['location'],
    earnings: (json['earnings'] as num).toDouble(),
  );
}
