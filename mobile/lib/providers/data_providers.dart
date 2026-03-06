import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/waste_listing_model.dart';
import '../models/bid_model.dart';
import '../models/collection_model.dart';
import '../services/api/listing_service.dart';
import '../services/api/bid_service.dart';
import '../services/api/collection_service.dart';
import '../services/api/payment_service.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';

// ─── Listings ───────────────────────────────────────────────────────────────

/// All open listings (Marketplace)
final listingsProvider = FutureProvider.autoDispose
    .family<List<WasteListing>, Map<String, dynamic>?>((ref, filters) async {
  return ListingService().getListings(filters: filters);
});

/// Active (open) listings — shorthand for marketplace
final openListingsProvider =
    FutureProvider.autoDispose<List<WasteListing>>((ref) async {
  return ListingService().getListings(filters: {'status': 'open'});
});

/// Hotel's own listings
final myListingsProvider =
    FutureProvider.autoDispose<List<WasteListing>>((ref) async {
  // Backend /api/v1/listings returns the hotel's own listings when the user is
  // authenticated as a hotel (no hotel_id filter needed — server scopes it).
  return ListingService().getListings(filters: {'status': 'open'});
});

/// Nearby listings for recycler home screen
final nearbyListingsProvider = FutureProvider.autoDispose
    .family<List<WasteListing>, ({double lat, double lng, double radius})>(
        (ref, loc) async {
  return ListingService().getNearbyListings(loc.lat, loc.lng, loc.radius);
});

// ─── Bids ───────────────────────────────────────────────────────────────────

/// Recycler's own bids
final myBidsProvider = FutureProvider.autoDispose<List<BidModel>>((ref) async {
  return BidService().getMyBids();
});

/// Bids on a specific listing (hotel view)
final listingBidsProvider = FutureProvider.autoDispose
    .family<List<BidModel>, String>((ref, listingId) async {
  return BidService().getListingBids(listingId);
});

// ─── Collections ─────────────────────────────────────────────────────────────

/// All collections for current user (role-scoped on server)
final collectionsProvider =
    FutureProvider.autoDispose<List<CollectionModel>>((ref) async {
  return CollectionService().getCollections();
});

/// Active (scheduled / en_route / collected) collections
final activeCollectionsProvider =
    FutureProvider.autoDispose<List<CollectionModel>>((ref) async {
  final response = await ApiClient().get(ApiEndpoints.activeCollections);
  return (response.data as List)
      .map((c) => CollectionModel.fromJson(c))
      .toList();
});

// ─── Payments / Earnings ─────────────────────────────────────────────────────

/// All payments for current user (driver earnings history)
final paymentsProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  return PaymentService().getPayments();
});

/// Earnings summary {today, weekly, total}
final earningsSummaryProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return PaymentService().getEarningsSummary();
});

// ─── Drivers ─────────────────────────────────────────────────────────────────

/// All drivers (for recycler fleet screen)
final driversProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final response = await ApiClient().get(ApiEndpoints.drivers);
  return List<Map<String, dynamic>>.from(response.data as List);
});

// ─── Notifications ───────────────────────────────────────────────────────────

final notificationsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final response = await ApiClient().get(ApiEndpoints.notifications);
  return List<Map<String, dynamic>>.from(response.data as List);
});
