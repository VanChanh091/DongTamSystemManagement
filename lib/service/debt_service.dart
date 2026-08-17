import "package:dongtam/data/models/warehouse/payment/customer_debt_summary_model.dart";
import "package:dongtam/utils/helper/helper_service.dart";
import "package:intl/intl.dart";

class DebtService {
  //===============================CLOSING DEBT====================================
  Future<Map<String, dynamic>> getCustomerDebtSummary({
    required int page,
    required int pageSize,
    String? customerId,
    String? userId,
  }) async {
    return HelperService().fetchPaginatedData<CustomerDebtItemModel>(
      endpoint: "debts/closing-debt",
      queryParameters: {
        "page": page,
        "pageSize": pageSize,
        if (customerId != null) "customerId": customerId,
        if (userId != null) "userId": userId,
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
