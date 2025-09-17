import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class CustomerService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  // get all
  Future<Map<String, dynamic>> getAllCustomers({
    bool refresh = false,
    int? page,
    int? pageSize,
    bool noPaging = false,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        "/api/customer/",
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          'refresh': refresh,
          'noPaging': noPaging,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      final customers = data['data'] as List; //data

      // Luôn parse list customers
      final parsedCustomers =
          customers.map((e) => Customer.fromJson(e)).toList();

      if (noPaging) {
        return {'customers': parsedCustomers};
      } else {
        final totalPages = data['totalPages']; //page size
        final currentPage = data['currentPage']; //page

        return {
          'customers': parsedCustomers,
          "totalPages": totalPages,
          "currentPage": currentPage,
        };
      }
    } catch (e) {
      throw Exception('Failed to load customers: $e');
    }
  }

  // get by id
  Future<Map<String, dynamic>> getCustomerById({
    String customerId = "",
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/customer/byCustomerId',
        queryParameters: {
          'customerId': customerId,
          'page': page,
          'pageSize': pageSize,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      final customers = data['data'] as List; //data
      final totalPages = data['totalPages'] ?? 1;
      final currentPage = data['currentPage'] ?? 1;

      final filteredCustomer =
          customers.map((json) => Customer.fromJson(json)).toList();

      return {
        'customers': filteredCustomer,
        'totalPages': totalPages,
        'currentPage': currentPage,
      };
    } catch (e) {
      throw Exception('Failed to get customerId: $e');
    }
  }

  // get by name
  Future<Map<String, dynamic>> getCustomerByName(
    String name,
    int page,
    int pageSize,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/customer/byName',
        queryParameters: {'name': name, 'page': page, 'pageSize': pageSize},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      final customers = data['data'] as List; //data
      final totalPages = data['totalPages'] ?? 1;
      final currentPage = data['currentPage'] ?? 1;

      final filteredCustomer =
          customers.map((json) => Customer.fromJson(json)).toList();

      return {
        'customers': filteredCustomer,
        'totalPages': totalPages,
        'currentPage': currentPage,
      };
    } catch (e) {
      throw Exception('Failed to get customerName: $e');
    }
  }

  // get by cskh
  Future<Map<String, dynamic>> getCustomerByCSKH(
    String cskh,
    int page,
    int pageSize,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/customer/byCskh',
        queryParameters: {'cskh': cskh, 'page': page, 'pageSize': pageSize},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      final customers = data['data'] as List; //data
      final totalPages = data['totalPages'] ?? 1;
      final currentPage = data['currentPage'] ?? 1;

      final filteredCustomer =
          customers.map((json) => Customer.fromJson(json)).toList();

      return {
        'customers': filteredCustomer,
        'totalPages': totalPages,
        'currentPage': currentPage,
      };
    } catch (e) {
      throw Exception('Failed to get customerName: $e');
    }
  }

  // get by phone
  Future<Map<String, dynamic>> getCustomerByPhone(
    String phone,
    int page,
    int pageSize,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/customer/byPhone',
        queryParameters: {'phone': phone, 'page': page, 'pageSize': pageSize},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      final customers = data['data'] as List; //data
      final totalPages = data['totalPages'] ?? 1;
      final currentPage = data['currentPage'] ?? 1;

      final filteredCustomer =
          customers.map((json) => Customer.fromJson(json)).toList();

      return {
        'customers': filteredCustomer,
        'totalPages': totalPages,
        'currentPage': currentPage,
      };
    } catch (e) {
      throw Exception('Failed to get customerName: $e');
    }
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }
}
