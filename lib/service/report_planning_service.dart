import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/report/report_planning_box.dart';
import 'package:dongtam/data/models/report/report_planning_paper.dart';
import 'package:dongtam/utils/helper/helper_service.dart';

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
      endpoint: "report/reportPaper/getCustomerName",
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

  //============================REPORT PAPER=================================
  Future<Map<String, dynamic>> getReportBox({
    required String machine,
    required int page,
    required int pageSize,
    bool refresh = false,
  }) async {
    return HelperService().fetchPaginatedData<ReportBoxModel>(
      endpoint: "report/reportBox/getCustomerName",
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
}
