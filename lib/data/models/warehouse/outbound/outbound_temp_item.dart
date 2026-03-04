import 'package:dongtam/data/models/warehouse/outbound/outbound_detail_model.dart';

class OutboundTempItem {
  final String orderId;
  final String customerName;
  final double? length;
  final String typeProduct;
  final String productName;
  final String saleName;
  final String? flute;
  final String? QC_box;
  final String dvt;
  final double quantityCustomer;
  final double? size;
  final double pricePaper;
  final int qtyOutbound;
  final int? qtyInventory;

  OutboundTempItem({
    required this.orderId,
    required this.customerName,
    this.length,
    required this.typeProduct,
    required this.productName,
    required this.saleName,
    this.flute,
    this.QC_box,
    required this.dvt,
    required this.quantityCustomer,
    this.size,
    required this.pricePaper,
    required this.qtyOutbound,
    this.qtyInventory,
  });

  factory OutboundTempItem.fromDetailModel(OutboundDetailModel detail) {
    final order = detail.order;

    return OutboundTempItem(
      orderId: detail.orderId,

      customerName: order?.customer?.customerName ?? "",
      length: order?.lengthPaperManufacture.toDouble() ?? 0,
      size: order?.paperSizeManufacture.toDouble() ?? 0,

      typeProduct: order?.product?.typeProduct ?? "",
      productName: order?.product?.productName ?? "",

      saleName: '',

      flute: order?.flute ?? "",
      QC_box: order?.QC_box ?? "",

      dvt: order?.dvt ?? "",
      quantityCustomer: order?.quantityCustomer.toDouble() ?? 0,

      pricePaper: detail.price.toDouble(),
      qtyOutbound: detail.outboundQty,
      qtyInventory: detail.order?.Inventory?.qtyInventory ?? 0,
    );
  }
}
