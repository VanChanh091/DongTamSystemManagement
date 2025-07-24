import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/planning/planning_model.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:intl/intl.dart';

class ManufactureService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  //get planning paper
  Future<List<Planning>> getPlanningPaper(String machine, String step) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/manufacture/planningPaper',
        queryParameters: {"machine": machine, "step": step},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((e) => Planning.fromJson(e)).toList();
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
    try {
      final token = await SecureStorageService().getToken();

      final Map<String, dynamic> data = {
        "qtyProduced": qtyProduced,
        "qtyWasteNorm": qtyWasteNorm,
        "dayCompleted": DateFormat('yyyy-MM-dd').format(dayCompleted),
        ...reportData,
      };

      await dioService.post(
        '/api/manufacture/addReportPaper',
        queryParameters: {"planningId": planningId},
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e) {
      throw Exception('Failed to create report paper: $e');
    }
  }
}
