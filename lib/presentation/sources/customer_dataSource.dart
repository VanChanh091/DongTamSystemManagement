import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CustomerDatasource extends DataGridSource {
  List<Customer> customer = [];
  String? selectedCustomerId;

  late List<DataGridRow> customerDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  CustomerDatasource({required this.customer, this.selectedCustomerId}) {
    buildDataGridRows();
  }

  List<DataGridCell> buildCustomerCells(Customer customer, int index) {
    return [
      DataGridCell<int>(columnName: "stt", value: index + 1),
      DataGridCell<String>(
        columnName: "customerId",
        value: customer.customerId,
      ),
      DataGridCell<String>(columnName: "maSoThue", value: customer.mst),
      DataGridCell<String>(
        columnName: "customerName",
        value: customer.customerName,
      ),
      DataGridCell<String>(
        columnName: "companyName",
        value: customer.companyName,
      ),
      DataGridCell<String>(
        columnName: "companyAddress",
        value: customer.companyAddress,
      ),
      DataGridCell<String>(
        columnName: "shippingAddress",
        value: customer.shippingAddress,
      ),
      DataGridCell<String>(columnName: "phone", value: customer.phone),
      DataGridCell<String>(
        columnName: "contactPerson",
        value: customer.contactPerson ?? "",
      ),
      DataGridCell<String>(
        columnName: "dayCreated",
        value:
            customer.dayCreated != null
                ? formatter.format(customer.dayCreated!)
                : "",
      ),
      DataGridCell<String>(columnName: "CSKH", value: customer.cskh),
    ];
  }

  @override
  List<DataGridRow> get rows => customerDataGridRows;

  void buildDataGridRows() {
    customerDataGridRows =
        customer
            .asMap()
            .entries
            .map<DataGridRow>(
              (entry) => DataGridRow(
                cells: buildCustomerCells(entry.value, entry.key),
              ),
            )
            .toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final customerId =
        row
            .getCells()
            .firstWhere((cell) => cell.columnName == 'customerId')
            .value
            .toString();

    Color backgroundColor;
    if (selectedCustomerId == customerId) {
      backgroundColor = Colors.blue.withOpacity(0.3);
    } else {
      backgroundColor = Colors.transparent;
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
