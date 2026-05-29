import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class SyntheticService {
  final Dio dioService = DioClient().dio;

  //==========================ORDERS==========================
  Future<Map<String, dynamic>> getAllSyntheticOrders({
    required int page,
    required int pageSize,
    required String status,
    required String allOrders,
    String? field,
    String? keyword,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return HelperService().fetchPaginatedData<Order>(
      endpoint: "synthetic/orders",
      queryParameters: {
        'status': status,
        'page': page,
        'pageSize': pageSize,
        'allOrders': allOrders,
        if (field != null && keyword != null) 'field': field,
        if (field != null && keyword != null) 'keyword': keyword,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      },
      fromJson: (json) => Order.fromJson(json),
      dataKey: 'orders',
    );
  }

  Future<PlanningBox?> getSyntheticBoxDetail({required String orderId}) async {
    return HelperService().fetchingSingleListData(
      endpoint: "synthetic/orders",
      queryParameters: {'orderId': orderId},
      fromJson: (json) => PlanningBox.fromJson(json),
    );
  }

  Future<bool> completeOrders({required List<String> orderIds}) async {
    return HelperService().updateItem(endpoint: "synthetic/orders", body: {"orderIds": orderIds});
  }

  Future<File?> exportExcelOrders({DateTime? fromDate, DateTime? toDate}) async {
    try {
      final token = await SecureStorageService().getToken();

      final Map<String, dynamic> body = {};

      if (fromDate != null && toDate != null) {
        body["fromDate"] = fromDate.toIso8601String();
        body["toDate"] = toDate.toIso8601String();
      }

      final response = await dioService.post(
        "/api/synthetic/orders/export",
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return await HelperService().saveExcelFile(
          bytes: response.data as List<int>,
          fileNamePrefix: "orders",
        );
      } else {
        AppLogger.w("Export failed with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("failed to export orders", error: e, stackTrace: s);
      return null;
    }
  }

  //=========================PLANNING=========================
  //get data planning paper
  Future<Map<String, dynamic>> getAllSyntheticPlanning({
    required int page,
    required int pageSize,
    required String status,
  }) async {
    return HelperService().fetchPaginatedData<PlanningPaper>(
      endpoint: "synthetic/planning",
      queryParameters: {'page': page, 'pageSize': pageSize, 'status': status},
      fromJson: (json) => PlanningPaper.fromJson(json),
      dataKey: 'dashboard',
    );
  }

  //get data details
  Future<List<PlanningStage>> getSyntheticPlanningDetail({required int planningId}) async {
    return HelperService().fetchingData(
      endpoint: "synthetic/planning",
      queryParameters: {'planningId': planningId},
      fromJson: (json) => PlanningStage.fromJson(json),
    );
  }

  //get synthetic planning by field
  Future<Map<String, dynamic>> getSyntheticPlanningByFields({
    required String field,
    required String keyword,
    int page = 1,
    int pageSize = 30,
  }) async {
    return HelperService().fetchPaginatedData<PlanningPaper>(
      endpoint: "synthetic/planning",
      queryParameters: {'field': field, 'keyword': keyword, 'page': page, 'pageSize': pageSize},
      fromJson: (json) => PlanningPaper.fromJson(json),
      dataKey: 'dashboard',
    );
  }

  //export db planning
  Future<File?> exportExcelSyntheticPlanning({
    String? username,
    String? machine,
    String? customerName,
    DateTime? dayStart,
    // bool all = false,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      // final Map<String, dynamic> body = {"all": all};
      final Map<String, dynamic> body = {};
      if (username != null) {
        body['username'] = username;
      } else if (machine != null) {
        body['machine'] = machine;
      } else if (customerName != null) {
        body['customerName'] = customerName;
      } else if (dayStart != null) {
        body["dayStart"] = dayStart.toIso8601String();
      }

      final response = await dioService.post(
        "/api/synthetic/planning/export",
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return await HelperService().saveExcelFile(
          bytes: response.data as List<int>,
          fileNamePrefix: "dbPlanning",
        );
      } else {
        AppLogger.w("Export failed with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("failed to export db planning", error: e, stackTrace: s);
      return null;
    }
  }
}
