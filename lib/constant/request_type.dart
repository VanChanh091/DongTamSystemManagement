enum RequestType {
  // Đơn hàng
  orderChangeDate,
  orderCancel,
  orderReject,
  orderConfirm,
  orderUpdate,

  // Mặc định
  unknown;

  static RequestType fromString(String? value) {
    switch (value) {
      case 'ORDER_CHANGE_DATE':
        return RequestType.orderChangeDate;
      case 'ORDER_CANCEL':
        return RequestType.orderCancel;
      case 'ORDER_REJECT':
        return RequestType.orderReject;
      case 'ORDER_CONFIRM':
        return RequestType.orderConfirm;
      case 'ORDER_UPDATE':
        return RequestType.orderUpdate;
      default:
        return RequestType.unknown;
    }
  }
}

enum RequestStatus {
  pending,
  approved,
  rejected,
  confirmed,
  unknown;

  static RequestStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return RequestStatus.pending;
      case 'approved':
        return RequestStatus.approved;
      case 'rejected':
        return RequestStatus.rejected;
      case 'confirmed':
        return RequestStatus.confirmed;
      default:
        return RequestStatus.unknown;
    }
  }
}
