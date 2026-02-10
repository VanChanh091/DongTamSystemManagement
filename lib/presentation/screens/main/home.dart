import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/sidebar_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/presentation/screens/auth/login.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_criteria.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_order.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_mange_user.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_vehicle.dart';
import 'package:dongtam/presentation/screens/main/admin/toptab/top_tab_admin_box.dart';
import 'package:dongtam/presentation/screens/main/admin/toptab/top_tab_admin_paper.dart';
import 'package:dongtam/presentation/screens/main/customer/customer.dart';
import 'package:dongtam/presentation/screens/main/dashboard/dashboard.dart';
import 'package:dongtam/presentation/screens/main/dashboard/dashboard_planning.dart';
import 'package:dongtam/presentation/screens/main/delivery/delivery_estimate_time.dart';
import 'package:dongtam/presentation/screens/main/delivery/delivery_schedule.dart';
import 'package:dongtam/presentation/screens/main/delivery/delivery_planning.dart';
import 'package:dongtam/presentation/screens/main/employee/employee.dart';
import 'package:dongtam/presentation/screens/main/manufacture/box_printing_production.dart';
import 'package:dongtam/presentation/screens/main/manufacture/paper_production.dart';
import 'package:dongtam/presentation/screens/main/order/top_tab_order.dart';
import 'package:dongtam/presentation/screens/main/planning/planning_stop.dart';
import 'package:dongtam/presentation/screens/main/planning/top_tab_planning.dart';
import 'package:dongtam/presentation/screens/main/planning/waiting_for_planing.dart';
import 'package:dongtam/presentation/screens/main/product/product.dart';
import 'package:dongtam/presentation/screens/main/report/report_warehouse/report_inbound_history.dart';
import 'package:dongtam/presentation/screens/main/report/reportPlanning/top_tab_history_report.dart';
import 'package:dongtam/presentation/screens/main/waitingCheck/waiting_check_box.dart';
import 'package:dongtam/presentation/screens/main/waitingCheck/waiting_check_paper.dart';
import 'package:dongtam/presentation/screens/main/warehouse/inventory.dart';
import 'package:dongtam/presentation/screens/main/warehouse/outbound_history.dart';
import 'package:dongtam/service/auth_service.dart';
import 'package:dongtam/socket/socket_service.dart';
import 'package:dongtam/utils/color/theme_picker_color.dart';
import 'package:dongtam/utils/helper/warning_unsaved_change.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dongtam/utils/helper/home/sidebar_submenu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();
  final socketService = SocketService();
  final unsavedChangeController = Get.put(UnsavedChangeController());
  final sidebarController = Get.put(SidebarController());
  final badgesController = Get.find<BadgesController>();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  bool _isSidebarOpen = false;
  bool _isPlanningExpanded = false;
  bool _isManufactureExpanded = false;
  bool _isReportExpanded = false;
  bool _isApprovalExpanded = false;
  bool _isWaitingExpanded = false;
  bool _isWarehouseExpanded = false;
  bool _isDeliveryExpanded = false;

  static const double _sidebarOpenWidth = 300;
  static const double _sidebarCollapsedWidth = 60;

  // @override
  // void initState() {
  //   super.initState();
  //   SocketService().connectSocket();
  // }

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
      _buildPage(permissions: ['plan'], child: TopTabPlanning()),
      _buildPage(permissions: ['plan'], child: PlanningStop()),

      // manufacture
      PaperProduction(),
      BoxPrintingProduction(),

      //waiting check
      _buildPage(permissions: ['QC'], child: WaitingCheckPaper()),
      _buildPage(permissions: ['QC'], child: WaitingCheckBox()),

      //outbound
      _buildPage(permissions: ['delivery'], child: OutboundHistory()),
      Inventory(),

      //delivery
      _buildPage(permissions: ['plan', 'sale'], child: DeliveryEstimateTime()),
      _buildPage(permissions: ['plan'], child: DeliveryPlanning()),
      DeliverySchedule(),

      //reporting hitstory
      TopTabHistoryReport(),
      ReportInboundHistory(),

      //dashboard planning
      DashboardPlanning(),

      // admin
      _buildPage(roles: ['admin', 'manager'], child: AdminOrder()),
      _buildPage(roles: ['admin'], child: TopTabAdminPaper()),
      _buildPage(roles: ['admin'], child: TopTabAdminBox()),
      _buildPage(roles: ['admin', 'manager'], child: AdminVehicle()),
      _buildPage(roles: ['admin'], child: AdminCriteria()),
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

  void logout() async {
    try {
      final secureStorage = SecureStorageService();
      await secureStorage.clearAll();

      await authService.logout();
      sidebarController.reset();

      socketService.off('updateBadgeCount');
      socketService.disconnect();
      //   if (Get.isRegistered<BadgesController>()) {
      //   Get.delete<BadgesController>(force: true);
      //   AppLogger.i("BadgesController has been forcibly terminated.");
      // }

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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

                      Expanded(child: _buildMenuList(pages)),
                      const Divider(color: Colors.white70),
                      _buildLogoutSection(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuList(List<Widget> pages) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebarItem(
            icon: Icons.dashboard,
            title: "Dashboard",
            index: pages.indexWhere((w) => w is DashboardPage),
          ),

          _buildSidebarItem(
            icon: Icons.shopping_cart,
            title: "Đơn Hàng",
            index: pages.indexWhere((w) => w is TopTabOrder),
            badgeCountSelector: () => badgesController.numberOrderReject.value,
          ),

          _buildSidebarItem(
            icon: Icons.person,
            title: "Khách Hàng",
            index: pages.indexWhere((w) => w is CustomerPage),
          ),

          _buildSidebarItem(
            icon: Icons.inventory,
            title: "Sản Phẩm",
            index: pages.indexWhere((w) => w is ProductPage),
          ),

          _buildSidebarItem(
            icon: Symbols.people_outline,
            title: "Nhân Viên",
            index: pages.indexWhere((w) => w is Employee),
          ),

          buildPlanningMenu(
            isSidebarOpen: _isSidebarOpen,
            isExpanded: _isPlanningExpanded,
            onToggle: () => setState(() => _isPlanningExpanded = !_isPlanningExpanded),
            pages: pages,
          ),

          buildManufactureMenu(
            isSidebarOpen: _isSidebarOpen,
            isExpanded: _isManufactureExpanded,
            onToggle: () => setState(() => _isManufactureExpanded = !_isManufactureExpanded),
            pages: pages,
          ),

          buildWaitingCheckMenu(
            isSidebarOpen: _isSidebarOpen,
            isExpanded: _isWaitingExpanded,
            onToggle: () => setState(() => _isWaitingExpanded = !_isWaitingExpanded),
            pages: pages,
          ),

          buildWarehouseMenu(
            isSidebarOpen: _isSidebarOpen,
            isExpanded: _isWarehouseExpanded,
            onToggle: () => setState(() => _isWarehouseExpanded = !_isWarehouseExpanded),
            pages: pages,
          ),

          buildDeliveryMenu(
            isSidebarOpen: _isSidebarOpen,
            isExpanded: _isDeliveryExpanded,
            onToggle: () => setState(() => _isDeliveryExpanded = !_isDeliveryExpanded),
            pages: pages,
          ),

          buildReportMenu(
            isSidebarOpen: _isSidebarOpen,
            isExpanded: _isReportExpanded,
            onToggle: () => setState(() => _isReportExpanded = !_isReportExpanded),
            pages: pages,
          ),

          _buildSidebarItem(
            icon: Symbols.dual_screen,
            title: "Tổng Hợp Sản Xuất",
            index: pages.indexWhere((w) => w is DashboardPlanning),
          ),

          buildApprovalMenu(
            isSidebarOpen: _isSidebarOpen,
            isExpanded: _isApprovalExpanded,
            onToggle: () => setState(() => _isApprovalExpanded = !_isApprovalExpanded),
            pages: pages,
          ),

          _buildSidebarItem(
            icon: Icons.color_lens,
            title: "Đổi Màu Theme",
            onTap: () => showThemeColorDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    int? index,
    VoidCallback? onTap,
    int Function()? badgeCountSelector,
  }) {
    final bool hasIndex = index != null && index != -1;

    if (!hasIndex && onTap == null) return const SizedBox.shrink();

    return hasIndex
        ? Obx(() {
          final isSelected = sidebarController.selectedIndex.value == index;
          final int totalCount = badgeCountSelector != null ? badgeCountSelector() : 0;

          final Color iconColor =
              isSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white;

          Widget leadingWidget;
          if (totalCount == 0) {
            leadingWidget = Icon(icon, color: iconColor);
          } else {
            leadingWidget =
                _isSidebarOpen
                    ? Badge.count(count: totalCount, child: Icon(icon, color: Colors.white))
                    : Badge(
                      smallSize: 8,
                      backgroundColor: Colors.red,
                      child: Icon(icon, color: Colors.white),
                    );
          }

          return _isSidebarOpen
              ? ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: leadingWidget,
                title: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white,
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                tileColor: isSelected ? Colors.white.withValues(alpha: 0.7) : Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onTap: () async {
                  if (onTap != null) {
                    onTap();
                  } else {
                    bool canNavigate = await UnsavedChangeDialog(unsavedChangeController);
                    if (canNavigate) {
                      sidebarController.changePage(index: index);
                    }
                  }
                },
              )
              : Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(child: leadingWidget),
              );
        })
        : _isSidebarOpen
        ? ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(icon, color: Colors.white),
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onTap: onTap,
        )
        : Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(child: Icon(icon, color: Colors.white)),
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

  //logout
  Widget _buildLogoutSection() {
    return _isSidebarOpen
        ? ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text("Đăng xuất", style: TextStyle(color: Colors.white, fontSize: 18)),
          onTap: () => logout(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        )
        : const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: Icon(Icons.logout, color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // UI chính
          Row(
            children: [
              buildSidebar(),
              Expanded(
                child: Obx(() {
                  final pages = getPages();
                  final index = sidebarController.selectedIndex.value;

                  Widget page;
                  if (index < 0 || index >= pages.length) {
                    page = Center(key: ValueKey('not_found'), child: Text("Trang không tồn tại"));
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

          // ✅ [CHANGED] Overlay bắt click ngoài sidebar để tự đóng
          if (_isSidebarOpen)
            Positioned(
              left: _sidebarOpenWidth,
              top: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    _isSidebarOpen = false;

                    _isPlanningExpanded = false;
                    _isManufactureExpanded = false;
                    _isReportExpanded = false;
                    _isApprovalExpanded = false;
                    _isWaitingExpanded = false;
                  });
                },
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );
  }
}
