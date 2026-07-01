import 'package:flutter/material.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/criteriaCheck/admin_criteria_box_check.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/criteriaCheck/admin_criteria_paper_check.dart';

class TopTabCriteriaCheck extends StatefulWidget {
  const TopTabCriteriaCheck({super.key});

  @override
  State<TopTabCriteriaCheck> createState() => _TopTabCriteriaCheckState();
}

class _TopTabCriteriaCheckState extends State<TopTabCriteriaCheck> {
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
