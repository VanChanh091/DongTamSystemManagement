// ignore_for_file: deprecated_member_use

import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/planning/planning_box_model.dart";
import "package:dongtam/data/models/report/report_box_model.dart";
import "package:dongtam/utils/helper/helper_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class ReportBoxDatasource extends DataGridSource {
  List<ReportBoxModel> reportPapers = [];
  int? selectedReportId;
  String machine;
  int currentPage;
  int pageSize;

  late List<DataGridRow> reportDataGridRows;
  final formatter = DateFormat("dd/MM/yyyy");
  final formatterDayReported = DateFormat("dd/MM/yyyy HH:mm:ss");

  ReportBoxDatasource({
    required this.reportPapers,
    this.selectedReportId,
    required this.machine,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();

    addColumnGroup(ColumnGroup(name: "dateTimeRp", sortGroupRows: false));
  }

  @override
  List<DataGridRow> get rows => reportDataGridRows;

  List<DataGridCell> buildReportInfoCell(ReportBoxModel reportBox, String machine, int index) {
    final orderCell = reportBox.planningBox!.order;
    final planningBoxCell = reportBox.planningBox!;
    final boxMachineTime = planningBoxCell.getBoxMachineTimeByMachine(machine);

    DataGridCell<String> buildDateCell({required String columnName, DateTime? value}) {
      return DataGridCell<String>(
        columnName: columnName,
        value: value != null ? formatter.format(value) : "",
      );
    }

    return [
      DataGridCell<int>(columnName: "index", value: index + 1),
      DataGridCell<String>(columnName: "orderId", value: orderCell!.orderId),
      DataGridCell<String>(columnName: "customerName", value: orderCell.customer?.customerName),

      // buildDateCell(columnName: "dateShipping", value: orderCell.dateRequestShipping!),
      buildDateCell(columnName: "dayStartProduction", value: boxMachineTime!.dayStart!),
      buildDateCell(columnName: "dayReported", value: reportBox.dayReport),

      DataGridCell<String>(columnName: "structure", value: planningBoxCell.formatterStructureOrder),
      DataGridCell<String>(columnName: "flute", value: orderCell.flute ?? ""),
      DataGridCell<bool>(columnName: "isFSC", value: orderCell.isFSC),
      DataGridCell<String>(columnName: "QC_box", value: orderCell.QC_box ?? ""),

      DataGridCell<double>(columnName: "size", value: planningBoxCell.size),
      DataGridCell<double>(columnName: "length", value: planningBoxCell.length),

      DataGridCell<int>(columnName: "child", value: orderCell.numberChild),
      DataGridCell<int>(columnName: "quantityOrd", value: orderCell.quantityCustomer),
      DataGridCell<int>(columnName: "qtyPaper", value: planningBoxCell.qtyPaper),
      DataGridCell<String>(
        columnName: "timeRunnings",
        value:
            boxMachineTime.timeRunning != null
                ? PlanningBoxModel.formatTimeOfDay(timeOfDay: boxMachineTime.timeRunning!)
                : "",
      ),

      ...buildBoxCells(reportBox, machine),

      DataGridCell<int>(columnName: "reportBoxId", value: reportBox.reportBoxId),
      DataGridCell<String?>(columnName: "dateTimeRp", value: formatter.format(reportBox.dayReport)),
    ];
  }

  List<DataGridCell> buildBoxCells(ReportBoxModel reportBox, String machine) {
    final planningCell = reportBox.planningBox!;
    final boxMachineTime = planningCell.getBoxMachineTimeByMachine(machine);

    /// Hàm dùng chung lấy qtyProduced
    int getQtyProduced(String machineName, {bool blankIfMissing = true}) {
      //check boxTimes theo machine
      if (machineName == machine) {
        if ((reportBox.qtyProduced) > 0) {
          return reportBox.qtyProduced;
        }
      } else {
        final all = planningCell.getAllBoxMachineTime(machineName);
        if (all != null && (all.qtyProduced ?? 0) > 0) {
          return all.qtyProduced ?? 0;
        }
      }
      return blankIfMissing ? 0 : -1;
    }

    return [
      DataGridCell<int>(columnName: "qtyPrinted", value: getQtyProduced("Máy In")),
      DataGridCell<int>(columnName: "qtyCanLan", value: getQtyProduced("Máy Cấn Lằn")),
      DataGridCell<int>(columnName: "qtyCanMang", value: getQtyProduced("Máy Cán Màng")),
      DataGridCell<int>(columnName: "qtyXa", value: getQtyProduced("Máy Xả")),
      DataGridCell<int>(columnName: "qtyCatKhe", value: getQtyProduced("Máy Cắt Khe")),
      DataGridCell<int>(columnName: "qtyBe", value: getQtyProduced("Máy Bế")),
      DataGridCell<int>(columnName: "qtyDan", value: getQtyProduced("Máy Dán")),
      DataGridCell<int>(columnName: "qtyDongGhim", value: getQtyProduced("Máy Đóng Ghim")),
      DataGridCell<int>(columnName: "lackOfQty", value: reportBox.lackOfQty),

      ...buildChildBoxCells(planningCell, machine),

      DataGridCell<String>(
        columnName: "dmWasteLoss",
        value: (boxMachineTime?.wasteBox ?? 0) > 0 ? "${toInt(boxMachineTime!.wasteBox)} Cái" : "0",
      ),
      DataGridCell<String>(
        columnName: "wasteLossRp",
        value: (reportBox.wasteLoss) > 0 ? "${toInt(reportBox.wasteLoss)} Cái" : "0",
      ),
      DataGridCell<String>(columnName: "shiftManager", value: reportBox.shiftManagement),
      DataGridCell<String>(columnName: "reportedBy", value: reportBox.reportedBy),
    ];
  }

  List<DataGridCell> buildChildBoxCells(PlanningBoxModel planning, String machine) {
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

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    reportDataGridRows =
        reportPapers.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;
          return DataGridRow(cells: buildReportInfoCell(entry.value, machine, globalIndex));
        }).toList();

    notifyListeners();
  }

  @override
  Widget? buildGroupCaptionCellWidget(RowColumnIndex rowColumnIndex, String summaryValue) {
    // Bắt ngày và số item, không phân biệt hoa thường
    final regex = RegExp(r"^.*?:\s*(.*?)\s*-\s*(\d+)\s*items?$", caseSensitive: false);
    final match = regex.firstMatch(summaryValue);

    String displayDate = "";
    String itemCount = "";

    if (match != null) {
      final fullDate = match.group(1) ?? "";
      displayDate = fullDate.split(" ").first; // chỉ lấy phần ngày
      final count = match.group(2) ?? "0";
      itemCount = "$count đơn hàng";
    }

    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        displayDate.isNotEmpty
            ? "📅 Ngày báo cáo: $displayDate – $itemCount"
            : "📅 Ngày báo cáo: Không xác định",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final Map<String, String> machineColumnMap = {
      "qtyPrinted": "Máy In",
      "qtyCanLan": "Máy Cấn Lằn",
      "qtyCanMang": "Máy Cán Màng",
      "qtyXa": "Máy Xả",
      "qtyCatKhe": "Máy Cắt Khe",
      "qtyBe": "Máy Bế",
      "qtyDan": "Máy Dán",
      "qtyDongGhim": "Máy Đóng Ghim",
    };
    final Set<String> boolColumns = {
      "dan_1_Manh",
      "dan_2_Manh",
      "dongGhim1Manh",
      "dongGhim2Manh",
      "isFSC",
    };

    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((dataCell) {
            final value = dataCell.value;
            String displayValue = "";
            String columnName = dataCell.columnName;

            Color cellColor = Colors.transparent;
            Alignment alignment = Alignment.centerLeft;

            if (value is num) {
              alignment = Alignment.centerRight;

              final numVal = value.toDouble();
              displayValue = numVal == 0 ? "-" : OrderModel.formatCurrency(numVal);

              if (columnName == "lackOfQty") {
                final String display = value < 0 ? "+${value.abs()}" : value.toString();

                Color textColor = Colors.black;
                value > 0 ? textColor = Colors.redAccent : textColor = Colors.green;

                return Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1)),
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

              //hightlight color for qtyProduct reported
              final machineColumnName = machineColumnMap[dataCell.columnName];
              if (machineColumnName != null && machineColumnName == machine) {
                if (value > 0) {
                  cellColor = Colors.amberAccent.withValues(alpha: 0.3);
                }
              }

              //highlight color for waste reported
              if (dataCell.columnName == "wasteLossRp") {
                cellColor = Colors.amberAccent.withValues(alpha: 0.3);
              }
            } else if (boolColumns.contains(columnName)) {
              alignment = Alignment.center;
              displayValue = (value == true) ? "✅" : "";
            } else {
              alignment = Alignment.centerLeft;
              displayValue = value?.toString() ?? "";
            }

            return formatDataTable(label: displayValue, alignment: alignment, cellColor: cellColor);
          }).toList(),
    );
  }
}
