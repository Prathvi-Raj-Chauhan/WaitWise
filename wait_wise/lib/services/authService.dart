import 'package:dio/dio.dart';
import 'package:wait_wise/services/dio.dart';


class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthUser {
  final String id;
  final String email;
  final String name;

  AuthUser({required this.id, required this.email, required this.name});

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id']?.toString() ?? '',
        email: json['email'] ?? '',
        name: json['name'] ?? '',
      );
}

class AuthService {
  static Dio get _dio => Dioclient.dio;

  static Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? examTarget,
  }) async {
    try {
      final res = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
      });
      final data =  res.data;
      if(data['success'] == 'true'){
        // TODO: use shared prefs and store clinic info like name etc.
        return true;
      }
      else {
        return false;
      }
    } on DioException catch (e) {
      throw AuthException(_extractError(e, 'Registration failed'));
    }
  }

  static Future<bool> login({required String email, required String password}) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data =  res.data;
      if(data['success'] == 'true'){
        // TODO: use shared prefs and store clinic info like name etc.
        return true;
      }
      else {
        return false;
      }
    } on DioException catch (e) {
      throw AuthException(_extractError(e, 'Login failed'));
    }
  }

  static Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // ignore network errors on logout
    }
  }

  static Future<AuthUser?> getCurrentUser() async {
    try {
      final res = await _dio.get('/auth/clinic');
      return AuthUser.fromJson(res.data['clinic'] ?? res.data);
    } on DioException {
      return null;
    }
  }

  static String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) return data['Error'] ?? data['message'] ?? fallback;
    return fallback;
  }
}