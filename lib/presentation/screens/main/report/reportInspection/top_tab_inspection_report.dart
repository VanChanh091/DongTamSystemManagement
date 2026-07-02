import 'package:dongtam/presentation/screens/main/report/reportInspection/tabInspectionReport/report_inspection_box.dart';
import 'package:dongtam/presentation/screens/main/report/reportInspection/tabInspectionReport/report_inspection_paper.dart';
import 'package:flutter/material.dart';

class TopTabInspectionReport extends StatefulWidget {
  const TopTabInspectionReport({super.key});

  @override
  State<TopTabInspectionReport> createState() => _TopTabInspectionReportState();
}

class _TopTabInspectionReportState extends State<TopTabInspectionReport> {
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
              tabs: const [Tab(text: "Giấy Tấm"), Tab(text: "Thùng")],
            ),
          ),
          Expanded(
            child: const TabBarView(children: [ReportInspectionPaper(), ReportInspectionBox()]),
          ),
        ],
      ),
    );
  }
}
