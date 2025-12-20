import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class OutboundDetailModel {
  final int outboundDetailId;
  final int outboundQty;
  final double price;
  final double totalPriceOutbound;
  final int deliveredQty;

  //FL
  final String orderId;
  final Order? order;

  OutboundDetailModel({
    required this.outboundDetailId,
    required this.outboundQty,
    required this.price,
    required this.totalPriceOutbound,
    required this.deliveredQty,

    required this.orderId,
    this.order,
  });

  factory OutboundDetailModel.fromJson(Map<String, dynamic> json) {
    return OutboundDetailModel(
      outboundDetailId: json['outboundDetailId'] ?? 0,
      outboundQty: json['outboundQty'] ?? 0,
      price: toDouble(json['price']),
      totalPriceOutbound: toDouble(json['totalPriceOutbound']),
      deliveredQty: json['deliveredQty'] ?? 0,

      orderId: json['orderId'] ?? "",
      order: json['Order'] != null ? Order.fromJson(json['Order']) : null,
    );
  }
}
