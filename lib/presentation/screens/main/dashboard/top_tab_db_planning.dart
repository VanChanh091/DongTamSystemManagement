import 'package:dongtam/presentation/screens/main/dashboard/dashboardPlanning/dashboard_box.dart';
import 'package:dongtam/presentation/screens/main/dashboard/dashboardPlanning/dashboard_paper.dart';
import 'package:flutter/material.dart';

class TopTabDbPlanning extends StatefulWidget {
  const TopTabDbPlanning({super.key});

  @override
  State<TopTabDbPlanning> createState() => _TopTabDbPlanningState();
}

class _TopTabDbPlanningState extends State<TopTabDbPlanning> {
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
              tabs: [Tab(text: "Công Đoạn 1"), Tab(text: "Công Đoạn 2")],
            ),
          ),
          Expanded(child: const TabBarView(children: [DashboardPapers(), DashboardBoxes()])),
        ],
      ),
    );
  }
}
