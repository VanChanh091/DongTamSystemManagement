import 'package:dio/dio.dart';
import 'package:dongtam/data/models/delivery/delivery_plan_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:intl/intl.dart';

class DeliveryService {
  final Dio dioService = DioClient().dio;

  //===============================PLANNING ESTIMATE==============================

  // get all planning estimate time
  Future<Map<String, dynamic>> getPlanningEstimateTime({
    required int page,
    required int pageSize,
    required DateTime dayStart,
    required String estimateTime,
  }) async {
    return HelperService().fetchPaginatedData<PlanningPaper>(
      endpoint: "delivery/getPlanningEstimate",
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        "dayStart": DateFormat('yyyy-MM-dd').format(dayStart),
        'estimateTime': estimateTime,
      },
      fromJson: (json) => PlanningPaper.fromJson(json),
      dataKey: 'plannings',
    );
  }

  // confirm ready delivery
  Future<bool> confirmReadyDelivery({required List<int> planningIds}) async {
    return HelperService().updateItem(
      endpoint: "delivery/confirmReadyDelivery",
      queryParameters: {'planningIds': planningIds},
    );
  }

  //=========================PLANNING & SCHEDULE DELIVERY===========================

  //get all planning waiting delivery
  Future<List<PlanningPaper>> getPlanningWaitingDelivery() async {
    return HelperService().fetchingData<PlanningPaper>(
      endpoint: "delivery/getPlanningWaitingDelivery",
      queryParameters: const {},
      fromJson: (json) => PlanningPaper.fromJson(json),
    );
  }

  //get all delivery
  Future<List<DeliveryPlanModel>> getAllPlanningDelivery({required DateTime deliveryDate}) async {
    return HelperService().fetchingData<DeliveryPlanModel>(
      endpoint: "delivery/getPlanningDelivery",
      queryParameters: {"deliveryDate": DateFormat('yyyy-MM-dd').format(deliveryDate)},
      fromJson: (json) => DeliveryPlanModel.fromJson(json),
    );
  }

  //create delivery schedule
  Future<bool> createDeliveryPlan({
    required DateTime deliveryDate,
    required List<Map<String, dynamic>> items,
  }) async {
    return HelperService().addItem(
      endpoint: "delivery/createDeliveryPlan",
      itemData: {"deliveryDate": DateFormat('yyyy-MM-dd').format(deliveryDate), "items": items},
    );
  }

  //confirm for delivery
}
