import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dongtam/constant/app_info.dart';
import 'package:dongtam/data/models/report/report_planning_box.dart';
import 'package:dongtam/data/models/report/report_planning_paper.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:diacritic/diacritic.dart';

class ReportPlanningService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  //============================REPORT PAPER=================================
  Future<Map<String, dynamic>> getReportPaper({
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportPaperModel>(
      endpoint: "report/reportPaper/",
      queryParameters: {
        "machine": machine,
        "page": page,
        "pageSize": pageSize,
        "refresh": refresh,
      },
      fromJson: (json) => ReportPaperModel.fromJson(json),
      dataKey: 'reportPapers',
    );
  }

  //get by customerName
  Future<Map<String, dynamic>> getRPByCustomerName({
    required String keyword,
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportPaperModel>(
      endpoint: "report/reportPaper/getCustomerName",
      queryParameters: {
        'customerName': keyword,
        'machine': machine,
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
      },
      fromJson: (json) => ReportPaperModel.fromJson(json),
      dataKey: 'reportPapers',
    );
  }

  //get by dayReported
  Future<Map<String, dynamic>> getRPByDayReported({
    required String keyword,
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportPaperModel>(
      endpoint: "report/reportPaper/getDayReported",
      queryParameters: {
        'dayReported': keyword,
        'machine': machine,
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
      },
      fromJson: (json) => ReportPaperModel.fromJson(json),
      dataKey: 'reportPapers',
    );
  }

  //get by qtyReported
  Future<Map<String, dynamic>> getRPByQtyReported({
    required String keyword,
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportPaperModel>(
      endpoint: "report/reportPaper/getQtyReported",
      queryParameters: {
        'qtyProduced': keyword,
        'machine': machine,
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
      },
      fromJson: (json) => ReportPaperModel.fromJson(json),
      dataKey: 'reportPapers',
    );
  }

  //get by ghepKho
  Future<Map<String, dynamic>> getRPByGhepKho({
    required String keyword,
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportPaperModel>(
      endpoint: "report/reportPaper/getGhepKho",
      queryParameters: {
        'ghepKho': keyword,
        'machine': machine,
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
      },
      fromJson: (json) => ReportPaperModel.fromJson(json),
      dataKey: 'reportPapers',
    );
  }

  //get by shiftManagement
  Future<Map<String, dynamic>> getRPByShiftManagement({
    required String keyword,
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportPaperModel>(
      endpoint: "report/reportPaper/getShiftManagement",
      queryParameters: {
        'shiftManagement': keyword,
        'machine': machine,
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
      },
      fromJson: (json) => ReportPaperModel.fromJson(json),
      dataKey: 'reportPapers',
    );
  }

  //get by orderId
  Future<Map<String, dynamic>> getRPByOrderId({
    required String keyword,
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportPaperModel>(
      endpoint: "report/reportPaper/getOrderId",
      queryParameters: {
        'orderId': keyword,
        'machine': machine,
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
      },
      fromJson: (json) => ReportPaperModel.fromJson(json),
      dataKey: 'reportPapers',
    );
  }

  //============================REPORT PAPER=================================
  Future<Map<String, dynamic>> getReportBox({
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportBoxModel>(
      endpoint: "report/reportBox/",
      queryParameters: {
        "machine": machine,
        "page": page,
        "pageSize": pageSize,
        "refresh": refresh,
      },
      fromJson: (json) => ReportBoxModel.fromJson(json),
      dataKey: 'reportBoxes',
    );
  }

  //get by customerName
  Future<Map<String, dynamic>> getRBByCustomerName({
    required String keyword,
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportBoxModel>(
      endpoint: "report/reportBox/getCustomerName",
      queryParameters: {
        'customerName': keyword,
        'machine': machine,
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
      },
      fromJson: (json) => ReportBoxModel.fromJson(json),
      dataKey: 'reportBoxes',
    );
  }

  //get by dayReported
  Future<Map<String, dynamic>> getRBByDayReported({
    required String keyword,
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportBoxModel>(
      endpoint: "report/reportBox/getDayReported",
      queryParameters: {
        'dayReported': keyword,
        'machine': machine,
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
      },
      fromJson: (json) => ReportBoxModel.fromJson(json),
      dataKey: 'reportBoxes',
    );
  }

  // get by qtyReported
  Future<Map<String, dynamic>> getRBByQtyReported({
    required String keyword,
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportBoxModel>(
      endpoint: "report/reportBox/getQtyReported",
      queryParameters: {
        'qtyProduced': keyword,
        'machine': machine,
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
      },
      fromJson: (json) => ReportBoxModel.fromJson(json),
      dataKey: 'reportBoxes',
    );
  }

  //get by QC_Box
  Future<Map<String, dynamic>> getRBByQcBox({
    required String keyword,
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportBoxModel>(
      endpoint: "report/reportBox/getQcBox",
      queryParameters: {
        'QcBox': keyword,
        'machine': machine,
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
      },
      fromJson: (json) => ReportBoxModel.fromJson(json),
      dataKey: 'reportBoxes',
    );
  }

  //get by shiftManagement
  Future<Map<String, dynamic>> getRBByShiftManagement({
    required String keyword,
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportBoxModel>(
      endpoint: "report/reportBox/getShiftManagement",
      queryParameters: {
        'shiftManagement': keyword,
        'machine': machine,
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
      },
      fromJson: (json) => ReportBoxModel.fromJson(json),
      dataKey: 'reportBoxes',
    );
  }

  //get by shiftManagement
  Future<Map<String, dynamic>> getRBByOrderId({
    required String keyword,
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportBoxModel>(
      endpoint: "report/reportBox/getOrderId",
      queryParameters: {
        'orderId': keyword,
        'machine': machine,
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
      },
      fromJson: (json) => ReportBoxModel.fromJson(json),
      dataKey: 'reportBoxes',
    );
  }

  //============================EXPORT EXCEL=================================

  //export paper
  Future<File?> exportExcelReportPaper({
    DateTime? fromDate,
    DateTime? toDate,
    List<int>? reportPaperId,
    required String machine,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final Map<String, dynamic> body = {"machine": machine};

      if (reportPaperId != null && reportPaperId.isNotEmpty) {
        body["reportPaperId"] = reportPaperId;
      } else if (fromDate != null && toDate != null) {
        body["fromDate"] = fromDate.toIso8601String();
        body["toDate"] = toDate.toIso8601String();
      }

      final response = await dioService.post(
        "/api/report/exportExcelPaper",
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
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
        final safeMachine = makeSafeFileName(machine);
        final fileName =
            "report-paper-${safeMachine.toLowerCase()}-${now.toIso8601String().split('T')[0]}.xlsx";
        final file = File("$dirPath/$fileName");

        await file.writeAsBytes(bytes, flush: true);
        AppLogger.i("Exported Excel report to: ${file.path}");

        return file;
      } else {
        AppLogger.w("Export failed with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("failed to export report paper", error: e, stackTrace: s);
      return null;
    }
  }

  //export box
  Future<File?> exportExcelReportBox({
    DateTime? fromDate,
    DateTime? toDate,
    List<int>? reportBoxId,
    required String machine,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final Map<String, dynamic> body = {"machine": machine};

      if (reportBoxId != null && reportBoxId.isNotEmpty) {
        body["reportBoxId"] = reportBoxId;
      } else if (fromDate != null && toDate != null) {
        body["fromDate"] = fromDate.toIso8601String();
        body["toDate"] = toDate.toIso8601String();
      }

      final response = await dioService.post(
        "/api/report/exportExcelBox",
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
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
        final safeMachine = makeSafeFileName(machine);
        final fileName =
            "report-box-${safeMachine.toLowerCase()}-${now.toIso8601String().split('T')[0]}.xlsx";
        final file = File("$dirPath/$fileName");

        await file.writeAsBytes(bytes, flush: true);
        AppLogger.i("Exported Excel report to: ${file.path}");

        return file;
      } else {
        AppLogger.w("Export failed with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("failed to export report box", error: e, stackTrace: s);
      return null;
    }
  }

  String makeSafeFileName(String input) {
    // bỏ dấu tiếng Việt
    var result = removeDiacritics(input);

    // thay khoảng trắng bằng "_"
    result = result.replaceAll(RegExp(r'\s+'), '_');

    // loại bỏ ký tự đặc biệt ngoài a-zA-Z0-9_
    result = result.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

    return result;
  }
}
