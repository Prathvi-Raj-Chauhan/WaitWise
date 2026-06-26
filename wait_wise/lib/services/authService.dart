import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wait_wise/services/dioClient.dart';

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

  static Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final res = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
      });
      final data = res.data;

      // ✅ Check boolean, not string
      if (data['success'] == true || data['success'] == 'true') {
        final SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString('clinicDbId', data['clinic']['id']);
      } else {
        // ✅ Throw so the UI can show the error
        throw AuthException(data['message'] ?? 'Registration failed.');
      }
    } on DioException catch (e) {
      throw AuthException(_extractError(e, 'Registration failed.'));
    }
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = res.data;

      // ✅ Check boolean, not string
      if (data['success'] == true || data['success'] == 'true') {
        final SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString('clinicDbId', data['clinic']['id']);
      } else {
        // ✅ Throw so the UI can show the error
        throw AuthException(data['message'] ?? 'Login failed.');
      }
    } on DioException catch (e) {
      throw AuthException(_extractError(e, 'Login failed.'));
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
    // No internet / server unreachable
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'No internet connection. Please try again.';
    }

    final data = e.response?.data;
    if (data is Map) {
      return data['message'] as String? ??
             data['Error'] as String? ??
             fallback;
    }
    return fallback;
  }
}