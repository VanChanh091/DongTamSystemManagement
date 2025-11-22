import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class StagesDataSource extends DataGridSource {
  List<PlanningStage> stages = [];

  late List<DataGridRow> stagesDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayCompleted = DateFormat("dd/MM/yyyy HH:mm:ss");

  StagesDataSource({required this.stages}) {
    buildDataGridRows();
  }

  List<DataGridCell> buildStagesCells(PlanningStage stage) {
    return [
      DataGridCell<String>(columnName: "machine", value: stage.machine),
      DataGridCell<String>(
        columnName: "dayStart",
        value: stage.dayStart != null ? formatter.format(stage.dayStart!) : "",
      ),
      DataGridCell<String>(
        columnName: "dayCompleted",
        value: stage.dayCompleted != null ? formatterDayCompleted.format(stage.dayCompleted!) : "",
      ),
      DataGridCell<String>(
        columnName: "dayCompletedOvfl",
        value:
            stage.timeOverflow?.overflowDayCompleted != null
                ? formatterDayCompleted.format(stage.timeOverflow!.overflowDayCompleted!)
                : "",
      ),
      DataGridCell<String>(
        columnName: "timeRunning",
        value:
            stage.timeRunning != null
                ? PlanningPaper.formatTimeOfDay(timeOfDay: stage.timeRunning!)
                : '',
      ),
      DataGridCell<String>(
        columnName: "timeRunningOvfl",
        value:
            stage.timeOverflow?.overflowTimeRunning != null
                ? PlanningPaper.formatTimeOfDay(timeOfDay: stage.timeOverflow!.overflowTimeRunning!)
                : '',
      ),
      DataGridCell<int>(columnName: "runningPlan", value: stage.runningPlan),
      DataGridCell<int>(columnName: "qtyProduced", value: stage.qtyProduced),
      DataGridCell<double>(columnName: "wasteBox", value: stage.wasteBox),
      DataGridCell<double>(columnName: "rpWasteLoss", value: stage.rpWasteLoss),
      DataGridCell<String>(columnName: "shiftManagement", value: stage.shiftManagement ?? ''),

      //hide
      DataGridCell<int>(columnName: "planningBoxId", value: stage.planningBoxId),
    ];
  }

  @override
  List<DataGridRow> get rows => stagesDataGridRows;

  void buildDataGridRows() {
    stagesDataGridRows =
        stages.map<DataGridRow>((stage) {
          final cells = buildStagesCells(stage);
          return DataGridRow(cells: cells);
        }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
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
