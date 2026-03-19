import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:file_picker/file_picker.dart';

class HelperService {
  final Dio dioService = DioClient().dio;

  void handleDioException(DioException e, String defaultMessage) {
    if (e.response != null) {
      throw ApiException(
        status: e.response?.statusCode,
        message: e.response?.data?['message'] ?? defaultMessage,
        errorCode: e.response?.data?['errorCode'],
      );
    } else {
      throw Exception("Network Error: ${e.message}");
    }
  }

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

      final result = <String, dynamic>{
        dataKey: items,
        'totalPages': data['totalPages'] ?? 1,
        'currentPage': data['currentPage'] ?? 1,
      };

      // Tự động map tất cả các key trả về từ API (những key như tổng tiền, extra value, v.v)
      data.forEach((key, value) {
        if (key != "data" && key != "totalPages" && key != "currentPage" && key != "message") {
          result[key] = value;
        }
      });

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

      if (data is Map<String, dynamic>) {
        return fromJson(data);
      }

      return null;
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
    } on DioException catch (e) {
      handleDioException(e, "Lỗi khi thêm dữ liệu");
      return false;
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
    } on DioException catch (e) {
      handleDioException(e, "Lỗi khi cập nhật dữ liệu");
      return false;
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
    } on DioException catch (e) {
      handleDioException(e, "Lỗi khi xóa dữ liệu");
      return false;
    } catch (e, s) {
      AppLogger.e("Failed to delete item", error: e, stackTrace: s);
      throw Exception('Failed to delete item: $e');
    }
  }

  //helper export
  Future<File?> saveExcelFile({required List<int> bytes, required String fileNamePrefix}) async {
    try {
      // Cho người dùng chọn thư mục lưu
      final dirPath = await FilePicker.platform.getDirectoryPath();
      if (dirPath == null) return null;

      // Tạo file name
      final now = DateTime.now();
      final fileName = "${fileNamePrefix}_${now.toIso8601String().split('T')[0]}.xlsx";
      final file = File("$dirPath/$fileName");

      // Ghi dữ liệu
      await file.writeAsBytes(bytes, flush: true);
      AppLogger.i("File saved to: ${file.path}");
      return file;
    } catch (e) {
      AppLogger.e("Error saving file: $e");
      return null;
    }
  }
}
