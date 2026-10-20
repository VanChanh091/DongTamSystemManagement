import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/synthetic/production/production_stage1_report_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProductionReportDataSource extends DataGridSource {
  final List<ProductionReportModel> items;
  final bool isMachine;
  List<DataGridRow> _productionReportRows = [];

  // Các giá trị tổng hợp
  double _sumPaperTon = 0;
  double _sumLength = 0;
  double _sumScrapKg = 0;
  double _sumRevenue = 0;
  int _sumQcErrors = 0;
  double _avgSpeed = 0;
  double _avgTimeAdherence = 0;
  double _avgFulfillment = 0;

  ProductionReportDataSource({required this.items, required this.isMachine}) {
    _buildRows();
    _initSummary();
  }

  @override
  List<DataGridRow> get rows => _productionReportRows;

  void _initSummary() {
    if (items.isEmpty) return;

    for (final item in items) {
      _sumPaperTon += item.totalPaperTon;
      _sumLength += item.totalLength;
      _sumScrapKg += item.totalScrapKg;
      _sumRevenue += item.totalRevenue;
      _sumQcErrors += item.totalQcErrors;
      _avgSpeed += item.averageSpeed;
      _avgTimeAdherence += item.timeAdherenceRate ?? 0;
      _avgFulfillment += item.fulfillmentRate ?? 0;
    }

    final count = items.length;
    _avgSpeed /= count;
    _avgTimeAdherence /= count;
    _avgFulfillment /= count;
  }

  List<DataGridCell> buildProductionReportCells(ProductionReportModel item, int index) {
    return [
      DataGridCell<int>(columnName: "index", value: index + 1),
      DataGridCell<String>(columnName: "dimensionKey", value: item.dimensionKey),
      DataGridCell<double>(columnName: "totalPaperTon", value: item.totalPaperTon),
      DataGridCell<double>(columnName: "totalLength", value: item.totalLength),
      DataGridCell<double>(columnName: "totalScrapKg", value: item.totalScrapKg),
      DataGridCell<double>(columnName: "scrapRate", value: item.scrapRate),
      DataGridCell<double>(columnName: "averageSpeed", value: item.averageSpeed),
      DataGridCell<double>(columnName: "totalRevenue", value: item.totalRevenue),

      if (isMachine)
        DataGridCell<double?>(columnName: "fulfillmentRate", value: item.fulfillmentRate),

      DataGridCell<double?>(columnName: "timeAdherenceRate", value: item.timeAdherenceRate),
      DataGridCell<int>(columnName: "totalQcErrors", value: item.totalQcErrors),
      DataGridCell<double>(columnName: "qcErrorPerTon", value: item.qcErrorPerTon),
    ];
  }

  void _buildRows() {
    _productionReportRows =
        items.asMap().entries.map((entry) {
          return DataGridRow(cells: buildProductionReportCells(entry.value, entry.key));
        }).toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((dataCell) {
            final colName = dataCell.columnName;
            final value = dataCell.value;

            // Căn lề: STT giữa, số sang phải, chữ sang trái
            Alignment alignment = Alignment.centerLeft;
            if (colName == "index") {
              alignment = Alignment.center;
            } else if (value is num) {
              alignment = Alignment.centerRight;
            }

            // Format hiển thị theo từng cột
            String displayValue = _formatCellValue(colName, value);

            return formatDataTable(label: displayValue, alignment: alignment);
          }).toList(),
    );
  }

  String _formatCellValue(String colName, dynamic value) {
    if (value == null) return "-";

    switch (colName) {
      case "index":
      case "dimensionKey":
        return value.toString();

      case "fulfillmentRate":
      case "timeAdherenceRate":
        return (value is num && value > 0) ? "${NumberFormat("0.##").format(value)}%" : "-";

      case "totalQcErrors":
        return value is num ? value.toInt().toString() : "0";

      default:
        if (value is num) {
          return value > 0 ? NumberFormat("#,##0.##").format(value) : "-";
        }
        return value.toString();
    }
  }

  @override
  Widget? buildTableSummaryCellWidget(
    GridTableSummaryRow summaryRow,
    GridSummaryColumn? summaryColumn,
    RowColumnIndex rowColumnIndex,
    String summaryValue,
  ) {
    // Cột tiêu đề của dòng tổng (thường là cột đầu tiên)
    if (summaryColumn == null) {
      return formatDataTable(
        label:
            summaryValue.isEmpty
                ? (rowColumnIndex.columnIndex == 0 ? "Tổng cộng" : "")
                : summaryValue,
        alignment: Alignment.center,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );
    }

    final colName = summaryColumn.columnName;
    return formatDataTable(
      label: _getSummaryDisplay(colName),
      alignment: Alignment.centerRight,
      textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
    );
  }

  String _getSummaryDisplay(String columnName) {
    if (items.isEmpty) return "-";

    switch (columnName) {
      case "totalPaperTon":
        return NumberFormat("#,##0.##").format(_sumPaperTon);
      case "totalLength":
        return NumberFormat("#,##0.##").format(_sumLength);
      case "totalScrapKg":
        return NumberFormat("#,##0.##").format(_sumScrapKg);
      case "totalRevenue":
        return OrderModel.formatCurrency(_sumRevenue);
      case "totalQcErrors":
        return _sumQcErrors.toString();
      case "averageSpeed":
        return NumberFormat("#,##0.##").format(_avgSpeed);
      case "timeAdherenceRate":
        return "${NumberFormat("0.##").format(_avgTimeAdherence)}%";
      case "fulfillmentRate":
        return isMachine ? "${NumberFormat("0.##").format(_avgFulfillment)}%" : "-";
      default:
        return "-";
    }
  }
}
