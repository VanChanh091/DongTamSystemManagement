enum NotificationType {
  // 1. Đơn hàng (Order)
  orderChangeDate("ORDER_CHANGE_DATE"),
  orderCancel("ORDER_CANCEL"),
  orderReject("ORDER_REJECT"),
  orderConfirm("ORDER_CONFIRM"),
  orderUpdate("ORDER_UPDATE"),

  // 2. Kiểm tra chất lượng (Inspection)
  inspectionRequest("INSPECTION_REQUEST"),
  inspectionRemind("INSPECTION_REMIND"),

  // 3. Cấn trừ công nợ (Debt Deduction)
  debtDeductionRequest("DEBT_DEDUCTION_REQUEST"),
  debtDeductionResubmitted("DEBT_DEDUCTION_RESUBMITTED"),
  debtDeductionApproved("DEBT_DEDUCTION_APPROVED"),
  debtDeductionRejected("DEBT_DEDUCTION_REJECTED"),

  // Mặc định
  unknown("UNKNOWN");

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String? type) {
    if (type == null) return NotificationType.unknown;
    return NotificationType.values.firstWhere(
      (e) => e.value.toUpperCase() == type.toUpperCase(),
      orElse: () => NotificationType.unknown,
    );
  }

  /// Kiểm tra có phải loại thông báo cấn trừ công nợ hay không
  bool get isDebtDeduction =>
      this == debtDeductionRequest ||
      this == debtDeductionResubmitted ||
      this == debtDeductionApproved ||
      this == debtDeductionRejected;

  /// Kiểm tra thông báo duyệt
  bool get isApproved => this == debtDeductionApproved || this == orderConfirm;

  /// Kiểm tra thông báo từ chối
  bool get isRejected => this == debtDeductionRejected || this == orderReject;
}
