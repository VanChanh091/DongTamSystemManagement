import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/admin_machinePaper.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/admin_wasteNorm.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/admin_waveCrest.dart';
import 'package:flutter/material.dart';

class TopTabAdminPaper extends StatefulWidget {
  const TopTabAdminPaper({super.key});

  @override
  State<TopTabAdminPaper> createState() => _TopTabAdminPaperState();
}

class _TopTabAdminPaperState extends State<TopTabAdminPaper> {
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
                Tab(text: "Thời Gian Máy Sóng"),
                Tab(text: "Định Mức PL Giấy"),
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
