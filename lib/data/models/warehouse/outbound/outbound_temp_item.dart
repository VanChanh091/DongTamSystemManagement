import 'package:dongtam/data/models/delivery/delivery_item_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_detail_model.dart';
import 'package:dongtam/data/models/warehouse/inventory/inventory_model.dart';

class OutboundTempItem {
  final String orderId;
  final String customerName;
  final String typeProduct;
  final String productName;
  final String saleName;

  final double? lengthManufacture;
  final double? sizeManufacture;
  final double? lengthCustomer;
  final double? sizeCustomer;
  final String? flute;
  final String? QC_box;
  final String dvt;

  final double quantityCustomer;
  final int qtyOutbound;

  final int? qtyInventory;
  final int? totalOutbound;

  final double pricePaper;

  OutboundTempItem({
    required this.orderId,
    required this.customerName,
    required this.typeProduct,
    required this.productName,
    required this.saleName,

    this.lengthManufacture,
    this.sizeManufacture,
    this.lengthCustomer,
    this.sizeCustomer,
    this.flute,
    this.QC_box,
    required this.dvt,

    required this.quantityCustomer,
    required this.qtyOutbound,
    this.qtyInventory,
    this.totalOutbound,
    required this.pricePaper,
  });

  factory OutboundTempItem.fromDetailModel(OutboundDetailModel detail) {
    final order = detail.order;

    return OutboundTempItem(
      orderId: detail.orderId,
      customerName: order?.customer?.customerName ?? "",

      lengthManufacture: order?.lengthPaperManufacture.toDouble() ?? 0,
      sizeManufacture: order?.paperSizeManufacture.toDouble() ?? 0,
      lengthCustomer: order?.lengthPaperCustomer.toDouble() ?? 0,
      sizeCustomer: order?.paperSizeCustomer.toDouble() ?? 0,

      typeProduct: order?.product?.typeProduct ?? "",
      productName: order?.product?.productName ?? "",

      saleName: '',

      flute: order?.flute ?? "",
      QC_box: order?.QC_box ?? "",

      dvt: order?.dvt ?? "",
      quantityCustomer: order?.quantityCustomer.toDouble() ?? 0,

      pricePaper: detail.price.toDouble(),
      qtyOutbound: detail.outboundQty,

      //qty
      qtyInventory: detail.order?.Inventory?.qtyInventory ?? 0,
      totalOutbound: detail.order?.Inventory?.totalQtyOutbound ?? 0,
    );
  }

  factory OutboundTempItem.fromInventoryModel(InventoryModel inventory) {
    final order = inventory.order;

    return OutboundTempItem(
      orderId: inventory.orderId,

      customerName: order?.customer?.customerName ?? "",
      lengthManufacture: order?.lengthPaperCustomer.toDouble() ?? 0,
      sizeManufacture: order?.paperSizeCustomer.toDouble() ?? 0,
      lengthCustomer: order?.lengthPaperCustomer.toDouble() ?? 0,
      sizeCustomer: order?.paperSizeCustomer.toDouble() ?? 0,

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
      totalOutbound: inventory.totalQtyOutbound,
    );
  }

  factory OutboundTempItem.fromDeliveryItemModel(DeliveryItemModel item) {
    final order = item.request?.paper?.order;
    final inventory = order?.Inventory;

    return OutboundTempItem(
      orderId: order?.orderId ?? "",
      customerName: order?.customer?.customerName ?? "",

      lengthManufacture: order?.lengthPaperCustomer.toDouble() ?? 0,
      sizeManufacture: order?.paperSizeCustomer.toDouble() ?? 0,
      lengthCustomer: order?.lengthPaperCustomer.toDouble() ?? 0,
      sizeCustomer: order?.paperSizeCustomer.toDouble() ?? 0,

      typeProduct: order?.product?.typeProduct ?? "",
      productName: order?.product?.productName ?? "",
      saleName: order?.user?.fullName ?? "",
      flute: order?.flute ?? "",
      QC_box: order?.QC_box ?? "",
      dvt: order?.dvt ?? "",
      quantityCustomer: order?.quantityCustomer.toDouble() ?? 0,
      pricePaper: order?.pricePaper?.toDouble() ?? 0,
      qtyOutbound: 0,
      qtyInventory: inventory?.qtyInventory ?? 0,
      totalOutbound: inventory?.totalQtyOutbound ?? 0,
    );
  }
}
