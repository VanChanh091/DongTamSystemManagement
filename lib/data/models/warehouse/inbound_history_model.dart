import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/qualityControl/qc_session_model.dart';

class InboundHistoryModel {
  final int inboundId;
  final DateTime dateInbound;
  final int qtyPaper;
  final int qtyInbound;

  //FK
  final String orderId;
  final Order? order;

  final int qcSessionId;
  final QcSessionModel? QcSession;

  InboundHistoryModel({
    required this.inboundId,
    required this.dateInbound,
    required this.qtyPaper,
    required this.qtyInbound,

    required this.orderId,
    this.order,

    required this.qcSessionId,
    this.QcSession,
  });

  factory InboundHistoryModel.fromJson(Map<String, dynamic> json) {
    return InboundHistoryModel(
      inboundId: json['inboundId'],
      dateInbound: DateTime.parse(json['dateInbound']),
      qtyPaper: json['qtyPaper'] ?? 0,
      qtyInbound: json['qtyInbound'] ?? 0,

      orderId: json['orderId'] ?? 0,
      order: json['Order'] != null ? Order.fromJson(json['Order']) : null,

      qcSessionId: json['qcSessionId'] ?? 0,
      QcSession: json['QcSession'] != null ? QcSessionModel.fromJson(json['QcSession']) : null,
    );
  }
}
