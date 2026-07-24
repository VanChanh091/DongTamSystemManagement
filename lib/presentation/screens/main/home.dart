import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/notification_controller.dart';
import 'package:dongtam/data/controller/sidebar_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/presentation/screens/auth/login.dart';
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
import 'package:dongtam/service/auth_service.dart';
import 'package:dongtam/socket/socket_service.dart';
import 'package:dongtam/utils/color/theme_picker_color.dart';
import 'package:dongtam/utils/helper/home/leaf_menu_config.dart';
import 'package:dongtam/utils/helper/home/sidebar_config.dart';
import 'package:dongtam/utils/helper/home/sidebar_three_level.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final List<SidebarItem> _cachedMenuConfigs;
  final AuthService authService = AuthService();
  final socketService = SocketService();

  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final badgesController = Get.find<BadgesController>();
  final sidebarController = Get.put(SidebarController());
  final notiController = Get.find<NotificationController>();
  final unsavedChangeController = Get.put(UnsavedChangeController());

  bool _isSidebarOpen = false;

  static const double _sidebarOpenWidth = 310;
  static const double _sidebarCollapsedWidth = 60;

  @override
  void initState() {
    super.initState();
    _cachedMenuConfigs = getSidebarConfigs(badgesController, () => showThemeColorDialog(context));
  }

  // build danh sách pages dựa vào quyền/role
  List<Widget> getPages() {
    return [
      //dashboard
      DashboardPage(),

      _buildPage(permissions: ['sale'], child: TopTabOrder()),
      CustomerPage(),
      ProductPage(),

      //Employee
      _buildPage(permissions: ['HR'], child: Employee()),

      // planning
      _buildPage(permissions: ['plan'], child: WaitingForPlanning()),
      _buildPage(permissions: ['plan'], child: ProductionQueuePaper()),
      _buildPage(permissions: ['plan'], child: ProductionQueueBox()),
      _buildPage(permissions: ['plan'], child: PlanningStop()),

      // manufacture
      PaperProduction(),
      BoxPrintingProduction(),
      _buildPage(
        permissions: ["machine1350", "machine1900", "machine2Layer", "MachineRollPaper"],
        child: ScrapReportPaper(),
      ),

      //waiting check
      _buildPage(permissions: ['QC'], child: WaitingCheckPaper()),
      _buildPage(permissions: ['QC'], child: WaitingCheckBox()),
      _buildPage(permissions: ['QC'], child: WaitingCheckScrapReport()),
      _buildPage(permissions: ['QC'], child: TopTabInspectionCheck()),

      //outbound
      _buildPage(permissions: ['delivery', 'accountant', 'sale'], child: OutboundHistory()),
      Inventory(),
      LiquidationInventory(),

      //delivery
      _buildPage(permissions: ['plan', 'sale'], child: DeliveryEstimateTime()),
      DeliveryPlanning(),
      DeliverySchedule(),
      _buildPage(permissions: ['delivery', 'accountant'], child: DeliveryPrepareGoods()),

      //reporting hitstory
      TopTabHistoryReport(),
      ReportInboundHistory(),
      TopTabInspectionReport(),

      //synthetic
      SyntheticPlanning(),
      _buildPage(permissions: ['sale', 'accountant', 'plan'], child: SyntheticOrder()),

      // admin
      _buildPage(roles: ['admin', 'manager'], child: AdminOrder()),
      _buildPage(roles: ['admin'], child: TopTabAdminPaper()),
      _buildPage(roles: ['admin'], child: TopTabAdminBox()),
      _buildPage(roles: ['admin', 'manager'], child: AdminVehicle()),
      _buildPage(roles: ['admin'], child: AdminCriteria()),
      _buildPage(roles: ['admin'], child: TopTabCriteriaCheck()),
      _buildPage(roles: ['admin'], child: AdminMangeUser()),
    ].whereType<Widget>().toList(); // lọc bỏ null
  }

  Widget? _buildPage({List<String>? permissions, List<String>? roles, Widget? child}) {
    final role = userController.role.value;

    if (roles != null && roles.isNotEmpty && !roles.contains(role)) {
      return null;
    } else {
      if (role == "admin" || role == "manager") return child;
    }

    if (permissions != null && permissions.isNotEmpty) {
      if (!userController.hasAnyPermission(permission: permissions)) {
        return null;
      }
    }

    return child;
  }

  //sidebar
  Widget buildSidebar() {
    final pages = getPages();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,

      onTap: () {
        if (!_isSidebarOpen) {
          setState(() => _isSidebarOpen = true);
        }
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isSidebarOpen ? _sidebarOpenWidth : _sidebarCollapsedWidth,
        decoration: _sidebarDecoration(themeController.currentColor.value),

        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              const SizedBox(height: 8),

              if (_isSidebarOpen)
                _buildLogoSection()
              else
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 6),
                  child: Image.asset('assets/images/logoDT.png', width: 40, height: 40),
                ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: _buildMenuList(pages),
                ),
              ),

              const Divider(color: Colors.white70, height: 1),
              _buildLogoutSection(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList(List<Widget> pages) {
    return SidebarThreeLevel(
      isSidebarOpen: _isSidebarOpen,
      onSidebarToggle: (open) {
        setState(() => _isSidebarOpen = open);
      },
      pages: pages,
      menuConfigs: _cachedMenuConfigs,
    );
  }

  BoxDecoration _sidebarDecoration(Color color) {
    return BoxDecoration(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      color: color,
      boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(3, 0), blurRadius: 10)],
    );
  }

  //logo DT
  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          Image.asset('assets/images/logoDT.png', width: 150, height: 150),
          const SizedBox(height: 5),
          Text(
            'Bao Bì Đồng Tâm',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  //logout
  Widget _buildLogoutSection() {
    return _isSidebarOpen
        ? Material(
          color: Colors.transparent,
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text("Đăng xuất", style: TextStyle(color: Colors.white, fontSize: 18)),
            onTap: () => {logout(), badgesController.stopTimer()},
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        )
        : const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: Icon(Icons.logout, color: Colors.white)),
        );
  }

  void logout() async {
    try {
      final secureStorage = SecureStorageService();
      await secureStorage.clearAll();

      await authService.logout();
      sidebarController.reset();

      socketService.off('updateBadgeCount');
      socketService.disconnect();

      if (Get.isRegistered<BadgesController>()) {
        Get.delete<BadgesController>(force: true);
        AppLogger.i("BadgesController has been forcibly terminated.");
      }

      if (Get.isRegistered<NotificationController>()) {
        Get.delete<NotificationController>(force: true);
        AppLogger.i("NotificationController has been forcibly terminated.");
      }

      badgesController.clearAllBadge();

      if (!mounted) return;
      showSnackBarSuccess(context, 'Đăng xuất thành công');

      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: Duration(milliseconds: 500),
          child: LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e, s) {
      AppLogger.e("Lỗi khi đăng xuất", error: e, stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Row(
            children: [
              buildSidebar(),

              Expanded(
                child: Obx(() {
                  final pages = getPages();
                  final index = sidebarController.selectedIndex.value;

                  Widget page;
                  if (index < 0 || index >= pages.length) {
                    page = Center(
                      key: const ValueKey('not_found'),
                      child: const Text("Trang không tồn tại"),
                    );
                  } else {
                    page = Container(key: ValueKey(index), child: pages[index]);
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offsetAnimation, child: child),
                      );
                    },
                    child: page,
                  );
                }),
              ),
            ],
          ),

          // OVERLAY: Bắt click ngoài sidebar để tự đóng
          if (_isSidebarOpen)
            Positioned(
              left: _sidebarOpenWidth,
              top: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() => _isSidebarOpen = false);
                },
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );
  }
}
