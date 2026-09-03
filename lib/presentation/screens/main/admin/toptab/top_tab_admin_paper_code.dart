import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/paperCode/paper_classification.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/paperCode/supplier_paper_code.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopTabAdminPaperCode extends StatefulWidget {
  const TopTabAdminPaperCode({super.key});

  @override
  State<TopTabAdminPaperCode> createState() => _TopTabAdminPaperCodeState();
}

class _TopTabAdminPaperCodeState extends State<TopTabAdminPaperCode> {
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: themeController.backgroundColor.value,
            child: TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.red,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: const [
                Tab(text: "Phân Loại Giấy Theo NCC"),
                Tab(text: "Phân Loại Cấp Độ Giấy"),
              ],
            ),
          ),
          Expanded(child: const TabBarView(children: [SupplierPaperCode(), PaperClassification()])),
        ],
      ),
    );
  }
}
