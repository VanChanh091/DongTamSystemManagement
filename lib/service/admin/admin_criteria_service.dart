import 'package:dio/dio.dart';
import 'package:dongtam/data/models/admin/qc_criteria_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';

class AdminCriteriaService {
  final Dio dioService = DioClient().dio;

  Future<List<QcCriteriaModel>> getAllQcCriteria({required String type}) async {
    return HelperService().fetchingData<QcCriteriaModel>(
      endpoint: "admin/getCriteria",
      queryParameters: {"type": type},
      fromJson: (json) => QcCriteriaModel.fromJson(json),
    );
  }

  Future<bool> createNewCriteria({required Map<String, dynamic> criteriaData}) async {
    return HelperService().addItem(endpoint: 'admin/newCriteria', itemData: criteriaData);
  }

  Future<bool> updateCriteria({
    required int qcCriteriaId,
    required Map<String, dynamic> criteriaUpdated,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/updateCriteria',
      queryParameters: {"qcCriteriaId": qcCriteriaId},
      dataUpdated: criteriaUpdated,
    );
  }

  Future<bool> deleteCriteria({required int qcCriteriaId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/deleteCriteria',
      queryParameters: {'qcCriteriaId': qcCriteriaId},
    );
  }
}
