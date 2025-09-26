import 'package:dio/dio.dart';
import 'package:dongtam/constant/app_info.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class ManufactureService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  //===============================MANUFACTURE PAPER====================================

  //get planning paper
  Future<List<PlanningPaper>> getPlanningPaper(
    String machine,
    bool refresh,
  ) async {
    return HelperService().fetchingData<PlanningPaper>(
      endpoint: "manufacture/planningPaper",
      queryParameters: {"machine": machine, 'refresh': refresh},
      fromJson: (json) => PlanningPaper.fromJson(json),
    );
  }

  //create report for planning
  Future<bool> createReportPaper(
    int planningId,
    int qtyProduced,
    double qtyWasteNorm,
    DateTime dayCompleted,
    Map<String, dynamic> reportData,
  ) async {
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
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
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
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<bool> confirmProducingPaper(int planningId) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/manufacture/producingPaper',
        queryParameters: {"planningId": planningId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return true;
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  //===============================MANUFACTURE BOX====================================
  //get planning paper
  Future<List<PlanningBox>> getPlanningBox(String machine, bool refresh) async {
    return HelperService().fetchingData<PlanningBox>(
      endpoint: "manufacture/planningBox",
      queryParameters: {"machine": machine, 'refresh': refresh},
      fromJson: (json) => PlanningBox.fromJson(json),
    );
  }

  //create report for planning
  Future<bool> createReportBox(
    int planningBoxId,
    String machine,
    DateTime dayCompleted,
    int qtyProduced,
    double rpWasteLoss,
    String shiftManagement,
  ) async {
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
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
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
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<bool> confirmProducingBox(int planningBoxId, String machine) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/manufacture/producingBox',
        queryParameters: {"planningBoxId": planningBoxId, "machine": machine},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return true;
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
