import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api/auth_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _service = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true; notifyListeners();
    try { _user = await _service.getProfile(); } catch (_) {}
    _isLoading = false; notifyListeners();
  }
}
