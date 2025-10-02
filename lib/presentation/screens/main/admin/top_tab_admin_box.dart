import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/box/admin_time_machine_box.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/box/admin_waste_box.dart';
import 'package:flutter/material.dart';

class TopTabAdminBox extends StatefulWidget {
  const TopTabAdminBox({super.key});

  @override
  State<TopTabAdminBox> createState() => _TopTabAdminState();
}

class _TopTabAdminState extends State<TopTabAdminBox> {
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
              tabs: const [
                Tab(text: "Thời Gian Làm Thùng"),
                Tab(text: "Định Mức PL Thùng"),
              ],
            ),
          ),
          Expanded(
            child: const TabBarView(
              children: [AdminMachineBox(), AdminWasteBox()],
            ),
          ),
        ],
      ),
    );
  }
}
