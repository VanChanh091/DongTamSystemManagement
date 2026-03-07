import 'package:dongtam/data/models/warehouse/inbound_history_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportInboundDataSource extends DataGridSource {
  List<InboundHistoryModel> reportInbounds = [];
  List<int>? selectedInboundId;

  late List<DataGridRow> reportDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  ReportInboundDataSource({required this.reportInbounds, this.selectedInboundId}) {
    buildDataGridRows();
    addColumnGroup(ColumnGroup(name: 'dateInbound', sortGroupRows: false));
  }

  List<DataGridCell> buildReportInfoCells(InboundHistoryModel inbound) {
    final orderCell = inbound.order;

    return [
      DataGridCell<String>(columnName: 'dateInbound', value: formatter.format(inbound.dateInbound)),
      DataGridCell<String>(columnName: 'orderId', value: inbound.orderId),
      DataGridCell<String>(
        columnName: 'customerName',
        value: orderCell?.customer?.customerName ?? "",
      ),
      DataGridCell<String>(
        columnName: "companyName",
        value: orderCell?.customer?.companyName ?? "",
      ),
      DataGridCell<String>(columnName: "typeProduct", value: orderCell?.product?.typeProduct ?? ""),
      DataGridCell<String?>(
        columnName: "productName",
        value: orderCell?.product?.productName ?? "",
      ),
      DataGridCell<String?>(columnName: "QcBox", value: orderCell?.QC_box ?? ""),
      DataGridCell<String>(columnName: 'flute', value: orderCell?.flute ?? ""),
      DataGridCell<String>(
        columnName: 'structure',
        value: orderCell?.formatterStructureOrder ?? "",
      ),
      DataGridCell<String>(columnName: 'size', value: '${orderCell?.paperSizeCustomer ?? 0} cm'),
      DataGridCell<String>(
        columnName: 'length',
        value: '${orderCell?.lengthPaperCustomer ?? 0} cm',
      ),
      DataGridCell<int>(columnName: 'quantityOrd', value: orderCell?.quantityCustomer ?? 0),
      DataGridCell<int>(columnName: 'qtyPaper', value: inbound.qtyPaper),
      DataGridCell<int>(columnName: 'qtyInbound', value: inbound.qtyInbound),

      //hidden
      DataGridCell<int>(columnName: 'inboundId', value: inbound.inboundId),
    ];
  }

  @override
  List<DataGridRow> get rows => reportDataGridRows;

  void buildDataGridRows() {
    reportDataGridRows =
        reportInbounds.map<DataGridRow>((inbound) {
          final cells = buildReportInfoCells(inbound);

          // debugPrint("Row has ${cells.length} cells");

          return DataGridRow(cells: cells);
        }).toList();

    notifyListeners();
  }

  @override
  Widget? buildGroupCaptionCellWidget(RowColumnIndex rowColumnIndex, String summaryValue) {
    // Bắt ngày và số item, không phân biệt hoa thường
    final regex = RegExp(r'^.*?:\s*(.*?)\s*-\s*(\d+)\s*items?$', caseSensitive: false);
    final match = regex.firstMatch(summaryValue);

    String displayDate = '';
    String itemCount = '';

    if (match != null) {
      final fullDate = match.group(1) ?? '';
      displayDate = fullDate.split(' ').first; // chỉ lấy phần ngày
      final count = match.group(2) ?? '0';
      itemCount = '$count đơn hàng';
    }

    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        displayDate.isNotEmpty
            ? '📅 Ngày báo cáo: $displayDate  $itemCount'
            : '📅 Ngày báo cáo: Không xác định',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final inboundId = row.getCells().firstWhere((cell) => cell.columnName == 'inboundId').value;
    final isSelected = selectedInboundId?.contains(inboundId);

    Color backgroundColor;
    if (isSelected == true) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      backgroundColor = Colors.transparent;
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: dataCell.value?.toString() ?? "", alignment: alignment);
          }).toList(),
    );
  }
}
