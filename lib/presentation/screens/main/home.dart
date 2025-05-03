import 'package:dongtam/data/controller/sidebar_controller.dart';
import 'package:dongtam/presentation/screens/auth/login.dart';
import 'package:dongtam/presentation/screens/main/admin/pendingOrder.dart';
import 'package:dongtam/presentation/screens/main/customer/customer.dart';
import 'package:dongtam/presentation/screens/main/dashboard/dashboard.dart';
import 'package:dongtam/presentation/screens/main/order/order.dart';
import 'package:dongtam/presentation/screens/main/planning/planing_Order.dart';
import 'package:dongtam/presentation/screens/main/product/product.dart';
import 'package:dongtam/service/auth_Service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  bool _isApprovalExpanded = false;

  final List<Widget> pages = [
    DashboardPage(),
    OrderPage(),
    CustomerPage(),
    ProductPage(),
    PlaningOrder(),
    PendingOrder(),
  ];

  void logout() async {
    try {
      await authService.logout();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đăng xuất thành công")));
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

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    return _isHovered
        ? ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(icon, color: Colors.white),
          title: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onTap: () {
            sidebarController.selectedIndex.value = index;
            sidebarController.changePage(index);
          },
          horizontalTitleGap: 12,
        )
        : Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(child: Icon(icon, color: Colors.white)),
        );
  }

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

      //drawer
      // drawer: Drawer(
      //   child: Container(
      //     color: Color(0xffcfa381),
      //     child: Column(
      //       children: [
      //         DrawerHeader(
      //           child: Row(
      //             crossAxisAlignment: CrossAxisAlignment.center,
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               Image.asset(
      //                 'assets/images/logoDT.png',
      //                 width: 100,
      //                 height: 100,
      //               ),
      //               SizedBox(width: 8),
      //               Text(
      //                 'Đồng Tâm',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 26,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //         Expanded(
      //           child: ListView(
      //             children: [
      //               _buildDrawerItem(Icons.dashboard, "Dashboard", 0),
      //               _buildDrawerItem(Icons.shopping_cart, "Đơn hàng", 1),
      //               _buildDrawerItem(Icons.person, "Khách hàng", 2),
      //               _buildDrawerItem(Symbols.box, "Sản phẩm", 3),
      //               Theme(
      //                 data: Theme.of(
      //                   context,
      //                 ).copyWith(dividerColor: Colors.transparent),
      //                 child: ExpansionTile(
      //                   leading: Icon(Icons.event_note, color: Colors.white),
      //                   title: Text(
      //                     "Kế hoạch",
      //                     style: TextStyle(color: Colors.white, fontSize: 18),
      //                   ),
      //                   iconColor: Colors.white,
      //                   collapsedIconColor: Colors.white,
      //                   childrenPadding: EdgeInsets.only(left: 20),
      //                   children: [
      //                     _buildSubMenuItem(
      //                       Icons.schedule,
      //                       "Chờ lên kế hoạch",
      //                       4,
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //               Theme(
      //                 data: Theme.of(
      //                   context,
      //                 ).copyWith(dividerColor: Colors.transparent),
      //                 child: ExpansionTile(
      //                   leading: Icon(
      //                     Symbols.bookmark_manager,
      //                     color: Colors.white,
      //                   ),
      //                   title: Text(
      //                     "Quản lý",
      //                     style: TextStyle(color: Colors.white, fontSize: 18),
      //                   ),
      //                   iconColor: Colors.white,
      //                   collapsedIconColor: Colors.white,
      //                   childrenPadding: EdgeInsets.only(left: 20),
      //                   children: [
      //                     _buildSubMenuItem(Symbols.docs, "Chờ duyệt", 5),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //         Divider(),
      //         ListTile(
      //           leading: Icon(Icons.logout, color: Colors.white),
      //           title: Text(
      //             "Đăng xuất",
      //             style: TextStyle(color: Colors.white, fontSize: 16),
      //           ),
      //           onTap: logout,
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      body: Row(
        children: [
          // Thanh bên trái
          MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: _isHovered ? 300 : 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                color: Color(0xffcfa381),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(3, 0),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  if (_isHovered)
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logoDT.png',
                            width: 150,
                            height: 150,
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Bao Bì Đồng Tâm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildSidebarItem(Icons.dashboard, "Dashboard", 0),
                        _buildSidebarItem(Icons.shopping_cart, "Đơn hàng", 1),
                        _buildSidebarItem(Icons.person, "Khách hàng", 2),
                        _buildSidebarItem(Icons.inventory, "Sản phẩm", 3),

                        // --- KẾ HOẠCH ---
                        _isHovered
                            ? ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              leading: Icon(
                                Icons.schedule,
                                color: Colors.white,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Kế hoạch",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    _isPlanningExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  _isPlanningExpanded = !_isPlanningExpanded;
                                });
                              },
                            )
                            : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Icon(
                                  Icons.schedule,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                        if (_isHovered && _isPlanningExpanded) ...[
                          _buildSubMenuItem(
                            Icons.outbox_rounded,
                            "Chờ lên kế hoạch",
                            4,
                          ),
                          // _buildSubMenuItem("Đang thực hiện", 5),
                        ],

                        // --- QUẢN LÝ ---
                        _isHovered
                            ? ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              leading: Icon(
                                Icons.assignment,
                                color: Colors.white,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Quản lý",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    _isApprovalExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(
                                  () =>
                                      _isApprovalExpanded =
                                          !_isApprovalExpanded,
                                );
                              },
                            )
                            : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Icon(
                                  Icons.assignment,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                        if (_isHovered && _isApprovalExpanded) ...[
                          _buildSubMenuItem(
                            Icons.outbox_rounded,
                            "Chờ duyệt",
                            5,
                          ),
                          // _buildSubMenuItem("Đã duyệt", 7),
                        ],
                      ],
                    ),
                  ),

                  _buildSidebarItem(Icons.notifications, "Thông báo", 6),
                  _buildSidebarItem(Icons.person, "Người dùng", 7),

                  Divider(color: Colors.white70),
                  _isHovered
                      ? ListTile(
                        leading: Icon(Icons.logout, color: Colors.white),
                        title: Text(
                          "Đăng xuất",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: logout,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      )
                      : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Icon(Icons.logout, color: Colors.white),
                        ),
                      ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Nội dung chính
          Expanded(
            child: Obx(() => pages[sidebarController.selectedIndex.value]),
          ),
        ],
      ),
    );
  }
}
