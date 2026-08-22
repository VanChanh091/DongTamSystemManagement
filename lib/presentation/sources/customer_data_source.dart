import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CustomerDatasource extends DataGridSource {
  List<CustomerModel> customer = [];
  int currentPage;
  int pageSize;

  late List<DataGridRow> customerDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  CustomerDatasource({required this.customer, required this.currentPage, required this.pageSize}) {
    buildDataGridRows();
  }

  List<DataGridCell> buildCustomerCells(CustomerModel customer, int index) {
    final payment = customer.payment;

    DataGridCell<String> buildCurrencyCell(String columnName, num value) {
      return DataGridCell<String>(
        columnName: columnName,
        value: (value) > 0 ? OrderModel.formatCurrency(value) : "0",
      );
    }

    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),
      DataGridCell<String>(columnName: "customerId", value: customer.customerId),
      DataGridCell<String>(columnName: "maSoThue", value: customer.mst),
      DataGridCell<String>(columnName: "customerName", value: customer.customerName),
      DataGridCell<String>(columnName: "phone", value: customer.phone),
      DataGridCell<String>(columnName: "contactPerson", value: customer.contactPerson ?? ""),

      buildCurrencyCell('debtLimit', payment?.debtLimit ?? 0),
      buildCurrencyCell('debtCurrent', payment?.debtCurrent ?? 0),
      DataGridCell<String>(
        columnName: "paymentType",
        value: payment?.paymentType != null ? payment!.paymentType : "",
      ),
      DataGridCell<String>(
        columnName: "closingDays",
        value:
            (payment?.closingDays != null && payment!.closingDays!.isNotEmpty)
                ? payment.closingDays!.join(', ')
                : '-',
      ),
      DataGridCell<String>(
        columnName: "paymentTermDays",
        value: payment?.paymentTermDays != null ? '${payment!.paymentTermDays} Ngày' : "",
      ),

      DataGridCell<String>(columnName: "companyName", value: customer.companyName),
      DataGridCell<String>(columnName: "companyAddress", value: customer.companyAddress),
      DataGridCell<String>(columnName: "shippingAddress", value: customer.shippingAddress),
      DataGridCell<String>(
        columnName: "distanceShip",
        value:
            (customer.distance ?? 0) > 0 ? OrderModel.formatCurrency(customer.distance ?? 0) : "0",
      ),
      DataGridCell<String>(columnName: "CSKH", value: customer.cskh),
      DataGridCell<String>(columnName: "customerSource", value: customer.customerSource),
      DataGridCell<String>(columnName: "rateCustomer", value: customer.rateCustomer ?? ""),
      DataGridCell<String>(
        columnName: "createdAt",
        value: customer.createdAt != null ? formatter.format(customer.createdAt!) : "",
      ),
    ];
  }

  @override
  List<DataGridRow> get rows => customerDataGridRows;

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    customerDataGridRows =
        customer.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;

          return DataGridRow(cells: buildCustomerCells(entry.value, globalIndex));
        }).toList();
  }

  String getStatusVi(String type) {
    switch (type) {
      case "daily":
        return "Theo ngày";
      case "weekly":
        return "Theo tuần";
      case "monthly":
        return "Theo tháng";
      case "custom_days":
        return "Tùy chỉnh";
      default:
        return type;
    }
  }

  String getClosingDaysVi(dynamic rawValue) {
    if (rawValue == null) return "-";

    List<int> days = [];

    // Trường hợp là List (ví dụ: [30] hoặc [1, 15])
    if (rawValue is List) {
      days = rawValue.map((e) => int.tryParse(e.toString()) ?? -1).where((e) => e != -1).toList();
    }
    // Trường hợp là int đơn lẻ
    else if (rawValue is int) {
      days = [rawValue];
    }
    // Trường hợp là String (ví dụ: "30" hoặc "[30]")
    else if (rawValue is String) {
      final cleanStr = rawValue.replaceAll(RegExp(r'[\[\]\s]'), '');
      days = cleanStr.split(',').map((e) => int.tryParse(e) ?? -1).where((e) => e != -1).toList();
    }

    if (days.isEmpty) return "-";

    return days
        .map((day) {
          switch (day) {
            case 1:
              return "Thứ 2";
            case 2:
              return "Thứ 3";
            case 3:
              return "Thứ 4";
            case 4:
              return "Thứ 5";
            case 5:
              return "Thứ 6";
            case 6:
              return "Thứ 7";
            case 0:
              return "Chủ Nhật";
            default:
              return "Ngày $day";
          }
        })
        .join(", ");
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((dataCell) {
            String displayValue = dataCell.value?.toString() ?? "";

            if (dataCell.columnName == 'paymentType') {
              displayValue = getStatusVi(displayValue);
            } else if (dataCell.columnName == 'closingDays') {
              displayValue = getClosingDaysVi(dataCell.value);
            }

            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: displayValue, alignment: alignment);
          }).toList(),
    );
  }
}
