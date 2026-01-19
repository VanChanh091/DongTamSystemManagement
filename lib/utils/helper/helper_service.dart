import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:file_picker/file_picker.dart';

class HelperService {
  final Dio dioService = DioClient().dio;

  //get data pagination
  Future<Map<String, dynamic>> fetchPaginatedData<T>({
    required String endpoint,
    required Map<String, dynamic> queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    required String dataKey,
    String? totalKey,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/$endpoint',
        queryParameters: queryParameters,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      final data = response.data;

      final rawList = data['data'] as List;

      final items = rawList.map((json) => fromJson(json as Map<String, dynamic>)).toList();

      final result = {
        dataKey: items,
        'totalPages': data['totalPages'] ?? 1,
        'currentPage': data['currentPage'] ?? 1,
      };

      if (totalKey != null && totalKey.isNotEmpty) {
        result[totalKey] = data[totalKey] ?? 0;
      }

      return result;
    } catch (e, s) {
      AppLogger.e("Failed to load data from $endpoint\nError: $e\nStackTrace: $s");
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
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      final data = response.data['data'] as List;

      return data.map((json) => fromJson(json as Map<String, dynamic>)).toList();
    } catch (e, s) {
      AppLogger.e("Failed to load data from $endpoint\nError: $e\nStackTrace: $s");
      throw Exception('Failed to load data from $endpoint: $e');
    }
  }

  //get list data
  Future<T?> fetchingSingleListData<T>({
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
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      final data = response.data['data'];
      if (data == null) return null;

      return fromJson(data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.e("Failed to load data from $endpoint\nError: $e");
      throw Exception('Failed to load data from $endpoint: $e');
    }
  }

  //get 1 data
  Future<T?> fetchSingleData<T>({
    required String endpoint,
    required Map<String, dynamic> queryParameters,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/$endpoint',
        queryParameters: queryParameters,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      final data = response.data['data'];
      if (data == null) return null;

      return parser(data);
    } catch (e) {
      throw Exception('Failed to load data from $endpoint: $e');
    }
  }

  //add item
  Future<bool> addItem({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    required Map<String, dynamic> itemData,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        "/api/$endpoint",
        queryParameters: queryParameters,
        data: itemData,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to add item", error: e, stackTrace: s);
      throw Exception('Failed to add item: $e');
    }
  }

  //update item
  Future<bool> updateItem({
    required String endpoint,
    required Map<String, dynamic> queryParameters,
    Map<String, dynamic>? dataUpdated,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/$endpoint",
        queryParameters: queryParameters,
        data: dataUpdated,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update item", error: e, stackTrace: s);
      throw Exception('Failed to update item: $e');
    }
  }

  //delete item
  Future<bool> deleteItem({
    required String endpoint,
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final token = await SecureStorageService().getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      await dioService.delete(
        '/api/$endpoint',
        queryParameters: queryParameters,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to delete item", error: e, stackTrace: s);
      throw Exception('Failed to delete item: $e');
    }
  }

  //export excel
  Future<File?> exportExcelItem({DateTime? fromDate, DateTime? toDate, bool all = false}) async {
    try {
      final token = await SecureStorageService().getToken();

      final Map<String, dynamic> body = {"all": all};

      if (fromDate != null && toDate != null) {
        body["fromDate"] = fromDate.toIso8601String();
        body["toDate"] = toDate.toIso8601String();
      }

      final response = await dioService.post(
        "/api/customer/exportExcel",
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        final bytes = response.data as List<int>;
        AppLogger.d("Received ${bytes.length} bytes from API");

        // Cho người dùng chọn thư mục lưu
        final dirPath = await FilePicker.platform.getDirectoryPath();
        if (dirPath == null) {
          return null;
        }

        final now = DateTime.now();
        final fileName = "customer_${now.toIso8601String().split('T')[0]}.xlsx";
        final file = File("$dirPath/$fileName");

        await file.writeAsBytes(bytes, flush: true);
        AppLogger.i("Exported Excel customer to: ${file.path}");

        return file;
      } else {
        AppLogger.w("Export failed with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("failed to export customer", error: e, stackTrace: s);
      return null;
    }
  }
}
