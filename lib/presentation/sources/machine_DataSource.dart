import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MachineDatasource extends DataGridSource {
  late List<DataGridRow> planningDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  List<Planning> planning;
  String? selectedPlanningId;

  MachineDatasource({required this.planning, this.selectedPlanningId}) {
    buildDataGridRows(); // Khởi tạo ngay từ đầu
  }

  /// Tạo danh sách cell cho từng hàng
  List<DataGridCell> buildPlanningCells(Planning planning) {
    return [
      DataGridCell<String>(columnName: 'orderId', value: planning.orderId),
      DataGridCell<String>(
        columnName: 'customerName',
        value: planning.order?.customer?.customerName ?? '',
      ),
      DataGridCell<String>(
        columnName: "dateShipping",
        value:
            planning.order?.dateRequestShipping != null
                ? formatter.format(planning.order!.dateRequestShipping)
                : '',
      ),
      DataGridCell<String>(
        columnName: 'structure',
        value: planning.formatterStructureOrder,
      ),
      DataGridCell<String>(
        columnName: 'QC_box',
        value: planning.order?.QC_box ?? '',
      ),
      DataGridCell<String>(
        columnName: "HD_special",
        value: planning.order?.instructSpecial ?? '',
      ),
      DataGridCell<String>(
        columnName: 'daoXa',
        value: planning.order?.daoXa ?? '',
      ),
      DataGridCell<double>(
        columnName: 'length',
        value: planning.lengthPaperPlanning,
      ),
      DataGridCell<double>(
        columnName: 'size',
        value: planning.sizePaperPLaning,
      ),
      DataGridCell<int>(
        columnName: 'quantity',
        value: planning.order?.quantityCustomer ?? 0,
      ),
      DataGridCell<int>(
        columnName: "runningPlanProd",
        value: planning.runningPlan,
      ),
      DataGridCell<String>(
        columnName: 'timeRunningProd',
        value: Planning.formatTimeOfDay(planning.timeRunning),
      ),
      DataGridCell<double>(
        columnName: 'dmPheLieu',
        value: planning.paperConsumptionNorm?.totalConsumption ?? 0,
      ),
      DataGridCell<double>(
        columnName: 'plDauC',
        value: planning.paperConsumptionNorm?.DmSongC ?? 0,
      ),
      DataGridCell<double>(
        columnName: 'plDauB',
        value: planning.paperConsumptionNorm?.DmSongB ?? 0,
      ),
      DataGridCell<double>(
        columnName: 'plDauE',
        value: planning.paperConsumptionNorm?.DmSongE ?? 0,
      ),
      DataGridCell<double>(
        columnName: 'plDay',
        value: planning.paperConsumptionNorm?.DmDay ?? 0,
      ),
      DataGridCell<double>(
        columnName: 'plDao',
        value: planning.paperConsumptionNorm?.DmDao ?? 0,
      ),
      DataGridCell<String>(
        columnName: 'totalPrice',
        value: Order.formatCurrency(planning.order?.totalPrice ?? 0),
      ),
    ];
  }

  @override
  List<DataGridRow> get rows => planningDataGridRows;

  String formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = [
      'canMang',
      'xa',
      'catKhe',
      'be',
      'dan_1_Manh',
      'dan_2_Manh',
      'dongGhimMotManh',
      'dongGhimHaiManh',
      'chongTham',
    ];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? 'Có' : '';
    }

    return value?.toString() ?? '';
  }

  /// Xây dựng lại danh sách DataGridRow
  void buildDataGridRows() {
    planningDataGridRows =
        planning
            .map<DataGridRow>(
              (planning) => DataGridRow(cells: buildPlanningCells(planning)),
            )
            .toList();

    notifyListeners(); // cập nhật lại DataGrid
  }

  /// Di chuyển hàng lên
  void moveRowUp(int index) {
    if (index > 0) {
      final temp = planning[index];
      planning[index] = planning[index - 1];
      planning[index - 1] = temp;
      buildDataGridRows(); // cập nhật bảng
    }
  }

  /// Di chuyển hàng xuống
  void moveRowDown(int index) {
    if (index < planning.length - 1) {
      final temp = planning[index];
      planning[index] = planning[index + 1];
      planning[index + 1] = temp;
      buildDataGridRows();
    }
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final orderId = row.getCells()[0].value.toString();

    Color backgroundColor = Colors.transparent;
    if (selectedPlanningId == orderId) {
      backgroundColor = Colors.blue.withOpacity(0.3);
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Text(
                formatCellValueBool(dataCell),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
    );
  }
}
