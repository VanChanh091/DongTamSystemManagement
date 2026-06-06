import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dongtam/data/models/scrap/scrap_report_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class ScrapReportService {
  final Dio dioService = DioClient().dio;

  // get all and search
  Future<Map<String, dynamic>> getAllScrapReports({
    required int page,
    required int pageSize,
    String? field,
    String? keyword,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return HelperService().fetchPaginatedData<ScrapReportModel>(
      endpoint: "scrapReports",
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (field != null) 'field': field,
        if (keyword != null) 'keyword': keyword,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      },
      fromJson: (json) => ScrapReportModel.fromJson(json),
      dataKey: 'scrapReports',
    );
  }

  // add scrap report
  Future<bool> addScrapReport({required Map<String, dynamic> scrapData}) async {
    return HelperService().addItem(endpoint: "scrapReports", body: scrapData);
  }

  // update scrap report
  Future<bool> updateScrapReport({
    required int scrapId,
    required Map<String, dynamic> updateScrapReport,
  }) async {
    return HelperService().updateItem(
      endpoint: "scrapReports",
      queryParameters: {"scrapId": scrapId},
      body: updateScrapReport,
    );
  }

  // delete scrap report
  Future<bool> deleteScrapReport({required int scrapId}) async {
    return HelperService().deleteItem(
      endpoint: "scrapReports",
      queryParameters: {"scrapId": scrapId},
    );
  }

  //export scrap reports
  Future<File?> exportExcelScrapReports({
    DateTime? fromDate,
    DateTime? toDate,
    bool all = false,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      final Map<String, dynamic> body = {"all": all};

      if (fromDate != null && toDate != null) {
        body["fromDate"] = fromDate.toIso8601String();
        body["toDate"] = toDate.toIso8601String();
      }

      final response = await dioService.post(
        "/api/scrapReports/export",
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return await HelperService().saveExcelFile(
          bytes: response.data as List<int>,
          fileNamePrefix: "scrapReports",
        );
      } else {
        AppLogger.w("Export failed with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("failed to export scrap report", error: e, stackTrace: s);
      return null;
    }
  }
}
