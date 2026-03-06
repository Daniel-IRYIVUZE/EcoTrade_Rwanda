import 'package:flutter/foundation.dart';
import '../services/api/payment_service.dart';
import '../models/payment_model.dart';

class EarningsViewModel extends ChangeNotifier {
  final PaymentService _service = PaymentService();
  List<PaymentModel> _payments = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = false;

  List<PaymentModel> get payments => _payments;
  Map<String, dynamic> get summary => _summary;
  bool get isLoading => _isLoading;
  double get todayEarnings => (_summary['today'] as num?)?.toDouble() ?? 0.0;
  double get weeklyEarnings => (_summary['weekly'] as num?)?.toDouble() ?? 0.0;
  double get totalEarnings => (_summary['total'] as num?)?.toDouble() ?? 0.0;

  Future<void> load() async {
    _isLoading = true; notifyListeners();
    try {
      _payments = await _service.getPayments();
      _summary = await _service.getEarningsSummary();
    } catch (_) {}
    _isLoading = false; notifyListeners();
  }

  Future<bool> requestWithdrawal(double amount, String method) async {
    try {
      await _service.requestWithdrawal(amount, method);
      return true;
    } catch (_) { return false; }
  }
}
