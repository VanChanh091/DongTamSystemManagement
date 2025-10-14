import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:file_picker/file_picker.dart';

class CustomerService {
  final Dio dioService = DioClient().dio;

  // get all
  Future<Map<String, dynamic>> getAllCustomers({
    bool refresh = false,
    int? page,
    int? pageSize,
    bool noPaging = false,
  }) async {
    return HelperService().fetchPaginatedData<Customer>(
      endpoint: "customer",
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
        'noPaging': noPaging,
      },
      fromJson: (json) => Customer.fromJson(json),
      dataKey: 'customers',
    );
  }

  // get by id
  Future<Map<String, dynamic>> getCustomerById({
    String customerId = "",
    int page = 1,
    int pageSize = 25,
  }) async {
    return HelperService().fetchPaginatedData<Customer>(
      endpoint: 'customer/byCustomerId',
      queryParameters: {
        'customerId': customerId,
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) => Customer.fromJson(json),
      dataKey: 'customers',
    );
  }

  // get by name
  Future<Map<String, dynamic>> getCustomerByName(
    String name,
    int page,
    int pageSize,
  ) async {
    return HelperService().fetchPaginatedData<Customer>(
      endpoint: 'customer/byName',
      queryParameters: {'name': name, 'page': page, 'pageSize': pageSize},
      fromJson: (json) => Customer.fromJson(json),
      dataKey: 'customers',
    );
  }

  // get by cskh
  Future<Map<String, dynamic>> getCustomerByCSKH(
    String cskh,
    int page,
    int pageSize,
  ) async {
    return HelperService().fetchPaginatedData<Customer>(
      endpoint: 'customer/byCskh',
      queryParameters: {'cskh': cskh, 'page': page, 'pageSize': pageSize},
      fromJson: (json) => Customer.fromJson(json),
      dataKey: 'customers',
    );
  }

  // get by phone
  Future<Map<String, dynamic>> getCustomerByPhone(
    String phone,
    int page,
    int pageSize,
  ) async {
    return HelperService().fetchPaginatedData<Customer>(
      endpoint: 'customer/byPhone',
      queryParameters: {'phone': phone, 'page': page, 'pageSize': pageSize},
      fromJson: (json) => Customer.fromJson(json),
      dataKey: 'customers',
    );
  }

  // add customer
  Future<bool> addCustomer(Map<String, dynamic> customerData) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        "/api/customer/",
        data: customerData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to add customer", error: e, stackTrace: s);
      throw Exception('Failed to add customer: $e');
    }
  }

  // update customer
  Future<bool> updateCustomer(
    String customerId,
    Map<String, dynamic> updateCustomer,
  ) async {
    try {
      final token = await SecureStorageService().getToken();
      await dioService.put(
        "/api/customer/customerUp",
        queryParameters: {"customerId": customerId},
        data: updateCustomer,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update customer", error: e, stackTrace: s);
      throw Exception('Failed to update customer: $e');
    }
  }

  // delete customer
  Future<bool> deleteCustomer(String customerId) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.delete(
        "/api/customer/customerDel",
        queryParameters: {"customerId": customerId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to delete customer", error: e, stackTrace: s);
      throw Exception('Failed to delete customer: $e');
    }
  }

  //export customer
  Future<File?> exportExcelCustomer({
    DateTime? fromDate,
    DateTime? toDate,
    bool all = false,
  }) async {
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
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
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
