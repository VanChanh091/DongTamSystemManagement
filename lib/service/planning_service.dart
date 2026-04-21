import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/service/report_planning_service.dart';
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
  Future<List<T>> getPlanningByMachine<T>({
    required String machine,
    String? field,
    String? keyword,
    bool isBox = false,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final endpoint = isBox ? 'planning-boxes' : 'planning-papers';

      final response = await dioService.get(
        '/api/planning/$endpoint',
        queryParameters: {'machine': machine, 'field': field, 'keyword': keyword},
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

  //update index planning
  Future<bool> updateIndexWTimeRunning({
    required bool isNewDay,
    required String machine,
    required DateTime dayStart,
    required TimeOfDay timeStart,
    required int totalTimeWorking,
    required List<Map<String, dynamic>> updateIndex,
    bool isBox = false, //flag FE
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final endpoint = isBox ? 'planning-boxes' : 'planning-papers';

      await dioService.post(
        "/api/planning/$endpoint",
        data: {
          'machine': machine,
          "dayStart": DateFormat('yyyy-MM-dd').format(dayStart),
          "timeStart":
              "${timeStart.hour.toString().padLeft(2, '0')}:${timeStart.minute.toString().padLeft(2, '0')}",
          "totalTimeWorking": totalTimeWorking,
          "updateIndex": updateIndex,
          'isNewDay': isNewDay,
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

  //confirm complete
  Future<bool> confirmCompletePlanning({
    required List<int> ids,
    required String action,
    String? machine,
    bool isBox = false, //flag FE
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final data = {
        "action": action,
        if (isBox) "planningBoxIds": ids else "planningIds": ids,
        if (machine != null) "machine": machine,
      };

      final endpoint = isBox ? 'planning-boxes' : 'planning-papers';

      await dioService.put(
        "/api/planning/$endpoint",
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } on DioException catch (e) {
      HelperService().handleDioException(e, "Lỗi khi thêm dữ liệu");
      return false;
    } catch (e, s) {
      AppLogger.e("Failed to confirm complete planning", error: e, stackTrace: s);
      throw Exception('Failed to confirm complete planning: $e');
    }
  }

  //change machine paper
  Future<bool> changeMachinePlanning({
    required List<int> planningIds,
    required String newMachine,
    required String action,
  }) async {
    return HelperService().updateItem(
      endpoint: "planning/planning-papers",
      queryParameters: {},
      dataUpdated: {"planningIds": planningIds, "newMachine": newMachine, "action": action},
    );
  }

  //pause or accept lack qty
  Future<bool> pauseOrAcceptLackQty({
    required List<int> ids,
    required String newStatus,
    required String action,
    String? machine,
    bool isBox = false, //flag FE
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final data = {
        if (isBox) "planningBoxIds": ids else "planningIds": ids,
        if (machine != null) "machine": machine,
        "newStatus": newStatus,
        "action": action,
      };

      final endpoint = isBox ? 'planning-boxes' : 'planning-papers';

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

  //notify planning
  Future<bool> notifyUpdatePlanning({
    required String machine,
    required bool isPaper,
    bool isPlan = true,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final keyName = isPaper ? "planningPaperUpdated" : "planningBoxUpdated";

      await dioService.post(
        "/api/planning/notify-planning",
        data: {'machine': machine, "keyName": keyName, "isPlan": isPlan},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to notify planning", error: e, stackTrace: s);
      throw Exception('Failed to notify planning: $e');
    }
  }

  // Export Paper
  Future<File?> exportPlanningExcel(String machine) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.post(
        "/api/planning/export",
        queryParameters: {"machine": machine},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        final safeMachine = ReportPlanningService.makeSafeFileName(input: machine);

        return await HelperService().saveExcelFile(
          bytes: response.data as List<int>,
          fileNamePrefix: "KHSX_${safeMachine.toLowerCase()}",
        );
      } else {
        AppLogger.w("Export failed with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("Failed to export Excel from $machine", error: e, stackTrace: s);
      return null;
    }
  }

  //===============================PLANNING ORDER====================================

  //get status order
  Future<List<Order>> getOrderAccept({required String type, String? field, String? keyword}) async {
    return HelperService().fetchingData<Order>(
      endpoint: "planning/planning-orders",
      queryParameters: {
        "type": type,
        if (field != null) "field": field,
        if (keyword != null) "keyword": keyword,
      },
      fromJson: (json) => Order.fromJson(json),
    );
  }

  //planning for order
  Future<bool> planningOrder({
    required String orderId,
    required Map<String, dynamic> orderPlanning,
  }) async {
    return HelperService().addItem(
      endpoint: "planning/planning-orders",
      queryParameters: {"orderId": orderId},
      itemData: orderPlanning,
    );
  }

  Future<bool> backOrderToReject({required String orderId}) async {
    return HelperService().updateItem(
      endpoint: "planning/planning-orders",
      queryParameters: {"orderId": orderId},
    );
  }

  //===============================PLANNING STOP====================================

  Future<Map<String, dynamic>> getPlanningStop({int? page, int? pageSize}) async {
    return HelperService().fetchPaginatedData<PlanningPaper>(
      endpoint: "planning/planning-stops",
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
        "/api/planning/planning-stops",
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
