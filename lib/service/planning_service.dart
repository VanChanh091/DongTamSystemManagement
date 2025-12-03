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

  //===============================PLANNING PAPER & BOX==============================

  //get planning by machine
  Future<List<T>> getPlanningByMachine<T>({required String machine, bool isBox = false}) async {
    try {
      final token = await SecureStorageService().getToken();

      final endpoint = isBox ? 'byMachineBox' : 'byMachinePaper';

      final response = await dioService.get(
        '/api/planning/$endpoint',
        queryParameters: {'machine': machine},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> planningData = response.data['data'];

      return planningData.map<T>((json) {
        if (isBox) {
          return PlanningBox.fromJson(json) as T;
        } else {
          return PlanningPaper.fromJson(json) as T;
        }
      }).toList();
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
  Future<List<T>> getPlanningSearch<T>({
    required String field,
    required String keyword,
    required String machine,
    bool isBox = false,
  }) async {
    final endpoint = isBox ? "filterBox" : "filterPaper";

    return HelperService().fetchingData<T>(
      endpoint: "planning/$endpoint",
      queryParameters: {'machine': machine, 'field': field, 'keyword': keyword},
      fromJson: (json) {
        if (isBox) {
          return PlanningBox.fromJson(json) as T;
        } else {
          return PlanningPaper.fromJson(json) as T;
        }
      },
    );
  }

  //confirm complete
  Future<bool> confirmCompletePlanning({
    required List<int> ids,
    String? machine,
    bool isBox = false,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final data = {
        if (isBox) "planningBoxIds": ids else "planningIds": ids,
        if (machine != null) "machine": machine,
      };
      final endpoint = isBox ? "confirmBox" : "confirmPaper";

      await dioService.put(
        "/api/planning/$endpoint",
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to confirm complete planning", error: e, stackTrace: s);
      throw Exception('Failed to confirm complete planning: $e');
    }
  }

  //pause or accept lack qty
  Future<bool> pauseOrAcceptLackQty({
    required List<int> ids,
    required String newStatus,
    String? machine,
    bool isBox = false,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final data = {
        if (isBox) "planningBoxIds": ids else "planningIds": ids,
        "newStatus": newStatus,
        if (machine != null) "machine": machine,
      };

      final endpoint = isBox ? "acceptLackQtyBox" : "pauseOrAcceptLackQtyPaper";

      await dioService.put(
        "/api/planning/$endpoint",
        data: data,
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

  //update index planning
  Future<bool> updateIndexWTimeRunning({
    required String machine,
    required DateTime dayStart,
    required TimeOfDay timeStart,
    required int totalTimeWorking,
    required List<Map<String, dynamic>> updateIndex,
    bool isBox = false,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final endpoint = isBox ? 'updateIndex_TimeRunningBox' : 'updateIndex_TimeRunningPaper';

      await dioService.post(
        "/api/planning/$endpoint",
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

  //change machine paper
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

  //update index planning
  Future<bool> cancelOrContinuePlannning({
    required List<int> planningId,
    required String action,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/planning/updateStopById",
        data: {'planningId': planningId, "action": action},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      if (action == "cancel") {
        AppLogger.e("Failed to cancel planning", error: e, stackTrace: s);
      } else {
        AppLogger.e("Failed to continue planning", error: e, stackTrace: s);
      }

      throw Exception('Failed to update planning: $e');
    }
  }
}
