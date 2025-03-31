import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool checked = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: CheckboxListTile(
          value: checked,
          onChanged: (bool? value) {
            setState(() {
              checked = value!;
            });
          },
        ),
      ),
    );
  }
}
