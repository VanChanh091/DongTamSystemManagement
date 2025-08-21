import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dongtam/data/controller/userController.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:get/get.dart';

class AuthService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  //jwt
  final SecureStorageService secureStorage = SecureStorageService();

  //register
  Future<bool> register(
    String fullName,
    String email,
    String password,
    String confirmPW,
    String otp,
  ) async {
    try {
      final response = await dioService.post(
        "/auth/register",
        data: {
          "fullName": fullName,
          "email": email,
          "password": password,
          "confirmPW": confirmPW,
          "otpInput": otp,
        },
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error register: $e");
      return false;
    }
  }

  //login
  Future<bool> login(String email, String password) async {
    try {
      final response = await dioService.post(
        "/auth/login",
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 201) {
        String token = response.data['token'];

        //get user object
        final user = response.data['user'] as Map<String, dynamic>;
        String role = user['role'];
        List<String> permissions = List<String>.from(user['permissions']);

        await secureStorage.saveToken(token);
        await secureStorage.saveRole(role);
        await secureStorage.savePermission(jsonEncode(permissions));

        final userController = Get.find<UserController>();
        userController.role.value = role;
        userController.permissions.value = permissions;

        print("Login successful, role: $role");
        print("Login successful, permission: $permissions");

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error login: $e");
      return false;
    }
  }

  Future<bool> checkLoginStatus() async {
    String? token = await secureStorage.getToken();
    return token != null;
  }

  //logout
  Future<void> logout() async {
    await secureStorage.deleteToken();
  }

  //get otp
  Future<bool> sendOTP(String email) async {
    try {
      final response = await dioService.post(
        "/auth/getOtpCode",
        data: {"email": email},
      );

      if (response.statusCode == 201) {
        response.data['otp'];
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error send otp: $e");
      return false;
    }
  }

  //verify otp
  Future<bool> verifyOTPChangePassword(String email, String otp) async {
    try {
      final response = await dioService.post(
        "/auth/verifyOTPChangePassword",
        data: {"email": email, "otpInput": otp},
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error verify otp: $e");
      return false;
    }
  }

  //change password
  Future<bool> changePassword(
    String email,
    String newPassword,
    String confirmNewPW,
  ) async {
    try {
      final token = await secureStorage.getToken();
      final response = await dioService.post(
        "/auth/changePassword",
        data: {
          "email": email,
          "newPassword": newPassword,
          "confirmNewPW": confirmNewPW,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error change password: $e");
      return false;
    }
  }
}
