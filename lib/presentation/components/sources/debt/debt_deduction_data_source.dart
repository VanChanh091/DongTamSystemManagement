import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/warehouse/debt_deduction_request_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class DebtDeductionDataSource extends DataGridSource {
  final List<DebtDeductionRequestModel> debtDeductions;
  final int? selectedRequestId;
  final int currentPage;
  final int pageSize;
  final formatter = DateFormat("dd/MM/yyyy");

  late List<DataGridRow> _rows;

  DebtDeductionDataSource({
    required this.debtDeductions,
    required this.currentPage,
    required this.pageSize,
    this.selectedRequestId,
  }) {
    buildDataGridRows();
  }

  @override
  List<DataGridRow> get rows => _rows;

  List<DataGridCell> buildDebtDeductionCells(DebtDeductionRequestModel debt, int index) {
    return [
      DataGridCell<int>(columnName: "index", value: index + 1),
      DataGridCell<String>(
        columnName: "customerName",
        value: debt.Customer?.customerName ?? debt.customerId,
      ),
      DataGridCell<String>(
        columnName: "createdAt",
        value: debt.createdAt != null ? formatter.format(debt.createdAt!) : "-",
      ),
      DataGridCell<double>(columnName: "amountRequested", value: debt.amountRequested),
      DataGridCell<double>(columnName: "currentDebt", value: debt.currentDebt),
      DataGridCell<String>(columnName: "paymentMethod", value: debt.paymentMethod),
      DataGridCell<String>(columnName: "requestedBy", value: debt.requestedBy),
      DataGridCell<String>(
        columnName: "isUrgent",
        value: debt.isUrgent ? "Khẩn cấp" : "Bình thường",
      ),
      DataGridCell<String>(columnName: "status", value: debt.status),
      DataGridCell<int>(columnName: "requestId", value: debt.requestId),
    ];
  }

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    _rows =
        debtDeductions.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;
          return DataGridRow(cells: buildDebtDeductionCells(entry.value, globalIndex));
        }).toList();
  }

  String _formatStatus(String status) {
    switch (status) {
      case "pending":
        return "Chờ duyệt";
      case "approved":
        return "Đã duyệt";
      case "rejected":
        return "Bị từ chối";
      default:
        return status;
    }
  }

  String _formatPaymentMethod(String method) {
    switch (method) {
      case "cash":
        return "Tiền mặt";
      case "bank_transfer":
        return "Chuyển khoản";
      default:
        return method;
    }
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final requestId = row.getCells().firstWhere((cell) => cell.columnName == "requestId").value;
    final isSelected = selectedRequestId == requestId;

    return DataGridRowAdapter(
      color: isSelected ? Colors.blue.withValues(alpha: 0.25) : Colors.transparent,
      cells:
          row.getCells().map<Widget>((dataCell) {
            final value = dataCell.value;

            String displayValue = "";
            Alignment alignment = Alignment.centerLeft;

            if (value is num) {
              alignment = Alignment.centerRight;
              final numVal = value.toDouble();
              displayValue =
                  (numVal == 0 && dataCell.columnName != "currentDebt")
                      ? "-"
                      : OrderModel.formatCurrency(numVal);
            } else {
              alignment = Alignment.centerLeft;
              displayValue = value?.toString() ?? "";

              if (dataCell.columnName == "status") {
                displayValue = _formatStatus(displayValue);
              } else if (dataCell.columnName == "paymentMethod") {
                displayValue = _formatPaymentMethod(displayValue);
              }
            }

            return formatDataTable(label: displayValue, alignment: alignment);
          }).toList(),
    );
  }
}
