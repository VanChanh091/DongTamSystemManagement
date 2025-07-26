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
  Future<List<Customer>> getAllCustomers(bool refresh) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        "/api/customer/",
        queryParameters: {'refresh': refresh},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;

      return data.map((e) => Customer.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load customers: $e');
    }
  }

  // get by id
  Future<List<Customer>> getCustomerById(String customerId) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/customer/$customerId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> customersData = response.data['data'];
      return customersData.map((e) => Customer.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to get customerId: $e');
    }
  }

  // get by name
  Future<List<Customer>> getCustomerByName(String customerName) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/customer/byName/$customerName',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> customersData = response.data['data'];
      return customersData.map((e) => Customer.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to get customerName: $e');
    }
  }

  // get by cskh
  Future<List<Customer>> getCustomerByCSKH(String nameCSKH) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/customer/cskh/$nameCSKH',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final List<dynamic> customersData = response.data['data'];
      return customersData.map((e) => Customer.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to get customerName: $e');
    }
  }

  // get by cskh
  Future<List<Customer>> getCustomerByPhone(String phone) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/customer/phone/$phone',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final List<dynamic> customersData = response.data['data'];
      return customersData
          .map((json) => Customer.fromJson(json))
          .where((customer) => customer.phone.contains(phone))
          .toList();
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
        "/api/customer/$customerId",
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
        '/api/customer/$customerId',
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
