import 'package:dongtam/presentation/screens/main/report/tabChildReport/report_planning_box.dart';
import 'package:dongtam/presentation/screens/main/report/tabChildReport/report_planning_paper.dart';
import 'package:flutter/material.dart';

class TopTabReport extends StatefulWidget {
  const TopTabReport({super.key});

  @override
  State<TopTabReport> createState() => _TopTabReportState();
}

class _TopTabReportState extends State<TopTabReport> {
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
                Tab(text: "Báo Cáo Giấy Tấm"),
                Tab(text: "Báo Cáo SX Thùng"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [ReportPlanningPaper(), ReportPlanningBox()],
            ),
          ),
        ],
      ),
    );
  }
}
