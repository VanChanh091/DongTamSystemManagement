import 'package:flutter/material.dart';

class PlaningPage extends StatefulWidget {
  const PlaningPage({super.key});

  @override
  State<PlaningPage> createState() => _PlaningPageState();
}

class _PlaningPageState extends State<PlaningPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Trang kế hoạch", style: TextStyle(fontSize: 24)),
    );
  }
}
