import 'package:dongtam/data/controller/sidebar_controller.dart';
import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:dongtam/utils/helper/home/sidebar_submenu.dart';
import 'package:dongtam/utils/helper/sidebar_expanded_menu.dart';
import 'package:dongtam/utils/helper/warning_unsaved_change.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildExpandedMenuHelper({
  required bool isSidebarOpen,
  required String title,
  required IconData icon,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<Widget> pages,
  required List<SubMenuConfig> configs,
}) {
  final sidebarController = Get.find<SidebarController>();

  // 1. Tự động tính toán index và lọc các menu hợp lệ
  final activeItems =
      configs
          .map((c) => {'index': c.getIndex(pages), 'config': c})
          .where((item) => item['index'] != -1)
          .toList();

  if (activeItems.isEmpty) return const SizedBox.shrink();

  return Obx(() {
    final selected = sidebarController.selectedIndex.value;
    final isParentSelected = activeItems.any((item) => item['index'] == selected);

    // 2. Logic Leading Icon (Badge cho menu cha)
    int totalCount = activeItems.fold(0, (sum, item) {
      final config = item['config'] as SubMenuConfig;
      return sum + (config.badge?.value ?? 0);
    });

    Widget buildLeading() {
      if (totalCount == 0) {
        return Icon(
          icon,
          color: isParentSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white,
        );
      }
      // Sidebar mở hiện số, đóng hiện chấm đỏ nhỏ
      return isSidebarOpen
          ? Badge.count(count: totalCount, child: Icon(icon, color: Colors.white))
          : Badge(
            smallSize: 8,
            backgroundColor: Colors.red,
            child: Icon(icon, color: Colors.white),
          );
    }

    return SidebarExpandedMenu(
      isSidebarOpen: isSidebarOpen,
      isExpanded: isExpanded,
      onToggle: onToggle,
      isParentSelected: isParentSelected,
      title: title,
      icon: icon,
      leading: buildLeading(),
      children:
          activeItems.map((item) {
            final config = item['config'] as SubMenuConfig;
            final idx = item['index'] as int;

            int currentSubBadge = config.badge?.value ?? 0;

            Widget? customLeading;
            if (config.showBadge && currentSubBadge > 0) {
              customLeading = Badge.count(
                count: currentSubBadge,
                child: Icon(config.icon, color: Colors.white),
              );
            }

            return buildSubMenuItem(
              isSidebarOpen: isSidebarOpen,
              icon: config.icon,
              title: config.label,
              index: idx,
              leadingWrapper: customLeading,
            );
          }).toList(),
    );
  });
}

Widget buildSubMenuItem({
  required bool isSidebarOpen,
  required IconData icon,
  required String title,
  required int index,
  Widget? leadingWrapper,
}) {
  if (index == -1) return const SizedBox.shrink();

  final sidebarController = Get.find<SidebarController>(); //change page
  final unsavedChangeController = Get.find<UnsavedChangeController>();

  return Obx(() {
    final isSelected = sidebarController.selectedIndex.value == index;

    return ListTile(
      leading:
          leadingWrapper ??
          Icon(icon, color: isSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white),
      contentPadding: EdgeInsets.only(left: isSidebarOpen ? 32 : 16),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color.fromARGB(255, 252, 220, 41) : Colors.white,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor:
          isSelected
              ? Colors.white.withValues(alpha: 0.7)
              : const Color.fromARGB(255, 252, 220, 41),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () async {
        bool canNavigate = await UnsavedChangeDialog(unsavedChangeController);
        if (canNavigate) {
          sidebarController.changePage(index: index);
        }
      },
    );
  });
}
