import 'package:flutter/foundation.dart';
import '../models/route_model.dart';
import '../services/geospatial/routing_service.dart';
import 'package:latlong2/latlong.dart';

class RouteViewModel extends ChangeNotifier {
  RouteModel? _route;
  List<LatLng> _optimized = [];
  int _currentStop = 0;
  bool _isStarted = false;

  RouteModel? get route => _route;
  List<LatLng> get optimizedWaypoints => _optimized;
  int get currentStop => _currentStop;
  bool get isStarted => _isStarted;
  RouteStop? get currentStopData => (_route != null && _currentStop < _route!.stops.length)
      ? _route!.stops[_currentStop] : null;
  double get progress => _route == null || _route!.stops.isEmpty
      ? 0 : _currentStop / _route!.stops.length;

  void setRoute(RouteModel route) {
    _route = route;
    final latlngs = route.stops.map((s) => LatLng(s.location.latitude, s.location.longitude)).toList();
    _optimized = RoutingService.optimizeRoute(latlngs);
    _currentStop = 0;
    notifyListeners();
  }

  void startRoute() { _isStarted = true; notifyListeners(); }
  void pauseRoute() { _isStarted = false; notifyListeners(); }

  void completeCurrentStop() {
    if (_route != null && _currentStop < _route!.stops.length - 1) {
      _currentStop++;
    }
    notifyListeners();
  }
}
