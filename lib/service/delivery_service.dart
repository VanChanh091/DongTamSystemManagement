import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dongtam/data/models/delivery/delivery_plan_model.dart';
import 'package:dongtam/data/models/delivery/delivery_request_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:intl/intl.dart';

class DeliveryService {
  final Dio dioService = DioClient().dio;

  //===============================PLANNING ESTIMATE==============================

  // get all planning estimate time
  Future<Map<String, dynamic>> getPlanningEstimateTime({
    required int page,
    required int pageSize,
    required DateTime dayStart,
    required String estimateTime,
    required String all,
    String? field,
    String? keyword,
  }) async {
    return HelperService().fetchPaginatedData<PlanningPaper>(
      endpoint: "delivery/estimate",
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        "dayStart": DateFormat('yyyy-MM-dd').format(dayStart),
        'estimateTime': estimateTime,
        'all': all,
        if (field != null && keyword != null) 'field': field,
        if (field != null && keyword != null) 'keyword': keyword,
      },
      fromJson: (json) => PlanningPaper.fromJson(json),
      dataKey: 'plannings',
    );
  }

  // confirm ready delivery
  Future<bool> handlePutDelivery({
    required List<int> planningId,
    int? qtyRegistered,
    bool? isPaper,
  }) async {
    return HelperService().updateItem(
      endpoint: "delivery/estimate",
      queryParameters: const {},
      dataUpdated: {'planningId': planningId, 'qtyRegistered': qtyRegistered, 'isPaper': isPaper},
    );
  }

  //=========================PLANNING DELIVERY===========================

  //get all planning waiting delivery
  Future<List<DeliveryRequest>> getPlanningRequest() async {
    return HelperService().fetchingData<DeliveryRequest>(
      endpoint: "delivery/planning",
      queryParameters: const {},
      fromJson: (json) => DeliveryRequest.fromJson(json),
    );
  }

  //get delivery plan detail for edit
  Future<DeliveryPlanModel?> getDeliveryPlanDetail({required DateTime deliveryDate}) async {
    return HelperService().fetchingSingleListData<DeliveryPlanModel>(
      endpoint: "delivery/planning",
      queryParameters: {"deliveryDate": DateFormat('yyyy-MM-dd').format(deliveryDate)},
      fromJson: (json) => DeliveryPlanModel.fromJson(json),
    );
  }

  //create delivery schedule
  Future<bool> createDeliveryPlan({
    required DateTime deliveryDate,
    required List<Map<String, dynamic>> items,
  }) async {
    return HelperService().addItem(
      endpoint: "delivery/planning",
      itemData: {"deliveryDate": DateFormat('yyyy-MM-dd').format(deliveryDate), "items": items},
    );
  }

  //confirm for delivery
  Future<bool> confirmForDeliveryPlanning({required DateTime deliveryDate}) async {
    return HelperService().updateItem(
      endpoint: "delivery/planning",
      queryParameters: {"deliveryDate": DateFormat('yyyy-MM-dd').format(deliveryDate)},
    );
  }

  //=========================SCHEDULE DELIVERY===========================

  // get schedule delivery
  Future<List<DeliveryPlanModel>> getScheduleDelivery({required DateTime deliveryDate}) async {
    return HelperService().fetchingData<DeliveryPlanModel>(
      endpoint: "delivery/schedule",
      queryParameters: {"deliveryDate": DateFormat('yyyy-MM-dd').format(deliveryDate)},
      fromJson: (json) => DeliveryPlanModel.fromJson(json),
    );
  }

  // update Status Delivery
  // status complete or cancel
  Future<bool> updateStatusDelivery({
    required int deliveryId,
    required List<int> itemIds,
    required String action,
  }) async {
    return HelperService().updateItem(
      endpoint: "delivery/schedule",
      queryParameters: {"deliveryId": deliveryId},
      dataUpdated: {"itemIds": itemIds, "action": action},
    );
  }

  //export delivery schedule
  Future<File?> exportDeliverySchedule({required DateTime deliveryDate}) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.post(
        "/api/delivery/schedule/export",
        queryParameters: {"deliveryDate": deliveryDate.toIso8601String().split('T')[0]},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return await HelperService().saveExcelFile(
          bytes: response.data as List<int>,
          fileNamePrefix: "delivery_schedule",
        );
      } else {
        AppLogger.w("Export failed with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("failed to export delivery schedule", error: e, stackTrace: s);
      return null;
    }
  }

  //=========================PREPARE GOODS===========================

  // get delivery request for prepare goods
  Future<List<DeliveryPlanModel>> getRequestPrepareGoods({required DateTime deliveryDate}) async {
    return HelperService().fetchingData<DeliveryPlanModel>(
      endpoint: "delivery/prepare",
      queryParameters: {"deliveryDate": DateFormat('yyyy-MM-dd').format(deliveryDate)},
      fromJson: (json) => DeliveryPlanModel.fromJson(json),
    );
  }

  Future<bool> requestOrPrepareGoods({required int deliveryItemId, required bool isRequest}) async {
    return HelperService().updateItem(
      endpoint: "delivery/prepare",
      queryParameters: {"deliveryItemId": deliveryItemId, "isRequest": isRequest},
    );
  }

  //notify planning
  Future<bool> notifyRequestPrepareGoods() async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        "/api/delivery/notify-delivery",
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to notify delivery", error: e, stackTrace: s);
      throw Exception('Failed to notify delivery: $e');
    }
  }
}
