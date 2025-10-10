import 'package:dio/dio.dart';
import 'package:dongtam/constant/app_info.dart';
import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class CustomerService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  // final Dio dioService = DioClient().dio;

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
}
