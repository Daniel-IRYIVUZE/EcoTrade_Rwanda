import 'location_model.dart';

class RecyclerModel {
  final String id;
  final String userId;
  final String companyName;
  final String contactName;
  final String phone;
  final String email;
  final LocationModel location;
  final List<String> wasteTypes;
  final double serviceRadiusKm;
  final bool isVerified;
  final double rating;
  final int totalBids;
  final int wonBids;
  final String? logoUrl;

  RecyclerModel({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.location,
    required this.wasteTypes,
    this.serviceRadiusKm = 10.0,
    this.isVerified = false,
    this.rating = 0.0,
    this.totalBids = 0,
    this.wonBids = 0,
    this.logoUrl,
  });

  double get winRate => totalBids == 0 ? 0 : (wonBids / totalBids) * 100;

  Map<String, dynamic> toJson() => {
    'id': id, 'userId': userId, 'companyName': companyName,
    'contactName': contactName, 'phone': phone, 'email': email,
    'location': location.toJson(), 'wasteTypes': wasteTypes,
    'serviceRadiusKm': serviceRadiusKm, 'isVerified': isVerified,
    'rating': rating, 'totalBids': totalBids, 'wonBids': wonBids,
    'logoUrl': logoUrl,
  };

  factory RecyclerModel.fromJson(Map<String, dynamic> json) => RecyclerModel(
    id: json['id'], userId: json['userId'], companyName: json['companyName'],
    contactName: json['contactName'], phone: json['phone'], email: json['email'],
    location: LocationModel.fromJson(json['location']),
    wasteTypes: List<String>.from(json['wasteTypes'] ?? []),
    serviceRadiusKm: (json['serviceRadiusKm'] as num?)?.toDouble() ?? 10.0,
    isVerified: json['isVerified'] ?? false,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    totalBids: json['totalBids'] ?? 0,
    wonBids: json['wonBids'] ?? 0,
    logoUrl: json['logoUrl'],
  );
}
