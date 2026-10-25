import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import '../main.dart';

/// Dio instance with built-in logging via Talker
/// Only active in debug mode for security
Dio createDioClient() {
  final dio = Dio();

  // Only add logger in debug mode
  if (kDebugMode) {
    dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printResponseData: true,
          printRequestData: true,
          printErrorData: true,
        ),
      ),
    );

    talker?.info('🔌 Dio client initialized with logging');
  }

  return dio;
}

/// Example API service using Dio
class ApiService {
  ApiService({Dio? dio}) : _dio = dio ?? createDioClient();

  final Dio _dio;

  Future<String> getData(String endpoint) async {
    try {
      talker?.debug('🌐 API Request: GET $endpoint');
      final response = await _dio.get(endpoint);
      talker?.debug('✅ API Response: $endpoint (${response.statusCode})');
      return response.data.toString();
    } catch (e, stack) {
      talker?.error('❌ API Error: $endpoint', e, stack);
      rethrow;
    }
  }

  Future<String> postData(String endpoint, Map<String, dynamic> data) async {
    try {
      talker?.debug('🌐 API Request: POST $endpoint');
      final response = await _dio.post(endpoint, data: data);
      talker?.debug('✅ API Response: $endpoint (${response.statusCode})');
      return response.data.toString();
    } catch (e, stack) {
      talker?.error('❌ API Error: $endpoint', e, stack);
      rethrow;
    }
  }
}
