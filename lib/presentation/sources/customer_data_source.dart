import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
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

  List<DataGridCell> buildCustomerCells(Customer customer) {
    return [
      DataGridCell<String>(columnName: "customerId", value: customer.customerId),
      DataGridCell<String>(columnName: "maSoThue", value: customer.mst),
      DataGridCell<String>(columnName: "customerName", value: customer.customerName),
      DataGridCell<String>(columnName: "phone", value: customer.phone),
      DataGridCell<String>(columnName: "contactPerson", value: customer.contactPerson ?? ""),
      DataGridCell<String>(
        columnName: "dayCreatedCus",
        value: customer.dayCreated != null ? formatter.format(customer.dayCreated!) : "",
      ),
      DataGridCell<String>(
        columnName: "debtLimitCustomer",
        value:
            (customer.debtLimit ?? 0) > 0
                ? '${Order.formatCurrency(customer.debtLimit ?? 0)} VNĐ'
                : "0",
      ),
      DataGridCell<String>(
        columnName: "debtCurrentCustomer",
        value:
            (customer.debtCurrent ?? 0) > 0
                ? '${Order.formatCurrency(customer.debtCurrent ?? 0)} VNĐ'
                : "0",
      ),
      DataGridCell<String>(
        columnName: "termPaymentCost",
        value: customer.timePayment != null ? formatter.format(customer.timePayment!) : "",
      ),
      DataGridCell<String>(columnName: "companyName", value: customer.companyName),
      DataGridCell<String>(columnName: "companyAddress", value: customer.companyAddress),
      DataGridCell<String>(columnName: "shippingAddress", value: customer.shippingAddress),
      DataGridCell<String>(
        columnName: "distanceShip",
        value:
            (customer.distance ?? 0) > 0
                ? '${Order.formatCurrency(customer.distance ?? 0)} Km'
                : "0",
      ),
      DataGridCell<String>(columnName: "CSKH", value: customer.cskh),
      DataGridCell<String>(columnName: "customerSource", value: customer.customerSource),
      DataGridCell<String>(columnName: "rateCustomer", value: customer.rateCustomer ?? ""),
    ];
  }

  @override
  List<DataGridRow> get rows => customerDataGridRows;

  void buildDataGridRows() {
    customerDataGridRows =
        customer.map<DataGridRow>((customer) {
          return DataGridRow(cells: buildCustomerCells(customer));
        }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final customerId =
        row.getCells().firstWhere((cell) => cell.columnName == 'customerId').value.toString();

    Color backgroundColor;
    if (selectedCustomerId == customerId) {
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
