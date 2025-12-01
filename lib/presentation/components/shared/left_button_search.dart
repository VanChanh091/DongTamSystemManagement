import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:flutter/material.dart';

class LeftButtonSearch extends StatelessWidget {
  final String selectedType;
  final List<String> types;

  final TextEditingController controller;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onSearch;

  final bool textFieldEnabled;
  final String buttonLabel;
  final IconData buttonIcon;
  final Color? buttonColor;

  const LeftButtonSearch({
    super.key,
    required this.selectedType,
    required this.types,
    required this.controller,
    required this.onTypeChanged,
    required this.onSearch,
    required this.textFieldEnabled,
    this.buttonLabel = "Tìm kiếm",
    this.buttonIcon = Icons.search,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;

          // giữ y nguyên logic của ông
          final dropdownWidth = (maxWidth * 0.2).clamp(120.0, 170.0);
          final textInputWidth = (maxWidth * 0.3).clamp(200.0, 250.0);

          return Row(
            children: [
              // Dropdown
              SizedBox(
                width: dropdownWidth,
                child: DropdownButtonFormField<String>(
                  value: selectedType,
                  items:
                      types
                          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                          .toList(),
                  onChanged: (value) {
                    if (value != null) onTypeChanged(value);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Input
              SizedBox(
                width: textInputWidth,
                height: 50,
                child: TextField(
                  controller: controller,
                  enabled: textFieldEnabled,
                  onSubmitted: (_) => onSearch(),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Button
              AnimatedButton(
                onPressed: onSearch,
                label: buttonLabel,
                icon: Icons.search,
                backgroundColor: buttonColor,
              ),
            ],
          );
        },
      ),
    );
  }
}
