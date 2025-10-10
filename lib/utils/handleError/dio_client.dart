import 'package:dio/dio.dart';
import 'package:dongtam/constant/app_info.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:get/get.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late Dio dio;

  final SecureStorageService _storage = SecureStorageService();

  Future<void> init() async {
    final token = await _storage.getToken();

    print("init dio client");

    dio = Dio(
      BaseOptions(
        baseUrl: AppInfo.BASE_URL,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          print('⚠️ Dio error caught!');
          print('🔸 StatusCode: ${e.response?.statusCode}');
          print('🔸 Response: ${e.response?.data}');

          if (e.response?.statusCode == 401) {
            final message = e.response?.data?['message'] ?? "";
            print(message);
            if (message.toString().toLowerCase().contains('expired')) {
              print("🚨 TOKEN EXPIRED");
              AppLogger.w(
                "🔁 Token expired — clearing storage and redirecting to login",
              );

              //token het han -> login
              await _storage.clearAll();
              Get.offAllNamed('/login');
              return;
            }
          }

          // Nếu lỗi khác thì cho đi tiếp
          return handler.next(e);
        },
      ),
    );
  }
}
