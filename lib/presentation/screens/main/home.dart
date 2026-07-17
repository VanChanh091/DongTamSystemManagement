import "package:dongtam/data/controller/badges_controller.dart";
import "package:dongtam/data/controller/sidebar_controller.dart";
import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/controller/unsaved_change_controller.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/presentation/screens/auth/login.dart";
import "package:dongtam/presentation/screens/main/QC/inspectionCheck/top_tab_inspection_check.dart";
import "package:dongtam/presentation/screens/main/admin/admin_criteria.dart";
import "package:dongtam/presentation/screens/main/admin/admin_order.dart";
import "package:dongtam/presentation/screens/main/admin/admin_mange_user.dart";
import "package:dongtam/presentation/screens/main/admin/admin_vehicle.dart";
import "package:dongtam/presentation/screens/main/admin/toptab/top_tab_admin_box.dart";
import "package:dongtam/presentation/screens/main/admin/toptab/top_tab_admin_criteria_check.dart";
import "package:dongtam/presentation/screens/main/admin/toptab/top_tab_admin_paper.dart";
import "package:dongtam/presentation/screens/main/customer/customer.dart";
import "package:dongtam/presentation/screens/main/dashboard/dashboard.dart";
import "package:dongtam/presentation/screens/main/manufacture/scrap_report_paper.dart";
import "package:dongtam/presentation/screens/main/report/reportInspection/top_tab_inspection_report.dart";
import "package:dongtam/presentation/screens/main/synthetic/synthetic_order.dart";
import "package:dongtam/presentation/screens/main/synthetic/synthetic_planning.dart";
import "package:dongtam/presentation/screens/main/delivery/delivery_estimate_time.dart";
import "package:dongtam/presentation/screens/main/delivery/delivery_prepare_goods.dart";
import "package:dongtam/presentation/screens/main/delivery/delivery_schedule.dart";
import "package:dongtam/presentation/screens/main/delivery/delivery_planning.dart";
import "package:dongtam/presentation/screens/main/employee/employee.dart";
import "package:dongtam/presentation/screens/main/manufacture/box_printing_production.dart";
import "package:dongtam/presentation/screens/main/manufacture/paper_production.dart";
import "package:dongtam/presentation/screens/main/order/top_tab_order.dart";
import "package:dongtam/presentation/screens/main/planning/planning_stop.dart";
import "package:dongtam/presentation/screens/main/planning/production_queue/production_queue_box.dart";
import "package:dongtam/presentation/screens/main/planning/production_queue/production_queue_paper.dart";
import "package:dongtam/presentation/screens/main/planning/waiting_for_planing.dart";
import "package:dongtam/presentation/screens/main/product/product.dart";
import "package:dongtam/presentation/screens/main/report/reportWarehouse/report_inbound_history.dart";
import "package:dongtam/presentation/screens/main/report/reportPlanning/top_tab_history_report.dart";
import "package:dongtam/presentation/screens/main/QC/waitingCheck/waiting_check_box.dart";
import "package:dongtam/presentation/screens/main/QC/waitingCheck/waiting_check_paper.dart";
import "package:dongtam/presentation/screens/main/QC/waitingCheck/waiting_check_scrap_report.dart";
import "package:dongtam/presentation/screens/main/warehouse/inventory.dart";
import "package:dongtam/presentation/screens/main/warehouse/liquidation_inventory.dart";
import "package:dongtam/presentation/screens/main/warehouse/outbound_history.dart";
import "package:dongtam/service/auth_service.dart";
import "package:dongtam/socket/socket_service.dart";
import "package:dongtam/utils/color/theme_picker_color.dart";
import "package:dongtam/utils/helper/home/menu_metadata.dart";
import "package:dongtam/utils/helper/warning_unsaved_change.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/storage/secure_storage_service.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:google_fonts/google_fonts.dart";
import "package:page_transition/page_transition.dart";
import "package:dongtam/utils/helper/home/sidebar_submenu.dart";

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
  bool _isReportExpanded = false;
  bool _isWarehouseExpanded = false;
  bool _isDeliveryExpanded = false;
  bool _isSyntheticExpanded = false;
  bool _isCommunityExpanded = false; // Cộng đồng

  static const double _sidebarOpenWidth = 300;
  static const double _sidebarCollapsedWidth = 60;

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

  // build danh sách pages dựa trên role/permission
  List<Widget> getPages() {
    return [
      //dashboard
      DashboardPage(),

      _buildPage(permissions: ["sale"], child: TopTabOrder()),
      CustomerPage(),
      ProductPage(),

      //Employee
      _buildPage(permissions: ["HR"], child: Employee()),

      // planning
      _buildPage(permissions: ["plan"], child: WaitingForPlanning()),
      _buildPage(permissions: ["plan"], child: ProductionQueuePaper()),
      _buildPage(permissions: ["plan"], child: ProductionQueueBox()),
      _buildPage(permissions: ["plan"], child: PlanningStop()),

      // manufacture
      PaperProduction(),
      BoxPrintingProduction(),
      _buildPage(
        permissions: ["machine1350", "machine1900", "machine2Layer", "MachineRollPaper"],
        child: ScrapReportPaper(),
      ),

      //waiting check
      _buildPage(permissions: ["QC"], child: WaitingCheckPaper()),
      _buildPage(permissions: ["QC"], child: WaitingCheckBox()),
      _buildPage(permissions: ["QC"], child: WaitingCheckScrapReport()),
      _buildPage(permissions: ["QC"], child: TopTabInspectionCheck()),

      //outbound
      _buildPage(permissions: ["delivery", "accountant", "sale"], child: OutboundHistory()),
      Inventory(),
      LiquidationInventory(),

      //delivery
      _buildPage(permissions: ["plan", "sale"], child: DeliveryEstimateTime()),
      DeliveryPlanning(),
      DeliverySchedule(),
      _buildPage(permissions: ["delivery", "accountant"], child: DeliveryPrepareGoods()),

      //reporting hitstory
      TopTabHistoryReport(),
      ReportInboundHistory(),
      TopTabInspectionReport(),

      //synthetic
      SyntheticPlanning(),
      _buildPage(permissions: ["sale", "accountant", "plan"], child: SyntheticOrder()),

      // admin
      _buildPage(roles: ["admin", "manager"], child: AdminOrder()),
      _buildPage(roles: ["admin"], child: TopTabAdminPaper()),
      _buildPage(roles: ["admin"], child: TopTabAdminBox()),
      _buildPage(roles: ["admin", "manager"], child: AdminVehicle()),
      _buildPage(roles: ["admin"], child: AdminCriteria()),
      _buildPage(roles: ["admin"], child: TopTabCriteriaCheck()),
      _buildPage(roles: ["admin"], child: AdminMangeUser()),
    ].whereType<Widget>().toList(); // lọc bỏ null
  }

  // Widget dropdown chọn phòng ban
  Widget _buildDepartmentSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white30),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => Theme(
            data: Theme.of(context).copyWith(
              hoverColor: Colors.white.withValues(alpha: 0.1), // Màu khi rê chuột vào
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(), // Khóa không cho user cuộn tay
              child: SizedBox(
                width: _sidebarOpenWidth - 56,
                child: DropdownButton<String>(
                  value: sidebarController.selectedDepartment.value,
                  dropdownColor: themeController.currentColor.value,
                  focusColor: Colors.transparent,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      sidebarController.changeDepartment(newValue);
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                  },
                  items:
                      departmentsMap.entries.map<DropdownMenuItem<String>>((entry) {
                        return DropdownMenuItem<String>(value: entry.key, child: Text(entry.value));
                      }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
          child: SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: _isSidebarOpen ? _sidebarOpenWidth : _sidebarCollapsedWidth,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    if (_isSidebarOpen)
                      _buildLogoSection()
                    else
                      GestureDetector(
                        onTap: () => sidebarController.changePage(index: 0),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 6),
                          child: Image.asset("assets/images/logoDT.png", width: 40, height: 40),
                        ),
                      ),
                    const SizedBox(height: 16),

                    if (_isSidebarOpen) _buildDepartmentSelector(),
                    const SizedBox(height: 10),

                    Expanded(child: _buildMenuList(pages)),

                    const Divider(color: Colors.white70),
                    _buildLogoutSection(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
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
          // ================== CHUÔNG THÔNG BÁO LIÊN PHÒNG BAN ==================
          _buildSidebarItem(
            icon: Icons.notifications_active,
            title: "Thông Báo",
            onTap: () {
              // Hàm mở trang thông báo phòng ban của bạn tại đây
            },
            badgeCountSelector: () => 5,
          ),
          if (_isSidebarOpen)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.white24),
            ),

          // ================== CHỨC NĂNG CHỌN PHÒNG BAN==================
          Obx(() {
            final currentDept = sidebarController.selectedDepartment.value;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: _isSidebarOpen ? 16 : 0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isSidebarOpen) ...[
                    const Text(
                      "📋 CHỨC NĂNG PHÒNG BAN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  DepartmentExpandedMenus(
                    departmentKey: currentDept,
                    pages: pages,
                    isSidebarOpen: _isSidebarOpen,
                    isPlanningExpanded: _isPlanningExpanded,
                    isWarehouseExpanded: _isWarehouseExpanded,
                    isDeliveryExpanded: _isDeliveryExpanded,
                    onTogglePlanning:
                        () => setState(() => _isPlanningExpanded = !_isPlanningExpanded),
                    onToggleWarehouse:
                        () => setState(() => _isWarehouseExpanded = !_isWarehouseExpanded),
                    onToggleDelivery:
                        () => setState(() => _isDeliveryExpanded = !_isDeliveryExpanded),
                    buildSidebarItem: _buildSidebarItem,
                  ),
                ],
              ),
            );
          }),
          const Divider(color: Colors.white24),

          // ================== GHIM CHỨC NĂNG ==================
          if (_isSidebarOpen) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "📌 LỐI TẮT CỦA TÔI",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white70, size: 16),
                    onPressed: () => _showPinSelectorDialog(pages),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            Obx(() {
              final pinnedIds = sidebarController.pinnedItemIds;
              if (pinnedIds.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    "Chưa có lối tắt được ghim",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                );
              }
              return Column(
                children:
                    pinnedIds.map((id) {
                      final item = allMenuItems.firstWhereOrNull((m) => m.id == id);
                      if (item == null) return const SizedBox.shrink();

                      final index = pages.indexWhere((w) => w.runtimeType == item.pageType);
                      if (index == -1) return const SizedBox.shrink();

                      return _buildSidebarItem(icon: item.icon, title: item.title, index: index);
                    }).toList(),
              );
            }),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.white24),
            ),
          ],

          // ================== PHẦN CHUNG==================
          if (_isSidebarOpen) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                "👫 PHẦN CHUNG",
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),

            // Cộng đồng
            buildCommunityMenu(
              isSidebarOpen: _isSidebarOpen,
              isExpanded: _isCommunityExpanded,
              onToggle: () => setState(() => _isCommunityExpanded = !_isCommunityExpanded),
              pages: pages,
            ),

            // Tổng hợp
            buildSummaryMenu(
              isSidebarOpen: _isSidebarOpen,
              isExpanded: _isSyntheticExpanded,
              onToggle: () => setState(() => _isSyntheticExpanded = !_isSyntheticExpanded),
              pages: pages,
            ),

            // Báo cáo
            buildReportsMenu(
              isSidebarOpen: _isSidebarOpen,
              isExpanded: _isReportExpanded,
              onToggle: () => setState(() => _isReportExpanded = !_isReportExpanded),
              pages: pages,
            ),
          ],

          // Đổi màu theme
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
              ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          leadingWidget,
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? const Color.fromARGB(255, 252, 220, 41)
                                        : Colors.white,
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              : Padding(
                // Khi thu nhỏ sidebar, icon cũng khít lại tương ứng
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(child: leadingWidget),
              );
        })
        : _isSidebarOpen
        ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2), // Hạ xuống 2
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Hạ xuống 8
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        : Padding(
          padding: const EdgeInsets.symmetric(vertical: 8), // Hạ xuống 8
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

  //logo DT
  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          Image.asset("assets/images/logoDT.png", width: 150, height: 150),
          const SizedBox(height: 5),
          Text(
            "Bao Bì Đồng Tâm",
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
            title: const Text("Đăng xuất", style: TextStyle(color: Colors.white, fontSize: 17)),
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

      socketService.off("updateBadgeCount");
      socketService.disconnect();

      if (Get.isRegistered<BadgesController>()) {
        Get.delete<BadgesController>(force: true);
        AppLogger.i("BadgesController has been forcibly terminated.");
      }

      badgesController.clearAllBadge();

      if (!mounted) return;
      showSnackBarSuccess(context, "Đăng xuất thành công");

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

  void _showPinSelectorDialog(List<Widget> pages) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: const [
              Icon(Icons.push_pin, color: Color.fromARGB(255, 252, 220, 41)),
              SizedBox(width: 8),
              Text("Cấu hình Lối Tắt", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 400,
            height: 450,
            child: SingleChildScrollView(
              child: Column(
                children:
                    allMenuItems.map((item) {
                      // Chỉ cho phép ghim các trang mà User hiện tại thực sự có quyền truy cập
                      final index = pages.indexWhere((w) => w.runtimeType == item.pageType);
                      if (index == -1) return const SizedBox.shrink();

                      return Obx(() {
                        final isPinned = sidebarController.isPinned(item.id);
                        return Material(
                          color: Colors.transparent,
                          child: CheckboxListTile(
                            secondary: Icon(item.icon, color: themeController.currentColor.value),
                            title: Text(item.title, style: const TextStyle(fontSize: 16)),
                            value: isPinned,
                            activeColor: themeController.currentColor.value,
                            onChanged: (bool? value) {
                              sidebarController.togglePin(item.id);
                            },
                          ),
                        );
                      });
                    }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Đóng", style: TextStyle(color: themeController.currentColor.value)),
            ),
          ],
        );
      },
    );
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
                      key: const ValueKey("not_found"),
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
