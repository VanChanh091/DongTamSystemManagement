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

  //get by customer name
  // Future<List<Order>> getOrderByCustomerName(String orderId) async {
  //   try {
  //     final response = await dioService.get();

  //     final List<dynamic> orderData = response.data['orders'];
  //     return orderData
  //         .map((json) => Order.fromJson(json))
  //         .where(
  //           (customer) => customer.customerName.toLowerCase().contains(
  //             orderId.toLowerCase(),
  //           ),
  //         )
  //         .toList();
  //   } catch (e) {
  //     throw Exception('Failed to load orders: $e');
  //   }
  // }

  //get by product name
  Future<List<Order>> getOrderByProductName(String inputProductName) async {
    try {
      final response = await dioService.get(
        '/api/order/productName?name=$inputProductName',
      );

      final List<dynamic> orderData = response.data['orders'];
      return orderData
          .map((json) => Order.fromJson(json))
          .where(
            (order) => order.productName!.toLowerCase().contains(
              inputProductName.toLowerCase(),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //get by type product
  Future<List<Order>> getOrderByTypeProduct(String inputCustomerName) async {
    try {
      final response = await dioService.get(
        '/api/order/customerName?name=$inputCustomerName',
      );

      final List<dynamic> orderData = response.data['orders'];
      return orderData
          .map((json) => Order.fromJson(json))
          .where(
            (order) => order.customer!.customerName!.toLowerCase().contains(
              inputCustomerName.toLowerCase(),
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
      final response = await dioService.get(
        '/api/order/qcBox?QcBox=$inputQcBox',
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
      final response = await dioService.get(
        '/api/order/qcBox?QcBox=$inputPrice',
      );

      final List<dynamic> orderData = response.data['orders'];
      return orderData
          .map((json) => Order.fromJson(json))
          .where((order) => order.price == inputPrice)
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
      await dioService.put("/api/order/orders?id=$orderId", data: orderUpdated);
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
