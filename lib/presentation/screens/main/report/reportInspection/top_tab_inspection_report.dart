import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/presentation/screens/main/report/reportInspection/tabInspectionReport/report_inspection_box.dart';
import 'package:dongtam/presentation/screens/main/report/reportInspection/tabInspectionReport/report_inspection_paper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopTabInspectionReport extends StatefulWidget {
  const TopTabInspectionReport({super.key});

  @override
  State<TopTabInspectionReport> createState() => _TopTabInspectionReportState();
}

class _TopTabInspectionReportState extends State<TopTabInspectionReport> {
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: themeController.backgroundColor.value,
            child: TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.red,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: const [Tab(text: "Giấy Tấm"), Tab(text: "Công Đoạn 2")],
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
