import 'package:dongtam/data/controller/sidebar_controller.dart';
import 'package:dongtam/presentation/screens/auth/login.dart';
import 'package:dongtam/service/auth_Service.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:get/get.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final AuthService authService = AuthService();
  final SidebarController sidebarController = Get.put(SidebarController());

  final List<Widget> pages = [
    Center(child: Text('Dashboard', style: TextStyle(fontSize: 24))),
    Center(child: Text('Order', style: TextStyle(fontSize: 24))),
    Center(child: Text('Planning', style: TextStyle(fontSize: 24))),
    Center(child: Text('Product', style: TextStyle(fontSize: 24))),
    Center(child: Text('Customer', style: TextStyle(fontSize: 24))),
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
      drawer: Drawer(
        child: Container(
          color: Color(0xffcfa381),
          child: ListView(
            children: [
              DrawerHeader(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //logo
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset('assets/images/logoDT.png'),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Đồng Tâm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // menu
              ListTile(
                leading: Icon(Icons.dashboard, color: Colors.white),
                title: Text("Dashboard", style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Điều hướng đến Dashboard
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart, color: Colors.white),
                title: Text("Order", style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Điều hướng đến Order
                },
              ),
              ExpansionTile(
                leading: Icon(Icons.event_note, color: Colors.white),
                title: Text("Planning", style: TextStyle(color: Colors.white)),
                children: [
                  ListTile(
                    title: Text(
                      "Task Management",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      // Điều hướng đến Task Management
                    },
                  ),
                  ListTile(
                    title: Text(
                      "Schedule",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      // Điều hướng đến Schedule
                    },
                  ),
                ],
              ),
              ListTile(
                leading: Icon(
                  Icons.production_quantity_limits,
                  color: Colors.white,
                ),
                title: Text("Product", style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Điều hướng đến Product
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.white),
                title: Text("Customer", style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Điều hướng đến Customer
                },
              ),

              Divider(color: Colors.white),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text(
                  "Đăng xuất",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: () {
                  logout();
                },
              ),
            ],
          ),
        ),
      ),

      body: Obx(() => pages[sidebarController.selectedIndex.value]),
    );
  }
}
