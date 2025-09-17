import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/report/report_planning_box.dart';
import 'package:dongtam/data/models/report/report_planning_paper.dart';
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

      // print('report papers: $reportPapers');

      return {
        'reportPapers': parsedReportPapers,
        "totalPages": totalPages,
        "currentPage": currentPage,
      };
    } catch (e) {
      throw Exception('Failed to load report papers: $e');
    }
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
}
