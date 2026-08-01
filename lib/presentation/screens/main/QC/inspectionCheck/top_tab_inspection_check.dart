import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/presentation/screens/main/QC/inspectionCheck/inspection_box_check.dart';
import 'package:dongtam/presentation/screens/main/QC/inspectionCheck/inspection_paper_check.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopTabInspectionCheck extends StatefulWidget {
  const TopTabInspectionCheck({super.key});

  @override
  State<TopTabInspectionCheck> createState() => _TopTabInspectionCheckState();
}

class _TopTabInspectionCheckState extends State<TopTabInspectionCheck> {
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
              tabs: const [Tab(text: "Kiểm Tra Giấy Tấm"), Tab(text: "Kiểm Tra Làm Thùng")],
            ),
          ),
          Expanded(
            child: const TabBarView(children: [InspectionPaperCheck(), InspectionBoxCheck()]),
          ),
        ],
      ),
    );
  }
}
