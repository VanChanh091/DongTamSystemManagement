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
    int? page,
    int? pageSize,
    bool noPaging = false,
  }) async {
    return HelperService().fetchPaginatedData<Customer>(
      endpoint: "customer/getAllCustomer",
      queryParameters: {'page': page, 'pageSize': pageSize, 'noPaging': noPaging},
      fromJson: (json) => Customer.fromJson(json),
      dataKey: 'customers',
    );
  }

  Future<Map<String, dynamic>> getCustomerByField({
    required String field,
    required String keyword,
    int page = 1,
    int pageSize = 30,
  }) async {
    return HelperService().fetchPaginatedData<Customer>(
      endpoint: 'customer/filter',
      queryParameters: {'field': field, 'keyword': keyword, 'page': page, 'pageSize': pageSize},
      fromJson: (json) => Customer.fromJson(json),
      dataKey: 'customers',
    );
  }

  // Future<Map<String, dynamic>> checkCustomerInOrders({required String customerId}) async {
  //   try {
  //     final token = await SecureStorageService().getToken();

  //     final response = await dioService.get(
  //       '/api/customer/orderCount',
  //       queryParameters: {"customerId": customerId},
  //       options: Options(
  //         headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
  //       ),
  //     );

  //     return response.data;
  //   } catch (e, s) {
  //     AppLogger.e("Check customer in orders failed\nError: $e\nStackTrace: $s");
  //     throw Exception('Check customer in orders failed: $e');
  //   }
  // }

  // add customer
  Future<bool> addCustomer({required Map<String, dynamic> customerData}) async {
    return HelperService().addItem(endpoint: "customer/newCustomer", itemData: customerData);
  }

  // update customer
  Future<bool> updateCustomer({
    required String customerId,
    required Map<String, dynamic> updateCustomer,
  }) async {
    return HelperService().updateItem(
      endpoint: "customer/updateCus",
      queryParameters: {"customerId": customerId},
      dataUpdated: updateCustomer,
    );
  }

  // delete customer
  Future<bool> deleteCustomer({required String customerId}) async {
    return HelperService().deleteItem(
      endpoint: "customer/deleteCus",
      queryParameters: {"customerId": customerId},
    );
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
