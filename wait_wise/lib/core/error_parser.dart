import 'package:dio/dio.dart';
import 'dart:io';

String parseError(dynamic error) {
  // No internet / server unreachable
  if (error is SocketException || 
      (error is DioException && error.type == DioExceptionType.connectionError)) {
    return 'No internet connection.';
  }

  // Timeout
  if (error is DioException && (
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout)) {
    return 'Request timed out. Please try again.';
  }

  // Server responded with error
  if (error is DioException && error.response != null) {
    final data = error.response?.data;
    // Pull message from your backend response if it exists
    if (data is Map && data['message'] != null) {
      return data['message'];
    }
    switch (error.response?.statusCode) {
      case 401: return 'Wrong email or password.';
      case 403: return 'You are not authorized.';
      case 404: return 'Not found.';
      case 500: return 'Server error. Please try again later.';
    }
  }

  return 'Something went wrong. Please try again.';
}