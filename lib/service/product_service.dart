import 'dart:io';
import 'dart:typed_data';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'dart:convert';

class ProductService {
  final Dio dioService = DioClient().dio;

  // get all
  Future<Map<String, dynamic>> getAllProducts({
    bool noPaging = false,
    int? page,
    int? pageSize,
  }) async {
    return HelperService().fetchPaginatedData<Product>(
      endpoint: "product",
      queryParameters: {'noPaging': noPaging, 'page': page, 'pageSize': pageSize},
      fromJson: (json) => Product.fromJson(json),
      dataKey: 'products',
    );
  }

  //get product by field
  Future<Map<String, dynamic>> getProductByField({
    required String field,
    required String keyword,
    int page = 1,
    int pageSize = 25,
  }) async {
    return HelperService().fetchPaginatedData<Product>(
      endpoint: "product/filter",
      queryParameters: {'field': field, 'keyword': keyword, 'page': page, 'pageSize': pageSize},
      fromJson: (json) => Product.fromJson(json),
      dataKey: 'products',
    );
  }

  //add product
  Future<bool> addProduct({
    required String prefix,
    required Map<String, dynamic> product,
    Uint8List? imageBytes,
  }) async {
    try {
      final token = await SecureStorageService().getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final formData = FormData.fromMap({
        'prefix': prefix,
        'product': jsonEncode(product),
        if (imageBytes != null)
          'productImage': MultipartFile.fromBytes(
            imageBytes,
            filename: 'product.webp',
            contentType: MediaType('image', 'webp'),
          ),
      });

      await dioService.post(
        '/api/product/',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'multipart/form-data'},
        ),
      );

      return true;
    } on DioException catch (e) {
      HelperService().handleDioException(e, "Lỗi khi thêm dữ liệu");
      return false;
    } catch (e, s) {
      AppLogger.e("Failed to add product", error: e, stackTrace: s);
      throw Exception('Failed to add product: $e');
    }
  }

  //update product
  Future<bool> updateProductById({
    required String productId,
    required Map<String, dynamic> productUpdated,
    Uint8List? imageBytes,
  }) async {
    try {
      final token = await SecureStorageService().getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      FormData formData = FormData.fromMap({
        ...productUpdated,
        if (imageBytes != null)
          'productImage': MultipartFile.fromBytes(
            imageBytes,
            filename: 'product.webp',
            contentType: MediaType('image', 'webp'),
          ),
      });

      await dioService.put(
        '/api/product/updateProduct',
        queryParameters: {'id': productId},
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'multipart/form-data'},
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update product", error: e, stackTrace: s);
      throw Exception('Failed to update product: $e');
    }
  }

  //delete product
  Future<bool> deleteProduct({required String productId}) async {
    return HelperService().deleteItem(endpoint: "product/$productId", queryParameters: const {});
  }

  //export product
  Future<File?> exportExcelProduct({String? typeProduct, bool all = false}) async {
    try {
      final token = await SecureStorageService().getToken();

      final Map<String, dynamic> body = {"all": all};

      if (typeProduct != null) {
        body["typeProduct"] = typeProduct;
      }

      final response = await dioService.post(
        "/api/product/exportExcel",
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        final bytes = response.data as List<int>;
        AppLogger.d("Received ${bytes.length} bytes from API");

        // Cho người dùng chọn thư mục lưu
        final dirPath = await FilePicker.platform.getDirectoryPath();
        if (dirPath == null) {
          return null;
        }

        final now = DateTime.now();
        final fileName = "product_${now.toIso8601String().split('T')[0]}.xlsx";
        final file = File("$dirPath/$fileName");

        await file.writeAsBytes(bytes, flush: true);
        AppLogger.i("Exported Excel product to: ${file.path}");

        return file;
      } else {
        AppLogger.w("Export failed with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("failed to export product", error: e, stackTrace: s);
      return null;
    }
  }
}
