import 'package:dio/dio.dart';

class DioConfig {
  static Dio createDio() {
    final dio = Dio();
    
    // Configure base options
    dio.options = BaseOptions(
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    // Add interceptors for logging (optional)
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) {
          print('DIO: $object');
        },
      ),
    );
    
    return dio;
  }
}
