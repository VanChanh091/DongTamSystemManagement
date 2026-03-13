import 'package:dongtam/data/models/warehouse/outbound/outbound_detail_model.dart';
import 'package:dongtam/data/models/warehouse/inventory_model.dart';

class OutboundTempItem {
  final String orderId;
  final String customerName;
  final String typeProduct;
  final String productName;
  final String saleName;

  final double? length;
  final double? size;
  final String? flute;
  final String? QC_box;
  final String dvt;

  final double quantityCustomer;
  final int qtyOutbound;
  final int? qtyInventory;

  final double pricePaper;

  OutboundTempItem({
    required this.orderId,
    required this.customerName,
    required this.typeProduct,
    required this.productName,
    required this.saleName,

    this.length,
    this.size,
    this.flute,
    this.QC_box,
    required this.dvt,

    required this.quantityCustomer,
    required this.qtyOutbound,
    this.qtyInventory,

    required this.pricePaper,
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

  factory OutboundTempItem.fromInventoryModel(InventoryModel inventory) {
    final order = inventory.order;

    return OutboundTempItem(
      orderId: inventory.orderId,

      customerName: order?.customer?.customerName ?? "",
      length: order?.lengthPaperCustomer.toDouble() ?? 0,
      size: order?.paperSizeCustomer.toDouble() ?? 0,

      typeProduct: order?.product?.typeProduct ?? "",
      productName: order?.product?.productName ?? "",

      saleName: order?.user?.fullName ?? "",

      flute: order?.flute ?? "",
      QC_box: order?.QC_box ?? "",

      dvt: order?.dvt ?? "",
      quantityCustomer: order?.quantityCustomer.toDouble() ?? 0,

      pricePaper: order?.pricePaper?.toDouble() ?? 0,
      qtyOutbound: 0,
      qtyInventory: inventory.qtyInventory,
    );
  }
}
