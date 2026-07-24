import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Lớp cơ sở cho các item hiển thị trực tiếp ở thanh Sidebar chính (Dashboard, Phòng ban, Đổi màu...)
abstract class SidebarItem {}

// Menu cấp 3 (Leaf): Chức năng chính
class LeafMenuConfig extends SidebarItem {
  final IconData icon;
  final String label;
  final Type? pageType; // Null nếu là Action tùy chỉnh (như đổi màu, đăng xuất)
  final VoidCallback? onTap;
  final bool showBadge;
  final RxInt? badge;

  LeafMenuConfig({
    required this.icon,
    required this.label,
    this.pageType,
    this.onTap,
    this.showBadge = false,
    this.badge,
  });

  int getIndex(List<Widget> pages) {
    if (pageType == null) return -1;
    return pages.indexWhere((w) => w.runtimeType == pageType);
  }

  bool isActive(int selectedIndex, List<Widget> pages) {
    final idx = getIndex(pages);
    return idx != -1 && selectedIndex == idx;
  }

  int getBadgeValue() => (showBadge && badge != null) ? badge!.value : 0;

  bool isVisible(List<Widget> pages) {
    if (pageType == null) return true; // Các nút chức năng hệ thống luôn hiện
    return getIndex(pages) != -1; // Ẩn nếu User không có quyền vào trang này
  }
}

// Menu cấp 2: Nhóm các chức năng với nhau
class GroupMenuConfig {
  final IconData icon;
  final String label;
  final List<LeafMenuConfig> items;

  GroupMenuConfig({required this.icon, required this.label, required this.items});

  bool isActive(int selectedIndex, List<Widget> pages) {
    return items.any((leaf) => leaf.isActive(selectedIndex, pages));
  }

  int getBadgeValue() {
    return items.fold(0, (sum, leaf) => sum + leaf.getBadgeValue());
  }

  bool isVisible(List<Widget> pages) {
    // Chỉ hiển thị Group nếu có ít nhất một chức năng con bên trong được phép truy cập
    return items.any((leaf) => leaf.isVisible(pages));
  }
}

// Menu cấp 1: Nhóm chức năng theo Phòng ban
class DepartmentMenuConfig extends SidebarItem {
  final IconData icon;
  final String label;

  /// Có thể chứa [GroupMenuConfig] (Cấp 2) hoặc [LeafMenuConfig] (Cấp 1)
  final List<dynamic> children;

  DepartmentMenuConfig({required this.icon, required this.label, required this.children});

  bool isActive(int selectedIndex, List<Widget> pages) {
    return children.any((child) {
      if (child is GroupMenuConfig) return child.isActive(selectedIndex, pages);
      if (child is LeafMenuConfig) return child.isActive(selectedIndex, pages);
      return false;
    });
  }

  int getBadgeValue() {
    return children.fold(0, (sum, child) {
      if (child is GroupMenuConfig) return sum + child.getBadgeValue();
      if (child is LeafMenuConfig) return sum + child.getBadgeValue();
      return sum;
    });
  }

  bool isVisible(List<Widget> pages) {
    // Chỉ hiển thị Phòng Ban nếu có ít nhất một menu con bên trong khả dụng
    return children.any((child) {
      if (child is GroupMenuConfig) return child.isVisible(pages);
      if (child is LeafMenuConfig) return child.isVisible(pages);
      return false;
    });
  }
}
