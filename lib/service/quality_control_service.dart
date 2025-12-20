import 'package:dio/dio.dart';
import 'package:dongtam/data/models/qualityControl/qc_sample_result_model.dart';
import 'package:dongtam/data/models/qualityControl/qc_sample_submit_model.dart';
import 'package:dongtam/data/models/qualityControl/qc_session_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class QualityControlService {
  final Dio dioService = DioClient().dio;

  //============================QC SESSION=================================

  Future<List<QcSessionModel>> getAllQcSession() async {
    return HelperService().fetchingData<QcSessionModel>(
      endpoint: "qc/getSession",
      queryParameters: const {},
      fromJson: (json) => QcSessionModel.fromJson(json),
    );
  }

  Future<bool> updateSession({
    required int qcSessionId,
    required int totalSample,
    required String status,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/qc/updateSession',
        data: {"qcSessionId": qcSessionId, "status": status, "totalSample": totalSample},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update session", error: e, stackTrace: s);
      throw Exception('Failed to update session: $e');
    }
  }

  //============================QC SAMPLE==================================

  Future<List<QcSampleResultModel>> getAllQcResult({required int qcSessionId}) async {
    return HelperService().fetchingData<QcSampleResultModel>(
      endpoint: "qc/getResult",
      queryParameters: {"qcSessionId": qcSessionId},
      fromJson: (json) => QcSampleResultModel.fromJson(json),
    );
  }

  Future<bool> updateResult({
    required int qcSessionId,
    required List<QcSampleSubmitModel> samples,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/qc/updateResult',
        data: {
          "qcSessionId": qcSessionId,
          "samples": samples.map((sample) => sample.toJson()).toList(),
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update QC sample result", error: e, stackTrace: s);
      throw Exception('Failed to update QC sample result: $e');
    }
  }

  Future<bool> confirmFinalizeSession({
    int? planningId,
    int? planningBoxId,
    required bool isPaper,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        '/api/qc/confirmFinalize',
        data: {"planningId": planningId, 'planningBoxId': planningBoxId, "isPaper": isPaper},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to confirm finalize session", error: e, stackTrace: s);
      throw Exception('Failed to confirm finalize session: $e');
    }
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
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/qc/submitQC',
        data: {
          'inboundQty': inboundQty,
          "processType": processType,
          "planningId": planningId,
          "planningBoxId": planningBoxId,
          "totalSample": totalSample,
          "samples": samples.map((sample) => sample.toJson()).toList(),
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to submit QC", error: e, stackTrace: s);
      throw Exception('Failed to submit QC: $e');
    }
  }
}
