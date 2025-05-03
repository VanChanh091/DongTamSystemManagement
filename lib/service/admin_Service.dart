import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/secure_storage_service.dart';

class AdminService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  //get status order
  Future<List<Order>> getOrderByStatus() async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/',
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

  //update status order
  Future<bool> updateStatusOrder(String orderId, String newStatus) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/admin/updateStatus?id=$orderId&newStatus=$newStatus",
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
}
