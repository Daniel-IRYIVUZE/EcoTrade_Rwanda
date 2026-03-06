import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class TrackingService {
  static Stream<Position>? _positionStream;

  static Stream<LatLng> startTracking() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
    return _positionStream!.map((pos) => LatLng(pos.latitude, pos.longitude));
  }

  static void stopTracking() {
    _positionStream = null;
  }
}
