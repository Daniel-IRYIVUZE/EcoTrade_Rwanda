import 'package:flutter/foundation.dart';
import '../services/api/bid_service.dart';
import '../models/bid_model.dart';

class BidViewModel extends ChangeNotifier {
  final BidService _service = BidService();
  List<BidModel> _bids = [];
  bool _isLoading = false;
  String? _error;

  List<BidModel> get bids => _bids;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BidModel> get activeBids => _bids.where((b) => b.status == 'pending').toList();
  List<BidModel> get acceptedBids => _bids.where((b) => b.status == 'accepted').toList();

  Future<void> loadMyBids() async {
    _isLoading = true; notifyListeners();
    try {
      _bids = await _service.getMyBids();
      _error = null;
    } catch (e) { _error = e.toString(); }
    _isLoading = false; notifyListeners();
  }

  Future<void> loadListingBids(String listingId) async {
    _isLoading = true; notifyListeners();
    try {
      _bids = await _service.getListingBids(listingId);
      _error = null;
    } catch (e) { _error = e.toString(); }
    _isLoading = false; notifyListeners();
  }

  Future<bool> placeBid({required String listingId, required double amount, String? note}) async {
    try {
      final bid = await _service.placeBid(listingId: listingId, amount: amount, note: note);
      _bids = [..._bids, bid];
      notifyListeners();
      return true;
    } catch (e) { _error = e.toString(); notifyListeners(); return false; }
  }
}
