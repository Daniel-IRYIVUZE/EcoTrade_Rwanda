import 'package:flutter/foundation.dart';
import '../services/api/listing_service.dart';
import '../models/waste_listing_model.dart';

class ListingViewModel extends ChangeNotifier {
  final ListingService _service = ListingService();
  List<WasteListing> _listings = [];
  bool _isLoading = false;
  String? _error;

  List<WasteListing> get listings => _listings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load({Map<String, dynamic>? filters}) async {
    _isLoading = true; notifyListeners();
    try {
      _listings = await _service.getListings(filters: filters);
      _error = null;
    } catch (e) { _error = e.toString(); }
    _isLoading = false; notifyListeners();
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      final listing = await _service.createListing(data);
      _listings = [listing, ..._listings];
      notifyListeners();
      return true;
    } catch (e) { _error = e.toString(); notifyListeners(); return false; }
  }
}
