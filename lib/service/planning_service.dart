import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_model.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class PlanningService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  //get status order
  Future<List<Order>> getOrderAccept() async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/planning/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      // print('Data: $data');
      return data.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<bool> planningOrder(
    String orderId,
    String newStatus,
    Map<String, dynamic> orderPlanning,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/planning/planningOrder',
        queryParameters: {"orderId": orderId, "newStatus": newStatus},
        data: orderPlanning,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return true;
    } catch (e) {
      throw Exception('Failed to plan order: $e');
    }
  }

  Future<List<Planning>> getPlanningByMachine(String machine) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/planning/byMachine',
        queryParameters: {'machine': machine},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> planningData = response.data['data'];
      return planningData
          .map((json) => Planning.fromJson(json))
          .where(
            (planning) => planning.chooseMachine.toLowerCase().contains(
              machine.toLowerCase(),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get planning: $e');
    }
  }

  Future<bool> changeMachinePlanning(
    List<int> planningIds,
    String newMachine,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/planning/changeMachine",
        data: {"planningIds": planningIds, "newMachine": newMachine},
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
