import 'package:dongtam/data/controller/sidebar_controller.dart';
import 'package:dongtam/presentation/screens/auth/login.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_order.dart';
import 'package:dongtam/presentation/screens/main/admin/admin_mange_user.dart';
import 'package:dongtam/presentation/screens/main/admin/top_tab_admin_box.dart';
import 'package:dongtam/presentation/screens/main/admin/top_tab_admin_paper.dart';
import 'package:dongtam/presentation/screens/main/customer/customer.dart';
import 'package:dongtam/presentation/screens/main/dashboard/dashboard.dart';
import 'package:dongtam/presentation/screens/main/manufacture/box_printing_production.dart';
import 'package:dongtam/presentation/screens/main/manufacture/paper_production.dart';
import 'package:dongtam/presentation/screens/main/order/top_tab_order.dart';
import 'package:dongtam/presentation/screens/main/planning/top_tab_planning.dart';
import 'package:dongtam/presentation/screens/main/planning/waiting_for_planing.dart';
import 'package:dongtam/presentation/screens/main/product/product.dart';
import 'package:dongtam/presentation/screens/main/user/user.dart';
import 'package:dongtam/service/auth_Service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
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
  final SidebarController sidebarController = Get.put(SidebarController());
  bool _isHovered = false;
  bool _isPlanningExpanded = false;
  bool _isManufactureExpanded = false;
  bool _isApprovalExpanded = false;
  int newNotificationsCount = 1;

  final List<Widget> pages = [
    DashboardPage(),
    TopTabOrder(),
    CustomerPage(),
    ProductPage(),
    //planning
    WaitingForPlanning(), TopTabPlanning(),
    //manufacture
    PaperProduction(), BoxPrintingProduction(),
    //admin
    AdminOrder(),
    TopTabAdminPaper(),
    TopTabAdminBox(),
    AdminMangeUser(),
    UserPage(),
  ];

  void logout() async {
    try {
      await authService.logout();
      sidebarController.reset();
      showSnackBarSuccess(context, 'Đăng xuất thành công');
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: Duration(milliseconds: 500),
          child: LoginScreen(),
        ),
      );
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  void updateNotifications(int newCount) {
    setState(() {
      newNotificationsCount = newCount;
    });
  }

  BoxDecoration _sidebarDecoration() {
    return const BoxDecoration(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      color: Color(0xffcfa381),
      boxShadow: [
        BoxShadow(color: Colors.black26, offset: Offset(3, 0), blurRadius: 10),
      ],
    );
  }

  //logout
  Widget _buildLogoutSection() {
    return _isHovered
        ? ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text(
            "Đăng xuất",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onTap: logout,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        )
        : const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: Icon(Icons.logout, color: Colors.white)),
        );
  }

  //logo
  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          Image.asset('assets/images/logoDT.png', width: 150, height: 150),
          const SizedBox(height: 5),
          const Text(
            'Bao Bì Đồng Tâm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  //index for screen
  Widget buildSidebar() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isHovered ? 300 : 60,
        decoration: _sidebarDecoration(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      if (_isHovered) _buildLogoSection(),
                      const SizedBox(height: 20),
                      Expanded(child: _buildMenuList()),
                      // Notifications
                      _buildSidebarItem(
                        Icons.notifications,
                        notificationCount: newNotificationsCount,
                        "Thông báo",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: Text('Thông báo'),
                                  content: Text('Bạn có 3 thông báo mới.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Đóng"),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                      // Personal
                      _buildSidebarItem(Icons.person, "Cá Nhân", index: 12),

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

  Widget _buildMenuList() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //dashboard
          _buildSidebarItem(Icons.dashboard, "Dashboard", index: 0),
          //order
          _buildSidebarItem(Icons.shopping_cart, "Đơn Hàng", index: 1),
          //customer
          _buildSidebarItem(Icons.person, "Khách Hàng", index: 2),
          //product
          _buildSidebarItem(Icons.inventory, "Sản Phẩm", index: 3),
          //planning
          _buildPlanningMenu(),
          //manufacture
          _buildManufactureMenu(),
          //admin
          _buildApprovalMenu(),
        ],
      ),
    );
  }

  //planning
  Widget _buildPlanningMenu() {
    return Column(
      children: [
        _isHovered
            ? ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(Icons.schedule, color: Colors.white),
              title:
                  _isHovered
                      ? const Text(
                        "Kế Hoạch",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      )
                      : null,
              trailing:
                  _isHovered
                      ? Icon(
                        _isPlanningExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.white,
                        size: 20,
                      )
                      : null,
              onTap:
                  () => setState(() {
                    _isPlanningExpanded = !_isPlanningExpanded;
                  }),
            )
            : const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: Icon(Icons.schedule, color: Colors.white)),
            ),
        if (_isHovered && _isPlanningExpanded) ...[
          _buildSubMenuItem(Icons.outbox_rounded, "Chờ Lên Kế Hoạch", 4),
          _buildSubMenuItem(
            Icons.production_quantity_limits_outlined,
            "Hàng Chờ Sản Xuất",
            5,
          ),
        ],
      ],
    );
  }

  //manufacture
  Widget _buildManufactureMenu() {
    return Column(
      children: [
        _isHovered
            ? ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(Symbols.manufacturing, color: Colors.white),
              title:
                  _isHovered
                      ? const Text(
                        "Sản Xuất",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      )
                      : null,
              trailing:
                  _isHovered
                      ? Icon(
                        _isManufactureExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.white,
                        size: 20,
                      )
                      : null,
              onTap:
                  () => setState(() {
                    _isManufactureExpanded = !_isManufactureExpanded;
                  }),
            )
            : const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Icon(Symbols.manufacturing, color: Colors.white),
              ),
            ),
        if (_isHovered && _isManufactureExpanded) ...[
          _buildSubMenuItem(Symbols.article, "Giấy Tấm", 6),
          _buildSubMenuItem(Symbols.package_2, "Thùng và In ấn", 7),
        ],
      ],
    );
  }

  //admin
  Widget _buildApprovalMenu() {
    return Column(
      children: [
        _isHovered
            ? ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
              ),
              title:
                  _isHovered
                      ? const Text(
                        "Quản Lý",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      )
                      : null,
              trailing:
                  _isHovered
                      ? Icon(
                        _isApprovalExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.white,
                        size: 20,
                      )
                      : null,
              onTap:
                  () => setState(() {
                    _isApprovalExpanded = !_isApprovalExpanded;
                  }),
            )
            : const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Icon(Icons.admin_panel_settings, color: Colors.white),
              ),
            ),
        if (_isHovered && _isApprovalExpanded) ...[
          _buildSubMenuItem(Icons.pending_actions, "Chờ Duyệt", 8),
          _buildSubMenuItem(Icons.gif_box, "Máy Sóng Và Phế Liệu", 9),
          _buildSubMenuItem(Icons.gif_box, "In Ấn Và Phế Liệu", 10),
          _buildSubMenuItem(Icons.person, "Người Dùng", 11),
        ],
      ],
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String title, {
    int? index,
    int? notificationCount,
    VoidCallback? onTap,
  }) {
    return _isHovered
        ? ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          leading: Stack(
            children: [
              Icon(icon, color: Colors.white),
              if (notificationCount != null && notificationCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationCount > 9 ? "9+" : "$notificationCount",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onTap:
              onTap ??
              () {
                if (index != null) {
                  sidebarController.selectedIndex.value = index;
                  sidebarController.changePage(index);
                }
              },
        )
        : Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(child: Icon(icon, color: Colors.white)),
        );
  }

  //component for sub menu item
  Widget _buildSubMenuItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      contentPadding: EdgeInsets.only(left: _isHovered ? 32 : 16),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
      onTap: () {
        sidebarController.selectedIndex.value = index;
        sidebarController.changePage(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Row(
        children: [
          // side bar
          buildSidebar(),
          // main
          Expanded(
            child: Obx(() {
              final index = sidebarController.selectedIndex.value;
              if (index < 0 || index >= pages.length) {
                return Center(child: Text("Trang không tồn tại"));
              }
              return pages[index];
            }),
          ),
        ],
      ),
    );
  }
}
