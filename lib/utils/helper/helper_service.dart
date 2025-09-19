import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class HelperService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  //get properties pagination
  Future<Map<String, dynamic>> fetchPaginatedData<T>({
    required String endpoint,
    required Map<String, dynamic> queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    String dataKey = 'items',
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
    } catch (e) {
      throw Exception('Failed to get customerName: $e');
    }
  }
}
