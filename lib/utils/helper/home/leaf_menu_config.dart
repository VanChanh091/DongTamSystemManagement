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
  final bool showBadge;
  final RxInt? badge;
  final List<String>? requiredRoles;
  final List<String>? requiredPermissions;

  LeafMenuConfig({
    required this.icon,
    required this.label,
    this.pageType,
    this.onTap,
    this.showBadge = false,
    this.badge,
    this.requiredRoles,
    this.requiredPermissions,
  });

  int getIndex(Map<Type, int> pageTypeMap) {
    if (pageType == null) return -1;
    return pageTypeMap[pageType] ?? -1;
  }

  bool isActive(int selectedIndex, Map<Type, int> pageTypeMap) {
    final idx = getIndex(pageTypeMap);
    return idx != -1 && selectedIndex == idx;
  }

  int getBadgeValue() => (showBadge && badge != null) ? badge!.value : 0;

  // Kiểm tra hiển thị — kết hợp cả role/permission restriction lẫn page existence
  bool isVisible(Map<Type, int> pageTypeMap, {String? userRole, List<String>? userPermissions}) {
    if (pageType == null) return true; // Các nút chức năng hệ thống luôn hiện

    // Kiểm tra role restriction (nếu có)
    if (requiredRoles != null && requiredRoles!.isNotEmpty) {
      if (userRole == null || !requiredRoles!.contains(userRole)) {
        return false;
      }
    }

    // Kiểm tra permission restriction (nếu có)
    // admin và manager có toàn quyền truy cập, chỉ áp dụng requiredPermissions cho user có role khác
    final isAdminOrManager = userRole == "admin" || userRole == "manager";
    if (!isAdminOrManager && requiredPermissions != null && requiredPermissions!.isNotEmpty) {
      if (userPermissions == null || !userPermissions.any((p) => requiredPermissions!.contains(p))) {
        return false;
      }
    }

    return pageTypeMap.containsKey(pageType); // Ẩn nếu User không có quyền vào trang này
  }
}

// Menu cấp 2: Nhóm các chức năng với nhau
class GroupMenuConfig {
  final IconData icon;
  final String label;
  final List<LeafMenuConfig> items;

  GroupMenuConfig({required this.icon, required this.label, required this.items});

  bool isActive(int selectedIndex, Map<Type, int> pageTypeMap) {
    return items.any((leaf) => leaf.isActive(selectedIndex, pageTypeMap));
  }

  int getBadgeValue() {
    return items.fold(0, (sum, leaf) => sum + leaf.getBadgeValue());
  }

  bool isVisible(Map<Type, int> pageTypeMap, {String? userRole, List<String>? userPermissions}) {
    // Chỉ hiển thị Group nếu có ít nhất một chức năng con bên trong được phép truy cập
    return items.any((leaf) => leaf.isVisible(pageTypeMap, userRole: userRole, userPermissions: userPermissions));
  }
}

// Menu cấp 1: Nhóm chức năng theo Phòng ban
class DepartmentMenuConfig extends SidebarItem {
  final IconData icon;
  final String label;

  /// Có thể chứa [GroupMenuConfig] (Cấp 2) hoặc [LeafMenuConfig] (Cấp 1)
  final List<dynamic> children;

  DepartmentMenuConfig({required this.icon, required this.label, required this.children});

  bool isActive(int selectedIndex, Map<Type, int> pageTypeMap) {
    return children.any((child) {
      if (child is GroupMenuConfig) return child.isActive(selectedIndex, pageTypeMap);
      if (child is LeafMenuConfig) return child.isActive(selectedIndex, pageTypeMap);
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

  bool isVisible(Map<Type, int> pageTypeMap, {String? userRole, List<String>? userPermissions}) {
    // Chỉ hiển thị Phòng Ban nếu có ít nhất một menu con bên trong khả dụng
    return children.any((child) {
      if (child is GroupMenuConfig) return child.isVisible(pageTypeMap, userRole: userRole, userPermissions: userPermissions);
      if (child is LeafMenuConfig) return child.isVisible(pageTypeMap, userRole: userRole, userPermissions: userPermissions);
      return false;
    });
  }
}
