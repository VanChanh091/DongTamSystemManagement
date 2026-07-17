import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/presentation/screens/main/delivery/delivery_planning.dart';
import 'package:dongtam/presentation/screens/main/delivery/delivery_prepare_goods.dart';
import 'package:dongtam/presentation/screens/main/delivery/delivery_schedule.dart';
import 'package:dongtam/presentation/screens/main/planning/planning_stop.dart';
import 'package:dongtam/presentation/screens/main/planning/production_queue/production_queue_box.dart';
import 'package:dongtam/presentation/screens/main/planning/production_queue/production_queue_paper.dart';
import 'package:dongtam/presentation/screens/main/planning/waiting_for_planing.dart';
import 'package:dongtam/presentation/screens/main/report/reportInspection/top_tab_inspection_report.dart';
import 'package:dongtam/presentation/screens/main/report/reportPlanning/top_tab_history_report.dart';
import 'package:dongtam/presentation/screens/main/report/reportWarehouse/report_inbound_history.dart';
import 'package:dongtam/presentation/screens/main/synthetic/synthetic_order.dart';
import 'package:dongtam/presentation/screens/main/synthetic/synthetic_planning.dart';
import 'package:dongtam/presentation/screens/main/warehouse/inventory.dart';
import 'package:dongtam/presentation/screens/main/warehouse/liquidation_inventory.dart';
import 'package:dongtam/presentation/screens/main/warehouse/outbound_history.dart';
import 'package:dongtam/utils/helper/home/sidebar_expanded_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import "package:dongtam/presentation/screens/main/QC/inspectionCheck/top_tab_inspection_check.dart";
import "package:dongtam/presentation/screens/main/admin/admin_criteria.dart";
import "package:dongtam/presentation/screens/main/admin/admin_order.dart";
import "package:dongtam/presentation/screens/main/admin/admin_mange_user.dart";
import "package:dongtam/presentation/screens/main/admin/admin_vehicle.dart";
import "package:dongtam/presentation/screens/main/admin/toptab/top_tab_admin_box.dart";
import "package:dongtam/presentation/screens/main/admin/toptab/top_tab_admin_criteria_check.dart";
import "package:dongtam/presentation/screens/main/admin/toptab/top_tab_admin_paper.dart";
import "package:dongtam/presentation/screens/main/customer/customer.dart";
import "package:dongtam/presentation/screens/main/manufacture/scrap_report_paper.dart";
import "package:dongtam/presentation/screens/main/delivery/delivery_estimate_time.dart";
import "package:dongtam/presentation/screens/main/employee/employee.dart";
import "package:dongtam/presentation/screens/main/manufacture/box_printing_production.dart";
import "package:dongtam/presentation/screens/main/manufacture/paper_production.dart";
import "package:dongtam/presentation/screens/main/order/top_tab_order.dart";
import "package:dongtam/presentation/screens/main/product/product.dart";
import "package:dongtam/presentation/screens/main/QC/waitingCheck/waiting_check_box.dart";
import "package:dongtam/presentation/screens/main/QC/waitingCheck/waiting_check_paper.dart";
import "package:dongtam/presentation/screens/main/QC/waitingCheck/waiting_check_scrap_report.dart";

class DepartmentExpandedMenus extends StatelessWidget {
  final String departmentKey;
  final List<Widget> pages;
  final bool isSidebarOpen;

  // Các biến trạng thái đóng mở từ HomePage chuyển qua
  final bool isPlanningExpanded;
  final bool isWarehouseExpanded;
  final bool isDeliveryExpanded;

  // Các hàm callback để thực hiện setState ở HomePage
  final VoidCallback onTogglePlanning;
  final VoidCallback onToggleWarehouse;
  final VoidCallback onToggleDelivery;

  // Hàm vẽ Item Sidebar được truyền từ HomePage sang để dùng chung style
  final Widget Function({
    required IconData icon,
    required String title,
    int? index,
    VoidCallback? onTap,
    int Function()? badgeCountSelector,
  })
  buildSidebarItem;

  const DepartmentExpandedMenus({
    super.key,
    required this.departmentKey,
    required this.pages,
    required this.isSidebarOpen,
    required this.isPlanningExpanded,
    required this.isWarehouseExpanded,
    required this.isDeliveryExpanded,
    required this.onTogglePlanning,
    required this.onToggleWarehouse,
    required this.onToggleDelivery,
    required this.buildSidebarItem,
  });

  @override
  Widget build(BuildContext context) {
    final badgesController = Get.find<BadgesController>();

    switch (departmentKey) {
      case "sales": // KINH DOANH
        return Column(
          children: [
            buildSidebarItem(
              icon: Icons.shopping_cart,
              title: "Đơn Hàng",
              index: pages.indexWhere((w) => w is TopTabOrder),
              badgeCountSelector: () => badgesController.numberOrderReject.value,
            ),
            buildSidebarItem(
              icon: Icons.person,
              title: "Khách Hàng",
              index: pages.indexWhere((w) => w is CustomerPage),
            ),
            buildSidebarItem(
              icon: Icons.inventory,
              title: "Sản Phẩm",
              index: pages.indexWhere((w) => w is ProductPage),
            ),
            buildSidebarItem(
              icon: Symbols.pending_actions,
              title: "Đăng Ký Giao Hàng",
              index: pages.indexWhere((w) => w is DeliveryEstimateTime),
            ),
          ],
        );

      case "production": // Sản Xuất
        return Column(
          children: [
            buildSidebarItem(
              icon: Icons.article,
              title: "Giấy Tấm",
              index: pages.indexWhere((w) => w is PaperProduction),
            ),
            buildSidebarItem(
              icon: Symbols.package_2,
              title: "Thùng và In ấn",
              index: pages.indexWhere((w) => w is BoxPrintingProduction),
            ),
            buildSidebarItem(
              icon: Symbols.delete_sweep,
              title: "Báo Cáo Phế Liệu",
              index: pages.indexWhere((w) => w is ScrapReportPaper),
            ),
          ],
        );

      case "operations": // Nghiệp Vụ
        return Column(
          children: [
            buildPlanningMenu(
              isSidebarOpen: isSidebarOpen,
              isExpanded: isPlanningExpanded,
              onToggle: onTogglePlanning,
              pages: pages,
            ),
          ],
        );

      case "qc": // CHẤT LƯỢNG
        return Column(
          children: [
            buildSidebarItem(
              icon: Icons.article,
              title: "Giấy Tấm",
              index: pages.indexWhere((w) => w is WaitingCheckPaper),
              badgeCountSelector: () => badgesController.numberPaperWaiting.value,
            ),
            buildSidebarItem(
              icon: Symbols.package_2,
              title: "Thùng và In ấn",
              index: pages.indexWhere((w) => w is WaitingCheckBox),
              badgeCountSelector: () => badgesController.numberBoxWaiting.value,
            ),
            buildSidebarItem(
              icon: Symbols.delete_sweep,
              title: "Chờ Kiểm Phế Liệu",
              index: pages.indexWhere((w) => w is WaitingCheckScrapReport),
              badgeCountSelector: () => badgesController.numberScrapWaiting.value,
            ),
            buildSidebarItem(
              icon: Symbols.engineering,
              title: "Tiến Trình Sản Xuất",
              index: pages.indexWhere((w) => w is TopTabInspectionCheck),
            ),
          ],
        );

      case "accountant": // KẾ TOÁN
        return Column(
          children: [
            buildSidebarItem(
              icon: Symbols.lab_profile,
              title: "Lịch Sử Xuất Kho",
              index: pages.indexWhere((w) => w is OutboundHistory),
            ),
          ],
        );

      case "hr": // NHÂN SỰ
        return Column(
          children: [
            buildSidebarItem(
              icon: Symbols.people_outline,
              title: "Nhân Viên",
              index: pages.indexWhere((w) => w is Employee),
            ),
          ],
        );

      case "logistics": // Kho Vận
        return Column(
          children: [
            buildWarehouseMenu(
              isSidebarOpen: isSidebarOpen,
              isExpanded: isWarehouseExpanded,
              onToggle: onToggleWarehouse,
              pages: pages,
            ),
            buildDeliveryMenu(
              isSidebarOpen: isSidebarOpen,
              isExpanded: isDeliveryExpanded,
              onToggle: onToggleDelivery,
              pages: pages,
            ),
          ],
        );

      case "admin": // Quản Trị
        return Column(
          children: [
            buildSidebarItem(
              icon: Icons.pending_actions,
              title: "Chờ Duyệt",
              index: pages.indexWhere((w) => w is AdminOrder),
              badgeCountSelector: () => badgesController.numberPendingApproval.value,
            ),
            buildSidebarItem(
              icon: Icons.gif_box,
              title: "Máy Sóng và Phế Liệu",
              index: pages.indexWhere((w) => w is TopTabAdminPaper),
            ),
            buildSidebarItem(
              icon: Icons.gif_box,
              title: "In Ấn và Phế Liệu",
              index: pages.indexWhere((w) => w is TopTabAdminBox),
            ),
            buildSidebarItem(
              icon: Icons.rule,
              title: "Tiêu Chí Sản Xuất",
              index: pages.indexWhere((w) => w is AdminCriteria),
            ),
            buildSidebarItem(
              icon: Icons.rule,
              title: "Tiêu Chí Kiểm Tra",
              index: pages.indexWhere((w) => w is TopTabCriteriaCheck),
            ),
            buildSidebarItem(
              icon: Symbols.directions_car,
              title: "Xe Giao Hàng",
              index: pages.indexWhere((w) => w is AdminVehicle),
            ),
            buildSidebarItem(
              icon: Icons.person,
              title: "Người Dùng",
              index: pages.indexWhere((w) => w is AdminMangeUser),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

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
        icon: Icons.article,
        label: "Sản Xuất Giấy Tấm",
        pageType: ProductionQueuePaper,
      ),
      SubMenuConfig(icon: Symbols.package_2, label: "Sản Xuất Thùng", pageType: ProductionQueueBox),
      SubMenuConfig(
        icon: Icons.queue,
        label: "Hàng Chờ Xử Lý",
        pageType: PlanningStop,
        showBadge: true,
        badge: badges.numberPlanningStop,
      ),
      SubMenuConfig(
        icon: Symbols.calendar_add_on,
        label: "Xếp Xe Giao Hàng",
        pageType: DeliveryPlanning,
        showBadge: true,
        badge: badges.numberDeliveryRequest,
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
      SubMenuConfig(
        icon: Symbols.lab_profile,
        label: "Lịch Sử Xuất Kho",
        pageType: OutboundHistory,
      ),
      SubMenuConfig(icon: Symbols.garage_home, label: "Kho Thành Phẩm", pageType: Inventory),
      SubMenuConfig(
        icon: Symbols.garage_home,
        label: "Kho Thanh Lý",
        pageType: LiquidationInventory,
      ),
    ],
  );
}

Widget buildDeliveryMenu({
  required bool isSidebarOpen,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<Widget> pages,
}) {
  final badges = Get.find<BadgesController>();

  return buildExpandedMenuHelper(
    isSidebarOpen: isSidebarOpen,
    title: "Giao Hàng",
    icon: Symbols.airport_shuttle,
    isExpanded: isExpanded,
    onToggle: onToggle,
    pages: pages,
    configs: [
      SubMenuConfig(icon: Symbols.schedule, label: "Lịch Giao Hàng", pageType: DeliverySchedule),
      SubMenuConfig(
        icon: Symbols.local_shipping,
        label: "Lệnh Xuất Hàng",
        pageType: DeliveryPrepareGoods,
        showBadge: true,
        badge: badges.numberPrepareGoods,
      ),
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
      SubMenuConfig(
        icon: Icons.engineering_outlined,
        label: "Tiến Trình Sản Xuất",
        pageType: TopTabInspectionReport,
      ),
    ],
  );
}

Widget buildSyntheticMenu({
  required bool isSidebarOpen,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<Widget> pages,
}) {
  return buildExpandedMenuHelper(
    isSidebarOpen: isSidebarOpen,
    title: "Tổng Hợp",
    icon: Symbols.analytics,
    isExpanded: isExpanded,
    onToggle: onToggle,
    pages: pages,
    configs: [
      SubMenuConfig(icon: Symbols.orders, label: "Tổng Hợp Đơn Hàng", pageType: SyntheticOrder),
      SubMenuConfig(
        icon: Symbols.dual_screen,
        label: "Tổng Hợp Sản Xuất",
        pageType: SyntheticPlanning,
      ),
    ],
  );
}

// Tổng Hợp
Widget buildSummaryMenu({
  required bool isSidebarOpen,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<Widget> pages,
}) {
  return buildExpandedMenuHelper(
    isSidebarOpen: isSidebarOpen,
    title: "Tổng Hợp",
    icon: Icons.analytics_outlined,
    isExpanded: isExpanded,
    onToggle: onToggle,
    pages: pages,
    configs: [
      SubMenuConfig(
        icon: Icons.analytics_sharp,
        label: "Tổng Hợp Sản Xuất",
        pageType: SyntheticPlanning,
      ),
      SubMenuConfig(
        icon: Icons.summarize_outlined,
        label: "Tổng Hợp Đơn Hàng",
        pageType: SyntheticOrder,
      ),
    ],
  );
}

// Báo Cáo
Widget buildReportsMenu({
  required bool isSidebarOpen,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<Widget> pages,
}) {
  return buildExpandedMenuHelper(
    isSidebarOpen: isSidebarOpen,
    title: "Báo Cáo",
    icon: Icons.assessment_outlined,
    isExpanded: isExpanded,
    onToggle: onToggle,
    pages: pages,
    configs: [
      SubMenuConfig(
        icon: Icons.analytics_outlined,
        label: "Báo Cáo Lịch Sử",
        pageType: TopTabHistoryReport,
      ),
      SubMenuConfig(
        icon: Icons.assessment_outlined,
        label: "Báo Cáo Nhập Kho",
        pageType: ReportInboundHistory,
      ),
      SubMenuConfig(
        icon: Icons.rule_folder_outlined,
        label: "Báo Cáo Nghiệm Thu",
        pageType: TopTabInspectionReport,
      ),
    ],
  );
}

//Cộng Đồng
Widget buildCommunityMenu({
  required bool isSidebarOpen,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<Widget> pages,
}) {
  return buildExpandedMenuHelper(
    isSidebarOpen: isSidebarOpen,
    title: "Cộng Đồng (Biểu mẫu)",
    icon: Icons.people_outline,
    isExpanded: isExpanded,
    onToggle: onToggle,
    pages: pages,
    configs: [
      // Sau này khi có trang biểu mẫu, bạn chỉ cần khai báo SubMenuConfig tại đây
    ],
  );
}
