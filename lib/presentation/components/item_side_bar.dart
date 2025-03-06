import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      // child: Container(child: ,),
    );
  }
}

// Widget _buildMenuItem(IconData icon, String title, int index) {
//     return Obx(() => ListTile(
//           leading: Icon(icon, color: Colors.white),
//           title: Text(title, style: TextStyle(color: Colors.white)),
//           tileColor: sidebarController.selectedIndex.value == index
//               ? Colors.yellow[700]
//               : null,
//           onTap: () {
//             sidebarController.changePage(index);
//             Get.back(); // Đóng drawer
//           },
//         ));
//   }
