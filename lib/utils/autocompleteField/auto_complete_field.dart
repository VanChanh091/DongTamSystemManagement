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
    final isFilled = _internalController.text.isNotEmpty;

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
        textEditingController.text = _internalController.text;

        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon: Icon(widget.icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            fillColor:
                isFilled ? Color.fromARGB(255, 148, 236, 154) : Colors.white,
            filled: true,
            suffixIcon:
                widget.onPlusTap != null
                    ? IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.red),
                      onPressed: widget.onPlusTap,
                    )
                    : null,
          ),
          onChanged: (val) {
            widget.onChanged(val);
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Không được để trống';
            }
            return null;
          },
        );
      },
      constraints: BoxConstraints(maxHeight: 200),
      emptyBuilder:
          (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Không tìm thấy dữ liệu.'),
          ),
    );
  }
}
