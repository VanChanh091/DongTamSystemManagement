import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/admin_machinePaper.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/admin_wasteNorm.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/admin_waveCrest.dart';
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
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.red,
              tabs: [
                Tab(text: "Thời Gian Máy Chạy"),
                Tab(text: "Định Mức Phế Liệu"),
                Tab(text: "Hệ Số Máy Sóng"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                AdminMachinePaper(),
                AdminWasteNorm(),
                AdminWaveCrest(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
