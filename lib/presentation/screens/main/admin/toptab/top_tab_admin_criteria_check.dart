import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/criteriaCheck/admin_criteria_box_check.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/criteriaCheck/admin_criteria_paper_check.dart';
import 'package:get/get.dart';

class TopTabCriteriaCheck extends StatefulWidget {
  const TopTabCriteriaCheck({super.key});

  @override
  State<TopTabCriteriaCheck> createState() => _TopTabCriteriaCheckState();
}

class _TopTabCriteriaCheckState extends State<TopTabCriteriaCheck> {
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
              tabs: const [Tab(text: "Giấy Tấm"), Tab(text: "Làm Thùng")],
            ),
          ),
          Expanded(
            child: const TabBarView(children: [AdminCriteriaPaperCheck(), AdminCriteriaBoxCheck()]),
          ),
        ],
      ),
    );
  }
}
