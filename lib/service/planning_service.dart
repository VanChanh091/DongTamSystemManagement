import 'package:dio/dio.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlanningService {
  final Dio dioService = DioClient().dio;

  //===============================PLANNING ORDER====================================

  //get status order
  Future<List<Order>> getOrderAccept() async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/planning/',
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );
      final data = response.data['data'] as List;

      return data.map((e) => Order.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("NO_PERMISSION");
      }
      rethrow;
    } catch (e, s) {
      AppLogger.e("Failed to load product", error: e, stackTrace: s);
      throw Exception('Failed to load orders: $e');
    }
  }

  //planning for order
  Future<bool> planningOrder({
    required String orderId,
    required Map<String, dynamic> orderPlanning,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/planning/planningOrder',
        queryParameters: {"orderId": orderId},
        data: orderPlanning,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to plan order", error: e, stackTrace: s);
      throw Exception('Failed to plan order: $e');
    }
  }

  //===============================PLANNING PAPER====================================

  //get planning by machine
  Future<List<PlanningPaper>> getPlanningPaperByMachine({required String machine}) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/planning/byMachinePaper',
        queryParameters: {'machine': machine},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> planningData = response.data['data'];
      return planningData.map((json) => PlanningPaper.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("NO_PERMISSION");
      }
      rethrow;
    } catch (e, s) {
      AppLogger.e("Failed to get planning", error: e, stackTrace: s);
      throw Exception('Failed to get planning: $e');
    }
  }

  //get planning paper by field
  Future<List<PlanningPaper>> getPlanningPaperSearch({
    required String field,
    required String keyword,
    required String machine,
  }) async {
    return HelperService().fetchingData<PlanningPaper>(
      endpoint: "planning/filterPaper",
      queryParameters: {'machine': machine, 'field': field, 'keyword': keyword},
      fromJson: (json) => PlanningPaper.fromJson(json),
    );
  }

  //change machine
  Future<bool> changeMachinePlanning({
    required String newMachine,
    required List<int> planningIds,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/planning/changeMachinePaper",
        data: {"planningIds": planningIds, "newMachine": newMachine},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update orders", error: e, stackTrace: s);
      throw Exception('Failed to update orders: $e');
    }
  }

  //update index planning
  Future<bool> updateIndexWTimeRunning({
    required String machine,
    required DateTime dayStart,
    required TimeOfDay timeStart,
    required int totalTimeWorking,
    required List<Map<String, dynamic>> updateIndex,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        "/api/planning/updateIndex_TimeRunningPaper",
        data: {
          'machine': machine,
          "dayStart": DateFormat('yyyy-MM-dd').format(dayStart),
          "timeStart":
              "${timeStart.hour.toString().padLeft(2, '0')}:${timeStart.minute.toString().padLeft(2, '0')}",
          "totalTimeWorking": totalTimeWorking,
          "updateIndex": updateIndex,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update planning", error: e, stackTrace: s);
      throw Exception('Failed to update planning: $e');
    }
  }

  //pause order
  Future<bool> pauseOrAcceptLackQty({
    required List<int> planningIds,
    required String newStatus,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/planning/pauseOrAcceptLackQtyPaper",
        data: {'planningIds': planningIds, "newStatus": newStatus},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to pause machine", error: e, stackTrace: s);
      throw Exception('Failed to pause machine: $e');
    }
  }

  //===============================PLANNING BOX====================================

  Future<List<PlanningBox>> getPlanningMachineBox({required String machine}) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/planning/byMachineBox',
        queryParameters: {'machine': machine},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> planningData = response.data['data'];
      // print(planningData);
      return planningData.map((json) => PlanningBox.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("NO_PERMISSION");
      }
      rethrow;
    } catch (e, s) {
      AppLogger.e("Failed to get planning", error: e, stackTrace: s);
      throw Exception('Failed to get planning: $e');
    }
  }

  //get planning paper by field
  Future<List<PlanningBox>> getPlanningBoxSearch({
    required String field,
    required String keyword,
    required String machine,
  }) async {
    return HelperService().fetchingData<PlanningBox>(
      endpoint: "planning/filterBox",
      queryParameters: {'machine': machine, 'field': field, 'keyword': keyword},
      fromJson: (json) => PlanningBox.fromJson(json),
    );
  }

  //update index planning
  Future<bool> updateIndexWTimeRunningBox({
    required String machine,
    required DateTime dayStart,
    required TimeOfDay timeStart,
    required int totalTimeWorking,
    required List<Map<String, dynamic>> updateIndex,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        "/api/planning/updateIndex_TimeRunningBox",
        data: {
          'machine': machine,
          "dayStart": DateFormat('yyyy-MM-dd').format(dayStart),
          "timeStart":
              "${timeStart.hour.toString().padLeft(2, '0')}:${timeStart.minute.toString().padLeft(2, '0')}",
          "totalTimeWorking": totalTimeWorking,
          "updateIndex": updateIndex,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update planning", error: e, stackTrace: s);
      throw Exception('Failed to update planning: $e');
    }
  }

  //accept lack qty
  Future<bool> acceptLackQtyBox({
    required List<int> planningBoxIds,
    required String newStatus,
    required String machine,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/planning/acceptLackQtyBox",
        data: {"planningBoxIds": planningBoxIds, "newStatus": newStatus, "machine": machine},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to pause machine", error: e, stackTrace: s);
      throw Exception('Failed to pause machine: $e');
    }
  }

  //===============================PLANNING STOP====================================

  Future<Map<String, dynamic>> getPlanningStop({int? page, int? pageSize}) async {
    return HelperService().fetchPaginatedData<PlanningPaper>(
      endpoint: "planning/getPlanningStop",
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (json) => PlanningPaper.fromJson(json),
      dataKey: 'plannings',
      totalKey: 'totalPlannings',
    );
  }
}
