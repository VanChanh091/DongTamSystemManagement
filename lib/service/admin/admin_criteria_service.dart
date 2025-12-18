import 'package:dio/dio.dart';
import 'package:dongtam/data/models/admin/qc_criteria_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class AdminCriteriaService {
  final Dio dioService = DioClient().dio;

  Future<List<QcCriteriaModel>> getAllQcCriteria({required String type}) async {
    return HelperService().fetchingData<QcCriteriaModel>(
      endpoint: "admin/getCriteria",
      queryParameters: {"type": type},
      fromJson: (json) => QcCriteriaModel.fromJson(json),
    );
  }

  Future<bool> createNewCriteria({
    required String processType,
    required String criteriaCode,
    required String criteriaName,
    required bool isRequired,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/admin/newCriteria',
        data: {
          "processType": processType,
          "criteriaCode": criteriaCode,
          "criteriaName": criteriaName,
          "isRequired": isRequired,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to create criteria", error: e, stackTrace: s);
      throw Exception('Failed to create criteria: $e');
    }
  }

  Future<bool> updateCriteria({
    required int qcCriteriaId,
    required String processType,
    required String criteriaCode,
    required String criteriaName,
    required bool isRequired,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/admin/updateCriteria',
        queryParameters: {"qcCriteriaId": qcCriteriaId},
        data: {
          "processType": processType,
          "criteriaCode": criteriaCode,
          "criteriaName": criteriaName,
          "isRequired": isRequired,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update criteria", error: e, stackTrace: s);
      throw Exception('Failed to update criteria: $e');
    }
  }

  Future<bool> deleteCriteria({required int qcCriteriaId}) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/admin/deleteCriteria',
        queryParameters: {"qcCriteriaId": qcCriteriaId},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update criteria", error: e, stackTrace: s);
      throw Exception('Failed to update criteria: $e');
    }
  }
}
