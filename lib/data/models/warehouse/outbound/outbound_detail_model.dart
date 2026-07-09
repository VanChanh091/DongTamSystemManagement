import "package:dongtam/data/models/delivery/delivery_item_model.dart";
import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/utils/helper/helper_model.dart";

class OutboundDetailModel {
  final int outboundDetailId;
  final int outboundQty;
  final double price;
  final double totalPriceOutbound;
  final int deliveredQty;
  final bool isPromotion;

  //FK
  final String orderId;
  final OrderModel? order;

  final int? deliveryItemId;
  final DeliveryItemModel? deliveryItem;

  OutboundDetailModel({
    required this.outboundDetailId,
    required this.outboundQty,
    required this.price,
    required this.totalPriceOutbound,
    required this.deliveredQty,
    required this.isPromotion,

    //FK
    required this.orderId,
    this.order,

    this.deliveryItemId,
    this.deliveryItem,
  });

  factory OutboundDetailModel.fromJson(Map<String, dynamic> json) {
    return OutboundDetailModel(
      outboundDetailId: json["outboundDetailId"] ?? 0,
      outboundQty: json["outboundQty"] ?? 0,
      price: toDouble(json["price"]),
      totalPriceOutbound: toDouble(json["totalPriceOutbound"]),
      deliveredQty: json["deliveredQty"] ?? 0,
      isPromotion: json["isPromotion"] ?? false,

      orderId: json["orderId"] ?? "",
      order: json["Order"] != null ? OrderModel.fromJson(json["Order"]) : null,

      deliveryItemId: json["deliveryItemId"],
      deliveryItem:
          json["DeliveryItem"] != null ? DeliveryItemModel.fromJson(json["DeliveryItem"]) : null,
    );
  }
}
