import 'package:dio/dio.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/data/models/warehouse/inbound_history.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class WarehouseService {
  final Dio dioService = DioClient().dio;

  //============================WAITTING CHECK QUANTITY================================
  Future<List<PlanningPaper>> getPaperWaitingChecked() async {
    return HelperService().fetchingData<PlanningPaper>(
      endpoint: "warehouse/getPaperWaiting",
      queryParameters: const {},
      fromJson: (json) => PlanningPaper.fromJson(json),
    );
  }

  Future<List<PlanningBox>> getBoxWaitingChecked() async {
    return HelperService().fetchingData<PlanningBox>(
      endpoint: "warehouse/getBoxWaiting",
      queryParameters: const {},
      fromJson: (json) => PlanningBox.fromJson(json),
    );
  }

  Future<List<PlanningStage>> getDbPlanningDetail({required int planningBoxId}) async {
    return HelperService().fetchingData(
      endpoint: 'warehouse/getBoxDetail',
      queryParameters: {'planningBoxId': planningBoxId},
      fromJson: (json) => PlanningStage.fromJson(json),
    );
  }

  Future<bool> inboundQtyWarehouse({
    required int inboundQty,
    int? planningId,
    int? planningBoxId,
    bool isBox = false,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final endpoint = isBox ? "inboundBox" : "inboundPaper";
      final params = {
        if (isBox) "planningBoxId": planningBoxId else "planningId": planningId,
        "inboundQty": inboundQty,
      };

      await dioService.post(
        '/api/warehouse/$endpoint',
        queryParameters: params,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to inbound paper", error: e, stackTrace: s);
      throw Exception('Failed to inbound paper: $e');
    }
  }

  Future<bool> inboundQtyPaper({required int planningId, required int inboundQty}) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/warehouse/inboundPaper',
        queryParameters: {"planningId": planningId, "inboundQty": inboundQty},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to inbound paper", error: e, stackTrace: s);
      throw Exception('Failed to inbound paper: $e');
    }
  }

  //============================INBOUND HISTORY================================

  Future<Map<String, dynamic>> getAllEmployees({required int page, required int pageSize}) async {
    return HelperService().fetchPaginatedData<InboundHistory>(
      endpoint: "warehouse/inbound",
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (json) => InboundHistory.fromJson(json),
      dataKey: 'inbounds',
    );
  }

  Future<Map<String, dynamic>> getEmployeeByField({
    required String field,
    required String keyword,
    required int page,
    required int pageSize,
  }) async {
    return HelperService().fetchPaginatedData<InboundHistory>(
      endpoint: 'warehouse/inbound/filter',
      queryParameters: {'field': field, 'keyword': keyword, 'page': page, 'pageSize': pageSize},
      fromJson: (json) => InboundHistory.fromJson(json),
      dataKey: 'inbounds',
    );
  }

  //============================OUTBOUND HISTORY===============================
}
