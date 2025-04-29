import 'package:flutter/widgets.dart';

class AdminOrder extends StatefulWidget {
  const AdminOrder({super.key});

  @override
  State<AdminOrder> createState() => _ManageOrderState();
}

class _ManageOrderState extends State<AdminOrder> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Trang quản lý đơn hàng", style: TextStyle(fontSize: 24)),
    );
  }
}
