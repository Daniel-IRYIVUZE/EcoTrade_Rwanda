import 'package:flutter/foundation.dart';
import '../services/api/collection_service.dart';
import '../models/collection_model.dart';

class CollectionViewModel extends ChangeNotifier {
  final CollectionService _service = CollectionService();
  List<CollectionModel> _collections = [];
  bool _isLoading = false;

  List<CollectionModel> get collections => _collections;
  bool get isLoading => _isLoading;
  List<CollectionModel> get upcoming => _collections.where((c) => c.status == 'scheduled' || c.status == 'assigned').toList();
  List<CollectionModel> get active => _collections.where((c) => c.status == 'enRoute' || c.status == 'collecting').toList();
  List<CollectionModel> get completed => _collections.where((c) => c.status == 'completed').toList();

  Future<void> load() async {
    _isLoading = true; notifyListeners();
    try {
      _collections = await _service.getCollections();
    } catch (e) { /* error handled */ }
    _isLoading = false; notifyListeners();
  }

  Future<bool> complete(String id, {required double volume}) async {
    try {
      final updated = await _service.completeCollection(id, actualWeight: volume);
      _collections = _collections.map((c) => c.id == id ? updated : c).toList();
      notifyListeners();
      return true;
    } catch (e) { /* error handled */ notifyListeners(); return false; }
  }
}
