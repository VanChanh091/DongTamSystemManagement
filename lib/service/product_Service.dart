import 'dart:typed_data';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:dongtam/constant/app_info.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'dart:convert';

class ProductService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  // get all
  Future<Map<String, dynamic>> getAllProducts({
    bool refresh = false,
    bool noPaging = false,
    int? page,
    int? pageSize,
  }) async {
    return HelperService().fetchPaginatedData<Product>(
      endpoint: "product",
      queryParameters: {
        'refresh': refresh,
        'noPaging': noPaging,
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) => Product.fromJson(json),
      dataKey: 'products',
    );
  }

  //get by id
  Future<Map<String, dynamic>> getProductById({
    required String productId,
    int page = 1,
    int pageSize = 25,
  }) async {
    return HelperService().fetchPaginatedData<Product>(
      endpoint: "product/byProductId",
      queryParameters: {
        'productId': productId,
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) => Product.fromJson(json),
      dataKey: 'products',
    );
  }

  //get by name
  Future<Map<String, dynamic>> getProductByName({
    required String productName,
    int page = 1,
    int pageSize = 25,
  }) async {
    return HelperService().fetchPaginatedData<Product>(
      endpoint: "product/byName",
      queryParameters: {
        'productName': productName,
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) => Product.fromJson(json),
      dataKey: 'products',
    );
  }

  //add product
  Future<bool> addProduct(
    String prefix,
    Map<String, dynamic> product, {
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
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception("productId existed");
      }
      rethrow;
    } catch (e, s) {
      AppLogger.e("Failed to add product", error: e, stackTrace: s);
      throw Exception('Failed to add product: $e');
    }
  }

  //update product
  Future<bool> updateProductById(
    String productId,
    Map<String, dynamic> productUpdated, {
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
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update product", error: e, stackTrace: s);
      throw Exception('Failed to update product: $e');
    }
  }

  //delete product
  Future<bool> deleteProduct(String productId) async {
    try {
      final token = await SecureStorageService().getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      await dioService.delete(
        '/api/product/$productId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to delete product", error: e, stackTrace: s);
      throw Exception('Failed to delete product: $e');
    }
  }
}
