import 'package:dio/dio.dart';
import 'package:dongtam/constant/app_info.dart';
import 'package:dongtam/data/models/admin/admin_machine_box_model.dart';
import 'package:dongtam/data/models/admin/admin_machine_paper_model.dart';
import 'package:dongtam/data/models/admin/admin_waste_norm_model.dart';
import 'package:dongtam/data/models/admin/admin_waste_box_model.dart';
import 'package:dongtam/data/models/admin/admin_wave_crest_model.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/user/user_admin_model.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class AdminService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  //===============================ORDER====================================

  //get status order
  Future<List<Order>> getOrderByPendingStatus() async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      // AppLogger.i("Fetched ${data.length} orders");

      return data.map((e) => Order.fromJson(e)).toList();
    } catch (e, s) {
      AppLogger.e("Failed to load orders", error: e, stackTrace: s);
      throw Exception('Failed to load orders: $e');
    }
  }

  //update status order
  Future<bool> updateStatusOrder(
    String orderId,
    String newStatus,
    String rejectReason,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/admin/updateStatus?id=$orderId",
        data: {"newStatus": newStatus, "rejectReason": rejectReason},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      AppLogger.i("update $orderId successfully");
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

  //===============================MACHINE PAPER====================================

  //get all machine
  Future<List<AdminMachinePaperModel>> getAllMachinePaper() async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getAllMachinePaper',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      AppLogger.i("Get all machine paper");

      return data.map((e) => AdminMachinePaperModel.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("NO_PERMISSION");
      }
      rethrow;
    } catch (e, s) {
      AppLogger.e("Failed to load machine paper", error: e, stackTrace: s);
      throw Exception('Failed to load machine paper: $e');
    }
  }

  //get machine by Id
  Future<List<AdminMachinePaperModel>> getMachinePaperById(
    int machineId,
  ) async {
    return HelperService().fetchingData<AdminMachinePaperModel>(
      endpoint: "admin/getMachinePaperById",
      queryParameters: {'machineId': machineId},
      fromJson: (json) => AdminMachinePaperModel.fromJson(json),
    );
  }

  //update machine
  Future<bool> updateMachinePaper(
    int machineId,
    Map<String, dynamic> machineUpdate,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/admin/updateMachinePaper",
        queryParameters: {"machineId": machineId},
        data: machineUpdate,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      AppLogger.i("update machine=$machineId successfully");
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update machine paper", error: e, stackTrace: s);
      throw Exception('Failed to update machine paper: $e');
    }
  }

  //delete machine
  Future<bool> deleteMachinePaper(int machineId) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.delete(
        "/api/admin/deleteMachinePaper",
        queryParameters: {"machineId": machineId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      AppLogger.i("Delete machine=$machineId successfully");
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to delete machine paper", error: e, stackTrace: s);
      throw Exception('Failed to delete machine paper: $e');
    }
  }

  //===============================MACHINE BOX====================================

  //get all machine
  Future<List<AdminMachineBoxModel>> getAllMachineBox() async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getAllMachineBox',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      AppLogger.i("Get all machine box");

      return data.map((e) => AdminMachineBoxModel.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("NO_PERMISSION");
      }
      rethrow;
    } catch (e, s) {
      AppLogger.e("Failed to load machine box", error: e, stackTrace: s);
      throw Exception('Failed to load machine box: $e');
    }
  }

  //get machine by Id
  Future<List<AdminMachineBoxModel>> getMachineBoxById(int machineId) async {
    return HelperService().fetchingData<AdminMachineBoxModel>(
      endpoint: "admin/getMachineBoxById",
      queryParameters: {'machineId': machineId},
      fromJson: (json) => AdminMachineBoxModel.fromJson(json),
    );
  }

  //update machine
  Future<bool> updateMachineBox(
    int machineId,
    Map<String, dynamic> machineUpdate,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/admin/updateMachineBox",
        queryParameters: {"machineId": machineId},
        data: machineUpdate,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update machine box", error: e, stackTrace: s);
      throw Exception('Failed to update machine box: $e');
    }
  }

  //delete machine
  Future<bool> deleteMachineBox(int machineId) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.delete(
        "/api/admin/deleteMachineBox",
        queryParameters: {"machineId": machineId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to delete machine box", error: e, stackTrace: s);
      throw Exception('Failed to delete machine box: $e');
    }
  }

  //===============================USER====================================

  //get all users
  Future<List<UserAdminModel>> getAllUsers() async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getAllUsers',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final List<dynamic> data = response.data['data'];
      return data.map((e) => UserAdminModel.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("NO_PERMISSION");
      }
      rethrow;
    } catch (e, s) {
      AppLogger.e("Failed to get all user", error: e, stackTrace: s);
      throw Exception('Failed to load users: $e');
    }
  }

  //get user by name
  Future<List<UserAdminModel>> getUserByName(String name) async {
    return HelperService().fetchingData<UserAdminModel>(
      endpoint: "admin/getUserByName",
      queryParameters: {"name": name},
      fromJson: (json) => UserAdminModel.fromJson(json),
    );
  }

  //get user by phone
  Future<List<UserAdminModel>> getUserByPhone(String phone) async {
    return HelperService().fetchingData<UserAdminModel>(
      endpoint: "admin/getUserByPhone",
      queryParameters: {"phone": phone},
      fromJson: (json) => UserAdminModel.fromJson(json),
    );
  }

  //get user by permission
  Future<List<UserAdminModel>> getUserByPermission(
    List<String> permissions,
  ) async {
    return HelperService().fetchingData<UserAdminModel>(
      endpoint: "admin/getUserByPermission",
      queryParameters: {'permission': permissions},
      fromJson: (json) => UserAdminModel.fromJson(json),
    );
  }

  //update role
  Future<bool> updateUserRole(int userId, String newRole) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/admin/updateRole",
        queryParameters: {"userId": userId, "newRole": newRole},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update user:$userId", error: e, stackTrace: s);
      throw Exception('Failed to update user role: $e');
    }
  }

  //update permissions
  Future<bool> updateUserPermissions(
    int userId,
    List<String> permissions,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/admin/updatePermission",
        queryParameters: {"userId": userId},
        data: {"permissions": permissions},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update permissions", error: e, stackTrace: s);
      throw Exception('Failed to update user permissions: $e');
    }
  }

  //reset password
  Future<bool> resetUserPassword({
    required List<int> userIds,
    String newPassword = '12345678',
  }) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/admin/resetPassword",
        data: {"userIds": userIds, "newPassword": newPassword},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to reset password user", error: e, stackTrace: s);
      throw Exception('Failed to reset user password: $e');
    }
  }

  //delete user
  Future<bool> deleteUserById(int userId) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.delete(
        "/api/admin/deleteUser",
        queryParameters: {"userId": userId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update machine box", error: e, stackTrace: s);
      throw Exception('Failed to delete user: $e');
    }
  }

  //===============================WASTE NORM PAPER====================================

  //get all waste norm
  Future<List<AdminWasteNormModel>> getAllWasteNorm() async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getAllWasteNorm',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((e) => AdminWasteNormModel.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("NO_PERMISSION");
      }
      rethrow;
    } catch (e, s) {
      AppLogger.e("Failed to get all waste norm", error: e, stackTrace: s);
      throw Exception('Failed to get all waste norm: $e');
    }
  }

  //get waste norm by Id
  Future<List<AdminWasteNormModel>> getWasteNormById(int wasteNormId) async {
    return HelperService().fetchingData<AdminWasteNormModel>(
      endpoint: "admin/getWasteNormById",
      queryParameters: {'wasteNormId': wasteNormId},
      fromJson: (json) => AdminWasteNormModel.fromJson(json),
    );
  }

  //update waste norm
  Future<bool> updateWasteNorm(
    int wasteNormId,
    Map<String, dynamic> wasteNormUpdate,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/admin/updateWasteNormById",
        queryParameters: {"wasteNormId": wasteNormId},
        data: wasteNormUpdate,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update waste norm", error: e, stackTrace: s);
      throw Exception('Failed to update waste norm: $e');
    }
  }

  //delete waste norm
  Future<bool> deleteWasteNorm(int wasteNormId) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.delete(
        "/api/admin/deleteWasteNormById",
        queryParameters: {"wasteNormId": wasteNormId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to delete waste norm", error: e, stackTrace: s);
      throw Exception('Failed to delete waste norm: $e');
    }
  }

  //===============================WASTE NORM BOX====================================

  //get all waste box
  Future<List<AdminWasteBoxModel>> getAllWasteBox() async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getAllWasteBox',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((e) => AdminWasteBoxModel.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("NO_PERMISSION");
      }
      rethrow;
    } catch (e, s) {
      AppLogger.e("Failed to get all waste box", error: e, stackTrace: s);
      throw Exception('Failed to load all wasteBox: $e');
    }
  }

  //get waste box by Id
  Future<List<AdminWasteBoxModel>> getWasteBoxById(int wasteNormId) async {
    return HelperService().fetchingData<AdminWasteBoxModel>(
      endpoint: "admin/getWasteBoxById",
      queryParameters: {'wasteNormId': wasteNormId},
      fromJson: (json) => AdminWasteBoxModel.fromJson(json),
    );
  }

  //update waste box
  Future<bool> updateWasteBoxById(
    int wasteNormId,
    Map<String, dynamic> wasteNormUpdate,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/admin/updateWasteBoxById",
        queryParameters: {"wasteNormId": wasteNormId},
        data: wasteNormUpdate,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update waste box", error: e, stackTrace: s);
      throw Exception('Failed to update waste box: $e');
    }
  }

  //delete waste box
  Future<bool> deleteWasteBoxById(int wasteNormId) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.delete(
        "/api/admin/deleteWasteBoxById",
        queryParameters: {"wasteNormId": wasteNormId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to delete waste box", error: e, stackTrace: s);
      throw Exception('Failed to delete waste box: $e');
    }
  }

  //==========================WAVE CREST COEFFICIENT====================================

  //get all wave crest
  Future<List<AdminWaveCrestModel>> getAllWaveCrest() async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getAllWaveCrest',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((e) => AdminWaveCrestModel.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("NO_PERMISSION");
      }
      rethrow;
    } catch (e, s) {
      AppLogger.e("Failed to get all waste crest", error: e, stackTrace: s);
      throw Exception('Failed to load waste crest: $e');
    }
  }

  //get wave crest by Id
  Future<List<AdminWaveCrestModel>> getWaveCrestById(int waveCrestId) async {
    return HelperService().fetchingData<AdminWaveCrestModel>(
      endpoint: "admin/getWaveCrestById",
      queryParameters: {'waveCrestId': waveCrestId},
      fromJson: (json) => AdminWaveCrestModel.fromJson(json),
    );
  }

  //update wave crest
  Future<bool> updateWaveCrest(
    int waveCrestId,
    Map<String, dynamic> waveCrestUpdate,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/admin/updateWaveCrestById",
        queryParameters: {"waveCrestId": waveCrestId},
        data: waveCrestUpdate,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update waste crest", error: e, stackTrace: s);
      throw Exception('Failed to update waste crest: $e');
    }
  }

  //delete wave crest
  Future<bool> deleteWaveCrest(int waveCrestId) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.delete(
        "/api/admin/deleteWaveCrestById",
        queryParameters: {"waveCrestId": waveCrestId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to load waste crest", error: e, stackTrace: s);
      throw Exception('Failed to delete waste crest: $e');
    }
  }
}
