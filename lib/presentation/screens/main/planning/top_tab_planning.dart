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

  Future<void> _handleTapOnTabBar(
    TapDownDetails details,
    BuildContext ctx,
  ) async {
    // Tính xem user bấm tab nào
    final renderBox = ctx.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final tabCount = _tabController.length;
    final tabWidth = size.width / tabCount;
    final tappedIndex = (details.localPosition.dx ~/ tabWidth).clamp(
      0,
      tabCount - 1,
    );

    // Nếu bấm lại tab hiện tại -> bỏ qua
    if (tappedIndex == _tabController.index) return;

    // Nếu có thay đổi chưa lưu -> hỏi người dùng
    if (unsavedChange.isUnsavedChanges.value) {
      final canLeave = await UnsavedChangeDialog(unsavedChange);
      if (canLeave) {
        unsavedChange.resetUnsavedChanges();
        _tabController.animateTo(tappedIndex);
      }
    } else {
      // Không có thay đổi thì chuyển tab bình thường
      _tabController.animateTo(tappedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _handleTapOnTabBar(d, context),
              child: AbsorbPointer(
                absorbing: true, // vẫn chặn tap mặc định
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.red,
                  tabs: const [
                    Tab(text: "Kế Hoạch SX Giấy Tấm"),
                    Tab(text: "Kế Hoạch SX Thùng"),
                  ],
                ),
              ),
            ),
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
