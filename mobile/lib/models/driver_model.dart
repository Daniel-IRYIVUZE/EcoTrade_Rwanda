import 'location_model.dart';

class DriverModel {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String email;
  final String? photoUrl;
  final String licensePlate;
  final String vehicleType;
  final bool isAvailable;
  final double rating;
  final int totalCollections;
  final double totalEarnings;
  final LocationModel? currentLocation;
  final String? recyclerId;
  final bool isVerified;

  DriverModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.email,
    this.photoUrl,
    required this.licensePlate,
    required this.vehicleType,
    this.isAvailable = true,
    this.rating = 0.0,
    this.totalCollections = 0,
    this.totalEarnings = 0.0,
    this.currentLocation,
    this.recyclerId,
    this.isVerified = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'userId': userId, 'fullName': fullName, 'phone': phone,
    'email': email, 'photoUrl': photoUrl, 'licensePlate': licensePlate,
    'vehicleType': vehicleType, 'isAvailable': isAvailable,
    'rating': rating, 'totalCollections': totalCollections,
    'totalEarnings': totalEarnings,
    'currentLocation': currentLocation?.toJson(),
    'recyclerId': recyclerId, 'isVerified': isVerified,
  };

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
    id: json['id'].toString(),
    userId: json['user_id'].toString(),
    fullName: json['full_name'],
    phone: json['phone'],
    email: json['email'],
    photoUrl: json['photo_url'],
    licensePlate: json['license_plate'],
    vehicleType: json['vehicle_type'],
    isAvailable: json['is_available'] ?? true,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    totalCollections: json['total_collections'] ?? 0,
    totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
    currentLocation: json['current_location'] != null
      ? LocationModel.fromJson(json['current_location']) : null,
    recyclerId: json['recycler_id'], isVerified: json['is_verified'] ?? false,
  );
}
