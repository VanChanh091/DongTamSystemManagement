import 'package:dongtam/data/controller/sidebar_controller.dart';
import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:dongtam/utils/helper/home/leaf_menu_config.dart';
import 'package:dongtam/utils/helper/warning_unsaved_change.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SidebarThreeLevel extends StatefulWidget {
  final bool isSidebarOpen;
  final List<Widget> pages;
  final List<SidebarItem> menuConfigs;
  final Function(bool) onSidebarToggle;

  const SidebarThreeLevel({
    super.key,
    required this.pages,
    required this.menuConfigs,
    required this.isSidebarOpen,
    required this.onSidebarToggle,
  });

  @override
  State<SidebarThreeLevel> createState() => _SidebarThreeLevelState();
}

class _SidebarThreeLevelState extends State<SidebarThreeLevel> {
  Color get _activeColor => const Color.fromARGB(255, 252, 220, 41);

  @override
  Widget build(BuildContext context) {
    final sidebarController = Get.find<SidebarController>();
    final unsavedChangeController = Get.find<UnsavedChangeController>();

    return Obx(() {
      final selectedIndex = sidebarController.selectedIndex.value;
      String activeKey = sidebarController.activeMenuKey.value;

      sidebarController.expandParentsForActiveKey(activeKey);
      bool keyMatchesCurrentIndex = false;

      for (var item in widget.menuConfigs) {
        if (item is LeafMenuConfig &&
            item.label == activeKey &&
            item.getIndex(widget.pages) == selectedIndex) {
          keyMatchesCurrentIndex = true;
          break;
        }
        if (item is DepartmentMenuConfig) {
          for (var child in item.children) {
            if (child is LeafMenuConfig &&
                "${item.label} > ${child.label}" == activeKey &&
                child.getIndex(widget.pages) == selectedIndex) {
              keyMatchesCurrentIndex = true;
              break;
            }
            if (child is GroupMenuConfig) {
              for (var leaf in child.items) {
                if ("${item.label} > ${child.label} > ${leaf.label}" == activeKey &&
                    leaf.getIndex(widget.pages) == selectedIndex) {
                  keyMatchesCurrentIndex = true;
                  break;
                }
              }
            }
          }
        }
      }

      if (!keyMatchesCurrentIndex) {
        String? fallbackKey;
        for (var item in widget.menuConfigs) {
          if (item is LeafMenuConfig && item.getIndex(widget.pages) == selectedIndex) {
            fallbackKey = item.label;
            break;
          }
          if (item is DepartmentMenuConfig) {
            for (var child in item.children) {
              if (child is LeafMenuConfig && child.getIndex(widget.pages) == selectedIndex) {
                fallbackKey = "${item.label} > ${child.label}";
                break;
              }
              if (child is GroupMenuConfig) {
                for (var leaf in child.items) {
                  if (leaf.getIndex(widget.pages) == selectedIndex) {
                    fallbackKey = "${item.label} > ${child.label} > ${leaf.label}";
                    break;
                  }
                }
              }
              if (fallbackKey != null) break;
            }
          }
          if (fallbackKey != null) break;
        }
        if (fallbackKey != null) {
          activeKey = fallbackKey;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            sidebarController.activeMenuKey.value = fallbackKey!;
          });
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(widget.menuConfigs.length, (index) {
          final item = widget.menuConfigs[index];

          // Nếu là Menu độc lập cấp 1 (Dashboard, Đổi màu theme)
          if (item is LeafMenuConfig) {
            if (item.onTap == null && !item.isVisible(widget.pages)) {
              return const SizedBox.shrink();
            }

            return _buildLeafNode(
              leaf: item,
              pages: widget.pages,
              selectedIndex: selectedIndex,
              unsavedController: unsavedChangeController,
              sidebarController: sidebarController,
              indentation: 16.0,
              isRoot: true,
              level: 1, // Cấp 1: Giữ nguyên khoảng cách gốc rộng rãi
              uniqueKey: item.label,
              activeKey: activeKey,
            );
          }

          // Nếu là Menu Phòng ban
          if (item is DepartmentMenuConfig) {
            if (!item.isVisible(widget.pages)) return const SizedBox.shrink();

            final isDeptActive = activeKey.startsWith("${item.label} > ");
            final deptKey = "dept_${item.label}";

            final isDeptExpanded = sidebarController.isExpanded(deptKey);
            final deptBadge = item.getBadgeValue();

            const double deptIconSize = 24.0;
            const double deptFontSize = 17.0;

            return Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.isSidebarOpen
                      ? ListTile(
                        // CẤP 1: Không dùng dense và visualDensity để giữ khoảng cách gốc rộng rãi
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading:
                            deptBadge > 0
                                ? Badge.count(
                                  count: deptBadge,
                                  child: Icon(
                                    item.icon,
                                    color: isDeptActive ? _activeColor : Colors.white,
                                    size: deptIconSize,
                                  ),
                                )
                                : Icon(
                                  item.icon,
                                  color: isDeptActive ? _activeColor : Colors.white,
                                  size: deptIconSize,
                                ),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            color: isDeptActive ? _activeColor : Colors.white,
                            fontSize: deptFontSize,
                            fontWeight: isDeptActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: Icon(
                          isDeptExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white,
                          size: 18,
                        ),
                        onTap: () => sidebarController.toggleExpand(deptKey),
                      )
                      : InkWell(
                        onTap: () {
                          widget.onSidebarToggle(true);
                          sidebarController.toggleExpand(deptKey);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child:
                                deptBadge > 0
                                    ? Badge(
                                      smallSize: 8,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        item.icon,
                                        color: isDeptActive ? _activeColor : Colors.white,
                                        size: deptIconSize,
                                      ),
                                    )
                                    : Icon(
                                      item.icon,
                                      color: isDeptActive ? _activeColor : Colors.white,
                                      size: deptIconSize,
                                    ),
                          ),
                        ),
                      ),

                  if (widget.isSidebarOpen && isDeptExpanded)
                    ...item.children.map<Widget>((child) {
                      if (child is GroupMenuConfig) {
                        if (!child.isVisible(widget.pages)) return const SizedBox.shrink();
                        final groupKey = "group_${item.label}_${child.label}";

                        final isGroupExpanded = sidebarController.isExpanded(groupKey);
                        final isGroupActive = activeKey.startsWith(
                          "${item.label} > ${child.label} > ",
                        );
                        final groupBadge = child.getBadgeValue();

                        const double groupIconSize = 22.5;
                        const double groupFontSize = 15.5;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => sidebarController.toggleExpand(groupKey),
                              child: Container(
                                padding: const EdgeInsets.only(
                                  left: 36,
                                  right: 16,
                                  top: 8,
                                  bottom: 8,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: SizedBox(
                                    width: 248, // 300px - 52px (trái 36 + phải 16)
                                    child: Row(
                                      children: [
                                        groupBadge > 0
                                            ? Badge.count(
                                              count: groupBadge,
                                              child: Icon(
                                                child.icon,
                                                color: isGroupActive ? _activeColor : Colors.white,
                                                size: groupIconSize,
                                              ),
                                            )
                                            : Icon(
                                              child.icon,
                                              color: isGroupActive ? _activeColor : Colors.white,
                                              size: groupIconSize,
                                            ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            child.label,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isGroupActive ? _activeColor : Colors.white,
                                              fontSize: groupFontSize,
                                              fontWeight:
                                                  isGroupActive
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          isGroupExpanded ? Icons.expand_less : Icons.expand_more,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (isGroupExpanded)
                              ...child.items.map<Widget>((leaf) {
                                if (!leaf.isVisible(widget.pages)) return const SizedBox.shrink();

                                final leafKey = "${item.label} > ${child.label} > ${leaf.label}";

                                return _buildLeafNode(
                                  leaf: leaf,
                                  pages: widget.pages,
                                  selectedIndex: selectedIndex,
                                  unsavedController: unsavedChangeController,
                                  sidebarController: sidebarController,
                                  indentation: 56.0, // Thụt lề Cấp 3 vừa đủ
                                  level: 3,
                                  uniqueKey: leafKey,
                                  activeKey: activeKey,
                                );
                              }),
                          ],
                        );
                      }

                      // Xử lý Cấp 2 dạng Leaf trực thuộc Phòng ban
                      if (child is LeafMenuConfig) {
                        if (!child.isVisible(widget.pages)) return const SizedBox.shrink();

                        final leafKey = "${item.label} > ${child.label}";

                        return _buildLeafNode(
                          leaf: child,
                          pages: widget.pages,
                          selectedIndex: selectedIndex,
                          unsavedController: unsavedChangeController,
                          sidebarController: sidebarController,
                          indentation: 40.0, // Thụt lề Cấp 2
                          level: 2,
                          uniqueKey: leafKey,
                          activeKey: activeKey,
                        );
                      }

                      return const SizedBox.shrink();
                    }),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      );
    });
  }

  // Builder dùng chung vẽ Dashboard, Menu lẻ Cấp 2, Menu Cấp 3
  Widget _buildLeafNode({
    required LeafMenuConfig leaf,
    required List<Widget> pages,
    required int selectedIndex,
    required double indentation, // Khoảng cách thụt lề cho Cấp 2 và Cấp 3
    required SidebarController sidebarController,
    required UnsavedChangeController unsavedController,
    required int level,
    required String uniqueKey,
    required String activeKey,
    bool isRoot = false,
  }) {
    final bool isActive = activeKey == uniqueKey;
    final int itemIndex = leaf.getIndex(pages);
    final int badgeValue = leaf.getBadgeValue();

    double finalIconSize = 24.0;
    double finalFontSize = 17.0;

    if (level == 2) {
      finalIconSize = 22.5;
      finalFontSize = 16.0;
    } else if (level == 3) {
      finalIconSize = 20.5;
      finalFontSize = 15.5;
    }

    final FontWeight finalFontWeight = isActive ? FontWeight.bold : FontWeight.normal;

    Widget leadingWidget =
        badgeValue > 0
            ? Badge.count(
              count: badgeValue,
              child: Icon(
                leaf.icon,
                color: isActive ? _activeColor : Colors.white,
                size: finalIconSize,
              ),
            )
            : Icon(leaf.icon, color: isActive ? _activeColor : Colors.white, size: finalIconSize);

    // KHI SIDEBAR ĐÓNG
    if (!widget.isSidebarOpen) {
      return InkWell(
        onTap: () async {
          if (leaf.onTap != null) {
            leaf.onTap!();
            return;
          }
          bool canNavigate = await UnsavedChangeDialog(unsavedController);
          if (canNavigate && itemIndex != -1) {
            sidebarController.changePage(index: itemIndex, menuKey: uniqueKey);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child:
                badgeValue > 0
                    ? Badge(
                      smallSize: 8,
                      backgroundColor: Colors.red,
                      child: Icon(
                        leaf.icon,
                        color: isActive ? _activeColor : Colors.white,
                        size: finalIconSize,
                      ),
                    )
                    : Icon(
                      leaf.icon,
                      color: isActive ? _activeColor : Colors.white,
                      size: finalIconSize,
                    ),
          ),
        ),
      );
    }

    // KHI SIDEBAR MỞ
    return InkWell(
      onTap: () async {
        if (leaf.onTap != null) {
          leaf.onTap!();
          return;
        }
        bool canNavigate = await UnsavedChangeDialog(unsavedController);
        if (canNavigate && itemIndex != -1) {
          sidebarController.changePage(index: itemIndex, menuKey: uniqueKey);
        }
      },

      child: ClipRect(
        child: Container(
          padding: EdgeInsets.only(
            left: indentation,
            right: 12,
            top: level == 1 ? 12 : 11,
            bottom: level == 1 ? 12 : 11,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: 300.0 - indentation - 12.0,
              child: Row(
                children: [
                  leadingWidget,
                  SizedBox(width: badgeValue > 0 ? 16 : 10),
                  Expanded(
                    child: Text(
                      leaf.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? _activeColor : Colors.white,
                        fontSize: finalFontSize,
                        fontWeight: finalFontWeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
