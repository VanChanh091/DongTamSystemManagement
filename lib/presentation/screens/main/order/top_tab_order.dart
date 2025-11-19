import 'package:dongtam/presentation/screens/main/order/tabChildOrder/order_accept_planning.dart';
import 'package:dongtam/presentation/screens/main/order/tabChildOrder/order_reject_pending.dart';
import 'package:flutter/material.dart';

class TopTabOrder extends StatefulWidget {
  const TopTabOrder({super.key});

  @override
  State<TopTabOrder> createState() => _TopTabOrderState();
}

class _TopTabOrderState extends State<TopTabOrder> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.red,
              tabs: [Tab(text: "Trạng Thái Đơn Hàng"), Tab(text: "Chờ Duyệt/Từ Chối")],
            ),
          ),
          Expanded(
            child: const TabBarView(children: [OrderAcceptAndPlanning(), OrderRejectAndPending()]),
          ),
        ],
      ),
    );
  }
}
