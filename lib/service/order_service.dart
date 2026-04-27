import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:http_parser/http_parser.dart';

class OrderService {
  final Dio dioService = DioClient().dio;

  //===============================ORDER AUTOCOMPLETE=====================================
  Future<List<Order>> getOrderIdRaw({required String orderId}) async {
    return HelperService().fetchingData<Order>(
      endpoint: "order/order-id-raw",
      queryParameters: {'orderId': orderId},
      fromJson: (json) => Order.fromJson(json),
    );
  }

  Future<Order?> getOrderDetail({required String orderId}) async {
    return HelperService().fetchSingleData(
      endpoint: "order/order-detail",
      queryParameters: {'orderId': orderId},
      parser: (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  //===============================ACCEPT AND PLANNING====================================

  //get Order Accept And Planning and search
  Future<Map<String, dynamic>> getOrderAcceptted({
    String? field,
    String? keyword,
    bool ownOnly = false,
  }) async {
    return HelperService().fetchPaginatedData<Order>(
      endpoint: "order/accept",
      queryParameters: {'field': field, 'keyword': keyword, 'ownOnly': ownOnly},
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
  Future<Map<String, dynamic>> addOrders({
    required Map<String, dynamic> orderData,
    Uint8List? imageBytes,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final formData = FormData.fromMap({
        'orderData': jsonEncode(orderData),
        if (imageBytes != null)
          'orderImage': MultipartFile.fromBytes(
            imageBytes,
            filename: 'order.webp',
            contentType: MediaType('image', 'webp'),
          ),
      });

      final response = await dioService.post(
        "/api/order",
        data: formData,
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
    } on DioException catch (e) {
      HelperService().handleDioException(e, "Lỗi khi thêm dữ liệu");
      return {'success': false, 'message': 'Lỗi khi thêm dữ liệu: ${e.message}'};
    } catch (e, s) {
      AppLogger.e("Failed to add order", error: e, stackTrace: s);
      throw Exception('Failed to add order: $e');
    }
  }

  //update order
  Future<bool> updateOrder({
    required String orderId,
    required Map<String, dynamic> orderUpdated,
    Uint8List? imageBytes,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final formData = FormData.fromMap({
        'orderData': jsonEncode(orderUpdated),
        if (imageBytes != null)
          'orderImage': MultipartFile.fromBytes(
            imageBytes,
            filename: 'order.webp',
            contentType: MediaType('image', 'webp'),
          ),
      });

      await dioService.put(
        "/api/order",
        queryParameters: {'orderId': orderId},
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'multipart/form-data'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update order", error: e, stackTrace: s);
      throw Exception('Failed to update order: $e');
    }
  }

  //delete order
  Future<bool> deleteOrder({required String orderId}) async {
    return HelperService().deleteItem(endpoint: 'order', queryParameters: {'orderId': orderId});
  }
}
