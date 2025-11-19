import 'package:dio/dio.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';

class DashboardService {
  final Dio dioService = DioClient().dio;

  Future<Map<String, dynamic>> getAllDataPaper({required int page, required int pageSize}) async {
    return HelperService().fetchPaginatedData<PlanningPaper>(
      endpoint: "dashboard/paper",
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (json) => PlanningPaper.fromJson(json),
      dataKey: 'planningPapers',
    );
  }

  Future<Map<String, dynamic>> getAllDataBox({required int page, required int pageSize}) async {
    return HelperService().fetchPaginatedData<PlanningBox>(
      endpoint: "dashboard/box",
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (json) => PlanningBox.fromJson(json),
      dataKey: 'planningBoxes',
    );
  }
}
