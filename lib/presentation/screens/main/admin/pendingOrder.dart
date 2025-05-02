import 'package:dongtam/presentation/screens/main/admin/admin_Order.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_Planing.dart';
import 'package:flutter/material.dart';

class PendingOrder extends StatefulWidget {
  const PendingOrder({super.key});

  @override
  State<PendingOrder> createState() => _PendingOrderState();
}

class _PendingOrderState extends State<PendingOrder> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.red,
              tabs: [Tab(text: 'Duyệt đơn hàng'), Tab(text: "Duyệt kế hoạch")],
            ),
          ),
          Expanded(child: TabBarView(children: [AdminOrder(), AdminPlaning()])),
        ],
      ),
    );
  }
}
