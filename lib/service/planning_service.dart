import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlanningService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  //===============================PLANNING ORDER====================================

  //get status order
  Future<List<Order>> getOrderAccept(bool refresh) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/planning/',
        queryParameters: {'refresh': refresh},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;

      return data.map((e) => Order.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("NO_PERMISSION");
      }
      rethrow;
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  //planning for order
  Future<bool> planningOrder(
    String orderId,
    String newStatus,
    Map<String, dynamic> orderPlanning,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/planning/planningOrder',
        queryParameters: {"orderId": orderId, "newStatus": newStatus},
        data: orderPlanning,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return true;
    } catch (e) {
      throw Exception('Failed to plan order: $e');
    }
  }

  //===============================PLANNING PAPER====================================

  //get planning by machine
  Future<List<PlanningPaper>> getPlanningPaperByMachine(
    String machine,
    bool refresh,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/planning/byMachinePaper',
        queryParameters: {'machine': machine, 'refresh': refresh},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> planningData = response.data['data'];
      return planningData.map((json) => PlanningPaper.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("NO_PERMISSION");
      }
      rethrow;
    } catch (e) {
      throw Exception('Failed to get planning: $e');
    }
  }

  //get planning by customer name
  Future<List<PlanningPaper>> getPlanningByCustomerName(
    String customerName,
    String machine,
  ) async {
    return HelperService().fetchingData<PlanningPaper>(
      endpoint: "planning/getCusNamePaper",
      queryParameters: {'customerName': customerName, 'machine': machine},
      fromJson: (json) => PlanningPaper.fromJson(json),
    );
  }

  //get planning by orderId
  Future<List<PlanningPaper>> getPlanningByOrderId(
    String orderId,
    String machine,
  ) async {
    return HelperService().fetchingData<PlanningPaper>(
      endpoint: "planning/getOrderIdPaper",
      queryParameters: {'orderId': orderId, 'machine': machine},
      fromJson: (json) => PlanningPaper.fromJson(json),
    );
  }

  //get planning by flute
  Future<List<PlanningPaper>> getPlanningByFlute(
    String flute,
    String machine,
  ) async {
    return HelperService().fetchingData<PlanningPaper>(
      endpoint: "planning/getFlutePaper",
      queryParameters: {'flute': flute, 'machine': machine},
      fromJson: (json) => PlanningPaper.fromJson(json),
    );
  }

  //get planning by ghepKho
  Future<List<PlanningPaper>> getPlanningByGhepKho(
    int ghepKho,
    String machine,
  ) async {
    return HelperService().fetchingData<PlanningPaper>(
      endpoint: "planning/getGhepKhoPaper",
      queryParameters: {'ghepKho': ghepKho, 'machine': machine},
      fromJson: (json) => PlanningPaper.fromJson(json),
    );
  }

  //change machine
  Future<bool> changeMachinePlanning(
    List<int> planningIds,
    String newMachine,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/planning/changeMachinePaper",
        data: {"planningIds": planningIds, "newMachine": newMachine},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return true;
    } catch (e) {
      throw Exception('Failed to update orders: $e');
    }
  }

  //update index planning
  Future<bool> updateIndexWTimeRunning(
    String machine,
    List<Map<String, dynamic>> updateIndex,
    DateTime dayStart,
    TimeOfDay timeStart,
    int totalTimeWorking,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        "/api/planning/updateIndex_TimeRunningPaper",
        queryParameters: {'machine': machine},
        data: {
          "updateIndex": updateIndex,
          "dayStart": DateFormat('yyyy-MM-dd').format(dayStart),
          "timeStart":
              "${timeStart.hour.toString().padLeft(2, '0')}:${timeStart.minute.toString().padLeft(2, '0')}",
          "totalTimeWorking": totalTimeWorking,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return true;
    } catch (e) {
      throw Exception('Failed to update planning: $e');
    }
  }

  //pause order
  Future<bool> pauseOrAcceptLackQty(
    List<int> planningIds,
    String newStatus,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/planning/pauseOrAcceptLackQtyPaper",
        data: {'planningIds': planningIds, "newStatus": newStatus},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return true;
    } catch (e) {
      throw Exception('Failed to pause machine: $e');
    }
  }

  //===============================PLANNING BOX====================================

  Future<List<PlanningBox>> getPlanningMachineBox(
    String machine,
    bool refresh,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/planning/byMachineBox',
        queryParameters: {'machine': machine, 'refresh': refresh},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> planningData = response.data['data'];
      // print(planningData);
      return planningData.map((json) => PlanningBox.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("NO_PERMISSION");
      }
      rethrow;
    } catch (e) {
      throw Exception('Failed to get planning: $e');
    }
  }

  //update index planning
  Future<bool> updateIndexWTimeRunningBox(
    String machine,
    DateTime dayStart,
    TimeOfDay timeStart,
    int totalTimeWorking,
    List<Map<String, dynamic>> updateIndex,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        "/api/planning/updateIndex_TimeRunningBox",
        data: {
          'machine': machine,
          "dayStart": DateFormat('yyyy-MM-dd').format(dayStart),
          "timeStart":
              "${timeStart.hour.toString().padLeft(2, '0')}:${timeStart.minute.toString().padLeft(2, '0')}",
          "totalTimeWorking": totalTimeWorking,
          "updateIndex": updateIndex,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return true;
    } catch (e) {
      throw Exception('Failed to update planning: $e');
    }
  }

  //accept lack qty
  Future<bool> acceptLackQtyBox(
    List<int> planningBoxIds,
    String newStatus,
    String machine,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/planning/acceptLackQtyBox",
        data: {
          "planningBoxIds": planningBoxIds,
          "newStatus": newStatus,
          "machine": machine,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return true;
    } catch (e) {
      throw Exception('Failed to pause machine: $e');
    }
  }

  //get planning by orderId
  Future<List<PlanningBox>> getOrderIdBox(
    String orderId,
    String machine,
  ) async {
    return HelperService().fetchingData<PlanningBox>(
      endpoint: "planning/getOrderIdBox",
      queryParameters: {'machine': machine, 'orderId': orderId},
      fromJson: (json) => PlanningBox.fromJson(json),
    );
  }

  //get planning by customer name
  Future<List<PlanningBox>> getCusNameBox(
    String customerName,
    String machine,
  ) async {
    return HelperService().fetchingData<PlanningBox>(
      endpoint: "planning/getCusNameBox",
      queryParameters: {'customerName': customerName, 'machine': machine},
      fromJson: (json) => PlanningBox.fromJson(json),
    );
  }

  //get planning by flute
  Future<List<PlanningBox>> getFluteBox(String flute, String machine) async {
    return HelperService().fetchingData<PlanningBox>(
      endpoint: "planning/getFluteBox",
      queryParameters: {'flute': flute, 'machine': machine},
      fromJson: (json) => PlanningBox.fromJson(json),
    );
  }

  //get planning by ghepKho
  Future<List<PlanningBox>> getQcBox(String QC_box, String machine) async {
    return HelperService().fetchingData<PlanningBox>(
      endpoint: "planning/getQcBox",
      queryParameters: {'QC_box': QC_box, 'machine': machine},
      fromJson: (json) => PlanningBox.fromJson(json),
    );
  }
}
