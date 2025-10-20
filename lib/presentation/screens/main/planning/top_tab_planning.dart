import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:dongtam/presentation/screens/main/planning/tabChildPlanning/production_queue_box.dart';
import 'package:dongtam/presentation/screens/main/planning/tabChildPlanning/production_queue_paper.dart';
import 'package:dongtam/utils/helper/warning_unsaved_change.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopTabPlanning extends StatefulWidget {
  const TopTabPlanning({super.key});

  @override
  State<TopTabPlanning> createState() => _TopTabPlanningState();
}

class _TopTabPlanningState extends State<TopTabPlanning>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final unsavedChange = Get.find<UnsavedChangeController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.red,
            onTap: (index) async {
              if (index == _tabController.index) return;

              // Kiểm tra flag chưa lưu
              bool canSwitch = await UnsavedChangeDialog(unsavedChange);
              if (canSwitch) {
                unsavedChange.resetUnsavedChanges();
                _tabController.index = index;
              } else {
                // ❌ Không cho đổi tab => giữ nguyên tab hiện tại
                // Không cần làm gì cả
              }
            },
            tabs: const [
              Tab(text: "Kế Hoạch SX Giấy Tấm"),
              Tab(text: "Kế Hoạch SX Thùng"),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [ProductionQueuePaper(), ProductionQueueBox()],
          ),
        ),
      ],
    );
  }
}
