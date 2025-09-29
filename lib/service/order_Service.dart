import 'package:dio/dio.dart';
import 'package:dongtam/constant/app_info.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
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
  Future<Map<String, dynamic>> getOrderAcceptAndPlanning({
    int page = 1,
    int pageSize = 20,
    bool refresh = false,
    bool ownOnly = false,
  }) async {
    return HelperService().fetchPaginatedData<Order>(
      endpoint: "order/accept-planning",
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
        'ownOnly': ownOnly,
      },
      fromJson: (json) => Order.fromJson(json),
      dataKey: 'orders',
    );
  }

  //get by customer name
  Future<Map<String, dynamic>> getOrderByCustomerName({
    String inputCustomerName = "",
    int page = 1,
    int pageSize = 20,
  }) async {
    return HelperService().fetchPaginatedData<Order>(
      endpoint: "order/customerName",
      queryParameters: {
        'name': inputCustomerName,
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) => Order.fromJson(json),
      dataKey: 'orders',
    );
  }

  //get by product name
  Future<Map<String, dynamic>> getOrderByProductName({
    String inputProductName = "",
    int page = 1,
    int pageSize = 20,
  }) async {
    return HelperService().fetchPaginatedData<Order>(
      endpoint: "order/productName",
      queryParameters: {
        'productName': inputProductName,
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) => Order.fromJson(json),
      dataKey: 'orders',
    );
  }

  //get by QC box
  Future<Map<String, dynamic>> getOrderByQcBox({
    String inputQcBox = "",
    int page = 1,
    int pageSize = 20,
  }) async {
    return HelperService().fetchPaginatedData<Order>(
      endpoint: "order/qcBox",
      queryParameters: {
        'QcBox': inputQcBox,
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) => Order.fromJson(json),
      dataKey: 'orders',
    );
  }

  //get by price
  Future<Map<String, dynamic>> getOrderByPrice({
    String price = "",
    int page = 1,
    int pageSize = 20,
  }) async {
    return HelperService().fetchPaginatedData<Order>(
      endpoint: "order/price",
      queryParameters: {'price': price, 'page': page, 'pageSize': pageSize},
      fromJson: (json) => Order.fromJson(json),
      dataKey: 'orders',
    );
  }

  //===============================PENDING AND REJECT=====================================

  //get Order Pending And Reject
  Future<List<Order>> getOrderPendingAndReject({
    bool refresh = false,
    bool ownOnly = false,
  }) async {
    return HelperService().fetchingData<Order>(
      endpoint: "order/pending-reject",
      queryParameters: {'refresh': refresh, 'ownOnly': ownOnly},
      fromJson: (json) => Order.fromJson(json),
    );
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
    } catch (e, s) {
      AppLogger.e("Failed to load orders", error: e, stackTrace: s);
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
        queryParameters: {'orderId': orderId},
        data: orderUpdated,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update orders", error: e, stackTrace: s);
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
    } catch (e, s) {
      AppLogger.e("Failed to delete orders", error: e, stackTrace: s);
      throw Exception('Failed to delete orders: $e');
    }
  }
}
