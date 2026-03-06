import '../../models/collection_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class CollectionService {
  final ApiClient _client = ApiClient();

  Future<List<CollectionModel>> getCollections() async {
    final response = await _client.get(ApiEndpoints.collections);
    return (response.data as List).map((c) => CollectionModel.fromJson(c)).toList();
  }

  Future<CollectionModel> getCollectionById(String id) async {
    final response = await _client.get(ApiEndpoints.collectionById(id));
    return CollectionModel.fromJson(response.data);
  }

  Future<CollectionModel> updateCollectionStatus(String id, String status,
      {double? actualWeight, double? rating, String? notes}) async {
    final response = await _client.patch(ApiEndpoints.collectionById(id), data: {
      'status': status,
      if (actualWeight != null) 'actual_weight': actualWeight,
      if (rating != null) 'rating': rating,
      if (notes != null) 'notes': notes,
    });
    return CollectionModel.fromJson(response.data);
  }

  Future<CollectionModel> completeCollection(String id,
      {required double actualWeight}) async {
    return updateCollectionStatus(id, 'completed',
        actualWeight: actualWeight);
  }

  Future<void> rateDriver(String collectionId, double rating, {String? comment}) async {
    await _client.post('${ApiEndpoints.collectionById(collectionId)}/rate',
        data: {'rating': rating, 'comment': comment});
  }
}
