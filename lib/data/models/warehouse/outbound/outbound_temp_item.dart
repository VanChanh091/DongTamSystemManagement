class OutboundTempItem {
  final String orderId;
  final String customerName;
  final String companyName;
  final String typeProduct;
  final String productName;
  final String saleName;
  final String? flute;
  final String? qcBox;
  final String dvt;
  final double quantityCustomer;
  final double? discount;
  final double price;
  final int qtyOutbound;

  OutboundTempItem({
    required this.orderId,
    required this.customerName,
    required this.companyName,
    required this.typeProduct,
    required this.productName,
    required this.saleName,
    this.flute,
    this.qcBox,
    required this.dvt,
    required this.quantityCustomer,
    this.discount,
    required this.price,
    required this.qtyOutbound,
  });
}
