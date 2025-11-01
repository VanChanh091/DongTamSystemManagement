import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

List<Widget> formatKeyValueRows({
  required List<Map<String, dynamic>> rows,
  required int columnCount,
  required double labelWidth,
  bool centerAlign = false,
  double spacing = 20,
}) {
  return rows.map((row) {
    // Lấy tất cả các cặp key-value có trong row
    final pairs = <MapEntry<String, dynamic>>[];

    for (final entry in row.entries) {
      if (entry.key.endsWith("Key")) {
        final base = entry.key.replaceAll("Key", "");
        final key = entry.value?.toString().trim() ?? '';
        final value = row["${base}Value"];
        if ((key.isNotEmpty) || (value != null && value.toString().trim().isNotEmpty)) {
          pairs.add(MapEntry(key, value));
        }
      }
    }

    if (pairs.isEmpty) return const SizedBox.shrink();

    // Nhóm cặp theo số cột
    final groupedPairs = <List<MapEntry<String, dynamic>>>[];
    for (var i = 0; i < pairs.length; i += columnCount) {
      groupedPairs.add(pairs.sublist(i, (i + columnCount).clamp(0, pairs.length)));
    }

    // Tạo từng dòng hiển thị
    return Column(
      children:
          groupedPairs.map((cols) {
            return Column(
              children: [
                Row(
                  crossAxisAlignment:
                      centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    ...cols.expand(
                      (pair) => [
                        Expanded(
                          flex: 1,
                          child: _buildKeyValue(pair.key, pair.value, labelWidth, centerAlign),
                        ),
                        if (cols.last != pair) SizedBox(width: spacing),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 18, thickness: 0.6, color: Color(0xFFE0E0E0)),
              ],
            );
          }).toList(),
    );
  }).toList();
}

Widget _buildKeyValue(String keyText, dynamic value, double labelWidth, bool centerAlign) {
  return Row(
    crossAxisAlignment: centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: labelWidth,
        child: Text(
          keyText.isNotEmpty ? "$keyText:" : "",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
        ),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child:
              value is Widget
                  ? value
                  : Text(
                    value?.toString() ?? "",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
        ),
      ),
    ],
  );
}
