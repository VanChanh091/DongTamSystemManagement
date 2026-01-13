import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DeliveryEstimateDataSource extends DataGridSource {
  List<PlanningPaper> delivery = [];
  List<int>? selectedPaperId;

  late List<DataGridRow> dbPaperDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayCompleted = DateFormat("dd/MM/yyyy HH:mm:ss");

  DeliveryEstimateDataSource({required this.delivery, this.selectedPaperId}) {
    buildDataGridRows();
  }

  List<DataGridCell> buildDbPaperCells(PlanningPaper paper) {
    DataGridCell<String> buildPriceCell({required String columnName, required double value}) {
      return DataGridCell<String>(
        columnName: columnName,
        value: value > 0 ? '${Order.formatCurrency(value)} VND' : '0',
      );
    }

    final order = paper.order;

    return [
      DataGridCell<String>(columnName: "orderId", value: paper.orderId),

      //customer
      DataGridCell<String>(columnName: "customerName", value: order?.customer?.customerName ?? ""),
      DataGridCell<String>(columnName: "companyName", value: order?.customer?.companyName ?? ""),

      //product
      DataGridCell<String>(columnName: "typeProduct", value: order?.product?.typeProduct ?? ""),
      DataGridCell<String>(columnName: "productName", value: order?.product?.productName ?? ""),

      //structure
      DataGridCell<String>(columnName: 'structure', value: paper.formatterStructureOrder),

      //day
      DataGridCell<String>(
        columnName: "dayReceive",
        value: order?.dayReceiveOrder != null ? formatter.format(order!.dayReceiveOrder) : "",
      ),
      DataGridCell<String>(
        columnName: "dateShipping",
        value:
            order?.dateRequestShipping != null ? formatter.format(order!.dateRequestShipping!) : "",
      ),
      DataGridCell<String>(
        columnName: "dayStartProduction",
        value: paper.dayStart != null ? formatter.format(paper.dayStart!) : "",
      ),
      DataGridCell<String>(
        columnName: "dayCompletedProd",
        value: paper.dayCompleted != null ? formatterDayCompleted.format(paper.dayCompleted!) : "",
      ),
      DataGridCell<String>(
        columnName: "dayCompletedOvfl",
        value:
            paper.timeOverflowPlanning?.overflowDayCompleted != null
                ? formatterDayCompleted.format(paper.timeOverflowPlanning!.overflowDayCompleted!)
                : "",
      ),

      //other fields
      DataGridCell<String>(columnName: 'flute', value: order?.flute ?? ''),
      DataGridCell<String>(columnName: 'khoCapGiay', value: '${paper.ghepKho} cm'),
      DataGridCell<String>(columnName: 'daoXa', value: order?.daoXa ?? ''),
      DataGridCell<String>(columnName: 'length', value: '${paper.lengthPaperPlanning} cm'),
      DataGridCell<String>(columnName: 'size', value: '${paper.sizePaperPLaning} cm'),
      DataGridCell<int>(columnName: 'child', value: paper.numberChild),

      //quantity
      DataGridCell<int>(columnName: 'quantityOrd', value: order?.quantityManufacture ?? 0),
      DataGridCell<int>(columnName: "qtyProduced", value: paper.qtyProduced),
      DataGridCell<int>(columnName: "runningPlanProd", value: paper.runningPlan),
      DataGridCell<int>(
        columnName: "totalOutbound",
        value: paper.order?.Inventory?.totalQtyOutbound ?? 0,
      ),

      //time running
      DataGridCell<String>(
        columnName: 'timeRunningProd',
        value:
            paper.timeRunning != null
                ? PlanningPaper.formatTimeOfDay(timeOfDay: paper.timeRunning!)
                : '',
      ),
      DataGridCell<String>(
        columnName: 'timeRunningOvfl',
        value:
            paper.timeOverflowPlanning?.overflowTimeRunning != null
                ? PlanningPaper.formatTimeOfDay(
                  timeOfDay: paper.timeOverflowPlanning!.overflowTimeRunning!,
                )
                : '',
      ),
      DataGridCell<String>(columnName: "instructSpecial", value: order?.instructSpecial ?? ''),

      // order
      DataGridCell<String>(columnName: "dvt", value: order?.dvt ?? ""),
      buildPriceCell(columnName: "price", value: order?.price ?? 0),

      //user
      DataGridCell<String>(columnName: "staffOrder", value: order?.user?.fullName ?? ""),

      // hidden technical fields
      DataGridCell<int>(columnName: "planningId", value: paper.planningId),
    ];
  }

  @override
  List<DataGridRow> get rows => dbPaperDataGridRows;

  void buildDataGridRows() {
    dbPaperDataGridRows =
        delivery.map<DataGridRow>((paper) {
          final cells = buildDbPaperCells(paper);

          // debugPrint("Row has ${cells.length} cells");

          return DataGridRow(cells: cells);
        }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final planningId = row.getCells().firstWhere((cell) => cell.columnName == 'planningId').value;

    Color backgroundColor;
    if (selectedPaperId != null && selectedPaperId!.contains(planningId)) {
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
