import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/presentation/screens/main/synthetic/report/synthetic_daily_revenue.dart';
import 'package:dongtam/presentation/screens/main/synthetic/report/synthetic_monthly_revenue.dart';
import 'package:dongtam/presentation/screens/main/synthetic/report/synthetic_yearly_revenue.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopTabSyntheticRevenue extends StatefulWidget {
  const TopTabSyntheticRevenue({super.key});

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
            child: const TabBarView(
              children: [
                SyntheticDailyRevenue(),
                SyntheticMonthlyRevenue(),
                SyntheticYearlyRevenue(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
