import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeftButtonSearch extends StatelessWidget {
  final String? selectedType;
  final List<String>? types;

  final TextEditingController controller;
  final ValueChanged<String>? onTypeChanged;
  final VoidCallback onSearch;

  final bool textFieldEnabled;
  final bool showDropdown;
  final String hintText;
  final String buttonLabel;
  final IconData buttonIcon;
  final Rx<Color>? buttonColor;

  final double minDropdownWidth;
  final double maxDropdownWidth;
  final double minInputWidth;
  final double maxInputWidth;

  final List<Widget> extraWidgets;
  final Widget? Function(double width)? customInputBuilder;

  const LeftButtonSearch({
    super.key,
    this.selectedType,
    this.types,
    required this.controller,
    this.onTypeChanged,
    required this.onSearch,
    this.textFieldEnabled = true,
    this.showDropdown = true,
    this.hintText = "Tìm kiếm...",
    this.buttonLabel = "Tìm kiếm",
    this.buttonIcon = Icons.search,
    this.buttonColor,

    this.minDropdownWidth = 120.0,
    this.maxDropdownWidth = 170.0,
    this.minInputWidth = 200.0,
    this.maxInputWidth = 250.0,

    this.extraWidgets = const [],
    this.customInputBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDropdown = showDropdown && (types?.isNotEmpty ?? false) && selectedType != null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;

          final dropdownWidth = (maxWidth * 0.2).clamp(minDropdownWidth, maxDropdownWidth);
          final textInputWidth = (maxWidth * 0.3).clamp(minInputWidth, maxInputWidth);

          Widget? custom = customInputBuilder?.call(textInputWidth);

          Widget inputWidget =
              custom ??
              SizedBox(
                width: textInputWidth,
                height: 45,
                child: TextField(
                  controller: controller,
                  enabled: textFieldEnabled,
                  onSubmitted: (_) => onSearch(),
                  decoration: InputDecoration(
                    hintText: hintText,
                    filled: true,
                    fillColor: textFieldEnabled ? Colors.white : Colors.grey.shade200,
                    prefixIcon: !hasDropdown ? const Icon(Icons.search, size: 20) : null,
                    suffixIcon:
                        controller.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                controller.clear();
                                onSearch();
                              },
                            )
                            : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: (_) => (context as Element).markNeedsBuild(),
                ),
              );

          return Row(
            children: [
              // Dropdown
              if (hasDropdown) ...[
                SizedBox(
                  width: dropdownWidth,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: selectedType,
                    items:
                        types!
                            .map(
                              (value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, overflow: TextOverflow.ellipsis, maxLines: 1),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null && onTypeChanged != null) onTypeChanged!(value);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],

              // Input
              inputWidget,
              const SizedBox(width: 10),

              // Button
              AnimatedButton(
                onPressed: onSearch,
                label: buttonLabel,
                icon: buttonIcon,
                backgroundColor: buttonColor,
              ),

              if (extraWidgets.isNotEmpty) const SizedBox(width: 10),
              ...extraWidgets,
            ],
          );
        },
      ),
    );
  }
}
