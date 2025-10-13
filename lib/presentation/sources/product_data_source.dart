import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProductDataSource extends DataGridSource {
  final BuildContext context;
  late List<DataGridRow> productDataGridRows;
  List<Product> products = [];
  String? selectedProductId;

  ProductDataSource({
    required this.context,
    required this.products,
    this.selectedProductId,
  }) {
    buildDataGridRows();
  }

  List<DataGridCell> buildProductCells(Product product) {
    return [
      DataGridCell<String>(columnName: "productId", value: product.productId),
      DataGridCell<String>(
        columnName: "typeProduct",
        value: product.typeProduct,
      ),
      DataGridCell<String>(
        columnName: "productName",
        value: product.productName ?? "",
      ),
      DataGridCell<String>(columnName: "maKhuon", value: product.maKhuon ?? ""),
      DataGridCell<String>(
        columnName: "imageProduct",
        value: product.productImage ?? "Không có ảnh",
      ),
    ];
  }

  @override
  List<DataGridRow> get rows => productDataGridRows;

  void buildDataGridRows() {
    productDataGridRows =
        products.map<DataGridRow>((product) {
          return DataGridRow(cells: buildProductCells(product));
        }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final productId =
        row
            .getCells()
            .firstWhere((cell) => cell.columnName == 'productId')
            .value
            .toString();

    Color backgroundColor =
        selectedProductId == productId
            ? Colors.blue.withValues(alpha: 0.3)
            : Colors.transparent;

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            Alignment alignment =
                dataCell.value is num
                    ? Alignment.centerRight
                    : Alignment.centerLeft;

            // ✅ Nếu là cột hình ảnh thì custom hiển thị
            if (dataCell.columnName == 'imageProduct') {
              final imageUrl = dataCell.value?.toString() ?? "";
              final hasImage =
                  imageUrl.isNotEmpty && imageUrl != "Không có ảnh";

              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child:
                    hasImage
                        ? TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) {
                                return GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Scaffold(
                                    backgroundColor: Colors.black54,
                                    body: Center(
                                      child: GestureDetector(
                                        onTap:
                                            () {}, // Ngăn đóng dialog khi bấm ảnh
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: SizedBox(
                                            width: 800,
                                            height: 800,
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.contain,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  width: 300,
                                                  height: 300,
                                                  color: Colors.grey.shade300,
                                                  alignment: Alignment.center,
                                                  child: const Text(
                                                    "Lỗi ảnh",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text(
                            "Xem ảnh",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                        : const Text("Không có ảnh"),
              );
            }

            // ✅ Các cột khác giữ nguyên
            return formatDataTable(
              label: dataCell.value?.toString() ?? "",
              alignment: alignment,
            );
          }).toList(),
    );
  }
}
