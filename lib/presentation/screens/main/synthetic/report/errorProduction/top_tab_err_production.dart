import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/presentation/screens/main/synthetic/report/errorProduction/synthetic_monthly_err_production.dart';
import 'package:dongtam/presentation/screens/main/synthetic/report/errorProduction/synthetic_yearly_err_production.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ErrScope { synthetic, business, admin }

class TopTabErrProduction extends StatefulWidget {
  final ErrScope scope;

  const TopTabErrProduction({super.key, this.scope = ErrScope.synthetic});

  @override
  State<TopTabErrProduction> createState() => _TopTabErrProductionState();
}

class _TopTabErrProductionState extends State<TopTabErrProduction> {
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
              tabs: const [Tab(text: "Lỗi Vận Hành"), Tab(text: "Tỷ Lệ Lỗi")],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                SyntheticMonthlyErrProduction(scope: widget.scope),
                SyntheticYearlyErrProduction(scope: widget.scope),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopTabBusinessErrProduction extends StatelessWidget {
  const TopTabBusinessErrProduction({super.key});

  @override
  Widget build(BuildContext context) {
    return const TopTabErrProduction(scope: ErrScope.business);
  }
}

class TopTabAdminErrProduction extends StatelessWidget {
  const TopTabAdminErrProduction({super.key});

  @override
  Widget build(BuildContext context) {
    return const TopTabErrProduction(scope: ErrScope.admin);
  }
}
