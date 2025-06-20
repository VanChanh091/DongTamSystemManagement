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

  //planning for order
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

  //get planning by machine
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

  //get planning by id
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

  //update index planning
  Future<bool> updateIndexPlanning(
    List<Map<String, dynamic>> updateIndex,
    String machine,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/planning/updateIndex",
        data: {"updateIndex": updateIndex, 'machine': machine},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return true;
    } catch (e) {
      throw Exception('Failed to update planning: $e');
    }
  }

  // Get planning by customer name
  Future<List<Planning>> getPlanningByCustomerName(
    String customerName,
    String machine,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/planning/getByCustomerName',
        queryParameters: {'customerName': customerName, 'machine': machine},
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
            (p) => p.order!.customer!.customerName.toLowerCase().contains(
              customerName.toLowerCase(),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get planning by customerName: $e');
    }
  }

  //get planning by flute
  Future<List<Planning>> getPlanningByFlute(
    String flute,
    String machine,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/planning/getByFlute',
        queryParameters: {'flute': flute, 'machine': machine},
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
            (p) => p.order!.flute!.toLowerCase().contains(flute.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get planning by flute: $e');
    }
  }

  //get planning by ghepKho
  Future<List<Planning>> getPlanningByGhepKho(
    int ghepKho,
    String machine,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/planning/getByGhepKho',
        queryParameters: {'ghepKho': ghepKho, 'machine': machine},
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
          .where((p) => p.ghepKho == ghepKho)
          .toList();
    } catch (e) {
      throw Exception('Failed to get planning by ghepKho: $e');
    }
  }
}
