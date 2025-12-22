import 'package:flutter/material.dart';

class SidebarExpandedMenu extends StatelessWidget {
  final bool isSidebarOpen;
  final bool isExpanded;
  final VoidCallback onToggle;

  final bool isParentSelected;
  final String title;

  /// icon default khi không có badge/custom leading
  final IconData icon;

  /// Nếu muốn leading có badge (Obx/Badge.count/Badge chấm đỏ) thì truyền widget vào đây
  final Widget? leading;

  /// list submenu items (đã build sẵn)
  final List<Widget> children;

  const SidebarExpandedMenu({
    super.key,
    required this.isSidebarOpen,
    required this.isExpanded,
    required this.onToggle,
    required this.isParentSelected,
    required this.title,
    required this.icon,
    this.leading,
    required this.children,
  });

  Color get _activeColor => const Color.fromARGB(255, 252, 220, 41);

  @override
  Widget build(BuildContext context) {
    final defaultLeading = Icon(icon, color: isParentSelected ? _activeColor : Colors.white);

    return Column(
      children: [
        isSidebarOpen
            ? ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: leading ?? defaultLeading,
              title: Text(
                title,
                style: TextStyle(
                  color: isParentSelected ? _activeColor : Colors.white,
                  fontSize: 18,
                  fontWeight: isParentSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
                size: 20,
              ),
              onTap: onToggle,
            )
            : Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(child: leading ?? defaultLeading),
            ),
        if (isSidebarOpen && isExpanded) ...children,
      ],
    );
  }
}
