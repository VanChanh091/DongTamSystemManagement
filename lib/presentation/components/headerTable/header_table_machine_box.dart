import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildMachineBoxColumns(String machine) {
  return [
    //planning
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
    GridColumn(columnName: 'qtyPrinted', label: formatColumn("SL In")),

    //can mang
    GridColumn(columnName: 'qtyCanMang', label: formatColumn("SL Cán Màng")),
    // GridColumn(columnName: 'wasteCanMang', label: formatColumn("Phế Liệu")),

    //xa
    GridColumn(columnName: 'qtyXa', label: formatColumn("SL Xả")),
    // GridColumn(columnName: 'wasteNormXa', label: formatColumn("Phế Liệu")),

    //cat khe
    GridColumn(columnName: 'qtyCatKhe', label: formatColumn("SL Cắt Khe")),
    // GridColumn(columnName: 'wasteCatKhe', label: formatColumn("Phế Liệu")),

    //be
    GridColumn(columnName: 'qtyBe', label: formatColumn("SL Bế")),
    // GridColumn(columnName: 'wasteNormBe', label: formatColumn("Phế Liệu")),

    //dan
    GridColumn(columnName: 'qtyDan', label: formatColumn("SL Dán")),
    // GridColumn(columnName: 'wasteDan', label: formatColumn("Phế Liệu")),

    //dong ghim
    GridColumn(columnName: 'qtyDongGhim', label: formatColumn("SL Đóng Ghim")),
    // GridColumn(columnName: 'wasteDGhim', label: formatColumn("Phế Liệu")),
    GridColumn(columnName: 'dmWasteLoss', label: formatColumn("DM Phế Liệu")),
    GridColumn(columnName: 'wastePrint', label: formatColumn("PL Thực Tế")),
    GridColumn(columnName: 'shiftManager', label: formatColumn("Trưởng Máy")),
    GridColumn(columnName: 'note', label: formatColumn("Ghi Chú")),
    GridColumn(columnName: 'status', label: SizedBox(), visible: false),
    GridColumn(
      columnName: 'index',
      label: formatColumn("Index"),
      visible: false,
    ),
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
