import 'package:dongtam/presentation/screens/main/report/tabChildReport/report_planning_box.dart';
import 'package:dongtam/presentation/screens/main/report/tabChildReport/report_planning_paper.dart';
import 'package:flutter/material.dart';

class TopTabHistoryReport extends StatefulWidget {
  const TopTabHistoryReport({super.key});

  @override
  State<TopTabHistoryReport> createState() => _TopTabHistoryReportState();
}

class _TopTabHistoryReportState extends State<TopTabHistoryReport> {
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
              tabs: const [Tab(text: "Báo Cáo Giấy Tấm"), Tab(text: "Báo Cáo SX Thùng")],
            ),
          ),
          Expanded(child: const TabBarView(children: [ReportPlanningPaper(), ReportPlanningBox()])),
        ],
      ),
    );
  }
}
