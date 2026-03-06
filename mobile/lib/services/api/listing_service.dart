import '../../models/waste_listing_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class ListingService {
  final ApiClient _client = ApiClient();

  Future<List<WasteListing>> getListings({Map<String, dynamic>? filters}) async {
    final response = await _client.get(ApiEndpoints.listings, params: filters);
    return (response.data as List).map((l) => WasteListing.fromJson(l)).toList();
  }

  Future<WasteListing> getListingById(String id) async {
    final response = await _client.get(ApiEndpoints.listingById(id));
    return WasteListing.fromJson(response.data);
  }

  Future<WasteListing> createListing(Map<String, dynamic> data) async {
    final response = await _client.post(ApiEndpoints.listings, data: data);
    return WasteListing.fromJson(response.data);
  }

  Future<WasteListing> updateListing(String id, Map<String, dynamic> data) async {
    final response = await _client.put(ApiEndpoints.listingById(id), data: data);
    return WasteListing.fromJson(response.data);
  }

  Future<void> deleteListing(String id) async {
    await _client.delete(ApiEndpoints.listingById(id));
  }

  Future<List<WasteListing>> getNearbyListings(double lat, double lng, double radiusKm) async {
    final response = await _client.get(ApiEndpoints.nearbyListings, params: {
      'lat': lat, 'lng': lng, 'radius': radiusKm,
    });
    return (response.data as List).map((l) => WasteListing.fromJson(l)).toList();
  }
}
