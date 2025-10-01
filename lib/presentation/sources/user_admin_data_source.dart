import 'package:dongtam/data/models/user/user_admin_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class UserDatasource extends DataGridSource {
  List<UserAdminModel> userAdmin;
  int? selectedUserId;

  late List<DataGridRow> userAdminDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  UserDatasource({required this.userAdmin, this.selectedUserId}) {
    buildDataGridRows();
  }

  List<DataGridCell> buildPlanningCells(UserAdminModel userAdmin) {
    return [
      DataGridCell<String>(columnName: 'fullName', value: userAdmin.fullName),
      DataGridCell<String>(columnName: 'email', value: userAdmin.email),
      DataGridCell<String>(columnName: 'sex', value: userAdmin.sex),
      DataGridCell<String>(columnName: 'phone', value: userAdmin.phone),
      DataGridCell<String>(columnName: 'role', value: userAdmin.role),
      DataGridCell<String>(
        columnName: 'permission',
        value: userAdmin.permissions.join(', '),
      ),
      DataGridCell<String>(columnName: 'avatar', value: userAdmin.avatar),
    ];
  }

  @override
  List<DataGridRow> get rows => userAdminDataGridRows;

  void buildDataGridRows() {
    userAdminDataGridRows =
        userAdmin
            .map<DataGridRow>(
              (planning) => DataGridRow(cells: buildPlanningCells(planning)),
            )
            .toList();

    notifyListeners();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: Colors.transparent,
      cells:
          row.getCells().map<Widget>((dataCell) {
            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else {
              alignment = Alignment.centerLeft;
            }

            return Container(
              alignment: alignment,
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
                dataCell.value?.toString() ?? "",
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
