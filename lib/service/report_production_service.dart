import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/report/report_production_model.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:intl/intl.dart';

class ReportProductionService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  //get all report production
  Future<List<ReportProductionModel>> getReportProdByMachine(
    String machine,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/report/',
        queryParameters: {"machine": machine},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;

      return data.map((e) => ReportProductionModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load report production: $e');
    }
  }

  //get by shift management
  Future<List<ReportProductionModel>> getReportByShiftManagement(
    String name,
    String machine,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/report/getByShiftManagement',
        queryParameters: {'name': name, "machine": machine},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((json) => ReportProductionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load report by shift management: $e');
    }
  }

  //get by day completed
  Future<List<ReportProductionModel>> getReportByDayCompleted(
    DateTime fromDate,
    DateTime toDate,
    String machine,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/report/getByDayCompleted',
        queryParameters: {
          'fromDate': DateFormat('yyyy-MM-dd').format(fromDate),
          'toDate': DateFormat('yyyy-MM-dd').format(toDate),
          'machine': machine,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;

      return data.map((e) => ReportProductionModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load report by day completed: $e');
    }
  }

  //create report production
  Future<bool> createReportProduction(
    int planningId,
    Map<String, dynamic> reportProduction,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/report',
        queryParameters: {'planningId': planningId},
        data: reportProduction,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return true;
    } catch (e) {
      throw Exception('Failed to create report production: $e');
    }
  }
}
