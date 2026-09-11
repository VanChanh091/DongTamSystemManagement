import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/paperCode/Supplier.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/paperCode/paper_basis_weight.dart';
import 'package:dongtam/presentation/screens/main/admin/tabChildAdmin/paperCode/paper_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopTabAdminPaperType extends StatefulWidget {
  const TopTabAdminPaperType({super.key});

  @override
  State<TopTabAdminPaperType> createState() => _TopTabAdminPaperTypeState();
}

class _TopTabAdminPaperTypeState extends State<TopTabAdminPaperType> {
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
                Tab(text: "Nhà Cung Cấp"),
                Tab(text: "Ký Hiệu Loại Giấy"),
                Tab(text: "Ký Hiệu Định Lượng"),
              ],
            ),
          ),
          Expanded(
            child: const TabBarView(children: [Supplier(), PaperType(), PaperBasisWeight()]),
          ),
        ],
      ),
    );
  }
}
