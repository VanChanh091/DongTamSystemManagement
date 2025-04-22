import 'package:dongtam/data/controller/sidebar_controller.dart';
import 'package:dongtam/presentation/screens/auth/login.dart';
import 'package:dongtam/presentation/screens/main/customer/customer.dart';
import 'package:dongtam/presentation/screens/main/dashboard/dashboard.dart';
import 'package:dongtam/presentation/screens/main/order/order.dart';
import 'package:dongtam/presentation/screens/main/planning/planing.dart';
import 'package:dongtam/presentation/screens/main/product/product.dart';
import 'package:dongtam/service/auth_Service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    PlaningPage(),
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

  // Hàm tạo item menu Drawer
  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 18)),
      onTap: () {
        sidebarController.selectedIndex.value = index;
        sidebarController.changePage(index);
        Navigator.pop(context); // Đóng Drawer sau khi chọn
      },
    );
  }

  // Hàm tạo sub-menu trong ExpansionTile
  Widget _buildSubMenuItem(String title, VoidCallback onTap, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, size: 35),
            onPressed: () {},
          ),
          SizedBox(width: 8),
          Container(
            color: Colors.white,
            width: 35,
            height: 35,
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://static.vecteezy.com/system/resources/previews/024/983/914/original/simple-user-default-icon-free-png.png",
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),

      //drawer
      drawer: Drawer(
        child: Container(
          color: Color(0xffcfa381),
          child: Column(
            children: [
              // Header (Logo + Title)
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

              // Menu Items
              Expanded(
                child: ListView(
                  children: [
                    _buildDrawerItem(Icons.dashboard, "Dashboard", 0),
                    _buildDrawerItem(Icons.shopping_cart, "Đơn hàng", 1),
                    _buildDrawerItem(Icons.person, "Khách hàng", 2),
                    _buildDrawerItem(Symbols.box, "Sản phẩm", 3),

                    // Expansion Tile
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
                            "Chờ lên kế hoạch",
                            () {},
                            Icons.schedule,
                          ),
                          _buildSubMenuItem(
                            "Hàng đang sản xuất",
                            () {},
                            Icons.production_quantity_limits,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Đăng xuất
              Divider(), //Đẩy xuống cuối
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

      // Nội dung hiển thị khi chọn menu
      body: Obx(() => pages[sidebarController.selectedIndex.value]),
    );
  }
}
