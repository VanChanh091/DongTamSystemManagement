import 'package:flutter/material.dart';

class AdminPlaning extends StatefulWidget {
  const AdminPlaning({super.key});

  @override
  State<AdminPlaning> createState() => _AdminPlaningState();
}

class _AdminPlaningState extends State<AdminPlaning> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Trang quản lý Ke hoach", style: TextStyle(fontSize: 24)),
    );
  }
}
