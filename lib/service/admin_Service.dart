import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/admin/admin_machinePaper_model.dart';
import 'package:dongtam/data/models/admin/admin_paperFactor_model.dart';
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

  //===============================PAPER FACTOR====================================

  //get paper factor
  Future<List<AdminPaperFactorModel>> getPaperFactor() async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getAllPF',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data.map((e) => AdminPaperFactorModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load paper factors: $e');
    }
  }

  //add paper factor
  Future<bool> addPaperFactor(Map<String, dynamic> paperFactor) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        "/api/admin/addPF",
        data: paperFactor,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e) {
      throw Exception('Failed to add paper factor: $e');
    }
  }

  //update paper factor
  Future<bool> updatePaperFactor(
    int id,
    Map<String, dynamic> paperFactorUpdated,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/admin/updatePF",
        queryParameters: {"id": id},
        data: paperFactorUpdated,
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

  //delete paper factor
  Future<bool> deletePaperFactor(int paperFactorId) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.delete(
        "/api/admin/deletePF",
        queryParameters: {"id": paperFactorId},
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

  //===============================Machine====================================

  //get all machine
  Future<List<AdminMachinePaperModel>> getAllMachine() async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getAllMachine',
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
  Future<List<AdminMachinePaperModel>> getMachineById(int machineId) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        '/api/admin/getMachineById',
        queryParameters: {'machineId': machineId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data['data'] as List;
      return data
          .map((json) => AdminMachinePaperModel.fromJson(json))
          .where((machine) => machine.machineId == machineId)
          .toList();
    } catch (e) {
      throw Exception('Failed to load paper factors: $e');
    }
  }

  //add machine
  Future<bool> addMachine(Map<String, dynamic> machine) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        "/api/admin/createMachine",
        data: machine,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e) {
      throw Exception('Failed to add paper factor: $e');
    }
  }

  //update machine
  Future<bool> updateMachine(
    int machineId,
    Map<String, dynamic> machineUpdate,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        "/api/admin/updateMachineById",
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
  Future<bool> deleteMachine(int machineId) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.delete(
        "/api/admin/deleteMachineById",
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
      return data
          .map((json) => UserAdminModel.fromJson(json))
          .where(
            (user) => user.fullName.toLowerCase().contains(name.toLowerCase()),
          )
          .toList();
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
      return data
          .map((json) => UserAdminModel.fromJson(json))
          .where(
            (user) => user.phone!.toLowerCase().contains(phone.toLowerCase()),
          )
          .toList();
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
}
