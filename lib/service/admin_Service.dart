import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/admin/admin_machineBox_model.dart';
import 'package:dongtam/data/models/admin/admin_machinePaper_model.dart';
import 'package:dongtam/data/models/admin/admin_wasteNorm_model.dart';
import 'package:dongtam/data/models/admin/admin_waste_box_model.dart';
import 'package:dongtam/data/models/admin/admin_waveCrest_model.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/user/user_admin_model.dart';
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
  Future<List<Order>> getOrderByStatus() async {
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

      return data.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
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
      return true;
    } catch (e) {
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
      return data.map((e) => AdminMachinePaperModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load paper factors: $e');
    }
  }

  //get machine by Id
  Future<List<AdminMachinePaperModel>> getMachinePaperById(
    int machineId,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getMachinePaperById',
        queryParameters: {'machineId': machineId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((json) => AdminMachinePaperModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load paper factors: $e');
    }
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
      return true;
    } catch (e) {
      throw Exception('Failed to update paper factor: $e');
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
      return true;
    } catch (e) {
      throw Exception('Failed to delete paper factor: $e');
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
      return data.map((e) => AdminMachineBoxModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load paper factors: $e');
    }
  }

  //get machine by Id
  Future<List<AdminMachineBoxModel>> getMachineBoxById(int machineId) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getMachineBoxById',
        queryParameters: {'machineId': machineId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((json) => AdminMachineBoxModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load paper factors: $e');
    }
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
    } catch (e) {
      throw Exception('Failed to update paper factor: $e');
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
    } catch (e) {
      throw Exception('Failed to delete paper factor: $e');
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
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  //get user by name
  Future<List<UserAdminModel>> getUserByName(String name) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getUserByName',
        queryParameters: {"name": name},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => UserAdminModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get user by name: $e');
    }
  }

  //get user by phone
  Future<List<UserAdminModel>> getUserByPhone(String phone) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getUserByPhone',
        queryParameters: {"phone": phone},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => UserAdminModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get user by name: $e');
    }
  }

  //get user by permission
  Future<List<UserAdminModel>> getUserByPermission(
    List<String> permissions,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getUserByPermission',
        queryParameters: {'permission': permissions},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> data = response.data['data'];

      return data.map((json) => UserAdminModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get users by permission: $e');
    }
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
    } catch (e) {
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
    } catch (e) {
      throw Exception('Failed to update user permissions: $e');
    }
  }

  //reset password
  Future<bool> resetUserPassword(List<int> userIds, String newPassword) async {
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
      throw Exception('Failed to load paper factors: $e');
    }
  }

  //get waste norm by Id
  Future<List<AdminWasteNormModel>> getWasteNormById(int wasteNormId) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getWasteNormById',
        queryParameters: {'wasteNormId': wasteNormId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((json) => AdminWasteNormModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load paper factors: $e');
    }
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
    } catch (e) {
      throw Exception('Failed to update paper factor: $e');
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
    } catch (e) {
      throw Exception('Failed to delete paper factor: $e');
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
    } catch (e) {
      throw Exception('Failed to load paper factors: $e');
    }
  }

  //get waste box by Id
  Future<List<AdminWasteBoxModel>> getWasteBoxById(int wasteNormId) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getWasteBoxById',
        queryParameters: {'wasteNormId': wasteNormId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((json) => AdminWasteBoxModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load paper factors: $e');
    }
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
    } catch (e) {
      throw Exception('Failed to update paper factor: $e');
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
    } catch (e) {
      throw Exception('Failed to delete paper factor: $e');
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
    } catch (e) {
      throw Exception('Failed to load paper factors: $e');
    }
  }

  //get wave crest by Id
  Future<List<AdminWaveCrestModel>> getWaveCrestById(int waveCrestId) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getWaveCrestById',
        queryParameters: {'waveCrestId': waveCrestId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((json) => AdminWaveCrestModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load paper factors: $e');
    }
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
    } catch (e) {
      throw Exception('Failed to update paper factor: $e');
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
    } catch (e) {
      throw Exception('Failed to delete paper factor: $e');
    }
  }
}
