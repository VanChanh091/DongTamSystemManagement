import 'package:dio/dio.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class ManufactureService {
  final Dio dioService = DioClient().dio;

  //===============================MANUFACTURE PAPER====================================

  //get planning paper
  Future<List<PlanningPaper>> getPlanningPaper({required String machine}) async {
    return HelperService().fetchingData<PlanningPaper>(
      endpoint: "manufacture/planningPaper",
      queryParameters: {"machine": machine},
      fromJson: (json) => PlanningPaper.fromJson(json),
    );
  }

  //create report for planning
  Future<bool> createReportPaper({
    required int planningId,
    required int qtyProduced,
    required double qtyWasteNorm,
    required DateTime dayCompleted,
    required Map<String, dynamic> reportData,
  }) async {
    final token = await SecureStorageService().getToken();

    final now = DateTime.now();
    final fullDateTime = DateTime(
      dayCompleted.year,
      dayCompleted.month,
      dayCompleted.day,
      now.hour,
      now.minute,
      now.second,
    );

    try {
      await dioService.post(
        '/api/manufacture/reportPaper',
        queryParameters: {"planningId": planningId},
        data: {
          "qtyProduced": qtyProduced,
          "qtyWasteNorm": qtyWasteNorm,
          "dayCompleted": fullDateTime.toIso8601String(),
          ...reportData,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final errorMsg = e.response?.data?['message'] ?? 'Unknown error';

        // Chuyển lỗi lên submit() để xử lý theo mã lỗi
        throw Exception("HTTP $statusCode: $errorMsg");
      } else {
        throw Exception("Network Error: ${e.message}");
      }
    } catch (e, s) {
      AppLogger.e("Failed to create report paper", error: e, stackTrace: s);
      throw Exception('Failed to create report paper: $e');
    }
  }

  Future<bool> confirmProducingPaper({required int planningId}) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/manufacture/producingPaper',
        queryParameters: {"planningId": planningId},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to confirm producing paper", error: e, stackTrace: s);
      throw Exception('Failed to confirm producing paper: $e');
    }
  }

  //===============================MANUFACTURE BOX====================================
  //get planning paper
  Future<List<PlanningBox>> getPlanningBox({required String machine}) async {
    return HelperService().fetchingData<PlanningBox>(
      endpoint: "manufacture/planningBox",
      queryParameters: {"machine": machine},
      fromJson: (json) => PlanningBox.fromJson(json),
    );
  }

  //create report for planning
  Future<bool> createReportBox({
    required int planningBoxId,
    required String machine,
    required DateTime dayCompleted,
    required int qtyProduced,
    required double rpWasteLoss,
    required String shiftManagement,
  }) async {
    final token = await SecureStorageService().getToken();

    final now = DateTime.now();
    final fullDateTime = DateTime(
      dayCompleted.year,
      dayCompleted.month,
      dayCompleted.day,
      now.hour,
      now.minute,
      now.second,
    );

    try {
      await dioService.post(
        '/api/manufacture/reportBox',
        queryParameters: {"planningBoxId": planningBoxId, "machine": machine},
        data: {
          "dayCompleted": fullDateTime.toIso8601String(),
          "qtyProduced": qtyProduced,
          "rpWasteLoss": rpWasteLoss,
          "shiftManagement": shiftManagement,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final errorMsg = e.response?.data?['message'] ?? 'Unknown error';

        // Chuyển lỗi lên submit() để xử lý theo mã lỗi
        throw Exception("HTTP $statusCode: $errorMsg");
      } else {
        throw Exception("Network Error: ${e.message}");
      }
    } catch (e, s) {
      AppLogger.e("Failed to create report box", error: e, stackTrace: s);
      throw Exception('Failed to create report box: $e');
    }
  }

  Future<bool> confirmProducingBox({required int planningBoxId, required String machine}) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/manufacture/producingBox',
        queryParameters: {"planningBoxId": planningBoxId, "machine": machine},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to confirm producing box", error: e, stackTrace: s);
      throw Exception('Failed to confirm producing box: $e');
    }
  }
}
