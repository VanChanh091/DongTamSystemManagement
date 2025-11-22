import 'package:dio/dio.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';

class DashboardService {
  final Dio dioService = DioClient().dio;

  Future<Map<String, dynamic>> getAllDataDashboard({
    required int page,
    required int pageSize,
  }) async {
    return HelperService().fetchPaginatedData<PlanningPaper>(
      endpoint: "dashboard/paper",
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (json) => PlanningPaper.fromJson(json),
      dataKey: 'dashboard',
    );
  }

  Future<List<PlanningStage>> getDbPlanningDetail({required int planningId}) async {
    return HelperService().fetchingData(
      endpoint: 'dashboard/getDetail',
      queryParameters: {'planningId': planningId},
      fromJson: (json) => PlanningStage.fromJson(json),
    );
  }
}
