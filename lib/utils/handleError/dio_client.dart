import "package:dio/dio.dart";
import "package:dongtam/constant/app_info.dart";
import "package:dongtam/presentation/screens/auth/login.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/storage/secure_storage_service.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:page_transition/page_transition.dart";

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late Dio dio;
  final SecureStorageService _storage = SecureStorageService();
  bool _isShowingDialog = false;

  Future<void> init() async {
    final token = await _storage.getToken();

    dio = Dio(
      BaseOptions(
        baseUrl: AppInfo.BASE_URL,
        headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Mỗi khi có request, tự động lấy token mới nhất
          final token = await _storage.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final message = e.response?.data?["message"] ?? "";

            if (message.toString().toLowerCase().contains("expired")) {
              AppLogger.w("🔁 Token expired — clearing storage and redirecting to login");

              if (!_isShowingDialog) {
                _isShowingDialog = true;
                Get.dialog(
                  AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Center(
                      child: Text(
                        "Phiên đăng nhập đã hết hạn",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    content: const Text(
                      "Vui lòng đăng nhập lại để tiếp tục sử dụng ứng dụng.",
                      style: TextStyle(fontSize: 16),
                    ),
                    actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          _isShowingDialog = false;
                          Get.back(); //đóng dialog và back
                          await _storage.clearAll();
                          Navigator.pushAndRemoveUntil(
                            Get.context!,
                            PageTransition(
                              type: PageTransitionType.fade,
                              duration: const Duration(milliseconds: 500),
                              child: LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff78D761),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          "Đăng nhập lại",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  barrierDismissible: false, //không cho đóng dialog
                );
              }

              return handler.next(e);
            }
          }

          // Nếu lỗi khác thì cho đi tiếp
          return handler.next(e);
        },
      ),
    );
  }
}
