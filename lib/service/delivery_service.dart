import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dongtam/data/models/delivery/delivery_plan_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:file_picker/file_picker.dart';
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
  }) async {
    return HelperService().fetchPaginatedData<PlanningPaper>(
      endpoint: "delivery/getPlanningEstimate",
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        "dayStart": DateFormat('yyyy-MM-dd').format(dayStart),
        'estimateTime': estimateTime,
      },
      fromJson: (json) => PlanningPaper.fromJson(json),
      dataKey: 'plannings',
    );
  }

  // confirm ready delivery
  Future<bool> confirmReadyDelivery({required List<int> planningIds}) async {
    return HelperService().updateItem(
      endpoint: "delivery/confirmReadyDelivery",
      queryParameters: {'planningIds': planningIds},
    );
  }

  //=========================PLANNING DELIVERY===========================

  //get all planning waiting delivery
  Future<List<PlanningPaper>> getPlanningPending() async {
    return HelperService().fetchingData<PlanningPaper>(
      endpoint: "delivery/getPlanningPending",
      queryParameters: const {},
      fromJson: (json) => PlanningPaper.fromJson(json),
    );
  }

  //get delivery plan detail for edit
  Future<List<DeliveryPlanModel>> getDeliveryPlanDetail({required DateTime deliveryDate}) async {
    return HelperService().fetchingData<DeliveryPlanModel>(
      endpoint: "delivery/getDeliveryPlanDetail",
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
      endpoint: "delivery/createDeliveryPlan",
      itemData: {"deliveryDate": DateFormat('yyyy-MM-dd').format(deliveryDate), "items": items},
    );
  }

  //confirm for delivery
  Future<bool> confirmForDeliveryPlanning({required DateTime deliveryDate}) async {
    return HelperService().updateItem(
      endpoint: "delivery/confirmDelivery",
      queryParameters: {"deliveryDate": DateFormat('yyyy-MM-dd').format(deliveryDate)},
    );
  }

  //=========================SCHEDULE DELIVERY===========================

  // get schedule delivery
  Future<List<DeliveryPlanModel>> getScheduleDelivery({required DateTime deliveryDate}) async {
    return HelperService().fetchingData<DeliveryPlanModel>(
      endpoint: "delivery/getScheduleDelivery",
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
      endpoint: "delivery/updateStatusDelivery",
      queryParameters: {"deliveryId": deliveryId},
      dataUpdated: {"itemIds": itemIds, "action": action},
    );
  }

  //export delivery schedule
  Future<File?> exportExcelCustomer({required DateTime deliveryDate}) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.post(
        "/api/delivery/exportExcel",
        queryParameters: {"deliveryDate": deliveryDate.toIso8601String().split('T')[0]},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        final bytes = response.data as List<int>;
        AppLogger.d("Received ${bytes.length} bytes from API");

        // Cho người dùng chọn thư mục lưu
        final dirPath = await FilePicker.platform.getDirectoryPath();
        if (dirPath == null) {
          return null;
        }

        final now = DateTime.now();
        final fileName = "delivery_schedule_${now.toIso8601String().split('T')[0]}.xlsx";
        final file = File("$dirPath/$fileName");

        await file.writeAsBytes(bytes, flush: true);
        AppLogger.i("Exported Excel delivery to: ${file.path}");

        return file;
      } else {
        AppLogger.w("Export failed with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("failed to export delivery schedule", error: e, stackTrace: s);
      return null;
    }
  }
}
