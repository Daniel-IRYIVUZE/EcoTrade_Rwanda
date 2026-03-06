import 'location_model.dart';

class HotelModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String? photoUrl;
  final LocationModel location;
  final double greenScore;
  final int starRating;
  final bool isVerified;
  final double totalRevenue;
  final int totalListings;
  final String? tinNumber;
  final List<String> wasteTypes;

  HotelModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    this.photoUrl,
    required this.location,
    this.greenScore = 0.0,
    this.starRating = 3,
    this.isVerified = false,
    this.totalRevenue = 0.0,
    this.totalListings = 0,
    this.tinNumber,
    this.wasteTypes = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'userId': userId, 'name': name, 'phone': phone,
    'email': email, 'photoUrl': photoUrl, 'location': location.toJson(),
    'greenScore': greenScore, 'starRating': starRating,
    'isVerified': isVerified, 'totalRevenue': totalRevenue,
    'totalListings': totalListings, 'tinNumber': tinNumber,
    'wasteTypes': wasteTypes,
  };

  factory HotelModel.fromJson(Map<String, dynamic> json) => HotelModel(
    id: json['id'], userId: json['userId'], name: json['name'],
    phone: json['phone'], email: json['email'], photoUrl: json['photoUrl'],
    location: LocationModel.fromJson(json['location']),
    greenScore: (json['greenScore'] as num?)?.toDouble() ?? 0.0,
    starRating: json['starRating'] ?? 3,
    isVerified: json['isVerified'] ?? false,
    totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    totalListings: json['totalListings'] ?? 0,
    tinNumber: json['tinNumber'],
    wasteTypes: List<String>.from(json['wasteTypes'] ?? []),
  );
}
