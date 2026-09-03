import 'package:dio/dio.dart';
import 'package:dongtam/data/models/admin/paperCode/paper_basis_weight_model.dart';
import 'package:dongtam/data/models/admin/paperCode/paper_classification_model.dart';
import 'package:dongtam/data/models/admin/paperCode/paper_type_model.dart';
import 'package:dongtam/data/models/admin/paperCode/supplier_model.dart';
import 'package:dongtam/data/models/admin/paperCode/supplier_paper_code_model.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';

class AdminPaperCodeService {
  final Dio dioService = DioClient().dio;

  //================================ SUPPLIER ========================================
  Future<List<SupplierModel>> getAllSuppliers() async {
    return HelperService().fetchingData<SupplierModel>(
      endpoint: 'admin/suppliers',
      fromJson: (json) => SupplierModel.fromJson(json),
    );
  }

  Future<bool> createSupplier({required Map<String, dynamic> supplierData}) async {
    return HelperService().addItem(endpoint: 'admin/suppliers', body: supplierData);
  }

  Future<bool> handleUpdateSupplier({
    required int supplierId,
    required String action,
    Map<String, dynamic>? supplierUpdate,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/suppliers',
      queryParameters: {"supplierId": supplierId, "action": action},
      body: {if (supplierUpdate != null) ...supplierUpdate},
    );
  }

  //=============================== PAPER TYPE ======================================

  Future<List<PaperTypeModel>> getAllPaperTypes() async {
    return HelperService().fetchingData<PaperTypeModel>(
      endpoint: 'admin/paper-types',
      fromJson: (json) => PaperTypeModel.fromJson(json),
    );
  }

  Future<bool> createPaperType({required Map<String, dynamic> paperTypeData}) async {
    return HelperService().addItem(endpoint: 'admin/paper-types', body: paperTypeData);
  }

  Future<bool> updatePaperType({
    required int paperTypeId,
    required Map<String, dynamic> paperTypeData,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/paper-types',
      queryParameters: {"paperTypeId": paperTypeId},
      body: paperTypeData,
    );
  }

  //=========================== PAPER BASIS WEIGHT ==================================

  Future<List<PaperBasisWeightModel>> getAllBasisWeights() async {
    return HelperService().fetchingData<PaperBasisWeightModel>(
      endpoint: 'admin/paper-basis-weights',
      fromJson: (json) => PaperBasisWeightModel.fromJson(json),
    );
  }

  Future<bool> createBasisWeight({required Map<String, dynamic> basisWeightData}) async {
    return HelperService().addItem(endpoint: 'admin/paper-basis-weights', body: basisWeightData);
  }

  Future<bool> updateBasisWeight({
    required int basisWeightId,
    required Map<String, dynamic> basisWeightData,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/paper-basis-weights',
      queryParameters: {"basisWeightId": basisWeightId},
      body: basisWeightData,
    );
  }

  //=========================== SUPPLIER PAPER CODE =================================

  Future<List<SupplierPaperCodeModel>> getAllSupplierPaperCodes() async {
    return HelperService().fetchingData<SupplierPaperCodeModel>(
      endpoint: 'admin/supplier-paper-codes',
      fromJson: (json) => SupplierPaperCodeModel.fromJson(json),
    );
  }

  Future<bool> createSupplierPaperCode({
    required List<Map<String, dynamic>> supplierPaperCodeData,
  }) async {
    return HelperService().addItem(
      endpoint: 'admin/supplier-paper-codes',
      body: supplierPaperCodeData,
    );
  }

  Future<bool> updateSupplierPaperCode({
    required List<Map<String, dynamic>> supplierPaperCodeData,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/supplier-paper-codes',
      body: supplierPaperCodeData,
    );
  }

  //============================PAPER CLASSIFICATION ================================

  Future<Map<String, dynamic>> getAllPaperClassifications({
    required int page,
    required int pageSize,
  }) async {
    return HelperService().fetchPaginatedData<PaperClassificationModel>(
      endpoint: 'admin/paper-classifications',
      queryParameters: {"page": page, "pageSize": pageSize},
      fromJson: (json) => PaperClassificationModel.fromJson(json),
      dataKey: 'classifications',
    );
  }

  Future<bool> createPaperClassification({
    required List<Map<String, dynamic>> paperClassificationData,
  }) async {
    return HelperService().addItem(
      endpoint: 'admin/paper-classifications',
      body: paperClassificationData,
    );
  }

  Future<bool> updatePaperClassification({
    required List<Map<String, dynamic>> paperClassificationData,
  }) async {
    return HelperService().updateItem(
      endpoint: 'admin/paper-classifications',
      body: paperClassificationData,
    );
  }
}
