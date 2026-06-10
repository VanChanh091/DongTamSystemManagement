import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BaseValidateInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool readOnly;
  final bool enabled;
  final String? prefixText;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool isCalculate; // Dành riêng cho logic tính toán của Order

  const BaseValidateInput({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.readOnly = false,
    this.enabled = true,
    this.prefixText,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onTap,
    this.isCalculate = false,
  });

  @override
  State<BaseValidateInput> createState() => _BaseValidateInputState();
}

class _BaseValidateInputState extends State<BaseValidateInput> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Xử lý logic tính toán tự động khi mất focus (Dành cho Order)
    if (widget.isCalculate) {
      _focusNode.addListener(_handleCalculation);
    }

    // Lắng nghe thay đổi text để cập nhật màu sắc
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleCalculation);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose(); // Tránh rò rỉ bộ nhớ
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _handleCalculation() {
    if (!_focusNode.hasFocus) {
      final text = widget.controller.text.trim();
      final mathPattern = RegExp(r'^(\d+\.?\d*)\s*[\/*]\s*(\d+\.?\d*)$');

      if (mathPattern.hasMatch(text)) {
        final match = mathPattern.firstMatch(text);
        if (match != null) {
          double val1 = double.parse(match.group(1)!);
          double val2 = double.parse(match.group(2)!);

          if (val2 != 0) {
            double result = val1 / val2;
            widget.controller.text = result.toStringAsFixed(2).replaceAll(RegExp(r'\.0$'), '');
            setState(() {});
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFilled = widget.controller.text.isEmpty;
    final effectiveReadOnly = widget.readOnly || !widget.enabled;

    final themeController = Get.find<ThemeController>();

    final isCustomTheme = themeController.isThemeCustomized.value;
    final isCurrentColor = themeController.currentColor.value;
    const defaultFill = Color.fromARGB(255, 148, 236, 154);

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      readOnly: effectiveReadOnly,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      validator: widget.validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        prefixText: widget.prefixText,
        prefixIcon: Icon(widget.icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        fillColor:
            effectiveReadOnly
                ? Colors.grey.shade300
                : (isFilled ? Colors.white : (isCustomTheme ? isCurrentColor : defaultFill)),
        filled: true,
        errorText: widget.errorText,
      ),
    );
  }
}
