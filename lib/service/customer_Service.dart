import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/customer_model.dart';

class CustomerService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  // get all //done
  Future<List<Customer>> getAllCustomers() async {
    try {
      final response = await dioService.get("/api/customer/");
      // print(response.data);
      final data = response.data['data'] as List;

      return data.map((e) => Customer.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load customers: $e');
    }
  }

  // get by id
  Future<Customer> getCustomerById(String customerId) async {
    try {
      final response = await dioService.get('/api/customer/$customerId');

      return Customer.fromJson(response.data['customer']);
    } catch (e) {
      throw Exception('Failed to get customerId: $e');
    }
  }

  // get by name
  Future<Customer> getCustomerByName(String customerName) async {
    try {
      final response = await dioService.get(
        '/api/customer/search/$customerName',
      );
      return Customer.fromJson(response.data['customer']);
    } catch (e) {
      throw Exception('Failed to get customerName: $e');
    }
  }

  // add customer
  Future<bool> addCustomer(Map<String, dynamic> customerData) async {
    try {
      await dioService.post("/api/customer/", data: customerData);

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
      await dioService.put("/api/customer/$customerId", data: updateCustomer);

      return true;
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  // delete customer
  Future<bool> deleteCustomer(String customerId) async {
    try {
      await dioService.delete('/api/customer/$customerId');
      return true;
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }
}
