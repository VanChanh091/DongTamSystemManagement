import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/admin_Order.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/admin_Planing.dart';
import 'package:flutter/material.dart';

class TopTabAdmin extends StatefulWidget {
  const TopTabAdmin({super.key});

  @override
  State<TopTabAdmin> createState() => _TopTabAdminState();
}

class _TopTabAdminState extends State<TopTabAdmin> {
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
