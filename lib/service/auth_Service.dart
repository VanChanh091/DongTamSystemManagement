import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: "http://localhost:5000",
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  final FlutterSecureStorage storage = FlutterSecureStorage(); //save token

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
        await storage.write(key: 'token', value: token);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error login: $e");
      return false;
    }
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
        "/auth/verifyOtpCode",
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
      final token = await storage.read(key: 'token');
      final response = await dioService.post(
        "/auth/changePassword",
        data: {
          "email": email,
          "newPassword": newPassword,
          "confirmNewPW": confirmNewPW,
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error change password: $e");
      return false;
    }
  }
}
