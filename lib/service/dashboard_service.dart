import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:file_picker/file_picker.dart';

class DashboardService {
  final Dio dioService = DioClient().dio;

  //get data planning paper
  Future<Map<String, dynamic>> getAllDataDashboard({
    required int page,
    required int pageSize,
  }) async {
    return HelperService().fetchPaginatedData<PlanningPaper>(
      endpoint: "dashboard/paper",
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (json) => PlanningPaper.fromJson(json),
      dataKey: 'dashboard',
    );
  }

  //get data details
  Future<List<PlanningStage>> getDbPlanningDetail({required int planningId}) async {
    return HelperService().fetchingData(
      endpoint: 'dashboard/getDetail',
      queryParameters: {'planningId': planningId},
      fromJson: (json) => PlanningStage.fromJson(json),
    );
  }

  //get db planning by field
  Future<Map<String, dynamic>> getDbPlanningByFields({
    required String field,
    required String keyword,
    int page = 1,
    int pageSize = 30,
  }) async {
    return HelperService().fetchPaginatedData<PlanningPaper>(
      endpoint: "dashboard/getDbByField",
      queryParameters: {'field': field, 'keyword': keyword, 'page': page, 'pageSize': pageSize},
      fromJson: (json) => PlanningPaper.fromJson(json),
      dataKey: 'dashboard',
    );
  }

  //export db planning
  Future<File?> exportExcelDbPlanning({
    String? username,
    String? machine,
    String? customerName,
    DateTime? dayStart,
    bool all = false,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final Map<String, dynamic> body = {"all": all};
      if (username != null) {
        body['username'] = username;
      } else if (machine != null) {
        body['machine'] = machine;
      } else if (customerName != null) {
        body['customerName'] = customerName;
      } else if (dayStart != null) {
        body["dayStart"] = dayStart.toIso8601String();
      }

      final response = await dioService.post(
        "/api/dashboard/exportExcel",
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
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

        final now = DateTime.now();
        final fileName = "dbPlanning_${now.toIso8601String().split('T')[0]}.xlsx";
        final file = File("$dirPath/$fileName");

        await file.writeAsBytes(bytes, flush: true);
        AppLogger.i("Exported Excel db planning to: ${file.path}");

        return file;
      } else {
        AppLogger.w("Export failed with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("failed to export db planning", error: e, stackTrace: s);
      return null;
    }
  }
}
