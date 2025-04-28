import 'package:dio/dio.dart';
import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/utils/secure_storage_service.dart';

class ProductService {
  final Dio dioService = Dio(
    BaseOptions(
      baseUrl: AppInfo.BASE_URL,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  // get all
  Future<List<Product>> getAllProducts() async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.get(
        "/api/product/",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
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
      return productsData
          .map((json) => Product.fromJson(json))
          .where(
            (product) => product.productId.toLowerCase().contains(
              productId.toLowerCase(),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get productId: $e');
    }
  }

  //get by name
  Future<List<Product>> getProductByName(String productName) async {
    try {
      final token = await SecureStorageService().getToken();

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
      return productsData
          .map((json) => Product.fromJson(json))
          .where(
            (product) => product.productName.toLowerCase().contains(
              productName.toLowerCase(),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get productId: $e');
    }
  }

  //add product
  Future<bool> addProduct(Map<String, dynamic> product) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        '/api/product/',
        data: product,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
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
    Map<String, dynamic> productUpdated,
  ) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.put(
        '/api/product/updateProduct',
        queryParameters: {'id': productId},
        data: productUpdated,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
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
