import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
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
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/manufacture/planningPaper',
        queryParameters: {"machine": machine, 'refresh': refresh},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((e) => PlanningPaper.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load planning papers: $e');
    }
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

    print('dateTime: ${fullDateTime.toIso8601String()}');

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

  //===============================MANUFACTURE BOX====================================
  //get planning paper
  Future<List<PlanningBox>> getPlanningBox(String machine, bool refresh) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/manufacture/planningBox',
        queryParameters: {"machine": machine, 'refresh': refresh},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((e) => PlanningBox.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load planning box: $e');
    }
  }

  //create report for planning
  Future<bool> createReportBox(
    int planningBoxId,
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
        queryParameters: {"planningBoxId": planningBoxId},
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
}
