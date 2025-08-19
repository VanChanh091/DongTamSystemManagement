import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildMachineBoxColumns(String machine) {
  return [
    //planning - 14 columns
    GridColumn(columnName: 'orderId', label: formatColumn('Mã Đơn Hàng')),
    GridColumn(columnName: 'planningBoxId', label: Container(), visible: false),
    GridColumn(
      columnName: 'customerName',
      label: formatColumn("Tên Khách Hàng"),
    ),
    GridColumn(columnName: 'dateShipping', label: formatColumn("Ngày YC Giao")),
    GridColumn(
      columnName: 'dayStartProduction',
      label: formatColumn("Ngày Sản Xuất"),
    ),
    GridColumn(
      columnName: 'dayCompletedProd',
      label: formatColumn("Ngày Hoàn Thành"),
    ),
    GridColumn(
      columnName: 'structure',
      label: formatColumn("Kết Cấu Đặt Hàng"),
    ),
    GridColumn(columnName: 'flute', label: formatColumn("Sóng")),
    GridColumn(columnName: 'QC_box', label: formatColumn("QC Thùng")),
    GridColumn(columnName: 'length', label: formatColumn("Dài")),
    GridColumn(columnName: 'size', label: formatColumn("Khổ")),
    GridColumn(columnName: 'child', label: formatColumn("Số Con")),
    GridColumn(columnName: 'quantityOrd', label: formatColumn("SL Đơn Hàng")),
    GridColumn(columnName: 'runningPlans', label: formatColumn("SL Giấy Tấm")),
    GridColumn(
      columnName: 'timeRunnings',
      label: formatColumn("Thời Gian Chạy"),
    ),

    //print
    if (machine == "Máy In") ...[
      GridColumn(columnName: 'inMatTruoc', label: formatColumn("In Mặt Trước")),
      GridColumn(columnName: 'inMatSau', label: formatColumn("In Mặt Sau")),
    ],
    GridColumn(columnName: 'qtyPrinted', label: formatColumn("In")),
    GridColumn(columnName: 'qtyCanLan', label: formatColumn("Cấn Lằn")),
    GridColumn(columnName: 'qtyCanMang', label: formatColumn("Cán Màng")),
    GridColumn(columnName: 'qtyXa', label: formatColumn("Xả")),
    GridColumn(columnName: 'qtyCatKhe', label: formatColumn("Cắt Khe")),
    GridColumn(columnName: 'qtyBe', label: formatColumn("Bế")),
    GridColumn(columnName: 'qtyDan', label: formatColumn("Dán")),
    GridColumn(columnName: 'qtyDongGhim', label: formatColumn("Đóng Ghim")),
    GridColumn(columnName: 'dmWasteLoss', label: formatColumn("Định Mức PL")),
    GridColumn(columnName: 'wasteActually', label: formatColumn("PL Thực Tế")),
    GridColumn(columnName: 'shiftManager', label: formatColumn("Trưởng Máy")),
    GridColumn(columnName: 'status', label: SizedBox(), visible: false),
    GridColumn(
      columnName: 'index',
      label: formatColumn("Index"),
      visible: false,
    ),

    // GridColumn(columnName: 'wasteCanMang', label: formatColumn("Phế Liệu")),
    // GridColumn(columnName: 'wasteNormXa', label: formatColumn("Phế Liệu")),
    // GridColumn(columnName: 'wasteCatKhe', label: formatColumn("Phế Liệu")),
    // GridColumn(columnName: 'wasteNormBe', label: formatColumn("Phế Liệu")),
    // GridColumn(columnName: 'wasteDan', label: formatColumn("Phế Liệu")),
    // GridColumn(columnName: 'wasteDGhim', label: formatColumn("Phế Liệu")),
  ];
}

Widget formatColumn(String text, {double widthBorder = 0}) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Color(0xffcfa381),
      border: Border(right: BorderSide(color: Colors.grey.shade400, width: 1)),
    ),
    width: widthBorder,
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Colors.white,
      ),
    ),
  );
}
