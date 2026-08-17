import 'package:dongtam/utils/helper/helper_model.dart';

class DebtAgingModel {
  final double inTerm;
  final double dueIn1_3;
  final double overdue1_30;
  final double overdue31_60;
  final double overdue61_90;
  final double overdueOver90;

  DebtAgingModel({
    required this.inTerm,
    required this.dueIn1_3,
    required this.overdue1_30,
    required this.overdue31_60,
    required this.overdue61_90,
    required this.overdueOver90,
  });

  factory DebtAgingModel.fromJson(Map<String, dynamic> json) {
    return DebtAgingModel(
      inTerm: toDouble(json["inTerm"]),
      dueIn1_3: toDouble(json["dueIn1_3"]),
      overdue1_30: toDouble(json["overdue1_30"]),
      overdue31_60: toDouble(json["overdue31_60"]),
      overdue61_90: toDouble(json["overdue61_90"]),
      overdueOver90: toDouble(json["overdueOver90"]),
    );
  }
}

class CustomerDebtItemModel {
  final String customerId;
  final String customerName;
  final double totalDebt;
  final double closedDebt;
  final double currentPeriodDebt;
  final double dueDebt;
  final double notDueDebt;
  final int unpaidOutboundCount;
  final DebtAgingModel aging;

  CustomerDebtItemModel({
    required this.customerId,
    required this.customerName,
    required this.totalDebt,
    required this.closedDebt,
    required this.currentPeriodDebt,
    required this.dueDebt,
    required this.notDueDebt,
    required this.unpaidOutboundCount,
    required this.aging,
  });

  factory CustomerDebtItemModel.fromJson(Map<String, dynamic> json) {
    return CustomerDebtItemModel(
      customerId: json['customerId'] ?? "",
      customerName: json['customerName'] ?? "",
      totalDebt: toDouble(json["totalDebt"]),
      closedDebt: toDouble(json["closedDebt"]),
      currentPeriodDebt: toDouble(json["currentPeriodDebt"]),
      dueDebt: toDouble(json["dueDebt"]),
      notDueDebt: toDouble(json["notDueDebt"]),
      unpaidOutboundCount: json['unpaidOutboundCount'] ?? 0,
      aging: DebtAgingModel.fromJson(json['aging'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class CustomerDebtSummaryModel {
  final List<CustomerDebtItemModel> data;
  final CustomerDebtItemModel? grandTotal;
  final int totalCustomers;

  CustomerDebtSummaryModel({required this.data, this.grandTotal, required this.totalCustomers});

  factory CustomerDebtSummaryModel.fromJson(Map<String, dynamic> json) {
    return CustomerDebtSummaryModel(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => CustomerDebtItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      grandTotal:
          json['grandTotal'] != null
              ? CustomerDebtItemModel.fromJson(json['grandTotal'] as Map<String, dynamic>)
              : null,
      totalCustomers: json['totalCustomers'] ?? 0,
    );
  }
}
