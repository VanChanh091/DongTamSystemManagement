import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/secure_storage_service.dart';

class OrderService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  //get all order
  Future<List<Order>> getAllOrders() async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        "/api/order/",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['orders'] as List;
      return data.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //get by customer name
  Future<List<Order>> getOrderByCustomerName(String inputCustomerName) async {
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
      final List<dynamic> orderData = response.data['orders'];
      return orderData
          .map((json) => Order.fromJson(json))
          .where(
            (order) => order.customer!.customerName.toLowerCase().contains(
              inputCustomerName.toLowerCase(),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //get by product name
  Future<List<Order>> getOrderByProductName(String inputProductName) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/order/productName',
        queryParameters: {'name': inputProductName},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final List<dynamic> orderData = response.data['orders'];
      return orderData
          .map((json) => Order.fromJson(json))
          .where(
            (order) => order.product!.productName.toLowerCase().contains(
              inputProductName.toLowerCase(),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //get by type product
  Future<List<Order>> getOrderByTypeProduct(String inputTypeProduct) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/order/typeProduct',
        queryParameters: {'type': inputTypeProduct},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final List<dynamic> orderData = response.data['orders'];
      return orderData
          .map((json) => Order.fromJson(json))
          .where(
            (order) => order.product!.typeProduct.toLowerCase().contains(
              inputTypeProduct.toLowerCase(),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //get by QC box
  Future<List<Order>> getOrderByQcBox(String inputQcBox) async {
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
      final List<dynamic> orderData = response.data['orders'];
      return orderData
          .map((json) => Order.fromJson(json))
          .where(
            (order) =>
                order.QC_box!.toLowerCase().contains(inputQcBox.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //get by price
  Future<List<Order>> getOrderByPrice(double inputPrice) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/order/price',
        queryParameters: {'price': inputPrice.toString()},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final List<dynamic> orderData = response.data['orders'];
      return orderData.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //add order
  Future<bool> addOrders(Map<String, dynamic> orderData) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        "/api/order/",
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
        "/api/order/orders?id=$orderId",
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
      throw Exception('Failed to load orders: $e');
    }
  }

  //delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.delete(
        '/api/order/orders?id=$orderId',
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
