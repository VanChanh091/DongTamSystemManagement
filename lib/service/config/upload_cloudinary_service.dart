import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:image/image.dart' as img;

class UploadCloudinaryService {
  final Dio dioService = DioClient().dio;

  //jwt
  final SecureStorageService secureStorage = SecureStorageService();

  Future<Map<String, dynamic>?> uploadToCloudinary({
    required List<int> imageBytes,
    required Function(double) onProgress,
  }) async {
    try {
      // --- BƯỚC 1: nén và convert ảnh sang webp ---
      AppLogger.i("Dung lượng gốc: ${(imageBytes.length / 1024).toStringAsFixed(2)} KB");

      img.Image? decodedImage = img.decodeImage(Uint8List.fromList(imageBytes));

      if (decodedImage == null) {
        AppLogger.e("Không thể giải mã ảnh");
        return null;
      }

      final Uint8List compressedBytes = Uint8List.fromList(
        img.encodeJpg(decodedImage, quality: 80),
      );

      AppLogger.i(
        "Dung lượng sau nén (JPG 80%): ${(compressedBytes.length / 1024).toStringAsFixed(2)} KB",
      );

      // --- BƯỚC 2: lấy signature cloudinary ---
      final token = await SecureStorageService().getToken();
      final sigRes = await dioService.get(
        "/api/order/get-signature",
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );
      final sigData = sigRes.data;

      // BƯỚC 3: Upload lên Cloudinary (KHÔNG DÙNG JWT)
      final Dio cloudinaryDio = Dio();

      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(compressedBytes, filename: "order_image.jpg"),
        "api_key": sigData['apiKey'],
        "timestamp": sigData['timestamp'],
        "signature": sigData['signature'],
        "folder": sigData['folder'],
      });

      final String cloudName = sigData['cloudName'];
      final String uploadUrl = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

      final response = await cloudinaryDio.post(
        uploadUrl,
        data: formData,
        onSendProgress: (sent, total) {
          onProgress(sent / total);
        },
      );

      return {"imageUrl": response.data['secure_url'], "publicId": response.data['public_id']};
    } catch (e) {
      if (e is DioException) {
        AppLogger.e("Lỗi Cloudinary: ${e.response?.data}");
      }
      AppLogger.e("Upload error: $e");
      return null;
    }
  }
}
