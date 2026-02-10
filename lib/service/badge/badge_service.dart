import 'package:dio/dio.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/logger/app_logger.dart';

class BadgeService {
  final Dio dioService = DioClient().dio;

  //HELPER
  Future<int> countForBadge(String endpoint) async {
    try {
      final response = await dioService.get("/api/badge/$endpoint");

      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as int;
      }

      return 0;
    } catch (e, s) {
      AppLogger.e("Failed to count for badge $endpoint", error: e, stackTrace: s);
      throw Exception('Failed to count for badge $endpoint: $e');
    }
  }

  //pending order
  Future<int> countOrderPending() async {
    return countForBadge("countPending");
  }

  //order reject
  Future<int> countOrderRejected() async {
    return countForBadge("countRejected");
  }

  //order pending planning
  Future<int> countOrderPendingPlanning() async {
    return countForBadge("countPendingPlanning");
  }

  //planning stop
  Future<int> countPlanningStop() async {
    return countForBadge("countPlanningStop");
  }

  //waiting check paper & box
  Future<int> countWaitingCheckPaper() async {
    return countForBadge("countWaitingCheckPaper");
  }

  Future<int> countWaitingCheckBox() async {
    return countForBadge("countWaitingCheckBox");
  }
}
