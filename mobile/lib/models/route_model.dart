import 'location_model.dart';

class RouteModel {
  final String id;
  final String driverId;
  final List<RouteStop> stops;
  final DateTime date;
  final double totalDistance;
  final String status;
  final String? optimizedPolyline;

  RouteModel({
    required this.id,
    required this.driverId,
    required this.stops,
    required this.date,
    required this.totalDistance,
    required this.status,
    this.optimizedPolyline,
  });
}

class RouteStop {
  final String stopId;
  final String hotelId;
  final String hotelName;
  final LocationModel location;
  final String wasteType;
  final double volume;
  final int stopOrder;
  final String status;
  final DateTime? arrivalTime;
  final DateTime? completionTime;

  RouteStop({
    required this.stopId,
    required this.hotelId,
    required this.hotelName,
    required this.location,
    required this.wasteType,
    required this.volume,
    required this.stopOrder,
    required this.status,
    this.arrivalTime,
    this.completionTime,
  });
}