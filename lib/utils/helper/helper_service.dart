import 'package:dio/dio.dart';
import 'package:dongtam/constant/app_info.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class HelperService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  //get data pagination
  Future<Map<String, dynamic>> fetchPaginatedData<T>({
    required String endpoint,
    required Map<String, dynamic> queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    required String dataKey,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/$endpoint',
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;

      final rawList = data['data'] as List;
      final items =
          rawList
              .map((json) => fromJson(json as Map<String, dynamic>))
              .toList();

      return {
        dataKey: items,
        'totalPages': data['totalPages'] ?? 1,
        'currentPage': data['currentPage'] ?? 1,
      };
    } catch (e, s) {
      AppLogger.e(
        "Failed to load data from $endpoint\nError: $e\nStackTrace: $s",
      );
      throw Exception('Failed to load data from $endpoint: $e');
    }
  }

  //get all data
  Future<List<T>> fetchingData<T>({
    required String endpoint,
    required Map<String, dynamic> queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/$endpoint',
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data['data'] as List;

      return data
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, s) {
      AppLogger.e(
        "Failed to load data from $endpoint\nError: $e\nStackTrace: $s",
      );
      throw Exception('Failed to load data from $endpoint: $e');
    }
  }
}
