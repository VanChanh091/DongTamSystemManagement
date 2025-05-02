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
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();
  final SidebarController sidebarController = Get.put(SidebarController());

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

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 18)),
      onTap: () {
        sidebarController.selectedIndex.value = index;
        sidebarController.changePage(index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSubMenuItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
      onTap: () {
        sidebarController.selectedIndex.value = index;
        sidebarController.changePage(index);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Container(
          color: Color(0xffcfa381),
          child: Column(
            children: [
              DrawerHeader(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logoDT.png',
                      width: 100,
                      height: 100,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Đồng Tâm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildDrawerItem(Icons.dashboard, "Dashboard", 0),
                    _buildDrawerItem(Icons.shopping_cart, "Đơn hàng", 1),
                    _buildDrawerItem(Icons.person, "Khách hàng", 2),
                    _buildDrawerItem(Symbols.box, "Sản phẩm", 3),
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Icon(Icons.event_note, color: Colors.white),
                        title: Text(
                          "Kế hoạch",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        iconColor: Colors.white,
                        collapsedIconColor: Colors.white,
                        childrenPadding: EdgeInsets.only(left: 20),
                        children: [
                          _buildSubMenuItem(
                            Icons.schedule,
                            "Chờ lên kế hoạch",
                            4,
                          ),
                        ],
                      ),
                    ),
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Icon(
                          Symbols.bookmark_manager,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Quản lý",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        iconColor: Colors.white,
                        collapsedIconColor: Colors.white,
                        childrenPadding: EdgeInsets.only(left: 20),
                        children: [
                          _buildSubMenuItem(Symbols.docs, "Chờ duyệt", 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text(
                  "Đăng xuất",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: logout,
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Color(0xffcfa381),
              // color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Builder(
                  builder:
                      (context) => IconButton(
                        icon: Icon(Icons.menu, color: Colors.black87),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    size: 28,
                    color: Colors.black87,
                  ),
                  onPressed: () {},
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    "https://static.vecteezy.com/system/resources/previews/024/983/914/original/simple-user-default-icon-free-png.png",
                  ),
                ),
                SizedBox(width: 16),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => pages[sidebarController.selectedIndex.value]),
          ),
        ],
      ),
    );
  }
}
