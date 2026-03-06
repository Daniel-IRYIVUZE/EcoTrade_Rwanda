import '../../models/payment_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class PaymentService {
  final ApiClient _client = ApiClient();

  Future<List<PaymentModel>> getPayments() async {
    final response = await _client.get(ApiEndpoints.payments);
    return (response.data as List).map((p) => PaymentModel.fromJson(p)).toList();
  }

  Future<Map<String, dynamic>> getEarningsSummary() async {
    final response = await _client.get('${ApiEndpoints.payments}/summary');
    return response.data;
  }

  Future<Map<String, dynamic>> requestWithdrawal(double amount, String method) async {
    final response = await _client.post(ApiEndpoints.withdrawal, data: {
      'amount': amount,
      'method': method,
    });
    return response.data;
  }
}
