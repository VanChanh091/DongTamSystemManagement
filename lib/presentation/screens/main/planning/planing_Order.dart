import 'package:flutter/material.dart';

class PlaningOrder extends StatefulWidget {
  const PlaningOrder({super.key});

  @override
  State<PlaningOrder> createState() => _PlaningPageState();
}

class _PlaningPageState extends State<PlaningOrder> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Trang kế hoạch", style: TextStyle(fontSize: 24)),
    );
  }
}
