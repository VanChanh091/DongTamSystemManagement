import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dongtam/data/models/delivery/delivery_item_model.dart';
import 'package:dongtam/data/models/delivery/delivery_schedule_model.dart';
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

  // register qty or close planning
  Future<bool> handlePutDelivery({
    required String action,
    required List<int> planningId,
    int? qtyRegistered,
    bool? isPaper,
    String? note,
  }) async {
    return HelperService().updateItem(
      endpoint: "delivery/estimate",
      queryParameters: const {},
      body: {
        'action': action,
        'planningId': planningId,
        if (qtyRegistered != null) 'qtyRegistered': qtyRegistered,
        if (note != null) 'note': note,
        'isPaper': isPaper,
      },
    );
  }

  //=========================PLANNING DELIVERY===========================

  //get all planning waiting delivery
  Future<List<DeliveryRequest>> getPlanningRequest({String? field, String? keyword}) async {
    return HelperService().fetchingData<DeliveryRequest>(
      endpoint: "delivery/planning",
      queryParameters: {
        if (field != null && keyword != null) 'field': field,
        if (field != null && keyword != null) 'keyword': keyword,
      },
      fromJson: (json) => DeliveryRequest.fromJson(json),
    );
  }

  //get delivery plan detail for edit
  Future<DeliveryScheduleModel?> getDeliveryPlanDetail({required DateTime deliveryDate}) async {
    return HelperService().fetchingSingleListData<DeliveryScheduleModel>(
      endpoint: "delivery/planning",
      queryParameters: {"deliveryDate": DateFormat('yyyy-MM-dd').format(deliveryDate)},
      fromJson: (json) => DeliveryScheduleModel.fromJson(json),
    );
  }

  //create delivery schedule
  Future<bool> createDeliveryPlan({
    required DateTime deliveryDate,
    required List<Map<String, dynamic>> items,
  }) async {
    return HelperService().addItem(
      endpoint: "delivery/planning",
      body: {"deliveryDate": DateFormat('yyyy-MM-dd').format(deliveryDate), "items": items},
    );
  }

  //back delivery request
  Future<bool> backDeliveryRequest({required List<int> requestIds}) async {
    return HelperService().addItem(endpoint: "delivery/planning", body: {"requestIds": requestIds});
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
  Future<List<DeliveryScheduleModel>> getScheduleDelivery({required DateTime deliveryDate}) async {
    return HelperService().fetchingData<DeliveryScheduleModel>(
      endpoint: "delivery/schedule",
      queryParameters: {"deliveryDate": DateFormat('yyyy-MM-dd').format(deliveryDate)},
      fromJson: (json) => DeliveryScheduleModel.fromJson(json),
    );
  }

  Future<List<DeliveryItemModel>> searchOrderIdsByKey({required String orderId}) async {
    return HelperService().fetchingData<DeliveryItemModel>(
      endpoint: "delivery/schedule/get-search",
      queryParameters: {"orderId": orderId},
      fromJson: (json) => DeliveryItemModel.fromJson(json),
    );
  }

  Future<DeliveryItemModel?> getDeliveryItemsById({required int deliveryItemId}) async {
    return HelperService().fetchSingleData<DeliveryItemModel>(
      endpoint: "delivery/schedule/get-search",
      queryParameters: {"deliveryItemId": deliveryItemId},
      parser: (json) => DeliveryItemModel.fromJson(json),
    );
  }

  // update Status Delivery
  // status complete or cancel
  Future<bool> cancelOrCompleteDelivery({
    required int deliveryId,
    required List<int> itemIds,
    required String action,
  }) async {
    return HelperService().updateItem(
      endpoint: "delivery/schedule",
      queryParameters: {"deliveryId": deliveryId},
      body: {"itemIds": itemIds, "action": action},
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
          dateTime: deliveryDate,
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
  Future<List<DeliveryScheduleModel>> getRequestPrepareGoods({
    required DateTime deliveryDate,
  }) async {
    return HelperService().fetchingData<DeliveryScheduleModel>(
      endpoint: "delivery/prepare",
      queryParameters: {"deliveryDate": DateFormat('yyyy-MM-dd').format(deliveryDate)},
      fromJson: (json) => DeliveryScheduleModel.fromJson(json),
    );
  }

  Future<bool> requestOrPrepareGoods({
    required int deliveryItemId,
    required bool isRequest,
    String? empCode,
  }) async {
    return HelperService().updateItem(
      endpoint: "delivery/prepare",
      queryParameters: {
        "deliveryItemId": deliveryItemId,
        "isRequest": isRequest,
        if (empCode != null) "empCode": empCode,
      },
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
