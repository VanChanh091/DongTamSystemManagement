import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/report/report_planning_box.dart';
import 'package:dongtam/data/models/report/report_planning_paper.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class ReportPlanningService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  //============================REPORT PAPER=================================
  Future<Map<String, dynamic>> getReportPaper(
    String machine,
    int page,
    int pageSize,
    bool refresh,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/report/reportPaper',
        queryParameters: {
          "machine": machine,
          "page": page,
          "pageSize": pageSize,
          "refresh": refresh,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      final reportPapers = data['data'] as List; //data
      final totalPages = data['totalPages']; //page size
      final currentPage = data['currentPage']; //page

      final parsedReportPapers =
          reportPapers.map((e) => ReportPaperModel.fromJson(e)).toList();

      return {
        'reportPapers': parsedReportPapers,
        "totalPages": totalPages,
        "currentPage": currentPage,
      };
    } catch (e) {
      throw Exception('Failed to load report papers: $e');
    }
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

  //============================REPORT PAPER=================================
  Future<Map<String, dynamic>> getReportBox(
    String machine,
    int page,
    int pageSize,
    bool refresh,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/report/reportBox',
        queryParameters: {
          "machine": machine,
          "page": page,
          "pageSize": pageSize,
          "refresh": refresh,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      final reportBoxes = data['data'] as List; //data
      final totalPages = data['totalPages']; //page size
      final currentPage = data['currentPage']; //page

      final parsedReportBoxes =
          reportBoxes.map((e) => ReportBoxModel.fromJson(e)).toList();

      return {
        'reportBoxes': parsedReportBoxes,
        "totalPages": totalPages,
        "currentPage": currentPage,
      };
    } catch (e) {
      throw Exception('Failed to load report boxes: $e');
    }
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
}
