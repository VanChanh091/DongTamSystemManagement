import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/presentation/screens/main/synthetic/report/sales/synthetic_daily_revenue.dart';
import 'package:dongtam/presentation/screens/main/synthetic/report/sales/synthetic_monthly_revenue.dart';
import 'package:dongtam/presentation/screens/main/synthetic/report/sales/synthetic_yearly_revenue.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum RevenueScope { synthetic, business, admin }

class TopTabSyntheticRevenue extends StatefulWidget {
  final RevenueScope scope;

  const TopTabSyntheticRevenue({super.key, this.scope = RevenueScope.synthetic});

  @override
  State<TopTabSyntheticRevenue> createState() => _TopTabSyntheticRevenueState();
}

class _TopTabSyntheticRevenueState extends State<TopTabSyntheticRevenue> {
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
                Tab(text: "Doanh Số Ngày"),
                Tab(text: "Doanh Số Tháng"),
                Tab(text: "Doanh Số Năm"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                SyntheticDailyRevenue(scope: widget.scope),
                SyntheticMonthlyRevenue(scope: widget.scope),
                SyntheticYearlyRevenue(scope: widget.scope),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopTabBusinessRevenue extends StatelessWidget {
  const TopTabBusinessRevenue({super.key});

  @override
  Widget build(BuildContext context) {
    return const TopTabSyntheticRevenue(scope: RevenueScope.business);
  }
}

class TopTabAdminRevenue extends StatelessWidget {
  const TopTabAdminRevenue({super.key});

  @override
  Widget build(BuildContext context) {
    return const TopTabSyntheticRevenue(scope: RevenueScope.admin);
  }
}
