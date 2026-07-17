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
import 'package:flutter/material.dart';

class MenuMetadata {
  final String id;
  final String title;
  final IconData icon;
  final Type pageType;
  final List<String> departments;
  final String group;

  MenuMetadata({
    required this.id,
    required this.title,
    required this.icon,
    required this.pageType,
    this.departments = const [],
    this.group = 'department',
  });
}

// Map danh sách phòng ban
final Map<String, String> departmentsMap = {
  'sales': 'Kinh Doanh',
  'operations': 'Nghiệp Vụ',
  'production': 'Sản Xuất',
  'qc': 'Chất Lượng',
  'hr': 'Nhân Sự',
  'accountant': 'Kế Toán',
  'logistics': 'Kho Vận',
  'admin': 'Quản Lý',
};

// Danh sách phẳng chứa tất cả các màn hình của hệ thống dùng để ghim
final List<MenuMetadata> allMenuItems = [
  MenuMetadata(id: 'dashboard', title: 'Dashboard', icon: Icons.dashboard, pageType: DashboardPage),

  // Kinh doanh
  MenuMetadata(id: 'order', title: 'Đơn Hàng', icon: Icons.shopping_cart, pageType: TopTabOrder),
  MenuMetadata(id: 'customer', title: 'Khách Hàng', icon: Icons.person, pageType: CustomerPage),
  MenuMetadata(id: 'product', title: 'Sản Phẩm', icon: Icons.inventory, pageType: ProductPage),

  // Nhân sự
  MenuMetadata(id: 'employee', title: 'Nhân Viên', icon: Icons.people_outline, pageType: Employee),

  // Nghiệp vụ (Lên kế hoạch)
  MenuMetadata(
    id: 'wait_plan',
    title: 'Chờ Lên Kế Hoạch',
    icon: Icons.outbox_rounded,
    pageType: WaitingForPlanning,
  ),
  MenuMetadata(
    id: 'prod_queue_paper',
    title: 'Sản Xuất Giấy Tấm',
    icon: Icons.article,
    pageType: ProductionQueuePaper,
  ),
  MenuMetadata(
    id: 'prod_queue_box',
    title: 'Sản Xuất Thùng',
    icon: Icons.widgets,
    pageType: ProductionQueueBox,
  ),
  MenuMetadata(id: 'plan_stop', title: 'Hàng Chờ Xử Lý', icon: Icons.queue, pageType: PlanningStop),

  // Chất lượng (QC)
  MenuMetadata(
    id: 'qc_paper',
    title: 'Hàng Chờ Kiểm Giấy',
    icon: Icons.file_present,
    pageType: WaitingCheckPaper,
  ),
  MenuMetadata(
    id: 'qc_box',
    title: 'Hàng Chờ Kiểm Thùng',
    icon: Icons.task_outlined,
    pageType: WaitingCheckBox,
  ),
  MenuMetadata(
    id: 'qc_scrap',
    title: 'Chờ Kiểm Báo Phế',
    icon: Icons.delete_forever_outlined,
    pageType: WaitingCheckScrapReport,
  ),
  MenuMetadata(
    id: 'qc_inspect',
    title: 'Kiểm Tra Nghiệm Thu',
    icon: Icons.assignment_turned_in_outlined,
    pageType: TopTabInspectionCheck,
  ),

  // Sản xuất
  MenuMetadata(
    id: 'paper_prod',
    title: 'Sản Xuất Giấy',
    icon: Icons.layers_outlined,
    pageType: PaperProduction,
  ),
  MenuMetadata(
    id: 'box_prod',
    title: 'Sản Xuất Hộp/Thùng',
    icon: Icons.print_outlined,
    pageType: BoxPrintingProduction,
  ),
  MenuMetadata(
    id: 'scrap_report',
    title: 'Báo Phế Giấy',
    icon: Icons.report_gmailerrorred_outlined,
    pageType: ScrapReportPaper,
  ),

  // Kho vận
  MenuMetadata(
    id: 'outbound_hist',
    title: 'Lịch Sử Xuất Kho',
    icon: Icons.history_toggle_off,
    pageType: OutboundHistory,
  ),
  MenuMetadata(
    id: 'inventory',
    title: 'Tồn Kho',
    icon: Icons.inventory_2_outlined,
    pageType: Inventory,
  ),
  MenuMetadata(
    id: 'liq_inventory',
    title: 'Thanh Lý Tồn Kho',
    icon: Icons.sell_outlined,
    pageType: LiquidationInventory,
  ),
  MenuMetadata(
    id: 'delivery_est',
    title: 'Dự Kiến Giao Hàng',
    icon: Icons.hourglass_bottom_outlined,
    pageType: DeliveryEstimateTime,
  ),
  MenuMetadata(
    id: 'delivery_plan',
    title: 'Lên Kế Hoạch Giao',
    icon: Icons.schedule_send_outlined,
    pageType: DeliveryPlanning,
  ),
  MenuMetadata(
    id: 'delivery_sched',
    title: 'Lịch Trình Giao',
    icon: Icons.calendar_month_outlined,
    pageType: DeliverySchedule,
  ),
  MenuMetadata(
    id: 'delivery_prepare',
    title: 'Chuẩn Bị Hàng',
    icon: Icons.shopping_bag_outlined,
    pageType: DeliveryPrepareGoods,
  ),

  // Cộng đồng & Báo cáo (Dùng chung
  MenuMetadata(
    id: 'hist_report',
    title: 'Lịch Sử Báo Cáo ',
    icon: Icons.analytics_outlined,
    pageType: TopTabHistoryReport,
  ),
  MenuMetadata(
    id: 'inbound_report',
    title: 'Báo Cáo Nhập Kho',
    icon: Icons.assessment_outlined,
    pageType: ReportInboundHistory,
  ),
  MenuMetadata(
    id: 'inspect_report',
    title: 'Kiểm Tra Tiến Trình',
    icon: Icons.rule_folder_outlined,
    pageType: TopTabInspectionReport,
  ),
  MenuMetadata(
    id: 'synthetic_plan',
    title: 'Tổng Hợp Kế Hoạch',
    icon: Icons.analytics_sharp,
    pageType: SyntheticPlanning,
  ),
  MenuMetadata(
    id: 'synthetic_order',
    title: 'Tổng Hợp Đơn Hàng',
    icon: Icons.summarize_outlined,
    pageType: SyntheticOrder,
  ),

  // Admin điều hành
  MenuMetadata(
    id: 'admin_order',
    title: 'Quản Lý Đơn Admin',
    icon: Icons.assignment_ind_outlined,
    pageType: AdminOrder,
  ),
  MenuMetadata(
    id: 'admin_paper',
    title: 'Cấu Hình Giấy',
    icon: Icons.settings_outlined,
    pageType: TopTabAdminPaper,
  ),
  MenuMetadata(
    id: 'admin_box',
    title: 'Cấu Hình Thùng',
    icon: Icons.settings_applications_outlined,
    pageType: TopTabAdminBox,
  ),
  MenuMetadata(
    id: 'admin_vehicle',
    title: 'Quản Lý Xe',
    icon: Icons.directions_car_filled_outlined,
    pageType: AdminVehicle,
  ),
  MenuMetadata(
    id: 'admin_criteria',
    title: 'Tiêu Chí Đánh Giá',
    icon: Icons.checklist_rtl_outlined,
    pageType: AdminCriteria,
  ),
  MenuMetadata(
    id: 'admin_crit_check',
    title: 'Duyệt Tiêu Chí',
    icon: Icons.verified_user_outlined,
    pageType: TopTabCriteriaCheck,
  ),
  MenuMetadata(
    id: 'admin_users',
    title: 'Quản Lý User',
    icon: Icons.manage_accounts_outlined,
    pageType: AdminMangeUser,
  ),
];
