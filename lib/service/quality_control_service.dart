import 'package:dio/dio.dart';
import 'package:dongtam/data/models/qualityControl/qcWaitingCheck/qc_sample_result_model.dart';
import 'package:dongtam/data/models/qualityControl/qcWaitingCheck/qc_sample_submit_model.dart';
import 'package:dongtam/data/models/qualityControl/qcWaitingCheck/qc_session_model.dart';
import 'package:dongtam/data/models/qualityControl/qc_shift.dart';
import 'package:dongtam/data/models/qualityControl/qcInspection/inspection_request_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';

class QualityControlService {
  final Dio dioService = DioClient().dio;

  //============================QC SESSION=================================
  Future<List<QcSessionModel>> getAllQcSession() async {
    return HelperService().fetchingData<QcSessionModel>(
      endpoint: "qc/session",
      queryParameters: const {},
      fromJson: (json) => QcSessionModel.fromJson(json),
    );
  }

  Future<bool> updateSession({
    required int qcSessionId,
    required int totalSample,
    required String status,
  }) async {
    return HelperService().updateItem(
      endpoint: "qc/session",
      queryParameters: const {},
      body: {"qcSessionId": qcSessionId, "status": status, "totalSample": totalSample},
    );
  }

  //============================QC SAMPLE==================================
  Future<List<QcSampleResultModel>> getAllQcResult({required int qcSessionId}) async {
    return HelperService().fetchingData<QcSampleResultModel>(
      endpoint: "qc/result",
      queryParameters: {"qcSessionId": qcSessionId},
      fromJson: (json) => QcSampleResultModel.fromJson(json),
    );
  }

  Future<bool> updateResult({
    required int qcSessionId,
    int? sampleIndex = 3,
    required List<QcSampleSubmitModel> samples,
  }) async {
    final data = {
      "qcSessionId": qcSessionId,
      "sampleIndex": sampleIndex,
      "samples": samples.map((sample) => sample.toJson()).toList(),
    };

    return HelperService().updateItem(endpoint: "qc/result", body: data);
  }

  Future<bool> confirmFinalizeSession({
    int? planningId,
    int? planningBoxId,
    required bool isPaper,
  }) async {
    return HelperService().updateItem(
      endpoint: "qc/result/confirm",
      queryParameters: {},
      body: {"planningId": planningId, 'planningBoxId': planningBoxId, "isPaper": isPaper},
    );
  }

  Future<bool> submitQC({
    required int inboundQty,
    required String processType,
    int? planningId,
    int? planningBoxId,
    int totalSample = 3,
    required List<QcSampleSubmitModel> samples,
  }) async {
    final data = {
      'inboundQty': inboundQty,
      "processType": processType,
      "planningId": planningId,
      "planningBoxId": planningBoxId,
      "totalSample": totalSample,
      "samples": samples.map((sample) => sample.toJson()).toList(),
    };

    return HelperService().addItem(endpoint: "qc/submit", body: data);
  }

  //============================QC SHIFT=================================
  Future<QcShiftModel?> getCurrentShiftActive() async {
    return HelperService().fetchSingleData<QcShiftModel>(
      endpoint: "qc/shift",
      queryParameters: {},
      parser: (json) => QcShiftModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<bool> startShift() async {
    return HelperService().addItem(endpoint: "qc/shift/start");
  }

  Future<bool> endShift() async {
    return HelperService().updateItem(endpoint: "qc/shift/end");
  }

  //========================INSPECTION REQUEST=============================

  // Lấy danh sách yêu cầu kiểm tra theo planningId
  Future<List<InspectionRequestModel>> getInspectionRequest({required int planningId}) async {
    return HelperService().fetchingData<InspectionRequestModel>(
      endpoint: "qc/inspection-request/planning",
      queryParameters: {"planningId": planningId},
      fromJson: (json) => InspectionRequestModel.fromJson(json),
    );
  }

  // Tạo yêu cầu kiểm tra mới từ sản xuất
  Future<bool> createInspectionRequest({required int planningId}) async {
    return HelperService().addItem(
      endpoint: "qc/inspection-request",
      queryParameters: {"planningId": planningId},
    );
  }

  // QC đã tiếp nhận yêu cầu
  Future<bool> qcReceivedRequest({required int inspectionId}) async {
    return HelperService().updateItem(
      endpoint: "qc/inspection-request/receive",
      queryParameters: {"inspectionId": inspectionId},
    );
  }

  // QC cập nhật kết quả kiểm tra
  Future<bool> updateInspectionRequest({required int inspectionId, required String status}) async {
    return HelperService().updateItem(
      endpoint: "qc/inspection-request",
      queryParameters: {"inspectionId": inspectionId, "status": status},
    );
  }

  //==========================SCRAP REPORT=================================
  Future<bool> handleUpdateScrapReport({
    required List<int> scrapIds,
    required String action,
    String? status,
    String? machine,
    String? rejectReason,
    DateTime? dayCompleted,
    String? shiftProduction,
  }) async {
    final data = {
      "scrapId": scrapIds,
      "action": action,
      if (status != null) "status": status,
      if (machine != null) "machine": machine,
      if (rejectReason != null) "rejectReason": rejectReason,
      if (dayCompleted != null) "dayCompleted": dayCompleted.toIso8601String(),
      if (shiftProduction != null) "shiftProduction": shiftProduction,
    };

    return HelperService().updateItem(endpoint: "qc/scrap-report", body: data);
  }

  //==========================INSPECTION=================================
  Future<T?> getQcInspectionErr<T>({
    required String isPaper,
    required int planningId,
    required int planningBoxId,
    required String machine,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return HelperService().fetchSingleData<T>(
      endpoint: "qc/inspection/check",
      queryParameters: {
        'isPaper': isPaper,
        "planningId": planningId,
        "planningBoxId": planningBoxId,
        "machine": machine,
      },
      parser: (json) => fromJson(json as Map<String, dynamic>),
    );
  }

  Future<bool> checkingInspection({
    required String isPaper,
    required String machine,
    required Map<String, bool?> errProgress,
    Map<String, num>? checking,
    int? planningId,
    int? planningBoxId,
    String? note,
    String? imgErr,
  }) async {
    return HelperService().addItem(
      endpoint: "qc/inspection",
      queryParameters: {"isPaper": isPaper},
      body: {
        "machine": machine,
        "errProgress": errProgress,
        if (checking != null) "checking": checking,
        if (planningBoxId != null) "planningBoxId": planningBoxId,
        if (planningId != null) "planningId": planningId,
        if (note != null) "note": note,
        if (imgErr != null) "imgErr": imgErr,
      },
    );
  }
}
