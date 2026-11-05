import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerProduct = [
  {"key": "index", "title": "STT"},
  {"key": "productId", "title": "Mã Sản Phẩm"},
  {"key": "typeProduct", "title": "Loại Sản Phẩm"},
  {"key": "productName", "title": "Tên Sản Phẩm"},
  {"key": "layerCount", "title": "Số lớp"},
  {"key": "wave", "title": "Loại Sóng"},
  {"key": "maKhuon", "title": "Mã Khuôn"},
  {"key": "imageProduct", "title": "Hình ảnh", "width": 150.0},
];


List<GridColumn> buildProductColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _headerProduct,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);
