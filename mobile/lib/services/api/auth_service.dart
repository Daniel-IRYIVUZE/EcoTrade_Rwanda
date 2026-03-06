import '../../models/user_model.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final ApiClient _client = ApiClient();
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });
      final data = response.data;
      await _storage.write(key: 'auth_token', value: data['access_token']);
      await _storage.write(key: 'user_id', value: data['user']['id'].toString());
      await _storage.write(key: 'user_role', value: data['user']['role']);
      return data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _client.post(ApiEndpoints.register, data: userData);
      return response.data;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } finally {
      await _storage.deleteAll();
    }
  }

  Future<void> forgotPassword(String email) async {
    await _client.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  Future<UserModel> getProfile() async {
    final response = await _client.get(ApiEndpoints.userProfile);
    return UserModel.fromJson(response.data);
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: 'user_role');
  }
}
