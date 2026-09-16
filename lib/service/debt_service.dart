import "dart:io";

import "package:dio/dio.dart";
import "package:dongtam/data/models/warehouse/payment/customer_debt_summary_model.dart";
import "package:dongtam/utils/handleError/dio_client.dart";
import "package:dongtam/utils/helper/helper_service.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/storage/secure_storage_service.dart";
import "package:intl/intl.dart";

class DebtService {
  final Dio dioService = DioClient().dio;

  //===============================CLOSING DEBT====================================
  Future<Map<String, dynamic>> getCustomerDebtSummary({
    required int page,
    required int pageSize,
    required DateTime targetDate,
    String? customerId,
    String? userId,
    String? search,
  }) async {
    return HelperService().fetchPaginatedData<CustomerDebtItemModel>(
      endpoint: "debts/closing-debt",
      queryParameters: {
        "page": page,
        "pageSize": pageSize,
        "targetDate": DateFormat("yyyy-MM-dd").format(targetDate),
        if (customerId != null) "customerId": customerId,
        if (userId != null) "userId": userId,
        if (search != null) "search": search,
      },
      fromJson: (json) => CustomerDebtItemModel.fromJson(json),
      dataKey: "debts",
    );
  }

  Future<bool> handleClosingDebt({
    required DateTime targetDate,
    required bool isAuto,
    String? customerId,
  }) async {
    return await HelperService().addItem(
      endpoint: "debts/closing-debt",
      body: {
        "customerId": customerId,
        "targetDate": DateFormat("yyyy-MM-dd").format(targetDate),
        "isAuto": isAuto,
      },
    );
  }

  // Export debt customer
  Future<File?> exportDebtCustomer({required DateTime targetDate}) async {
    try {
      final token = await SecureStorageService().getToken();

      final response = await dioService.post(
        "/api/debts/closing-debt/export",
        queryParameters: {"targetDate": DateFormat("yyyy-MM-dd").format(targetDate)},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return await HelperService().saveExcelFile(
          bytes: response.data as List<int>,
          fileNamePrefix: "debt_customer_",
          dateTime: targetDate,
        );
      } else {
        AppLogger.w("Export failed with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("Failed to export debt customer", error: e, stackTrace: s);
      return null;
    }
  }

  //=================================PAYMENT=======================================

  Future<bool> paymentDebtByCustomerId({
    required String customerId,
    required double amount,
    required List<String> outboundSlipCodes,
  }) async {
    return await HelperService().addItem(
      endpoint: "debts/payment",
      body: {"customerId": customerId, "amount": amount, "outboundSlipCodes": outboundSlipCodes},
    );
  }

  Future<bool> importAmountPayment(String filePath) async {
    return await HelperService().importFile(endpoint: "debts/payment/import", filePath: filePath);
  }

  Future<bool> writeOffDebt({required String outboundSlipCode}) async {
    return await HelperService().updateItem(
      endpoint: "debts/payment",
      queryParameters: {"outboundSlipCode": outboundSlipCode},
    );
  }
}
