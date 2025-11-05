import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:get/get.dart';

class AuthService {
  final Dio dioService = DioClient().dio;

  //jwt
  final SecureStorageService secureStorage = SecureStorageService();

  //register
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPW,
    required String otp,
  }) async {
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
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg = e.response?.data?['message'] ?? 'Unknown error';

        // Chuyển lỗi lên submit() để xử lý theo mã lỗi
        throw Exception(errorMsg);
      } else {
        throw Exception("Network Error: ${e.message}");
      }
    } catch (e, s) {
      AppLogger.e("error register", error: e, stackTrace: s);
      throw Exception('Failed to register: $e');
    }
  }

  //login
  Future<bool> login({required String email, required String password}) async {
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
        AppLogger.w("Login failed for email=$email, status=${response.statusCode}");
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
  Future<bool> sendOTP({required String email}) async {
    try {
      final response = await dioService.post("/auth/getOtpCode", data: {"email": email});

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
  Future<bool> verifyOTPChangePassword({required String email, required String otp}) async {
    try {
      final response = await dioService.post(
        "/auth/verifyOTPChangePassword",
        data: {"email": email, "otpInput": otp},
      );

      AppLogger.i("Verify OTP result: ${response.statusCode == 201 ? "success" : "failed"}");
      return response.statusCode == 201;
    } catch (e, s) {
      AppLogger.e("Lỗi khi xác thực otp", error: e, stackTrace: s);
      return false;
    }
  }

  //change password
  Future<bool> changePassword({
    required String email,
    required String newPassword,
    required String confirmNewPW,
  }) async {
    try {
      final token = await secureStorage.getToken();
      final response = await dioService.post(
        "/auth/changePassword",
        data: {"email": email, "newPassword": newPassword, "confirmNewPW": confirmNewPW},
        options: Options(
          headers: {"Authorization": "Bearer $token", 'Content-Type': 'application/json'},
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
