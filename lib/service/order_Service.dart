import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/order/order_model.dart';

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
      final response = await dioService.get("/api/order/");
      final data = response.data['data'];

      if (data is List) {
        return data.map((e) => Order.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //get order by id
  Future<List<Order>> getOrdersById(String orderId) async {
    try {
      final response = await dioService.get('/api/order/$orderId');

      final List<dynamic> orderData = response.data['orders'];
      return orderData
          .map((json) => Order.fromJson(json))
          .where(
            (customer) =>
                customer.orderId.toLowerCase().contains(orderId.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //add order
  Future<bool> addOrders(Map<String, dynamic> orderData) async {
    try {
      await dioService.post("/api/order/", data: orderData);
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
      await dioService.put("/api/order/", data: orderUpdated);
      return true;
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      await dioService.delete('/api/order/orders?id=$orderId');
      return true;
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }
}
