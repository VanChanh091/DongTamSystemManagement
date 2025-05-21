import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class OrderService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  //===============================ACCEPT AND PLANNING====================================

  //get Order Accept And Planning
  Future<Map<String, dynamic>> getOrderAcceptAndPlanning(
    int page,
    int pageSize,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        "/api/order/accept-planning",
        queryParameters: {"page": page, 'pageSize': pageSize},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data;
      final orders = data['data'] as List;
      final currentPage = data['currentPage'];
      final totalPages = data['totalPages'];

      print('Current Page: $totalPages');

      // Trả về dữ liệu cùng với totalPages và currentPage
      return {
        'orders': orders.map((e) => Order.fromJson(e)).toList(),
        'currentPage': currentPage,
        'totalPages': totalPages,
      };
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //get by customer name
  Future<Map<String, dynamic>> getOrderByCustomerName(
    String inputCustomerName,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/order/customerName',
        queryParameters: {'name': inputCustomerName},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      final List<dynamic> orderData = data['data'];

      final filteredOrders =
          orderData.map((json) => Order.fromJson(json)).toList();
      final totalPages = data['totalPages'] ?? 1;
      final currentPage = data['currentPage'] ?? 1;

      return {
        'orders': filteredOrders,
        'totalPages': totalPages,
        'currentPage': currentPage,
      };
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //get by product name
  Future<Map<String, dynamic>> getOrderByProductName(
    String inputProductName,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/order/productName',
        queryParameters: {'productName': inputProductName},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      final List<dynamic> orderData = data['data'];

      final filteredOrders =
          orderData.map((json) => Order.fromJson(json)).toList();
      final totalPages = data['totalPages'] ?? 1;
      final currentPage = data['currentPage'] ?? 1;

      return {
        'orders': filteredOrders,
        'totalPages': totalPages,
        'currentPage': currentPage,
      };
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //get by QC box
  Future<Map<String, dynamic>> getOrderByQcBox(String inputQcBox) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/order/qcBox',
        queryParameters: {'QcBox': inputQcBox},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      final List<dynamic> orderData = data['data'];

      final filteredOrders =
          orderData.map((json) => Order.fromJson(json)).toList();
      final totalPages = data['totalPages'] ?? 1;
      final currentPage = data['currentPage'] ?? 1;

      return {
        'orders': filteredOrders,
        'totalPages': totalPages,
        'currentPage': currentPage,
      };
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //get by price
  Future<Map<String, dynamic>> getOrderByPrice(double price) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/order/price',
        queryParameters: {'price': price},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      final List<dynamic> orderData = data['data'];

      final filteredOrders =
          orderData.map((json) => Order.fromJson(json)).toList();
      final totalPages = data['totalPages'] ?? 1;
      final currentPage = data['currentPage'] ?? 1;

      return {
        'orders': filteredOrders,
        'totalPages': totalPages,
        'currentPage': currentPage,
      };
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //===============================PENDING AND REJECT=====================================

  //get Order Pending And Reject
  Future<List<Order>> getOrderPendingAndReject() async {
    try {
      final token = await SecureStorageService().getToken();
      final response = await dioService.get(
        "/api/order/pending-reject",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //add order
  Future<bool> addOrders(Map<String, dynamic> orderData) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        "/api/order",
        data: orderData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //update order
  Future<bool> updateOrderById(
    String orderId,
    Map<String, dynamic> orderUpdated,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/order/orders",
        queryParameters: {'id': orderId},
        data: orderUpdated,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e) {
      throw Exception('Failed to update orders: $e');
    }
  }

  //delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.delete(
        '/api/order/orders',
        queryParameters: {'id': orderId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }
}
