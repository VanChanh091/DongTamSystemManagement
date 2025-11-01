import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/sidebar_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/presentation/screens/auth/login.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_order.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_mange_user.dart';
import 'package:dongtam/presentation/screens/main/admin/top_tab_admin_box.dart';
import 'package:dongtam/presentation/screens/main/admin/top_tab_admin_paper.dart';
import 'package:dongtam/presentation/screens/main/customer/customer.dart';
import 'package:dongtam/presentation/screens/main/dashboard/dashboard.dart';
import 'package:dongtam/presentation/screens/main/employee/employee.dart';
import 'package:dongtam/presentation/screens/main/manufacture/box_printing_production.dart';
import 'package:dongtam/presentation/screens/main/manufacture/paper_production.dart';
import 'package:dongtam/presentation/screens/main/order/top_tab_order.dart';
import 'package:dongtam/presentation/screens/main/planning/top_tab_planning.dart';
import 'package:dongtam/presentation/screens/main/planning/waiting_for_planing.dart';
import 'package:dongtam/presentation/screens/main/product/product.dart';
import 'package:dongtam/presentation/screens/main/report/top_tab_report.dart';
import 'package:dongtam/service/auth_service.dart';
import 'package:dongtam/socket/socket_service.dart';
import 'package:dongtam/utils/color/theme_picker_color.dart';
import 'package:dongtam/utils/helper/warning_unsaved_change.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:page_transition/page_transition.dart';

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
  final badgesController = Get.put(BadgesController());
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  bool _isHovered = false;
  bool _isPlanningExpanded = false;
  bool _isManufactureExpanded = false;
  bool _isApprovalExpanded = false;

  @override
  void initState() {
    super.initState();
    SocketService().connectSocket();
  }

  // build danh sách pages dựa vào quyền/role
  List<Widget> getPages() {
    return [
      //dashboard
      DashboardPage(),

      _buildPage(permission: 'sale', child: TopTabOrder()),
      CustomerPage(),
      ProductPage(),

      //Employee
      _buildPage(permission: 'HR', child: Employee()),

      // planning
      _buildPage(permission: 'plan', child: WaitingForPlanning()),
      _buildPage(permission: 'plan', child: TopTabPlanning()),

      // manufacture
      PaperProduction(),
      BoxPrintingProduction(),

      //report
      TopTabReport(),

      // admin
      _buildPage(roles: ['admin', 'manager'], child: AdminOrder()),
      _buildPage(roles: ['admin'], child: TopTabAdminPaper()),
      _buildPage(roles: ['admin'], child: TopTabAdminBox()),
      _buildPage(roles: ['admin'], child: AdminMangeUser()),
    ].whereType<Widget>().toList(); // lọc bỏ null
  }

  Widget? _buildPage({String? permission, List<String>? roles, Widget? child}) {
    final role = userController.role.value;

    if (roles != null && roles.isNotEmpty) {
      if (!roles.contains(role)) return null;
    } else {
      if (role == "admin" || role == "manager") return child;
    }

    if (roles != null && roles.isNotEmpty && !roles.contains(role)) {
      return null;
    }

    if (permission != null && !userController.hasAnyPermission(permission: [permission])) {
      return null;
    }

    return child;
  }

  void logout() async {
    try {
      final secureStorage = SecureStorageService();
      await secureStorage.deleteToken();
      await secureStorage.deleteRole();
      await secureStorage.deletePermission();

      await authService.logout();
      sidebarController.reset();

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

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isHovered ? 300 : 60,
        decoration: _sidebarDecoration(themeController.currentColor.value),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      //logo DT
                      if (_isHovered)
                        _buildLogoSection()
                      else
                        Image.asset('assets/images/logoDT.png', width: 40, height: 40),
                      const SizedBox(height: 20),
                      //menu
                      Expanded(child: _buildMenuList(pages)),
                      const Divider(color: Colors.white70),
                      //logo logout
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
            Icons.dashboard,
            "Dashboard",
            index: pages.indexWhere((w) => w is DashboardPage),
          ),
          _buildSidebarItem(
            Icons.shopping_cart,
            "Đơn Hàng",
            index: pages.indexWhere((w) => w is TopTabOrder),
          ),
          _buildSidebarItem(
            Icons.person,
            "Khách Hàng",
            index: pages.indexWhere((w) => w is CustomerPage),
          ),
          _buildSidebarItem(
            Icons.inventory,
            "Sản Phẩm",
            index: pages.indexWhere((w) => w is ProductPage),
          ),
          _buildSidebarItem(
            Symbols.people_outline,
            "Nhân Viên",
            index: pages.indexWhere((w) => w is Employee),
          ),
          _buildPlanningMenu(pages),
          _buildManufactureMenu(pages),
          _buildSidebarItem(
            Symbols.assignment,
            "Lịch Sử Sản Xuất",
            index: pages.indexWhere((w) => w is TopTabReport),
          ),
          _buildApprovalMenu(pages),
          _buildSidebarItem(
            Icons.color_lens,
            "Đổi Màu Theme",
            onTap: () => showThemeColorDialog(context),
          ),
        ],
      ),
    );
  }

  //planning
  Widget _buildPlanningMenu(List<Widget> pages) {
    final waitingIndex = pages.indexWhere((w) => w is WaitingForPlanning);
    final planningIndex = pages.indexWhere((w) => w is TopTabPlanning);

    if (waitingIndex == -1 && planningIndex == -1) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final selected = sidebarController.selectedIndex.value;
      final isParentSelected = selected == waitingIndex || selected == planningIndex;

      return Column(
        children: [
          _isHovered
              ? ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(
                  Icons.schedule,
                  color: isParentSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white,
                ),
                title: Text(
                  "Kế Hoạch",
                  style: TextStyle(
                    color:
                        isParentSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white,
                    fontSize: 18,
                    fontWeight: isParentSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: Icon(
                  _isPlanningExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                  size: 20,
                ),
                onTap: () => setState(() => _isPlanningExpanded = !_isPlanningExpanded),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Icon(
                    Icons.schedule,
                    color:
                        isParentSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white,
                  ),
                ),
              ),
          if (_isHovered && _isPlanningExpanded) ...[
            if (waitingIndex != -1)
              _buildSubMenuItem(Icons.outbox_rounded, "Chờ Lên Kế Hoạch", waitingIndex),
            if (planningIndex != -1)
              _buildSubMenuItem(
                Icons.production_quantity_limits_outlined,
                "Hàng Chờ Sản Xuất",
                planningIndex,
              ),
          ],
        ],
      );
    });
  }

  //manufacture
  Widget _buildManufactureMenu(List<Widget> pages) {
    final paperIndex = pages.indexWhere((w) => w is PaperProduction);
    final boxIndex = pages.indexWhere((w) => w is BoxPrintingProduction);

    if (paperIndex == -1 && boxIndex == -1) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final selected = sidebarController.selectedIndex.value;
      final isParentSelected = selected == paperIndex || selected == boxIndex;

      return Column(
        children: [
          _isHovered
              ? ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(
                  Symbols.manufacturing,
                  color: isParentSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white,
                ),
                title: Text(
                  "Sản Xuất",
                  style: TextStyle(
                    color:
                        isParentSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white,
                    fontSize: 18,
                    fontWeight: isParentSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: Icon(
                  _isManufactureExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                  size: 20,
                ),
                onTap: () => setState(() => _isManufactureExpanded = !_isManufactureExpanded),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Icon(
                    Symbols.manufacturing,
                    color:
                        isParentSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white,
                  ),
                ),
              ),
          if (_isHovered && _isManufactureExpanded) ...[
            if (paperIndex != -1) _buildSubMenuItem(Icons.article, "Giấy Tấm", paperIndex),
            if (boxIndex != -1) _buildSubMenuItem(Symbols.package_2, "Thùng và In ấn", boxIndex),
          ],
        ],
      );
    });
  }

  //admin
  Widget _buildApprovalMenu(List<Widget> pages) {
    final adminOrderIndex = pages.indexWhere((w) => w is AdminOrder);
    final adminPaperIndex = pages.indexWhere((w) => w is TopTabAdminPaper);
    final adminBoxIndex = pages.indexWhere((w) => w is TopTabAdminBox);
    final manageUserIndex = pages.indexWhere((w) => w is AdminMangeUser);

    if (adminOrderIndex == -1 &&
        adminPaperIndex == -1 &&
        adminBoxIndex == -1 &&
        manageUserIndex == -1) {
      return const SizedBox.shrink();
    }

    final badgesController = Get.find<BadgesController>();

    return Obx(() {
      final selected = sidebarController.selectedIndex.value;
      final isParentSelected =
          selected == adminOrderIndex ||
          selected == adminPaperIndex ||
          selected == adminBoxIndex ||
          selected == manageUserIndex;

      return Column(
        children: [
          _isHovered
              ? ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Obx(() {
                  final count = badgesController.numberBadges.value;
                  if (count == 0) {
                    return Icon(
                      Icons.admin_panel_settings,
                      color:
                          isParentSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white,
                    );
                  }
                  return Badge.count(
                    count: count,
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white),
                  );
                }),
                title: Text(
                  "Quản Lý",
                  style: TextStyle(
                    color:
                        isParentSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white,
                    fontSize: 18,
                    fontWeight: isParentSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: Icon(
                  _isApprovalExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                  size: 20,
                ),
                onTap:
                    () => setState(() {
                      _isApprovalExpanded = !_isApprovalExpanded;
                    }),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Obx(() {
                    final count = badgesController.numberBadges.value;
                    if (count == 0) {
                      return Icon(
                        Icons.admin_panel_settings,
                        color:
                            isParentSelected
                                ? const Color.fromARGB(255, 252, 220, 41)
                                : Colors.white,
                      );
                    }
                    return Badge(
                      smallSize: 8, // chấm đỏ nhỏ
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.admin_panel_settings,
                        color:
                            isParentSelected
                                ? const Color.fromARGB(255, 252, 220, 41)
                                : Colors.white,
                      ),
                    );
                  }),
                ),
              ),
          if (_isHovered && _isApprovalExpanded) ...[
            if (adminOrderIndex != -1)
              _buildSubMenuItem(
                Icons.pending_actions,
                "Chờ Duyệt",
                adminOrderIndex,
                leadingWrapper: Obx(() {
                  final count = badgesController.numberBadges.value;
                  if (count == 0) {
                    return const Icon(Icons.pending_actions, color: Colors.white);
                  }
                  return Badge.count(
                    count: count,
                    child: const Icon(Icons.pending_actions, color: Colors.white),
                  );
                }),
              ),
            if (adminPaperIndex != -1)
              _buildSubMenuItem(Icons.gif_box, "Máy Sóng Và Phế Liệu", adminPaperIndex),
            if (adminBoxIndex != -1)
              _buildSubMenuItem(Icons.gif_box, "In Ấn Và Phế Liệu", adminBoxIndex),
            if (manageUserIndex != -1)
              _buildSubMenuItem(Icons.person, "Người Dùng", manageUserIndex),
          ],
        ],
      );
    });
  }

  Widget _buildSidebarItem(IconData icon, String title, {int? index, VoidCallback? onTap}) {
    final bool hasIndex = index != null && index != -1;

    return hasIndex
        ? Obx(() {
          final isSelected = sidebarController.selectedIndex.value == index;

          return _isHovered
              ? ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(
                  icon,
                  color: isSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white,
                ),
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
                child: Center(
                  child: Icon(
                    icon,
                    color: isSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white,
                  ),
                ),
              );
        })
        : _isHovered
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

  Widget _buildSubMenuItem(IconData icon, String title, int index, {Widget? leadingWrapper}) {
    if (index == -1) return const SizedBox.shrink();

    return Obx(() {
      final isSelected = sidebarController.selectedIndex.value == index;

      return ListTile(
        leading:
            leadingWrapper ??
            Icon(icon, color: isSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white),
        contentPadding: EdgeInsets.only(left: _isHovered ? 32 : 16),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        tileColor:
            isSelected
                ? Colors.white.withValues(alpha: 0.7)
                : const Color.fromARGB(255, 252, 220, 41),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () async {
          bool canNavigate = await UnsavedChangeDialog(unsavedChangeController);
          if (canNavigate) {
            sidebarController.changePage(index: index);
          }
        },
      );
    });
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
    return _isHovered
        ? ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text("Đăng xuất", style: TextStyle(color: Colors.white, fontSize: 18)),
          onTap: () {
            logout();
            socketService.disconnect();
          },
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
          const Text(
            'Bao Bì Đồng Tâm',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          buildSidebar(),
          Expanded(
            child: Obx(() {
              final pages = getPages();
              final index = sidebarController.selectedIndex.value;

              // Xác định trang hiện tại
              Widget page;
              if (index < 0 || index >= pages.length) {
                page = Center(key: ValueKey('not_found'), child: Text("Trang không tồn tại"));
              } else {
                page = Container(
                  key: ValueKey(index), // key duy nhất cho mỗi trang
                  child: pages[index],
                );
              }

              // AnimatedSwitcher cho hiệu ứng chuyển trang
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut, // cong mượt hơn
                    ),
                  );

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
    );
  }
}
