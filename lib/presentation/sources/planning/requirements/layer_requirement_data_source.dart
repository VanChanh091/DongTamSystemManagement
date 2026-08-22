import 'package:dongtam/data/models/planning/requirements/paper_requirement_layers.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class LayerRequirementDataSource extends DataGridSource {
  List<PaperRequirementLayerModel> layers;

  late List<DataGridRow> paperDataGridRows;

  LayerRequirementDataSource({required this.layers}) {
    buildDataGridRows();
  }

  List<DataGridCell> buildLayerRequirementCells(PaperRequirementLayerModel layers) {
    return [
      DataGridCell<String>(columnName: "paperCode", value: layers.paperCode),
      DataGridCell<String>(columnName: "layerRole", value: layers.layerRole),
      DataGridCell<int>(columnName: "weightGsm", value: layers.weightGsm),
      DataGridCell<String>(columnName: "fluteType", value: layers.fluteType),
      DataGridCell<int>(columnName: "paperRollWidth", value: layers.paperRollWidth),
      DataGridCell<double>(columnName: "availableStock", value: layers.availableStock),
      DataGridCell<double>(columnName: "shortageQty", value: layers.shortageQty),
      DataGridCell<bool>(columnName: "isEnoughQty", value: layers.isEnoughQty),

      //hide
      DataGridCell<int>(columnName: "layerId", value: layers.layerId),
    ];
  }

  @override
  List<DataGridRow> get rows => paperDataGridRows;

  void buildDataGridRows() {
    paperDataGridRows =
        layers.map<DataGridRow>((layers) {
          final cells = buildLayerRequirementCells(layers);
          return DataGridRow(cells: cells);
        }).toList();
  }

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = ["isEnoughQty"];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? '✅' : '❌';
    }

    if (dataCell.columnName == "layerRole") {
      switch (value) {
        case "BOTTOM":
          return "Lớp Đáy";
        case "FLUTE_1" || "FLUTE_2" || "FLUTE_3":
          return "Lớp Sóng";
        case "MID_1" || "MID_2":
          return "Lớp Giữa";
        case "TOP":
          return "Lớp Mặt";
        default:
          return "";
      }
    }

    return value?.toString() ?? '';
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().asMap().entries.map<Widget>((entry) {
            final DataGridCell dataCell = entry.value;
            final cellText = _formatCellValueBool(dataCell);

            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else if (cellText == '✅' || cellText == '❌') {
              alignment = Alignment.center;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: _formatCellValueBool(dataCell), alignment: alignment);
          }).toList(),
    );
  }
}
