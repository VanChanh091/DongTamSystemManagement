import 'dart:io';

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
import 'package:file_picker/file_picker.dart';

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
      endpoint: 'warehouse/outbound/searchOrderIds',
      queryParameters: {'orderId': orderId},
      fromJson: (json) => Order.fromJson(json),
    );
  }

  //get get Order Inbound Qty
  Future<Order?> getOrderInboundQty({required String orderId}) async {
    return HelperService().fetchSingleData(
      endpoint: 'warehouse/outbound/getInboundQty',
      queryParameters: {'orderId': orderId},
      parser: (json) => Order.fromJson(json as Map<String, dynamic>),
    );
  }

  //create outbound
  Future<bool> createOutbound({required List<Map<String, dynamic>> list}) async {
    return await HelperService().addItem(
      endpoint: 'warehouse/outbound/createOutbound',
      itemData: {'outboundDetails': list},
    );
  }

  Future<bool> updateOutbound({
    required int outboundId,
    required List<Map<String, dynamic>> list,
  }) async {
    return HelperService().updateItem(
      endpoint: 'warehouse/outbound/updateOutbound',
      queryParameters: const {},
      dataUpdated: {"outboundId": outboundId, "outboundDetails": list},
    );
  }

  Future<bool> deleteOutbound({required int outboundId}) async {
    return HelperService().deleteItem(
      endpoint: 'warehouse/outbound/deleteOutbound',
      queryParameters: {'outboundId': outboundId},
    );
  }

  Future<File?> exportFilePDFOutbound({required int outboundId}) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.post(
        "/api/warehouse/outbound/exportFile",
        queryParameters: {'outboundId': outboundId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
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

        final contentDisposition = response.headers.value('content-disposition');

        String fileName = "phieu_xuat_kho.pdf";

        if (contentDisposition != null) {
          final match = RegExp(r'filename="?([^"]+)"?').firstMatch(contentDisposition);
          if (match != null) {
            fileName = match.group(1)!;
          }
        }

        final file = File("$dirPath/$fileName");
        await file.writeAsBytes(bytes, flush: true);

        await file.writeAsBytes(bytes, flush: true);
        AppLogger.i("Export pdf outbound to: ${file.path}");

        return file;
      } else {
        AppLogger.w("Export failed with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("failed to export pdf outbound", error: e, stackTrace: s);
      return null;
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
