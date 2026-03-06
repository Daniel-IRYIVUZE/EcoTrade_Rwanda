import 'package:geocoding/geocoding.dart';

class GeocodingService {
  static Future<String> getAddress(double lat, double lng) async {
    try {
      final marks = await placemarkFromCoordinates(lat, lng);
      if (marks.isNotEmpty) {
        final p = marks.first;
        return '${p.street ?? ''}, ${p.locality ?? ''}, ${p.country ?? ''}'.replaceAll(RegExp(r'^, |, $'), '');
      }
      return 'Unknown location';
    } catch (_) {
      return 'Unknown location';
    }
  }

  static Future<List<Location>> searchAddress(String query) async {
    try {
      return await locationFromAddress(query);
    } catch (_) {
      return [];
    }
  }
}
