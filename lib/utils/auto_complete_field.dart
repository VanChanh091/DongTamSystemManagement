import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AutoCompleteField<T> extends StatelessWidget {
  final TextEditingController controller;
  final Future<List<T>> Function(String pattern) suggestionsCallback;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final void Function(T selectedItem) onSelected;
  final String labelText;
  final IconData icon;
  final String Function(T item) displayStringForItem;

  const AutoCompleteField({
    super.key,
    required this.controller,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSelected,
    required this.labelText,
    required this.icon,
    required this.displayStringForItem,
  });

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<T>(
      suggestionsCallback: (pattern) async {
        final trimmed = pattern.trim();
        if (trimmed.isEmpty) return [];
        return await suggestionsCallback(trimmed);
      },
      itemBuilder: itemBuilder,
      onSelected: (item) {
        // Gán hiển thị vào TextField
        controller.text = displayStringForItem(item);
        onSelected(item);
      },
      builder: (context, textEditingController, focusNode) {
        textEditingController.text = controller.text;

        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (val) => controller.text = val,
        );
      },
      emptyBuilder:
          (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Không tìm thấy dữ liệu.'),
          ),
    );
  }
}
