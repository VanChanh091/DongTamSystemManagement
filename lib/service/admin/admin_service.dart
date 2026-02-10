import 'package:dio/dio.dart';
import 'package:dongtam/data/models/admin/admin_flute_ratio_model.dart';
import 'package:dongtam/data/models/admin/admin_machine_box_model.dart';
import 'package:dongtam/data/models/admin/admin_machine_paper_model.dart';
import 'package:dongtam/data/models/admin/admin_vehicle_model.dart';
import 'package:dongtam/data/models/admin/admin_waste_norm_model.dart';
import 'package:dongtam/data/models/admin/admin_waste_box_model.dart';
import 'package:dongtam/data/models/admin/admin_wave_crest_model.dart';
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
      endpoint: 'admin',
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
        "/api/admin/updateStatus?id=$orderId",
        data: {"newStatus": newStatus, "rejectReason": rejectReason},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception("Debt limit exceeded");
      }
      rethrow;
    } catch (e, s) {
      AppLogger.e("Failed to load orders", error: e, stackTrace: s);
      throw Exception('Failed to update orders: $e');
    }
  }

  //===============================USER====================================

  //get all users
  Future<List<UserAdminModel>> getAllUsers() async {
    return HelperService().fetchingData<UserAdminModel>(
      endpoint: "admin/getAllUsers",
      queryParameters: const {},
      fromJson: (json) => UserAdminModel.fromJson(json),
    );
  }

  //get user by name
  Future<List<UserAdminModel>> getUserByName({required String name}) async {
    return HelperService().fetchingData<UserAdminModel>(
      endpoint: "admin/getUserByName",
      queryParameters: {"name": name},
      fromJson: (json) => UserAdminModel.fromJson(json),
    );
  }

  //get user by phone
  Future<List<UserAdminModel>> getUserByPhone({required String phone}) async {
    return HelperService().fetchingData<UserAdminModel>(
      endpoint: "admin/getUserByPhone",
      queryParameters: {"phone": phone},
      fromJson: (json) => UserAdminModel.fromJson(json),
    );
  }

  //get user by permission
  Future<List<UserAdminModel>> getUserByPermission({required List<String> permissions}) async {
    return HelperService().fetchingData<UserAdminModel>(
      endpoint: "admin/getUserByPermission",
      queryParameters: {'permission': permissions},
      fromJson: (json) => UserAdminModel.fromJson(json),
    );
  }

  //update role
  Future<bool> updateUserRole({required int userId, required String newRole}) async {
    return HelperService().updateItem(
      endpoint: 'admin/updateRole',
      queryParameters: {"userId": userId, "newRole": newRole},
    );
  }

  //update permissions
  Future<bool> updateUserPermissions({
    required int userId,
    required List<String> permissions,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/updatePermission',
      queryParameters: {"userId": userId},
      dataUpdated: {"permissions": permissions},
    );
  }

  //reset password
  Future<bool> resetUserPassword({
    required List<int> userIds,
    String newPassword = 'baobidongtam2025',
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/resetPassword',
      queryParameters: const {},
      dataUpdated: {"userIds": userIds, "newPassword": newPassword},
    );
  }

  //delete user
  Future<bool> deleteUserById({required int userId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/deleteUser',
      queryParameters: {"userId": userId},
    );
  }

  //===============================MACHINE PAPER====================================

  //get all machine
  Future<List<AdminMachinePaperModel>> getAllMachinePaper() async {
    return HelperService().fetchingData<AdminMachinePaperModel>(
      endpoint: 'admin/getAllMachinePaper',
      queryParameters: const {},
      fromJson: (json) => AdminMachinePaperModel.fromJson(json),
    );
  }

  //get machine by Id
  Future<List<AdminMachinePaperModel>> getMachinePaperById({required int machineId}) async {
    return HelperService().fetchingData<AdminMachinePaperModel>(
      endpoint: "admin/getMachinePaperById",
      queryParameters: {'machineId': machineId},
      fromJson: (json) => AdminMachinePaperModel.fromJson(json),
    );
  }

  //update machine
  Future<bool> updateMachinePaper({
    required int machineId,
    required Map<String, dynamic> machineUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/updateMachinePaper',
      queryParameters: {"machineId": machineId},
      dataUpdated: machineUpdate,
    );
  }

  //delete machine
  Future<bool> deleteMachinePaper({required int machineId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/deleteMachinePaper',
      queryParameters: {"machineId": machineId},
    );
  }

  //===============================MACHINE BOX====================================

  //get all machine
  Future<List<AdminMachineBoxModel>> getAllMachineBox() async {
    return HelperService().fetchingData<AdminMachineBoxModel>(
      endpoint: 'admin/getAllMachineBox',
      queryParameters: const {},
      fromJson: (json) => AdminMachineBoxModel.fromJson(json),
    );
  }

  //get machine by Id
  Future<List<AdminMachineBoxModel>> getMachineBoxById({required int machineId}) async {
    return HelperService().fetchingData<AdminMachineBoxModel>(
      endpoint: "admin/getMachineBoxById",
      queryParameters: {'machineId': machineId},
      fromJson: (json) => AdminMachineBoxModel.fromJson(json),
    );
  }

  //update machine
  Future<bool> updateMachineBox({
    required int machineId,
    required Map<String, dynamic> machineUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/updateMachineBox',
      queryParameters: {"machineId": machineId},
      dataUpdated: machineUpdate,
    );
  }

  //delete machine
  Future<bool> deleteMachineBox({required int machineId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/deleteMachineBox',
      queryParameters: {"machineId": machineId},
    );
  }

  //===============================WASTE NORM PAPER====================================

  //get all waste norm
  Future<List<AdminWasteNormModel>> getAllWasteNorm() async {
    return HelperService().fetchingData<AdminWasteNormModel>(
      endpoint: "admin/getAllWasteNorm",
      queryParameters: const {},
      fromJson: (json) => AdminWasteNormModel.fromJson(json),
    );
  }

  //get waste norm by Id
  Future<List<AdminWasteNormModel>> getWasteNormById({required int wasteNormId}) async {
    return HelperService().fetchingData<AdminWasteNormModel>(
      endpoint: "admin/getWasteNormById",
      queryParameters: {'wasteNormId': wasteNormId},
      fromJson: (json) => AdminWasteNormModel.fromJson(json),
    );
  }

  //update waste norm
  Future<bool> updateWasteNorm({
    required int wasteNormId,
    required Map<String, dynamic> wasteNormUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/updateWasteNormById',
      queryParameters: {"wasteNormId": wasteNormId},
      dataUpdated: wasteNormUpdate,
    );
  }

  //delete waste norm
  Future<bool> deleteWasteNorm({required int wasteNormId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/deleteWasteNormById',
      queryParameters: {"wasteNormId": wasteNormId},
    );
  }

  //===============================WASTE NORM BOX====================================

  //get all waste box
  Future<List<AdminWasteBoxModel>> getAllWasteBox() async {
    return HelperService().fetchingData<AdminWasteBoxModel>(
      endpoint: 'admin/getAllWasteBox',
      queryParameters: const {},
      fromJson: (json) => AdminWasteBoxModel.fromJson(json),
    );
  }

  //get waste box by Id
  Future<List<AdminWasteBoxModel>> getWasteBoxById({required int wasteNormId}) async {
    return HelperService().fetchingData<AdminWasteBoxModel>(
      endpoint: "admin/getWasteBoxById",
      queryParameters: {'wasteNormId': wasteNormId},
      fromJson: (json) => AdminWasteBoxModel.fromJson(json),
    );
  }

  //update waste box
  Future<bool> updateWasteBoxById({
    required int wasteNormId,
    required Map<String, dynamic> wasteNormUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/updateWasteBoxById',
      queryParameters: {"wasteNormId": wasteNormId},
      dataUpdated: wasteNormUpdate,
    );
  }

  //delete waste box
  Future<bool> deleteWasteBoxById({required int wasteNormId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/deleteWasteBoxById',
      queryParameters: {"wasteNormId": wasteNormId},
    );
  }

  //==========================WAVE CREST COEFFICIENT====================================

  //get all wave crest
  Future<List<AdminWaveCrestModel>> getAllWaveCrest() async {
    return HelperService().fetchingData<AdminWaveCrestModel>(
      endpoint: 'admin/getAllWaveCrest',
      queryParameters: const {},
      fromJson: (json) => AdminWaveCrestModel.fromJson(json),
    );
  }

  //get wave crest by Id
  Future<List<AdminWaveCrestModel>> getWaveCrestById({required int waveCrestId}) async {
    return HelperService().fetchingData<AdminWaveCrestModel>(
      endpoint: "admin/getWaveCrestById",
      queryParameters: {'waveCrestId': waveCrestId},
      fromJson: (json) => AdminWaveCrestModel.fromJson(json),
    );
  }

  //update wave crest
  Future<bool> updateWaveCrest({
    required int waveCrestId,
    required Map<String, dynamic> waveCrestUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/updateWaveCrestById',
      queryParameters: {"waveCrestId": waveCrestId},
      dataUpdated: waveCrestUpdate,
    );
  }

  //delete wave crest
  Future<bool> deleteWaveCrest({required int waveCrestId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/deleteWaveCrestById',
      queryParameters: {"waveCrestId": waveCrestId},
    );
  }

  //==========================FLUTE RATIO====================================

  //get all flute ratio
  Future<List<AdminFluteRatioModel>> getAllFluteRatio() async {
    return HelperService().fetchingData<AdminFluteRatioModel>(
      endpoint: 'admin/getFluteRatio',
      queryParameters: const {},
      fromJson: (json) => AdminFluteRatioModel.fromJson(json),
    );
  }

  // add flute ratio
  Future<bool> addFluteRatio({required Map<String, dynamic> fluteRatioData}) async {
    return HelperService().addItem(endpoint: 'admin/createFluteRatio', itemData: fluteRatioData);
  }

  //update flute ratio
  Future<bool> updateFluteRatio({
    required int fluteRatioId,
    required Map<String, dynamic> fluteRatioUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/updateFluteRatio',
      queryParameters: {"fluteRatioId": fluteRatioId},
      dataUpdated: fluteRatioUpdate,
    );
  }

  //delete flute ratio
  Future<bool> deleteFluteRatio({required int fluteRatioId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/deleteFluteRatio',
      queryParameters: {"fluteRatioId": fluteRatioId},
    );
  }

  //==========================VEHICLE====================================

  //get all vehicle
  Future<List<AdminVehicleModel>> getAllVehicle() async {
    return HelperService().fetchingData<AdminVehicleModel>(
      endpoint: 'admin/getAllVehicle',
      queryParameters: const {},
      fromJson: (json) => AdminVehicleModel.fromJson(json),
    );
  }

  // add qc criteria
  Future<bool> addVehicle({required Map<String, dynamic> vehicleData}) async {
    return HelperService().addItem(endpoint: 'admin/newVehicle', itemData: vehicleData);
  }

  //update vehicle
  Future<bool> updateVehicle({
    required int vehicleId,
    required Map<String, dynamic> vehicleUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/updateVehicle',
      queryParameters: {"vehicleId": vehicleId},
      dataUpdated: vehicleUpdate,
    );
  }

  //delete vehicle
  Future<bool> deleteVehicle({required int vehicleId}) async {
    return HelperService().deleteItem(
      endpoint: 'admin/deleteVehicle',
      queryParameters: {"vehicleId": vehicleId},
    );
  }
}
