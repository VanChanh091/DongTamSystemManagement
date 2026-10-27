import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/warehouse/debt_deduction_request_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class DebtDeductionDataSource extends DataGridSource {
  final List<DebtDeductionRequestModel> debtDeductions;
  final int? selectedRequestId;
  final bool isReport;
  final int currentPage;
  final int pageSize;
  final formatter = DateFormat("dd/MM/yyyy HH:mm:ss");
  final formatterNoHour = DateFormat("dd/MM/yyyy HH:mm:ss");

  late List<DataGridRow> _rows;

  DebtDeductionDataSource({
    required this.debtDeductions,
    required this.isReport,
    required this.currentPage,
    required this.pageSize,
    this.selectedRequestId,
  }) {
    buildDataGridRows();
    addColumnGroup(ColumnGroup(name: "createdRequest", sortGroupRows: false));
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

      if (isReport != true)
        DataGridCell<double>(columnName: "currentDebt", value: debt.currentDebt),

      DataGridCell<String>(columnName: "paymentMethod", value: debt.paymentMethod),
      DataGridCell<String>(columnName: "requestedBy", value: debt.requestedBy),

      if (isReport) DataGridCell<String>(columnName: "approvedBy", value: debt.approvedBy),

      DataGridCell<String>(
        columnName: "isUrgent",
        value: debt.isUrgent ? "Khẩn cấp" : "Bình thường",
      ),
      DataGridCell<String>(columnName: "status", value: debt.status),

      //hidden fields
      DataGridCell<int>(columnName: "requestId", value: debt.requestId),
      DataGridCell<String>(
        columnName: "createdRequest",
        value: debt.createdAt != null ? formatterNoHour.format(debt.createdAt!) : "-",
      ),
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
      itemCount = "(Số lượng: $count)";
    }

    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        displayDate.isNotEmpty
            ? "📅 Ngày Yêu Cầu: $displayDate  $itemCount"
            : "📅 Ngày Yêu Cầu: Không xác định",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final requestId = row.getCells().firstWhere((cell) => cell.columnName == "requestId").value;
    final status = row.getCells().firstWhere((cell) => cell.columnName == "status").value;
    final isSelected = selectedRequestId == requestId;
    final isRejected = status == "rejected";

    // Màu nền dòng: Nếu được chọn thì xanh, nếu bị từ chối thì nền đỏ nhạt nổi bật
    Color rowColor = Colors.transparent;
    if (isSelected) {
      rowColor = Colors.blue.withValues(alpha: 0.25);
    } else if (isRejected) {
      rowColor = Colors.red.withValues(alpha: 0.4);
    }

    return DataGridRowAdapter(
      color: rowColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            final value = dataCell.value;

            String displayValue = "";
            Alignment alignment = Alignment.centerLeft;
            TextStyle? textStyle;

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

            return formatDataTable(label: displayValue, alignment: alignment, textStyle: textStyle);
          }).toList(),
    );
  }
}
