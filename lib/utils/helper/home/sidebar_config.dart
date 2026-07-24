import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/notification_controller.dart';
import 'package:dongtam/presentation/components/dialog/other/dialog_show_notification.dart';
import 'package:dongtam/presentation/screens/main/QC/inspectionCheck/top_tab_inspection_check.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_criteria.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_order.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_mange_user.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_vehicle.dart';
import 'package:dongtam/presentation/screens/main/admin/toptab/top_tab_admin_box.dart';
import 'package:dongtam/presentation/screens/main/admin/toptab/top_tab_admin_criteria_check.dart';
import 'package:dongtam/presentation/screens/main/admin/toptab/top_tab_admin_paper.dart';
import 'package:dongtam/presentation/screens/main/customer/customer.dart';
import 'package:dongtam/presentation/screens/main/dashboard/dashboard.dart';
import 'package:dongtam/presentation/screens/main/manufacture/scrap_report_paper.dart';
import 'package:dongtam/presentation/screens/main/report/reportInspection/top_tab_inspection_report.dart';
import 'package:dongtam/presentation/screens/main/synthetic/synthetic_order.dart';
import 'package:dongtam/presentation/screens/main/synthetic/synthetic_planning.dart';
import 'package:dongtam/presentation/screens/main/delivery/delivery_estimate_time.dart';
import 'package:dongtam/presentation/screens/main/delivery/delivery_prepare_goods.dart';
import 'package:dongtam/presentation/screens/main/delivery/delivery_schedule.dart';
import 'package:dongtam/presentation/screens/main/delivery/delivery_planning.dart';
import 'package:dongtam/presentation/screens/main/employee/employee.dart';
import 'package:dongtam/presentation/screens/main/manufacture/box_printing_production.dart';
import 'package:dongtam/presentation/screens/main/manufacture/paper_production.dart';
import 'package:dongtam/presentation/screens/main/order/top_tab_order.dart';
import 'package:dongtam/presentation/screens/main/planning/planning_stop.dart';
import 'package:dongtam/presentation/screens/main/planning/production_queue/production_queue_box.dart';
import 'package:dongtam/presentation/screens/main/planning/production_queue/production_queue_paper.dart';
import 'package:dongtam/presentation/screens/main/planning/waiting_for_planing.dart';
import 'package:dongtam/presentation/screens/main/product/product.dart';
import 'package:dongtam/presentation/screens/main/report/reportWarehouse/report_inbound_history.dart';
import 'package:dongtam/presentation/screens/main/report/reportPlanning/top_tab_history_report.dart';
import 'package:dongtam/presentation/screens/main/QC/waitingCheck/waiting_check_box.dart';
import 'package:dongtam/presentation/screens/main/QC/waitingCheck/waiting_check_paper.dart';
import 'package:dongtam/presentation/screens/main/QC/waitingCheck/waiting_check_scrap_report.dart';
import 'package:dongtam/presentation/screens/main/warehouse/inventory.dart';
import 'package:dongtam/presentation/screens/main/warehouse/liquidation_inventory.dart';
import 'package:dongtam/presentation/screens/main/warehouse/outbound_history.dart';
import 'package:dongtam/utils/helper/home/leaf_menu_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

List<SidebarItem> getSidebarConfigs(BadgesController badges, VoidCallback onChangeTheme) {
  final notifController = Get.find<NotificationController>();

  return [
    LeafMenuConfig(icon: Icons.dashboard, label: "Dashboard", pageType: DashboardPage),

    //notification
    LeafMenuConfig(
      icon: Icons.notifications,
      label: "Thông Báo",
      pageType: Container,
      showBadge: true,
      badge: notifController.unreadCount,
      onTap: () {
        notifController.fetchOldNotifications();
        showNotificationDialog(notifController);
      },
    ),

    // Báo Cáo và Tổng Hợp
    DepartmentMenuConfig(
      icon: Icons.analytics,
      label: "Báo Cáo & Tổng Hợp",
      children: [
        GroupMenuConfig(
          icon: Icons.stacked_bar_chart,
          label: "Tổng Hợp",
          items: [
            LeafMenuConfig(
              icon: Symbols.orders,
              label: "Tổng Hợp Đơn Hàng",
              pageType: SyntheticOrder,
            ),
            LeafMenuConfig(
              icon: Symbols.dual_screen,
              label: "Tổng Hợp Sản Xuất",
              pageType: SyntheticPlanning,
            ),
          ],
        ),
        GroupMenuConfig(
          icon: Icons.folder_shared,
          label: "Lịch Sử",
          items: [
            LeafMenuConfig(
              icon: Icons.article,
              label: "Lịch Sử Sản Xuất",
              pageType: TopTabHistoryReport,
            ),
            LeafMenuConfig(
              icon: Icons.production_quantity_limits_outlined,
              label: "Lịch Sử Nhập Kho",
              pageType: ReportInboundHistory,
            ),
            LeafMenuConfig(
              icon: Icons.engineering_outlined,
              label: "Tiến Trình Sản Xuất",
              pageType: TopTabInspectionReport,
            ),
          ],
        ),
      ],
    ),

    //PHÒNG BAN: Nhân Sự
    DepartmentMenuConfig(
      icon: Icons.people,
      label: "Nhân Sự",
      children: [
        LeafMenuConfig(icon: Symbols.people_outline, label: "Nhân Viên", pageType: Employee),
      ],
    ),

    // PHÒNG BAN: KẾ TOÁN
    DepartmentMenuConfig(
      icon: Icons.account_balance_wallet,
      label: "Kế Toán",
      children: [
        LeafMenuConfig(icon: Symbols.lab_profile, label: "Xuất Kho", pageType: OutboundHistory),
        LeafMenuConfig(icon: Symbols.garage_home, label: "Kho Thành Phẩm", pageType: Inventory),
      ],
    ),

    // PHÒNG BAN: KINH DOANH
    DepartmentMenuConfig(
      icon: Icons.business,
      label: "Kinh Doanh",
      children: [
        // GroupMenuConfig(icon: Icons.shopping_cart, label: "Quản Lý Đơn Hàng", items: []),
        LeafMenuConfig(
          icon: Icons.gavel,
          label: "Duyệt Đơn",
          pageType: AdminOrder,
          showBadge: true,
          badge: badges.numberPendingApproval,
        ),
        LeafMenuConfig(icon: Icons.assignment_turned_in, label: "Đơn Hàng", pageType: TopTabOrder),
        LeafMenuConfig(icon: Icons.person, label: "Khách Hàng", pageType: CustomerPage),
        LeafMenuConfig(icon: Icons.inventory_2, label: "Sản Phẩm", pageType: ProductPage),
        LeafMenuConfig(
          icon: Symbols.pending_actions,
          label: "Đăng Ký Giao Hàng",
          pageType: DeliveryEstimateTime,
        ),
      ],
    ),

    // PHÒNG BAN: NGHIỆP VỤ
    DepartmentMenuConfig(
      icon: Icons.business_center,
      label: "Nghiệp Vụ",
      children: [
        GroupMenuConfig(
          icon: Icons.schedule,
          label: "Kế Hoạch",
          items: [
            LeafMenuConfig(
              icon: Icons.outbox_rounded,
              label: "Chờ Lên Kế Hoạch",
              pageType: WaitingForPlanning,
              showBadge: true,
              badge: badges.numberOrderPendingPlanning,
            ),
            LeafMenuConfig(
              icon: Icons.article,
              label: "Sản Xuất Giấy Tấm",
              pageType: ProductionQueuePaper,
            ),
            LeafMenuConfig(
              icon: Icons.view_in_ar,
              label: "Sản Xuất Thùng",
              pageType: ProductionQueueBox,
            ),
            LeafMenuConfig(
              icon: Symbols.pending_actions,
              label: "Đăng Ký Giao Hàng",
              pageType: DeliveryEstimateTime,
            ),
            LeafMenuConfig(
              icon: Symbols.calendar_add_on,
              label: "Xếp Xe Giao Hàng",
              pageType: DeliveryPlanning,
              showBadge: true,
              badge: badges.numberDeliveryRequest,
            ),
          ],
        ),
        LeafMenuConfig(
          icon: Icons.queue,
          label: "Hàng Chờ Xử Lý",
          pageType: PlanningStop,
          showBadge: true,
          badge: badges.numberPlanningStop,
        ),
        LeafMenuConfig(icon: Icons.list_alt, label: "Tổng Hợp Đơn Hàng", pageType: SyntheticOrder),
      ],
    ),

    // PHÒNG BAN: SẢN XUẤT
    DepartmentMenuConfig(
      icon: Icons.precision_manufacturing,
      label: "Sản Xuất",
      children: [
        LeafMenuConfig(icon: Icons.article, label: "Giấy Tấm", pageType: PaperProduction),
        LeafMenuConfig(
          icon: Symbols.package_2,
          label: "Thùng và In ấn",
          pageType: BoxPrintingProduction,
        ),
        LeafMenuConfig(
          icon: Symbols.delete_sweep,
          label: "Báo Cáo Phế Liệu",
          pageType: ScrapReportPaper,
        ),
        LeafMenuConfig(
          icon: Icons.article,
          label: "Lịch Sử Sản Xuất",
          pageType: TopTabHistoryReport,
        ),
      ],
    ),

    // PHÒNG BAN: QC
    DepartmentMenuConfig(
      icon: Icons.fact_check,
      label: "Chất Lượng",
      children: [
        LeafMenuConfig(
          icon: Icons.article,
          label: "Giấy Tấm",
          pageType: WaitingCheckPaper,
          showBadge: true,
          badge: badges.numberPaperWaiting,
        ),
        LeafMenuConfig(
          icon: Symbols.package_2,
          label: "Thùng và In ấn",
          pageType: WaitingCheckBox,
          showBadge: true,
          badge: badges.numberBoxWaiting,
        ),
        LeafMenuConfig(
          icon: Symbols.delete_sweep,
          label: "Chờ Kiểm Phế Liệu",
          pageType: WaitingCheckScrapReport,
          showBadge: true,
          badge: badges.numberScrapWaiting,
        ),
        LeafMenuConfig(
          icon: Symbols.engineering,
          label: "Tiến Trình Sản Xuất",
          pageType: TopTabInspectionCheck,
          showBadge: true,
          badge: badges.numberScrapWaiting,
        ),
      ],
    ),

    // PHÒNG BAN: KHO VẬN
    DepartmentMenuConfig(
      icon: Icons.local_shipping,
      label: "Kho Vận",
      children: [
        GroupMenuConfig(
          icon: Icons.warehouse,
          label: "Tồn Kho",
          items: [
            LeafMenuConfig(icon: Symbols.lab_profile, label: "Xuất Kho", pageType: OutboundHistory),
            LeafMenuConfig(icon: Symbols.garage_home, label: "Kho Thành Phẩm", pageType: Inventory),
            LeafMenuConfig(
              icon: Symbols.garage_home,
              label: "Kho Thanh Lý",
              pageType: LiquidationInventory,
            ),
          ],
        ),
        GroupMenuConfig(
          label: "Giao Hàng",
          icon: Symbols.airport_shuttle,
          items: [
            LeafMenuConfig(
              icon: Symbols.schedule,
              label: "Lịch Giao Hàng",
              pageType: DeliverySchedule,
            ),
            LeafMenuConfig(
              icon: Symbols.local_shipping,
              label: "Lệnh Xuất Hàng",
              pageType: DeliveryPrepareGoods,
              showBadge: true,
              badge: badges.numberPrepareGoods,
            ),
          ],
        ),
      ],
    ),

    // ADMIN
    DepartmentMenuConfig(
      icon: Icons.admin_panel_settings,
      label: "Quản Trị Hệ Thống",
      children: [
        GroupMenuConfig(
          icon: Icons.settings_applications,
          label: "Danh Mục",
          items: [
            LeafMenuConfig(
              icon: Icons.gif_box,
              label: "Máy Sóng và Phế Liệu",
              pageType: TopTabAdminPaper,
            ),
            LeafMenuConfig(
              icon: Icons.gif_box,
              label: "In Ấn và Phế Liệu",
              pageType: TopTabAdminBox,
            ),
            LeafMenuConfig(
              icon: Symbols.directions_car,
              label: "Xe Giao Hàng",
              pageType: AdminVehicle,
            ),
            LeafMenuConfig(icon: Icons.people, label: "Người Dùng", pageType: AdminMangeUser),
          ],
        ),
        GroupMenuConfig(
          icon: Icons.admin_panel_settings,
          label: "Tiêu Chí Kiểm Tra",
          items: [
            LeafMenuConfig(icon: Icons.rule, label: "Kiểm Tra Thành Phẩm", pageType: AdminCriteria),
            LeafMenuConfig(
              icon: Icons.rule,
              label: "Tiến Trình Sản Xuất",
              pageType: TopTabCriteriaCheck,
            ),
          ],
        ),
      ],
    ),

    LeafMenuConfig(icon: Icons.color_lens, label: "Đổi Màu Theme", onTap: onChangeTheme),
  ];
}
