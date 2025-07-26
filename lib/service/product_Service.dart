import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
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
  Future<List<Product>> getAllProducts(bool refresh) async {
    try {
      final token = await SecureStorageService().getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await dioService.get(
        "/api/product/",
        queryParameters: {'refresh': refresh},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'User-Agent': 'Mozilla/5.0',
          },
        ),
      );

      final data = response.data['data'] as List;

      return data.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  //get by id
  Future<List<Product>> getProductById(String productId) async {
    try {
      final token = await SecureStorageService().getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await dioService.get(
        '/api/product/productId',
        queryParameters: {"id": productId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final List<dynamic> productsData = response.data['data'];
      return productsData.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get productId: $e');
    }
  }

  //get by name
  Future<List<Product>> getProductByName(String productName) async {
    try {
      final token = await SecureStorageService().getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await dioService.get(
        '/api/product/productName',
        queryParameters: {'name': productName},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final List<dynamic> productsData = response.data['data'];
      return productsData.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get productId: $e');
    }
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
}
