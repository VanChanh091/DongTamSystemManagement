import 'package:dio/dio.dart';
import 'package:dongtam/data/models/admin/admin_flute_ratio_model.dart';
import 'package:dongtam/data/models/admin/admin_machine_box_model.dart';
import 'package:dongtam/data/models/admin/admin_machine_paper_model.dart';
import 'package:dongtam/data/models/admin/admin_vehicle_model.dart';
import 'package:dongtam/data/models/admin/admin_waste_norm_model.dart';
import 'package:dongtam/data/models/admin/admin_waste_box_model.dart';
import 'package:dongtam/data/models/admin/admin_wave_crest_model.dart';
import 'package:dongtam/data/models/admin/qc_criteria_model.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/user/user_admin_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class AdminService {
  final Dio dioService = DioClient().dio;

  //===============================ORDER====================================

  //get status order
  Future<List<Order>> getOrderByPendingStatus() async {
    return HelperService().fetchingData<Order>(
      endpoint: 'admin/orders',
      queryParameters: const {},
      fromJson: (json) => Order.fromJson(json),
    );
  }

  //update status order
  Future<bool> updateStatusOrder({
    required String orderId,
    required String newStatus,
    required String rejectReason,
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/admin/orders?id=$orderId",
        data: {"newStatus": newStatus, "rejectReason": rejectReason},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } on DioException catch (e) {
      HelperService().handleDioException(e, "Lỗi khi thêm dữ liệu");
      return false;
    } catch (e, s) {
      AppLogger.e("Failed to load orders", error: e, stackTrace: s);
      throw Exception('Failed to update orders: $e');
    }
  }

  //===============================USER====================================

  // get all and search
  Future<List<UserAdminModel>> getUsersAdmin({
    String? name,
    String? phone,
    List<String>? permissions,
  }) async {
    return HelperService().fetchingData<UserAdminModel>(
      endpoint: "admin/users",
      queryParameters: {
        if (name != null) "name": name,
        if (phone != null) "phone": phone,
        if (permissions != null && permissions.isNotEmpty) "permissions": permissions,
      },
      fromJson: (json) => UserAdminModel.fromJson(json),
    );
  }

  //update user
  Future<bool> updateInfoUser({
    int? userId,
    String? newRole,
    List<String>? permissions,
    List<int>? userIds,
    String? newPassword,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/users',
      queryParameters: {
        if (userId != null) "userId": userId,
        if (newRole != null && newRole.isNotEmpty) "newRole": newRole,
      },
      dataUpdated: {
        if (permissions != null && permissions.isNotEmpty) "permissions": permissions,
        if (userIds != null && userIds.isNotEmpty) "userIds": userIds,
        if (newPassword != null && newPassword.isNotEmpty) "newPassword": newPassword,
      },
    );
  }

  //delete user
  Future<bool> deleteUser({required int userId}) async {
    return HelperService().deleteItem(endpoint: 'admin/users', queryParameters: {"userId": userId});
  }

  //===============================MACHINE PAPER====================================

  //get all machine
  Future<List<AdminMachinePaperModel>> getMachinePapers() async {
    return HelperService().fetchingData<AdminMachinePaperModel>(
      endpoint: 'admin/machine-papers',
      queryParameters: const {},
      fromJson: (json) => AdminMachinePaperModel.fromJson(json),
    );
  }

  //update machine
  Future<bool> updateMachinePaper({
    required int machineId,
    required Map<String, dynamic> machineUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/machine-papers',
      queryParameters: {"machineId": machineId},
      dataUpdated: machineUpdate,
    );
  }

  //delete machine
  Future<bool> deleteMachinePaper({required int machineId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/machine-papers',
      queryParameters: {"machineId": machineId},
    );
  }

  //===============================MACHINE BOX====================================

  //get all machine
  Future<List<AdminMachineBoxModel>> getAllMachineBox() async {
    return HelperService().fetchingData<AdminMachineBoxModel>(
      endpoint: 'admin/machine-boxes',
      queryParameters: const {},
      fromJson: (json) => AdminMachineBoxModel.fromJson(json),
    );
  }

  //update machine
  Future<bool> updateMachineBox({
    required int machineId,
    required Map<String, dynamic> machineUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/machine-boxes',
      queryParameters: {"machineId": machineId},
      dataUpdated: machineUpdate,
    );
  }

  //delete machine
  Future<bool> deleteMachineBox({required int machineId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/machine-boxes',
      queryParameters: {"machineId": machineId},
    );
  }

  //===============================WASTE NORM PAPER====================================

  //get all waste norm
  Future<List<AdminWasteNormModel>> getWastePapers() async {
    return HelperService().fetchingData<AdminWasteNormModel>(
      endpoint: "admin/waste-norms/papers",
      queryParameters: const {},
      fromJson: (json) => AdminWasteNormModel.fromJson(json),
    );
  }

  //update waste norm
  Future<bool> updateWastePaper({
    required int wasteNormId,
    required Map<String, dynamic> wasteNormUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/waste-norms/papers',
      queryParameters: {"wasteNormId": wasteNormId},
      dataUpdated: wasteNormUpdate,
    );
  }

  //delete waste norm
  Future<bool> deleteWastePaper({required int wasteNormId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/waste-norms/papers',
      queryParameters: {"wasteNormId": wasteNormId},
    );
  }

  //===============================WASTE NORM BOX====================================

  //get all waste box
  Future<List<AdminWasteBoxModel>> getWasteBoxes() async {
    return HelperService().fetchingData<AdminWasteBoxModel>(
      endpoint: 'admin/waste-norms/boxes',
      queryParameters: const {},
      fromJson: (json) => AdminWasteBoxModel.fromJson(json),
    );
  }

  //update waste box
  Future<bool> updateWasteBox({
    required int wasteNormId,
    required Map<String, dynamic> wasteNormUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/waste-norms/boxes',
      queryParameters: {"wasteNormId": wasteNormId},
      dataUpdated: wasteNormUpdate,
    );
  }

  //delete waste box
  Future<bool> deleteWasteBox({required int wasteNormId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/waste-norms/boxes',
      queryParameters: {"wasteNormId": wasteNormId},
    );
  }

  //==========================WAVE CREST COEFFICIENT================================

  //get all wave crest
  Future<List<AdminWaveCrestModel>> getAllWaveCrest() async {
    return HelperService().fetchingData<AdminWaveCrestModel>(
      endpoint: 'admin/wave-crest-coeff',
      queryParameters: const {},
      fromJson: (json) => AdminWaveCrestModel.fromJson(json),
    );
  }

  //update wave crest
  Future<bool> updateWaveCrest({
    required int waveCrestId,
    required Map<String, dynamic> waveCrestUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/wave-crest-coeff',
      queryParameters: {"waveCrestId": waveCrestId},
      dataUpdated: waveCrestUpdate,
    );
  }

  //delete wave crest
  Future<bool> deleteWaveCrest({required int waveCrestId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/wave-crest-coeff',
      queryParameters: {"waveCrestId": waveCrestId},
    );
  }

  //===========================CRITERIA======================================

  Future<List<QcCriteriaModel>> getAllQcCriteria({required String type}) async {
    return HelperService().fetchingData<QcCriteriaModel>(
      endpoint: "admin/criterias",
      queryParameters: {"type": type},
      fromJson: (json) => QcCriteriaModel.fromJson(json),
    );
  }

  Future<bool> createNewCriteria({required Map<String, dynamic> criteriaData}) async {
    return HelperService().addItem(endpoint: 'admin/criterias', itemData: criteriaData);
  }

  Future<bool> updateCriteria({
    required int qcCriteriaId,
    required Map<String, dynamic> criteriaUpdated,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/criterias',
      queryParameters: {"qcCriteriaId": qcCriteriaId},
      dataUpdated: criteriaUpdated,
    );
  }

  Future<bool> deleteCriteria({required int qcCriteriaId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/criterias',
      queryParameters: {'qcCriteriaId': qcCriteriaId},
    );
  }

  //==========================FLUTE RATIO====================================

  //get all flute ratio
  Future<List<AdminFluteRatioModel>> getAllFluteRatio() async {
    return HelperService().fetchingData<AdminFluteRatioModel>(
      endpoint: 'admin/flute-ratios',
      queryParameters: const {},
      fromJson: (json) => AdminFluteRatioModel.fromJson(json),
    );
  }

  // add flute ratio
  Future<bool> addFluteRatio({required Map<String, dynamic> fluteRatioData}) async {
    return HelperService().addItem(endpoint: 'admin/flute-ratios', itemData: fluteRatioData);
  }

  //update flute ratio
  Future<bool> updateFluteRatio({
    required int fluteRatioId,
    required Map<String, dynamic> fluteRatioUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/flute-ratios',
      queryParameters: {"fluteRatioId": fluteRatioId},
      dataUpdated: fluteRatioUpdate,
    );
  }

  //delete flute ratio
  Future<bool> deleteFluteRatio({required int fluteRatioId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/flute-ratios',
      queryParameters: {"fluteRatioId": fluteRatioId},
    );
  }

  //==========================VEHICLE====================================

  //get all vehicle
  Future<List<AdminVehicleModel>> getAllVehicle() async {
    return HelperService().fetchingData<AdminVehicleModel>(
      endpoint: 'admin/vehicles',
      queryParameters: const {},
      fromJson: (json) => AdminVehicleModel.fromJson(json),
    );
  }

  // add qc criteria
  Future<bool> addVehicle({required Map<String, dynamic> vehicleData}) async {
    return HelperService().addItem(endpoint: 'admin/vehicles', itemData: vehicleData);
  }

  //update vehicle
  Future<bool> updateVehicle({
    required int vehicleId,
    required Map<String, dynamic> vehicleUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/vehicles',
      queryParameters: {"vehicleId": vehicleId},
      dataUpdated: vehicleUpdate,
    );
  }

  //delete vehicle
  Future<bool> deleteVehicle({required int vehicleId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/vehicles',
      queryParameters: {"vehicleId": vehicleId},
    );
  }
}
