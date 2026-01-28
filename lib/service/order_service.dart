import 'package:dio/dio.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class OrderService {
  final Dio dioService = DioClient().dio;

  //===============================ORDER AUTOCOMPLETE=====================================
  Future<List<Order>> getOrderIdRaw({required String orderId}) async {
    return HelperService().fetchingData<Order>(
      endpoint: "order/getOrderIdRaw",
      queryParameters: {'orderId': orderId},
      fromJson: (json) => Order.fromJson(json),
    );
  }

  Future<Order?> getOrderDetail({required String orderId}) async {
    return HelperService().fetchSingleData(
      endpoint: "order/getOrderDetail",
      queryParameters: {'orderId': orderId},
      parser: (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  //===============================ACCEPT AND PLANNING====================================

  //get Order Accept And Planning
  Future<Map<String, dynamic>> getOrderAcceptAndPlanning({
    int page = 1,
    int pageSize = 20,
    bool ownOnly = false,
  }) async {
    return HelperService().fetchPaginatedData<Order>(
      endpoint: "order/accept-planning",
      queryParameters: {'page': page, 'pageSize': pageSize, 'ownOnly': ownOnly},
      fromJson: (json) => Order.fromJson(json),
      dataKey: 'orders',
    );
  }

  //get by customer name
  Future<Map<String, dynamic>> getOrderByField({
    required String field,
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    return HelperService().fetchPaginatedData<Order>(
      endpoint: "order/filter",
      queryParameters: {'field': field, 'keyword': keyword, 'page': page, 'pageSize': pageSize},
      fromJson: (json) => Order.fromJson(json),
      dataKey: 'orders',
    );
  }

  //===============================PENDING AND REJECT=====================================

  //get Order Pending And Reject
  Future<List<Order>> getOrderPendingAndReject({bool ownOnly = false}) async {
    return HelperService().fetchingData<Order>(
      endpoint: "order/pending-reject",
      queryParameters: {'ownOnly': ownOnly},
      fromJson: (json) => Order.fromJson(json),
    );
  }

  //add order
  Future<Map<String, dynamic>> addOrders({required Map<String, dynamic> orderData}) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.post(
        "/api/order",
        data: orderData,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return response.data;
        } else {
          throw Exception("Invalid response format from server");
        }
      } else {
        throw Exception(
          'Thêm đơn hàng thất bại: ${response.statusCode} - ${response.statusMessage}',
        );
      }
    } catch (e, s) {
      AppLogger.e("Failed to add order", error: e, stackTrace: s);
      throw Exception('Failed to add order: $e');
    }
  }

  //update order
  Future<bool> updateOrderById({
    required String orderId,
    required Map<String, dynamic> orderUpdated,
  }) async {
    return HelperService().updateItem(
      endpoint: 'order/orders',
      queryParameters: {'orderId': orderId},
      dataUpdated: orderUpdated,
    );
  }

  //delete order
  Future<bool> deleteOrder({required String orderId}) async {
    return HelperService().deleteItem(endpoint: 'order/orders', queryParameters: {'id': orderId});
  }
}
