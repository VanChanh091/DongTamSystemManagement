import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/data/models/report/report_planning_box.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportBoxDatasource extends DataGridSource {
  List<ReportBoxModel> reportPapers = [];
  List<int>? selectedReportId;
  String machine;

  late List<DataGridRow> reportDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayReported = DateFormat("dd/MM/yyyy HH:mm:ss");

  ReportBoxDatasource({
    required this.reportPapers,
    this.selectedReportId,
    required this.machine,
  }) {
    buildDataGridRows();

    addColumnGroup(ColumnGroup(name: 'dateTimeRp', sortGroupRows: false));
  }

  List<DataGridCell> buildReportInfoCell(
    ReportBoxModel reportBox,
    String machine,
  ) {
    final orderCell = reportBox.planningBox!.order;
    final planningBoxCell = reportBox.planningBox!;
    final boxMachineTime = planningBoxCell.getBoxMachineTimeByMachine(machine);

    return [
      //14 items
      DataGridCell<String>(columnName: "orderId", value: orderCell!.orderId),
      DataGridCell<int>(
        columnName: "reportBoxId",
        value: reportBox.reportBoxId,
      ),
      DataGridCell<String>(
        columnName: "customerName",
        value: orderCell.customer?.customerName,
      ),
      DataGridCell<String>(
        columnName: "dateShipping",
        value: formatter.format(orderCell.dateRequestShipping),
      ),
      DataGridCell<String>(
        columnName: "dayStartProduction",
        value:
            boxMachineTime?.dayStart != null
                ? formatter.format(boxMachineTime!.dayStart!)
                : '',
      ),
      DataGridCell<String>(
        columnName: "dayReported",
        value: formatterDayReported.format(reportBox.dayReport),
      ),
      DataGridCell<String?>(
        columnName: "dateTimeRp",
        value: formatter.format(reportBox.dayReport),
      ),
      DataGridCell<String>(
        columnName: "structure",
        value: planningBoxCell.formatterStructureOrder,
      ),
      DataGridCell<String>(columnName: "flute", value: orderCell.flute ?? ""),
      DataGridCell<String>(columnName: "QC_box", value: orderCell.QC_box ?? ""),
      DataGridCell<String>(
        columnName: "length",
        value: '${planningBoxCell.length} cm',
      ),
      DataGridCell<String>(
        columnName: "size",
        value: '${planningBoxCell.size} cm',
      ),
      DataGridCell<int>(columnName: 'child', value: orderCell.numberChild),
      DataGridCell<int>(
        columnName: "quantityOrd",
        value: orderCell.quantityCustomer,
      ),
      DataGridCell<int>(
        columnName: "qtyPaper",
        value: planningBoxCell.qtyPaper,
      ),
      DataGridCell<String>(
        columnName: "timeRunnings",
        value:
            boxMachineTime?.timeRunning != null
                ? PlanningBox.formatTimeOfDay(boxMachineTime!.timeRunning!)
                : '',
      ),
    ];
  }

  List<DataGridCell> buildBoxCells(ReportBoxModel reportBox, String machine) {
    final planningCell = reportBox.planningBox!;
    final boxMachineTime = planningCell.getBoxMachineTimeByMachine(machine);

    /// Hàm dùng chung lấy qtyProduced
    String getQtyProduced(String machineName, {bool blankIfMissing = true}) {
      //check boxTimes theo machine
      if (machineName == machine) {
        if ((reportBox.qtyProduced) > 0) {
          return reportBox.qtyProduced.toString();
        }
      } else {
        final all = planningCell.getAllBoxMachineTime(machineName);
        if (all != null && (all.qtyProduced ?? 0) > 0) {
          return all.qtyProduced.toString();
        }
      }
      return blankIfMissing ? "" : "0";
    }

    return [
      DataGridCell<String>(
        columnName: "qtyPrinted",
        value: getQtyProduced("Máy In"),
      ),
      DataGridCell<String>(
        columnName: "qtyCanLan",
        value: getQtyProduced("Máy Cấn Lằn"),
      ),
      DataGridCell<String>(
        columnName: "qtyCanMang",
        value: getQtyProduced("Máy Cán Màng"),
      ),
      DataGridCell<String>(
        columnName: "qtyXa",
        value: getQtyProduced("Máy Xả"),
      ),
      DataGridCell<String>(
        columnName: "qtyCatKhe",
        value: getQtyProduced("Máy Cắt Khe"),
      ),
      DataGridCell<String>(
        columnName: "qtyBe",
        value: getQtyProduced("Máy Bế"),
      ),
      DataGridCell<String>(
        columnName: "qtyDan",
        value: getQtyProduced("Máy Dán"),
      ),
      DataGridCell<String>(
        columnName: "qtyDongGhim",
        value: getQtyProduced("Máy Đóng Ghim"),
      ),
      DataGridCell<int>(columnName: "lackOfQty", value: reportBox.lackOfQty),

      ...buildChildBoxCells(planningCell, machine),

      DataGridCell<String>(
        columnName: "dmWasteLoss",
        value:
            (boxMachineTime?.wasteBox ?? 0) > 0
                ? '${boxMachineTime!.wasteBox} Cái'
                : "0",
      ),
      DataGridCell<String>(
        columnName: "wasteLossRp",
        value: (reportBox.wasteLoss) > 0 ? '${reportBox.wasteLoss} Cái' : "0",
      ),
      DataGridCell<String>(
        columnName: "shiftManager",
        value: reportBox.shiftManagement,
      ),
    ];
  }

  List<DataGridCell> buildChildBoxCells(PlanningBox planning, String machine) {
    final boxCell = planning.order!.box;

    return [
      DataGridCell<int>(
        columnName: "inMatTruoc",
        value: machine == "Máy In" ? (boxCell!.inMatTruoc ?? 0) : null,
      ),
      DataGridCell<int>(
        columnName: "inMatSau",
        value: machine == "Máy In" ? boxCell!.inMatSau ?? 0 : null,
      ),
      DataGridCell<bool>(
        columnName: "dan_1_Manh",
        value: machine == "Máy Dán" ? boxCell!.dan_1_Manh : false,
      ),
      DataGridCell<bool>(
        columnName: "dan_2_Manh",
        value: machine == "Máy Dán" ? boxCell!.dan_2_Manh : false,
      ),
      DataGridCell<bool>(
        columnName: "dongGhim1Manh",
        value: machine == "Máy Đóng Ghim" ? boxCell!.dongGhim1Manh : false,
      ),
      DataGridCell<bool>(
        columnName: "dongGhim2Manh",
        value: machine == "Máy Đóng Ghim" ? boxCell!.dongGhim2Manh : false,
      ),
    ];
  }

  @override
  List<DataGridRow> get rows => reportDataGridRows;

  void buildDataGridRows() {
    reportDataGridRows =
        reportPapers.map<DataGridRow>((report) {
          return DataGridRow(
            cells: [
              ...buildReportInfoCell(report, machine),
              ...buildBoxCells(report, machine),
            ],
          );
        }).toList();

    notifyListeners();
  }

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = [
      'dan_1_Manh',
      'dan_2_Manh',
      'dongGhim1Manh',
      'dongGhim2Manh',
    ];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? '✅' : '';
    }

    return value?.toString() ?? '';
  }

  @override
  Widget? buildGroupCaptionCellWidget(
    RowColumnIndex rowColumnIndex,
    String summaryValue,
  ) {
    // Bắt ngày và số item, không phân biệt hoa thường
    final regex = RegExp(
      r'^.*?:\s*(.*?)\s*-\s*(\d+)\s*items?$',
      caseSensitive: false,
    );
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
            ? '📅 Ngày báo cáo: $displayDate – $itemCount'
            : '📅 Ngày báo cáo: Không xác định',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final reportPaperId =
        row
            .getCells()
            .firstWhere((cell) => cell.columnName == 'reportBoxId')
            .value;
    final isSelected = selectedReportId?.contains(reportPaperId);

    final Map<String, String> machineColumnMap = {
      'qtyPrinted': "Máy In",
      'qtyCanLan': "Máy Cấn Lằn",
      'qtyCanMang': "Máy Cán Màng",
      'qtyXa': "Máy Xả",
      'qtyCatKhe': "Máy Cắt Khe",
      'qtyBe': "Máy Bế",
      'qtyDan': "Máy Dán",
      'qtyDongGhim': "Máy Đóng Ghim",
    };

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
            Color cellColor = Colors.transparent;

            if (dataCell.columnName == "lackOfQty") {
              final int value = dataCell.value ?? 0;
              final String display =
                  value < 0 ? "+${value.abs()}" : value.toString();

              Color textColor = Colors.black;

              if (value > 0) {
                textColor = Colors.redAccent;
              } else if (value < 0) {
                textColor = Colors.green;
              }

              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Text(
                  display,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: value < 0 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              );
            }

            //hight color for qtyProduct reported
            final machineColumnName = machineColumnMap[dataCell.columnName];
            if (machineColumnName != null && machineColumnName == machine) {
              final qtyStr = dataCell.value?.toString() ?? "0";
              final qty = int.tryParse(qtyStr) ?? 0;
              if (qty > 0) {
                cellColor = Colors.amberAccent.withValues(alpha: 0.3);
              }
            }

            //highlight color for waste reported
            if (dataCell.columnName == 'wasteLossRp') {
              cellColor = Colors.amberAccent.withValues(alpha: 0.3);
            }

            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(
              label: _formatCellValueBool(dataCell),
              alignment: alignment,
              cellColor: cellColor,
            );
          }).toList(),
    );
  }
}
