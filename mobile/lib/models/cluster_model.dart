import 'location_model.dart';

class ClusterModel {
  final int clusterId;
  final List<String> hotelIds;
  final LocationModel centroid;
  final double radiusMeters;
  final int totalVolume;
  final List<String> wasteTypes;

  ClusterModel({
    required this.clusterId,
    required this.hotelIds,
    required this.centroid,
    required this.radiusMeters,
    required this.totalVolume,
    required this.wasteTypes,
  });

  int get hotelCount => hotelIds.length;

  Map<String, dynamic> toJson() => {
    'clusterId': clusterId,
    'hotelIds': hotelIds,
    'centroid': centroid.toJson(),
    'radiusMeters': radiusMeters,
    'totalVolume': totalVolume,
    'wasteTypes': wasteTypes,
  };

  factory ClusterModel.fromJson(Map<String, dynamic> json) => ClusterModel(
    clusterId: json['clusterId'],
    hotelIds: List<String>.from(json['hotelIds']),
    centroid: LocationModel.fromJson(json['centroid']),
    radiusMeters: (json['radiusMeters'] as num).toDouble(),
    totalVolume: json['totalVolume'],
    wasteTypes: List<String>.from(json['wasteTypes']),
  );
}
