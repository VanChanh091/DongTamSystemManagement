import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class GridResizeHelper {
  static bool onResizeStart(ColumnResizeStartDetails details) => true;

  static bool onResizeUpdate({
    required ColumnResizeUpdateDetails details,
    required List<GridColumn> columns,
    required void Function(void Function()) setState,
  }) {
    if (details.width < 50) return false;

    setState(() {
      final old = columns[details.columnIndex];
      columns[details.columnIndex] = GridColumn(
        columnName: old.columnName,
        label: old.label,
        width: details.width,
        visible: old.visible,
      );
    });
    return true;
  }

  static Future<void> onResizeEnd({
    required ColumnResizeEndDetails details,
    required String tableKey,
    required Map<String, double> columnWidths,
    required void Function(void Function()) setState,
  }) async {
    if (details.width >= 10) {
      await ColumnWidthTable.saveWidth(
        tableKey: tableKey,
        columnName: details.column.columnName,
        width: details.width,
      );
      setState(() {
        columnWidths[details.column.columnName] = details.width;
      });
    }
  }
}
