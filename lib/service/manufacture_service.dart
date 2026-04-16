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
  Future<List<PlanningPaper>> getPlanningPaper({
    required String machine,
    required String filterType,
  }) async {
    return HelperService().fetchingData<PlanningPaper>(
      endpoint: "manufacture/paper",
      queryParameters: {"machine": machine, "filterType": filterType},
      fromJson: (json) => PlanningPaper.fromJson(json),
    );
  }

  //create report for planning
  Future<bool> createOrUpdateReportPaper({
    required int planningId,
    required int qtyProduced,
    required double qtyWasteNorm,
    required DateTime dayCompleted,
    required String reportedBy,
    required Map<String, dynamic> reportData,
    bool isUpdate = false,
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

    final method = isUpdate ? dioService.put : dioService.post;

    try {
      await method(
        '/api/manufacture/paper',
        queryParameters: {"planningId": planningId},
        data: {
          "qtyProduced": qtyProduced,
          "qtyWasteNorm": qtyWasteNorm,
          "dayCompleted": fullDateTime.toIso8601String(),
          "reportedBy": reportedBy,
          ...reportData,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } on DioException catch (e) {
      HelperService().handleDioException(e, "Lỗi khi thêm dữ liệu");
      return false;
    } catch (e, s) {
      AppLogger.e(
        "Failed to ${isUpdate ? 'update' : 'create'} report paper",
        error: e,
        stackTrace: s,
      );
      throw Exception('Failed to ${isUpdate ? 'update' : 'create'} report paper: $e');
    }
  }

  Future<bool> confirmProducingPaper({required int planningId}) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/manufacture/paper/confirm',
        queryParameters: {"planningId": planningId},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } on DioException catch (e) {
      HelperService().handleDioException(e, "Lỗi khi thêm dữ liệu");
      return false;
    } catch (e, s) {
      AppLogger.e("Failed to confirm producing paper", error: e, stackTrace: s);
      throw Exception('Failed to confirm producing paper: $e');
    }
  }

  //===============================MANUFACTURE BOX====================================
  //get planning paper
  Future<List<PlanningBox>> getPlanningBox({required String machine}) async {
    return HelperService().fetchingData<PlanningBox>(
      endpoint: "manufacture/box",
      queryParameters: {"machine": machine},
      fromJson: (json) => PlanningBox.fromJson(json),
    );
  }

  //create report for planning
  Future<bool> createOrUpdateReportBox({
    required int planningBoxId,
    required String machine,
    required DateTime dayCompleted,
    required int qtyProduced,
    required double rpWasteLoss,
    required String shiftManagement,
    required String reportedBy,
    bool isUpdate = false,
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

    final method = isUpdate ? dioService.put : dioService.post;

    try {
      await method(
        '/api/manufacture/box',
        queryParameters: {"planningBoxId": planningBoxId, "machine": machine},
        data: {
          "dayCompleted": fullDateTime.toIso8601String(),
          "qtyProduced": qtyProduced,
          "rpWasteLoss": rpWasteLoss,
          "shiftManagement": shiftManagement,
          "reportedBy": reportedBy,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } on DioException catch (e) {
      HelperService().handleDioException(e, "Lỗi khi thêm dữ liệu");
      return false;
    } catch (e, s) {
      AppLogger.e(
        "Failed to ${isUpdate ? 'update' : 'create'} report box",
        error: e,
        stackTrace: s,
      );
      throw Exception('Failed to ${isUpdate ? 'update' : 'create'} report box: $e');
    }
  }

  Future<bool> confirmProducingBox({required int planningBoxId, required String machine}) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/manufacture/box/confirm',
        queryParameters: {"planningBoxId": planningBoxId, "machine": machine},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } on DioException catch (e) {
      HelperService().handleDioException(e, "Lỗi khi thêm dữ liệu");
      return false;
    } catch (e, s) {
      AppLogger.e("Failed to confirm producing box", error: e, stackTrace: s);
      throw Exception('Failed to confirm producing box: $e');
    }
  }

  Future<bool> updateRequestStockCheck({
    required int planningBoxId,
    required String machine,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        '/api/manufacture/box/request',
        queryParameters: {"planningBoxId": planningBoxId, 'machine': machine},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } on DioException catch (e) {
      HelperService().handleDioException(e, "Lỗi khi thêm dữ liệu");
      return false;
    } catch (e, s) {
      AppLogger.e("Failed to update request check", error: e, stackTrace: s);
      throw Exception('Failed to update request check: $e');
    }
  }
}
