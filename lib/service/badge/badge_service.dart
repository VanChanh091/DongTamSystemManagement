import 'package:dio/dio.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/logger/app_logger.dart';

class BadgeService {
  final Dio dioService = DioClient().dio;

  //HELPER
  Future<int> countForBadge(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dioService.get(
        "/api/badge/$endpoint",
        queryParameters: queryParameters,
      );

      // print("API Response for $endpoint: ${response.statusCode} - Data: ${response.data}");

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
    return countForBadge("count-pending");
  }

  //order reject
  Future<int> countOrderRejected() async {
    return countForBadge("count-rejected");
  }

  //order pending planning
  Future<int> countOrderPendingPlanning() async {
    return countForBadge("count-pending-planning");
  }

  //planning stop
  Future<int> countPlanningStop() async {
    return countForBadge("count-planning-stop");
  }

  //waiting check paper & box
  Future<int> countWaitingCheck(String type) async {
    return countForBadge("count-waiting-check", queryParameters: {"type": type});
  }

  //delivery request
  Future<int> countDeliveryRequest() async {
    return countForBadge("count-delivery-request");
  }

  //request prepare goods
  Future<int> countPrepareGoods() async {
    return countForBadge("count-prepare-goods");
  }
}
