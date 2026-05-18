import 'package:dongtam/data/models/delivery/delivery_item_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_detail_model.dart';
import 'package:dongtam/data/models/warehouse/inventory/inventory_model.dart';

class OutboundTempItem {
  final String orderId;
  final String customerName;
  final String productName;

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
  final int? deliveryItemId;

  final bool isPromotion;

  final double pricePaper;

  OutboundTempItem({
    required this.orderId,
    required this.customerName,
    required this.productName,

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
    this.deliveryItemId,
    required this.pricePaper,
    required this.isPromotion,
  });

  factory OutboundTempItem.fromDetailModel(OutboundDetailModel detail) {
    final order = detail.order;

    // print('--- CHECKING DATA START DETAIL ---');
    // print({
    //   'orderId': order?.orderId ?? "",
    //   'lengthManufacture': order?.lengthPaperManufacture.toDouble() ?? 0,
    //   'sizeManufacture': order?.paperSizeManufacture.toDouble() ?? 0,
    //   'lengthCustomer': order?.lengthPaperCustomer.toDouble() ?? 0,
    //   'sizeCustomer': order?.paperSizeCustomer.toDouble() ?? 0,
    //   'deliveryItemId': detail.deliveryItemId ?? "",
    // });
    // print('--- CHECKING DATA END ---');

    return OutboundTempItem(
      orderId: detail.orderId,
      customerName: order?.customer?.customerName ?? "",

      lengthManufacture: order?.lengthPaperManufacture.toDouble() ?? 0,
      sizeManufacture: order?.paperSizeManufacture.toDouble() ?? 0,
      lengthCustomer: order?.lengthPaperCustomer.toDouble() ?? 0,
      sizeCustomer: order?.paperSizeCustomer.toDouble() ?? 0,

      productName: order?.product?.productName ?? "",

      flute: order?.flute ?? "",
      QC_box: order?.QC_box ?? "",

      dvt: order?.dvt ?? "",
      quantityCustomer: order?.quantityCustomer.toDouble() ?? 0,

      pricePaper: detail.price.toDouble(),
      qtyOutbound: detail.outboundQty,

      isPromotion: detail.isPromotion,

      //qty
      qtyInventory: detail.order?.Inventory?.qtyInventory ?? 0,
      totalOutbound: detail.order?.Inventory?.totalQtyOutbound ?? 0,
      deliveryItemId: detail.deliveryItemId,
    );
  }

  factory OutboundTempItem.fromInventoryModel(InventoryModel inventory) {
    final order = inventory.order;

    // print('--- CHECKING DATA START INVENTORY ---');
    // print({
    //   'orderId': inventory.orderId,
    //   'lengthManufacture': order?.lengthPaperManufacture.toDouble() ?? 0,
    //   'sizeManufacture': order?.paperSizeManufacture.toDouble() ?? 0,
    //   'lengthCustomer': order?.lengthPaperCustomer.toDouble() ?? 0,
    //   'sizeCustomer': order?.paperSizeCustomer.toDouble() ?? 0,
    // });
    // print('--- CHECKING DATA END ---');

    return OutboundTempItem(
      orderId: inventory.orderId,

      customerName: order?.customer?.customerName ?? "",
      lengthManufacture: order?.lengthPaperManufacture.toDouble() ?? 0,
      sizeManufacture: order?.paperSizeManufacture.toDouble() ?? 0,
      lengthCustomer: order?.lengthPaperCustomer.toDouble() ?? 0,
      sizeCustomer: order?.paperSizeCustomer.toDouble() ?? 0,

      productName: order?.product?.productName ?? "",

      flute: order?.flute ?? "",
      QC_box: order?.QC_box ?? "",

      dvt: order?.dvt ?? "",
      quantityCustomer: order?.quantityCustomer.toDouble() ?? 0,

      pricePaper: order?.pricePaper?.toDouble() ?? 0,
      qtyOutbound: 0,
      qtyInventory: inventory.qtyInventory,
      totalOutbound: inventory.totalQtyOutbound,
      isPromotion: false,
    );
  }

  factory OutboundTempItem.fromDeliveryItemModel(DeliveryItemModel item) {
    final order = item.request?.paper?.order;
    final inventory = order?.Inventory;

    // print('--- CHECKING DATA START DELIVERY ---');
    // print({
    //   'orderId': order?.orderId ?? "",
    //   'lengthManufacture': order?.lengthPaperManufacture.toDouble() ?? 0,
    //   'sizeManufacture': order?.paperSizeManufacture.toDouble() ?? 0,
    //   'lengthCustomer': order?.lengthPaperCustomer.toDouble() ?? 0,
    //   'sizeCustomer': order?.paperSizeCustomer.toDouble() ?? 0,
    //   'deliveryItemId': item.deliveryItemId,
    // });
    // print('--- CHECKING DATA END ---');

    return OutboundTempItem(
      orderId: order?.orderId ?? "",
      customerName: order?.customer?.customerName ?? "",

      lengthManufacture: order?.lengthPaperManufacture.toDouble() ?? 0,
      sizeManufacture: order?.paperSizeManufacture.toDouble() ?? 0,
      lengthCustomer: order?.lengthPaperCustomer.toDouble() ?? 0,
      sizeCustomer: order?.paperSizeCustomer.toDouble() ?? 0,

      productName: order?.product?.productName ?? "",

      flute: order?.flute ?? "",
      QC_box: order?.QC_box ?? "",
      dvt: order?.dvt ?? "",
      quantityCustomer: order?.quantityCustomer.toDouble() ?? 0,
      pricePaper: order?.pricePaper?.toDouble() ?? 0,
      qtyOutbound: 0,
      qtyInventory: inventory?.qtyInventory ?? 0,
      totalOutbound: inventory?.totalQtyOutbound ?? 0,
      deliveryItemId: item.deliveryItemId,
      isPromotion: false,
    );
  }
}
