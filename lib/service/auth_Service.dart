import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:dongtam/constant/app_info.dart';
import 'package:get/get.dart';

class AuthService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
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
      await dioService.post(
        "/auth/register",
        data: {
          "fullName": fullName,
          "email": email,
          "password": password,
          "confirmPW": confirmPW,
          "otpInput": otp,
        },
      );

      AppLogger.i("Register successful for email=$email");
      return true;
    } catch (e, s) {
      AppLogger.e("error register", error: e, stackTrace: s);
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

        AppLogger.i("Login successful, role: $role, permission: $permissions");

        return true;
      } else {
        AppLogger.w(
          "Login failed for email=$email, status=${response.statusCode}",
        );
        return false;
      }
    } catch (e, s) {
      AppLogger.e("Lỗi khi tải đăng nhập", error: e, stackTrace: s);
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
        AppLogger.i("OTP sent successfully to $email");
        return true;
      } else {
        AppLogger.w("Failed to send OTP for $email");
        return false;
      }
    } catch (e, s) {
      AppLogger.e("Lỗi khi gửi otp", error: e, stackTrace: s);
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

      AppLogger.i(
        "Verify OTP result: ${response.statusCode == 201 ? "success" : "failed"}",
      );
      return response.statusCode == 201;
    } catch (e, s) {
      AppLogger.e("Lỗi khi xác thực otp", error: e, stackTrace: s);
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

      AppLogger.i("Password changed successfully for email=$email");
      return response.statusCode == 201;
    } catch (e, s) {
      AppLogger.e("Lỗi khi thay đổi password", error: e, stackTrace: s);
      return false;
    }
  }
}
