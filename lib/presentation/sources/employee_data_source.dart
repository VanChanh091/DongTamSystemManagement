import 'package:dongtam/data/models/employee/employee_basic_info.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class EmployeeDataSource extends DataGridSource {
  List<EmployeeBasicInfo> employee = [];
  int? selectedEmployeeId;

  late List<DataGridRow> employeeDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  EmployeeDataSource({required this.employee, this.selectedEmployeeId}) {
    buildDataGridRows();
  }

  List<DataGridCell> buildEmployeeCells(EmployeeBasicInfo employee) {
    final companyInfo = employee.companyInfo;

    return [
      DataGridCell<String>(columnName: "employeeCode", value: companyInfo?.employeeCode ?? ""),
      DataGridCell<String>(columnName: "fullName", value: employee.fullName),
      DataGridCell<String>(
        columnName: "joinDate",
        value: companyInfo?.joinDate != null ? formatter.format(companyInfo!.joinDate!) : '',
      ),
      DataGridCell<String>(columnName: "department", value: companyInfo?.department ?? ""),
      DataGridCell<String>(columnName: "position", value: companyInfo?.position ?? ""),
      DataGridCell<String>(columnName: "gender", value: employee.gender),
      DataGridCell<String>(
        columnName: "birthday",
        value: employee.birthday != null ? formatter.format(employee.birthday!) : "",
      ),
      DataGridCell<String>(columnName: "birthPlace", value: employee.birthPlace),
      DataGridCell<String>(columnName: "homeTown", value: employee.homeTown),
      DataGridCell<String>(columnName: "citizenId", value: employee.citizenId),
      DataGridCell<String>(
        columnName: "citizenDate",
        value:
            employee.citizenIssuedDate != null ? formatter.format(employee.citizenIssuedDate!) : "",
      ),
      DataGridCell<String>(columnName: "citizenIssuedPlace", value: employee.citizenIssuedPlace),
      DataGridCell<String>(columnName: "permanentAddress", value: employee.permanentAddress),
      DataGridCell<String>(columnName: "temporaryAddress", value: employee.temporaryAddress),
      DataGridCell<String>(columnName: "ethnicity", value: employee.ethnicity),
      DataGridCell<String>(columnName: "educationLevel", value: employee.educationLevel),
      DataGridCell<String>(columnName: "educationSystem", value: employee.educationSystem),
      DataGridCell<String>(columnName: "major", value: employee.major),
      DataGridCell<String>(columnName: "phoneNumber", value: employee.phoneNumber),
      DataGridCell<String>(columnName: "emergencyPhone", value: companyInfo?.emergencyPhone ?? ""),
      DataGridCell<String>(columnName: "status", value: companyInfo?.status ?? ""),

      //hidden
      DataGridCell<int>(columnName: "employeeId", value: employee.employeeId),
    ];
  }

  @override
  List<DataGridRow> get rows => employeeDataGridRows;

  void buildDataGridRows() {
    employeeDataGridRows =
        employee.map<DataGridRow>((e) {
          return DataGridRow(cells: buildEmployeeCells(e));
        }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final employeeId = row.getCells().firstWhere((cell) => cell.columnName == 'employeeId').value;

    Color backgroundColor;
    if (selectedEmployeeId == employeeId) {
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
