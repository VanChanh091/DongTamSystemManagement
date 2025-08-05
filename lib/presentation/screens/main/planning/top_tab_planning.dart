import 'package:dongtam/presentation/screens/main/planning/tabChildPlanning/production_queue_box.dart';
import 'package:dongtam/presentation/screens/main/planning/tabChildPlanning/production_queue_paper.dart';
import 'package:flutter/material.dart';

class TopTabPlanning extends StatefulWidget {
  const TopTabPlanning({super.key});

  @override
  State<TopTabPlanning> createState() => _TopTabPlanningState();
}

class _TopTabPlanningState extends State<TopTabPlanning> {
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
              tabs: [
                Tab(text: "Kế Hoạch SX Giấy Tấm"),
                Tab(text: "Kế Hoạch SX Thùng"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [ProductionQueuePaper(), ProductionQueueBox()],
            ),
          ),
        ],
      ),
    );
  }
}
