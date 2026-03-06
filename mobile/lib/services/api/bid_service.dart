import '../../models/bid_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class BidService {
  final ApiClient _client = ApiClient();

  Future<List<BidModel>> getListingBids(String listingId) async {
    final response = await _client.get(ApiEndpoints.listingBids(listingId));
    return (response.data as List).map((b) => BidModel.fromJson(b)).toList();
  }

  Future<List<BidModel>> getMyBids() async {
    final response = await _client.get(ApiEndpoints.bids);
    return (response.data as List).map((b) => BidModel.fromJson(b)).toList();
  }

  Future<BidModel> placeBid({
    required String listingId,
    required double amount,
    String? note,
    String? collectionPreference,
  }) async {
    final response = await _client.post(
      '${ApiEndpoints.bids}?listing_id=$listingId',
      data: {
        'amount': amount,
        if (note != null) 'note': note,
        if (collectionPreference != null) 'collection_preference': collectionPreference,
      },
    );
    return BidModel.fromJson(response.data);
  }

  Future<BidModel> updateBidStatus(String bidId, String status) async {
    final response = await _client.patch(ApiEndpoints.bidById(bidId), data: {'status': status});
    return BidModel.fromJson(response.data);
  }

  Future<void> acceptBid(String listingId, String bidId) async {
    await _client.post('${ApiEndpoints.listingBids(listingId)}/$bidId/accept');
  }

  Future<void> rejectBid(String bidId) => updateBidStatus(bidId, 'lost');
}
