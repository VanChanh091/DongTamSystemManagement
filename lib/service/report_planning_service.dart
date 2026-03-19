import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dongtam/data/models/report/report_planning_box.dart';
import 'package:dongtam/data/models/report/report_planning_paper.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:diacritic/diacritic.dart';

class ReportPlanningService {
  final Dio dioService = DioClient().dio;

  //============================REPORT PAPER=================================
  // get all and search
  Future<Map<String, dynamic>> getReportPapers({
    String? field,
    String? keyword,
    String? machine,
    int? page,
    int? pageSize,
  }) async {
    return HelperService().fetchPaginatedData<ReportPaperModel>(
      endpoint: "report/paper",
      queryParameters: {
        'field': field,
        'keyword': keyword,
        'machine': machine,
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) => ReportPaperModel.fromJson(json),
      dataKey: 'reportPapers',
    );
  }

  //============================REPORT BOX=================================
  // get all and search
  Future<Map<String, dynamic>> getReportBoxes({
    String? field,
    String? keyword,
    String? machine,
    int? page,
    int? pageSize,
  }) async {
    return HelperService().fetchPaginatedData<ReportBoxModel>(
      endpoint: "report/box",
      queryParameters: {
        'field': field,
        'keyword': keyword,
        'machine': machine,
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) => ReportBoxModel.fromJson(json),
      dataKey: 'reportBoxes',
    );
  }

  //============================EXPORT EXCEL=================================

  // Export Paper
  Future<File?> exportExcelReportPaper({
    DateTime? fromDate,
    DateTime? toDate,
    List<int>? reportPaperId,
    required String machine,
  }) {
    return _exportExcelBase(
      endpoint: "/api/report/export-paper",
      idKey: "reportPaperId",
      filePrefix: "bao_cao",
      machine: machine,
      ids: reportPaperId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  // Export Box
  Future<File?> exportExcelReportBox({
    DateTime? fromDate,
    DateTime? toDate,
    List<int>? reportBoxId,
    required String machine,
  }) {
    return _exportExcelBase(
      endpoint: "/api/report/export-box",
      idKey: "reportBoxId",
      filePrefix: "bao_cao",
      machine: machine,
      ids: reportBoxId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  //helper func
  Future<File?> _exportExcelBase({
    required String endpoint,
    required String idKey,
    required String filePrefix,
    required String machine,
    List<int>? ids,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final token = await SecureStorageService().getToken();
      final Map<String, dynamic> body = {"machine": machine};

      // Xử lý điều kiện lọc
      if (ids != null && ids.isNotEmpty) {
        body[idKey] = ids;
      } else if (fromDate != null && toDate != null) {
        body["fromDate"] = fromDate.toIso8601String();
        body["toDate"] = toDate.toIso8601String();
      }

      final response = await dioService.post(
        endpoint,
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        final safeMachine = makeSafeFileName(input: machine);

        return await HelperService().saveExcelFile(
          bytes: response.data as List<int>,
          fileNamePrefix: "${filePrefix}_${safeMachine.toLowerCase()}",
        );
      } else {
        AppLogger.w("Export failed ($endpoint) with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("Failed to export Excel from $endpoint", error: e, stackTrace: s);
      return null;
    }
  }

  String makeSafeFileName({required String input}) {
    // bỏ dấu tiếng Việt
    var result = removeDiacritics(input);

    // thay khoảng trắng bằng "_"
    result = result.replaceAll(RegExp(r'\s+'), '_');

    // loại bỏ ký tự đặc biệt ngoài a-zA-Z0-9_
    result = result.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

    return result;
  }
}
