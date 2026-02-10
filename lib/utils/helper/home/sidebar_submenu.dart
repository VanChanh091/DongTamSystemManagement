import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_criteria.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_mange_user.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_order.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_vehicle.dart';
import 'package:dongtam/presentation/screens/main/admin/toptab/top_tab_admin_box.dart';
import 'package:dongtam/presentation/screens/main/admin/toptab/top_tab_admin_paper.dart';
import 'package:dongtam/presentation/screens/main/delivery/delivery_estimate_time.dart';
import 'package:dongtam/presentation/screens/main/delivery/delivery_planning.dart';
import 'package:dongtam/presentation/screens/main/delivery/delivery_schedule.dart';
import 'package:dongtam/presentation/screens/main/manufacture/box_printing_production.dart';
import 'package:dongtam/presentation/screens/main/manufacture/paper_production.dart';
import 'package:dongtam/presentation/screens/main/planning/planning_stop.dart';
import 'package:dongtam/presentation/screens/main/planning/top_tab_planning.dart';
import 'package:dongtam/presentation/screens/main/planning/waiting_for_planing.dart';
import 'package:dongtam/presentation/screens/main/report/reportPlanning/top_tab_history_report.dart';
import 'package:dongtam/presentation/screens/main/report/report_warehouse/report_inbound_history.dart';
import 'package:dongtam/presentation/screens/main/waitingCheck/waiting_check_box.dart';
import 'package:dongtam/presentation/screens/main/waitingCheck/waiting_check_paper.dart';
import 'package:dongtam/presentation/screens/main/warehouse/inventory.dart';
import 'package:dongtam/presentation/screens/main/warehouse/outbound_history.dart';
import 'package:dongtam/utils/helper/home/sidebar_expanded_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class SubMenuConfig {
  final IconData icon;
  final String label;
  final Type pageType;
  final bool showBadge;
  final RxInt? badge;

  SubMenuConfig({
    required this.icon,
    required this.label,
    required this.pageType,
    this.showBadge = false,
    this.badge,
  });

  int getIndex(List<Widget> pages) => pages.indexWhere((w) => w.runtimeType == pageType);
}

Widget buildPlanningMenu({
  required bool isSidebarOpen,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<Widget> pages,
}) {
  final badges = Get.find<BadgesController>();

  return buildExpandedMenuHelper(
    isSidebarOpen: isSidebarOpen,
    title: "Kế Hoạch",
    icon: Icons.schedule,
    isExpanded: isExpanded,
    onToggle: onToggle,
    pages: pages,
    configs: [
      SubMenuConfig(
        icon: Icons.outbox_rounded,
        label: "Chờ Lên Kế Hoạch",
        pageType: WaitingForPlanning,
        showBadge: true,
        badge: badges.numberOrderPendingPlanning,
      ),
      SubMenuConfig(
        icon: Icons.production_quantity_limits_outlined,
        label: "Hàng Chờ Sản Xuất",
        pageType: TopTabPlanning,
      ),
      SubMenuConfig(
        icon: Icons.queue,
        label: "Hàng Chờ Xử Lý",
        pageType: PlanningStop,
        showBadge: true,
        badge: badges.numberPlanningStop,
      ),
    ],
  );
}

Widget buildManufactureMenu({
  required bool isSidebarOpen,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<Widget> pages,
}) {
  return buildExpandedMenuHelper(
    isSidebarOpen: isSidebarOpen,
    title: "Sản Xuất",
    icon: Symbols.manufacturing,
    isExpanded: isExpanded,
    onToggle: onToggle,
    pages: pages,
    configs: [
      SubMenuConfig(icon: Icons.article, label: "Giấy Tấm", pageType: PaperProduction),
      SubMenuConfig(
        icon: Symbols.package_2,
        label: "Thùng và In ấn",
        pageType: BoxPrintingProduction,
      ),
    ],
  );
}

Widget buildWaitingCheckMenu({
  required bool isSidebarOpen,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<Widget> pages,
}) {
  final badges = Get.find<BadgesController>();

  return buildExpandedMenuHelper(
    isSidebarOpen: isSidebarOpen,
    title: "Hàng Chờ Kiểm",
    icon: Symbols.home_storage,
    isExpanded: isExpanded,
    onToggle: onToggle,
    pages: pages,
    configs: [
      SubMenuConfig(
        icon: Icons.article,
        label: "Giấy Tấm",
        pageType: WaitingCheckPaper,
        showBadge: true,
        badge: badges.numberPaperWaiting,
      ),
      SubMenuConfig(
        icon: Symbols.package_2,
        label: "Thùng và In ấn",
        pageType: WaitingCheckBox,
        showBadge: true,
        badge: badges.numberBoxWaiting,
      ),
    ],
  );
}

Widget buildWarehouseMenu({
  required bool isSidebarOpen,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<Widget> pages,
}) {
  return buildExpandedMenuHelper(
    isSidebarOpen: isSidebarOpen,
    title: "Xuất và Tồn Kho",
    icon: Symbols.warehouse,
    isExpanded: isExpanded,
    onToggle: onToggle,
    pages: pages,
    configs: [
      SubMenuConfig(icon: Symbols.lab_profile, label: "Xuất Kho", pageType: OutboundHistory),
      SubMenuConfig(icon: Symbols.garage_home, label: "Tồn Kho", pageType: Inventory),
    ],
  );
}

Widget buildDeliveryMenu({
  required bool isSidebarOpen,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<Widget> pages,
}) {
  return buildExpandedMenuHelper(
    isSidebarOpen: isSidebarOpen,
    title: "Giao Hàng",
    icon: Symbols.airport_shuttle,
    isExpanded: isExpanded,
    onToggle: onToggle,
    pages: pages,
    configs: [
      SubMenuConfig(
        icon: Symbols.pending_actions,
        label: "Đăng Ký Giao Hàng",
        pageType: DeliveryEstimateTime,
      ),
      SubMenuConfig(
        icon: Symbols.calendar_add_on,
        label: "Kế Hoạch Giao Hàng",
        pageType: DeliveryPlanning,
      ),
      SubMenuConfig(icon: Symbols.schedule, label: "Lịch Giao Hàng", pageType: DeliverySchedule),
    ],
  );
}

Widget buildReportMenu({
  required bool isSidebarOpen,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<Widget> pages,
}) {
  return buildExpandedMenuHelper(
    isSidebarOpen: isSidebarOpen,
    title: "Lịch Sử",
    icon: Symbols.contract,
    isExpanded: isExpanded,
    onToggle: onToggle,
    pages: pages,
    configs: [
      SubMenuConfig(icon: Icons.article, label: "Lịch Sử Sản Xuất", pageType: TopTabHistoryReport),
      SubMenuConfig(
        icon: Icons.production_quantity_limits_outlined,
        label: "Lịch Sử Nhập Kho",
        pageType: ReportInboundHistory,
      ),
    ],
  );
}

Widget buildApprovalMenu({
  required bool isSidebarOpen,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<Widget> pages,
}) {
  final badges = Get.find<BadgesController>();

  return buildExpandedMenuHelper(
    isSidebarOpen: isSidebarOpen,
    title: "Quản Lý",
    icon: Icons.admin_panel_settings,
    isExpanded: isExpanded,
    onToggle: onToggle,
    pages: pages,
    configs: [
      SubMenuConfig(
        icon: Icons.pending_actions,
        label: "Chờ Duyệt",
        pageType: AdminOrder,
        showBadge: true,
        badge: badges.numberPendingApproval,
      ),
      SubMenuConfig(icon: Icons.gif_box, label: "Máy Sóng và Phế Liệu", pageType: TopTabAdminPaper),
      SubMenuConfig(icon: Icons.gif_box, label: "In Ấn và Phế Liệu", pageType: TopTabAdminBox),
      SubMenuConfig(icon: Icons.rule, label: "Tiêu Chí Sản Xuất", pageType: AdminCriteria),
      SubMenuConfig(icon: Symbols.directions_car, label: "Xe Giao Hàng", pageType: AdminVehicle),
      SubMenuConfig(icon: Icons.person, label: "Người Dùng", pageType: AdminMangeUser),
    ],
  );
}
