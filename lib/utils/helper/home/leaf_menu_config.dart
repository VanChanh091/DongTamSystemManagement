import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/utils/helper/home/page_rule.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// Lớp cơ sở cho các item hiển thị trực tiếp ở thanh Sidebar chính (Dashboard, Phòng ban, Đổi màu...)
abstract class SidebarItem {}

// Menu cấp 3 (Leaf): Chức năng chính
class LeafMenuConfig extends SidebarItem {
  final IconData icon;
  final String label;
  final Type? pageType; // Null nếu là Action tùy chỉnh (như đổi màu, đăng xuất)
  final VoidCallback? onTap;
  final RxInt? badge;
  final PageRule? rule;

  LeafMenuConfig({
    required this.icon,
    required this.label,
    this.pageType,
    this.onTap,
    this.badge,
    this.rule,
  });
  bool get showBadge => badge != null;

  int getIndex(Map<Type, int> pageTypeMap) {
    if (pageType == null) return -1;
    return pageTypeMap[pageType] ?? -1;
  }

  bool isActive(int selectedIndex, Map<Type, int> pageTypeMap) {
    final idx = getIndex(pageTypeMap);
    return idx != -1 && selectedIndex == idx;
  }

  int getBadgeValue() => (showBadge && badge != null) ? badge!.value : 0;

  bool isVisible({required Map<Type, int> pageTypeMap, required UserController userController}) {
    if (pageType == null) return true; // Các nút chức năng hệ thống luôn hiện

    // Nếu User hoàn toàn không có quyền mở trang này
    if (!pageTypeMap.containsKey(pageType)) return false;

    // Nếu vị trí menu này có đặt điều kiện riêng -> Kiểm tra thêm rule
    if (rule != null) {
      return userController.canAccess(
        departments: rule!.departments,
        managerDept: rule!.managerDept,
        permissions: rule!.permissions,
        roles: rule!.roles,
        requireDept: rule!.requireDept,
      );
    }

    return true;
  }
}

// Menu cấp 2: Nhóm các chức năng với nhau
class GroupMenuConfig {
  final IconData icon;
  final String label;
  final List<LeafMenuConfig> items;
  final PageRule? rule;

  GroupMenuConfig({required this.icon, required this.label, required this.items, this.rule});

  bool isActive({required Map<Type, int> pageTypeMap, required UserController userController}) {
    // Kiểm tra quyền của chính Group này trước
    if (rule != null) {
      final canAccess = userController.canAccess(
        departments: rule!.departments,
        managerDept: rule!.managerDept,
        permissions: rule!.permissions,
        roles: rule!.roles,
        requireDept: rule!.requireDept,
      );
      if (!canAccess) return false;
    }

    return items.any(
      (leaf) => leaf.isVisible(pageTypeMap: pageTypeMap, userController: userController),
    );
  }

  int getBadgeValue({required Map<Type, int> pageTypeMap, required UserController userController}) {
    return items.fold(0, (sum, leaf) {
      if (!leaf.isVisible(pageTypeMap: pageTypeMap, userController: userController)) {
        return sum;
      }
      return sum + leaf.getBadgeValue();
    });
  }

  bool isVisible({required Map<Type, int> pageTypeMap, required UserController userController}) {
    // Chỉ hiển thị Group nếu có ít nhất một chức năng con bên trong được phép truy cập
    return items.any(
      (leaf) => leaf.isVisible(pageTypeMap: pageTypeMap, userController: userController),
    );
  }
}

// Menu cấp 1: Nhóm chức năng theo Phòng ban
class DepartmentMenuConfig extends SidebarItem {
  final IconData icon;
  final String label;

  /// Có thể chứa [GroupMenuConfig] (Cấp 2) hoặc [LeafMenuConfig] (Cấp 1)
  final List<dynamic> children;
  final PageRule? rule;

  DepartmentMenuConfig({
    required this.icon,
    required this.label,
    required this.children,
    this.rule,
  });

  bool isVisible({required Map<Type, int> pageTypeMap, required UserController userController}) {
    // Kiểm tra quyền của chính Phòng ban này trước
    if (rule != null) {
      final canAccess = userController.canAccess(
        departments: rule!.departments,
        managerDept: rule!.managerDept,
        permissions: rule!.permissions,
        roles: rule!.roles,
        requireDept: rule!.requireDept,
      );
      if (!canAccess) return false;
    }

    return children.any((child) {
      if (child is GroupMenuConfig) {
        return child.isVisible(pageTypeMap: pageTypeMap, userController: userController);
      }
      if (child is LeafMenuConfig) {
        return child.isVisible(pageTypeMap: pageTypeMap, userController: userController);
      }
      return false;
    });
  }

  int getBadgeValue({required Map<Type, int> pageTypeMap, required UserController userController}) {
    return children.fold<int>(0, (int sum, dynamic child) {
      if (child is GroupMenuConfig) {
        if (!child.isVisible(pageTypeMap: pageTypeMap, userController: userController)) return sum;
        return sum + child.getBadgeValue(pageTypeMap: pageTypeMap, userController: userController);
      }
      if (child is LeafMenuConfig) {
        if (!child.isVisible(pageTypeMap: pageTypeMap, userController: userController)) return sum;
        return sum + child.getBadgeValue();
      }
      return sum;
    });
  }
}
