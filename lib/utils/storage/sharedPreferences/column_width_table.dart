import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ColumnWidthTable {
  static const String _prefix = 'columnWidth_';
  static final Map<String, Map<String, double>> _cache = {};

  /// Lưu width của 1 cột cụ thể
  static Future<void> saveWidth({
    required String tableKey,
    required String columnName,
    required double width,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final fullKey = '$_prefix${tableKey}_$columnName';

    // Cập nhật cache
    _cache[tableKey] ??= {};
    _cache[tableKey]![columnName] = width;

    // Lưu xuống disk
    await prefs.setDouble(fullKey, width);
  }

  /// Load width của các cột (nếu có trong SharedPreferences)
  static Future<Map<String, double>> loadWidths({
    required String tableKey,
    required List<GridColumn> columns,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, double> result = {};

    _cache[tableKey] ??= {};

    for (final col in columns) {
      final cachedWidth = _cache[tableKey]![col.columnName];

      if (cachedWidth != null) {
        result[col.columnName] = cachedWidth;
      } else {
        final fullKey = '$_prefix${tableKey}_${col.columnName}';

        final savedWidth = prefs.getDouble(fullKey);

        final finalWidth = savedWidth ?? col.width;
        result[col.columnName] = finalWidth;

        // Lưu lại cache
        _cache[tableKey]![col.columnName] = finalWidth;
      }
    }

    return result;
  }

  static List<GridColumn> applySavedWidths({
    required List<GridColumn> columns,
    required Map<String, double> widths,
  }) {
    return columns.map((c) {
      return GridColumn(
        columnName: c.columnName,
        label: c.label,
        width: widths[c.columnName] ?? c.width,
        visible: c.visible,
      );
    }).toList();
  }

  static void clearCache([String? tableKey]) {
    if (tableKey != null) {
      _cache.remove(tableKey);
    } else {
      _cache.clear();
    }
  }
}
