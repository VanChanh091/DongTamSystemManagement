import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AutoCompleteField<T> extends StatefulWidget {
  final TextEditingController controller;
  final Future<List<T>> Function(String pattern) suggestionsCallback;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final void Function(T selectedItem) onSelected;
  final String labelText;
  final IconData icon;
  final String Function(T item) displayStringForItem;
  final VoidCallback? onPlusTap;
  final void Function(String) onChanged;

  const AutoCompleteField({
    super.key,
    required this.controller,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSelected,
    required this.labelText,
    required this.icon,
    required this.displayStringForItem,
    this.onPlusTap,
    required this.onChanged,
  });

  @override
  State<AutoCompleteField<T>> createState() => _AutoCompleteFieldState<T>();
}

class _AutoCompleteFieldState<T> extends State<AutoCompleteField<T>> {
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller;

    _internalController.addListener(() {
      setState(() {}); // Cập nhật lại màu khi text thay đổi
    });
  }

  @override
  void dispose() {
    _internalController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<T>(
      suggestionsCallback: (pattern) async {
        final trimmed = pattern.trim();
        if (trimmed.isEmpty) return [];
        return await widget.suggestionsCallback(trimmed);
      },
      itemBuilder: widget.itemBuilder,
      onSelected: (item) {
        _internalController.text = widget.displayStringForItem(item);
        widget.onSelected(item);
      },
      builder: (context, textEditingController, focusNode) {
        final isFilled = textEditingController.text.isNotEmpty;

        // Gán controller ra ngoài để dùng bên ngoài widget
        if (textEditingController.text != _internalController.text) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              textEditingController.value = _internalController.value;
            }
          });
        }

        return TextFormField(
          controller: textEditingController, // Để TypeAhead hoạt động đúng
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            prefixIcon: Icon(widget.icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            fillColor:
                isFilled
                    ? const Color.fromARGB(255, 148, 236, 154)
                    : Colors.white,
            filled: true,
            suffixIcon:
                widget.onPlusTap != null
                    ? IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.red),
                      onPressed: widget.onPlusTap,
                    )
                    : null,
          ),
          onChanged: widget.onChanged,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Không được để trống';
            }
            return null;
          },
        );
      },

      constraints: const BoxConstraints(maxHeight: 200),
      emptyBuilder:
          (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Không tìm thấy dữ liệu.'),
          ),
    );
  }
}
