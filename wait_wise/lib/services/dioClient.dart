import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';

class Dioclient{
  static late final Dio dio;

  static void init(){
    BaseOptions options = BaseOptions(
      // baseUrl: "http://localhost:9000",
      baseUrl: "https://waitwise-jaoa.onrender.com",
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        }
    );
    dio = Dio(options);
    (dio.httpClientAdapter as BrowserHttpClientAdapter).withCredentials = true;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('➡️ ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('❌ ${e.response?.statusCode} ${e.requestOptions.uri}');

          // 🔐 Auto redirect on auth failure
          if (e.response?.statusCode == 401) {
            debugPrint('❌401 un Authorised');
          }

          handler.next(e);
        },
      ),
    );
  }
}