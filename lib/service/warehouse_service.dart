import 'package:dio/dio.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/data/models/warehouse/inbound_history_model.dart';
import 'package:dongtam/data/models/warehouse/inventory_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_detail_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_history_model.dart';
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

  //============================INBOUND HISTORY================================

  Future<Map<String, dynamic>> getAllInboundHistory({
    required int page,
    required int pageSize,
  }) async {
    return HelperService().fetchPaginatedData<InboundHistoryModel>(
      endpoint: "warehouse/inbound",
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (json) => InboundHistoryModel.fromJson(json),
      dataKey: 'inbounds',
    );
  }

  Future<Map<String, dynamic>> getInboundByField({
    required String field,
    required String keyword,
    required int page,
    required int pageSize,
  }) async {
    return HelperService().fetchPaginatedData<InboundHistoryModel>(
      endpoint: 'warehouse/inbound/filter',
      queryParameters: {'field': field, 'keyword': keyword, 'page': page, 'pageSize': pageSize},
      fromJson: (json) => InboundHistoryModel.fromJson(json),
      dataKey: 'inbounds',
    );
  }

  //============================OUTBOUND HISTORY===============================

  //get outbound
  Future<Map<String, dynamic>> getOutboundHistory({
    required int page,
    required int pageSize,
  }) async {
    return HelperService().fetchPaginatedData<OutboundHistoryModel>(
      endpoint: "warehouse/outbound",
      queryParameters: {"page": page, "pageSize": pageSize},
      fromJson: (json) => OutboundHistoryModel.fromJson(json),
      dataKey: 'outbounds',
    );
  }

  //get outbound detail
  Future<List<OutboundDetailModel>> getOutboundDetail({required int outboundId}) async {
    return HelperService().fetchingData(
      endpoint: 'warehouse/outbound/detail',
      queryParameters: {'outboundId': outboundId},
      fromJson: (json) => OutboundDetailModel.fromJson(json),
    );
  }

  Future<List<Order>> searchOrderIds({required String orderId}) async {
    return HelperService().fetchingData(
      endpoint: 'warehouse/searchOrderIds',
      queryParameters: {'orderId': orderId},
      fromJson: (json) => Order.fromJson(json),
    );
  }

  //get get Order Inbound Qty
  Future<Order?> getOrderInboundQty({required String orderId}) async {
    return HelperService().fetchSingleData(
      endpoint: 'warehouse/getOrderInboundQty',
      queryParameters: {'orderId': orderId},
      fromJson: (json) => Order.fromJson(json),
    );
  }

  //create outbound
  Future<bool> createOutbound({required List<Map<String, dynamic>> list}) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/warehouse/createOutbound',
        data: {"outboundDetails": list},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to create outbound", error: e, stackTrace: s);
      throw Exception('Failed to create outbound: $e');
    }
  }

  //============================INVENTORY===============================
  Future<Map<String, dynamic>> getAllInventory({required int page, required int pageSize}) async {
    return HelperService().fetchPaginatedData<InventoryModel>(
      endpoint: "warehouse/getAllInventory",
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (json) => InventoryModel.fromJson(json),
      dataKey: 'inventories',
    );
  }
}
