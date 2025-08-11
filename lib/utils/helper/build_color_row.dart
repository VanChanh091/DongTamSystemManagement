import 'package:syncfusion_flutter_datagrid/datagrid.dart';

T getCellValue<T>(DataGridRow row, String columnName, T defaultValue) {
  return row
          .getCells()
          .firstWhere(
            (cell) => cell.columnName == columnName,
            orElse:
                () => DataGridCell<T>(
                  columnName: columnName,
                  value: defaultValue,
                ),
          )
          .value
      as T;
}
