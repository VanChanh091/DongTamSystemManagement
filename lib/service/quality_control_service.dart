import 'package:dio/dio.dart';
import 'package:dongtam/data/models/qualityControl/qcWaitingCheck/qc_sample_result_model.dart';
import 'package:dongtam/data/models/qualityControl/qcWaitingCheck/qc_sample_submit_model.dart';
import 'package:dongtam/data/models/qualityControl/qcWaitingCheck/qc_session_model.dart';
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

  //===========================ORCHESTRATOR================================
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
  Future<List<T>> getManufactureProducing<T>({
    required String machine,
    required String isPaper,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return HelperService().fetchingData<T>(
      endpoint: "qc/inspection/manufacture",
      queryParameters: {"machine": machine, "isPaper": isPaper},
      fromJson: (json) => fromJson(json),
    );
  }

  Future<Map<String, dynamic>> getQcInspection<T>({
    required String isPaper,
    required int page,
    required int pageSize,
    required String machine,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return HelperService().fetchPaginatedData<T>(
      endpoint: "qc/inspection",
      queryParameters: {"isPaper": isPaper, "page": page, "pageSize": pageSize, "machine": machine},
      fromJson: fromJson,
      dataKey: isPaper == 'paper' ? 'inspectionPapers' : 'inspectionBoxes',
    );
  }

  Future<bool> checkingInspection({
    int? planningId,
    int? planningBoxId,
    required String isPaper,
    required String machine,
    Map<String, num>? checking,
    required Map<String, bool> errProgress,
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
      },
    );
  }
}
