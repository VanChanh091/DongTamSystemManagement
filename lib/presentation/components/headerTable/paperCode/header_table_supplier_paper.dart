import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerSupplierPaperCode = [
  {"key": "supplierCode", "title": "Mã Nhà Cung Cấp"},
  {"key": "companyCode", "title": "Mã Đồng Tâm"},
  {"key": "layerType", "title": "Loại Giấy"},
  {"key": "paperName", "title": "Tên Giấy"},
  {"key": "paperCode", "title": "Mã Giấy"},
  {"key": "grade", "title": "Cấp Độ"},
  {"key": "supplierName", "title": "Tên NCC"},

  //hidden field
  {"key": "supplierPaperId", "title": "", "visible": false},
  {"key": "supplierId", "title": "", "visible": false},
];

List<GridColumn> buildSupplierPaperColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _headerSupplierPaperCode,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);
