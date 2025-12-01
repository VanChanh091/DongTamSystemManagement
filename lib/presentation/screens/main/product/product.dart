import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_add_product.dart';
import 'package:dongtam/presentation/components/dialog/dialog_export_cus_or_prod.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_product.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/sources/product_data_source.dart';
import 'package:dongtam/service/product_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<Map<String, dynamic>> futureProduct;
  late ProductDataSource productDataSource;
  late List<GridColumn> columns;
  final Map<String, String> searchFieldMap = {"Theo Mã": "productId", "Theo Tên SP": "productName"};
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  TextEditingController searchController = TextEditingController();
  Map<String, double> columnWidths = {};
  bool selectedAll = false;
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm
  String searchType = "Tất cả";
  String? selectedProductId;

  int currentPage = 1;
  int pageSize = 30;
  int pageSizeSearch = 20;

  @override
  void initState() {
    super.initState();
    loadProduct();

    columns = buildProductColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'product', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadProduct() {
    setState(() {
      final String selectedField = searchFieldMap[searchType] ?? "";

      String keyword = searchController.text.trim().toLowerCase();

      if (isSearching && searchType != "Tất cả") {
        AppLogger.i("loadProducts: isSearching=true, keyword='$keyword'");

        futureProduct = ensureMinLoading(
          ProductService().getProductByField(
            field: selectedField,
            keyword: keyword,
            page: currentPage,
            pageSize: pageSizeSearch,
          ),
        );
      } else {
        futureProduct = ensureMinLoading(
          ProductService().getAllProducts(page: currentPage, pageSize: pageSize),
        );
      }

      selectedProductId = null;
    });
  }

  void searchProduct() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchProduct: searchType=$searchType, keyword='$keyword'");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchProduct: search bị bỏ qua vì keyword trống");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");

      if (searchType == "Tất cả") {
        AppLogger.i("searchProduct: tìm tất cả SP");
        futureProduct = ensureMinLoading(
          ProductService().getAllProducts(page: currentPage, pageSize: pageSize),
        );
      } else {
        final selectedField = searchFieldMap[searchType] ?? "";

        AppLogger.i("searchProduct: tìm theo field SP");
        futureProduct = ProductService().getProductByField(
          field: selectedField,
          keyword: keyword,
          page: currentPage,
          pageSize: pageSizeSearch,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSale = userController.hasPermission(permission: "sale");

    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            //button
            SizedBox(
              height: 105,
              width: double.infinity,
              child: Column(
                children: [
                  //title
                  SizedBox(
                    height: 35,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "DANH SÁCH SẢN PHẨM",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: themeController.currentColor.value,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //left button
                        Expanded(
                          flex: 1,
                          child: LeftButtonSearch(
                            selectedType: searchType,
                            types: const ['Tất cả', "Theo Mã", "Theo Tên SP"],
                            onTypeChanged: (value) {
                              setState(() {
                                searchType = value;
                                isTextFieldEnabled = value != 'Tất cả';
                                searchController.clear();
                              });
                            },
                            controller: searchController,
                            textFieldEnabled: isTextFieldEnabled,
                            buttonColor: themeController.buttonColor,

                            onSearch: () => searchProduct(),
                          ),
                        ),

                        //right button
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child:
                                isSale
                                    ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        //export excel
                                        AnimatedButton(
                                          onPressed: () async {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (_) => DialogExportCusOrProd(isProduct: true),
                                            );
                                          },
                                          label: "Xuất Excel",
                                          icon: Symbols.export_notes,
                                          backgroundColor: themeController.buttonColor,
                                        ),
                                        const SizedBox(width: 10),

                                        //add
                                        AnimatedButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (_) => ProductDialog(
                                                    product: null,
                                                    onProductAddOrUpdate: () => loadProduct(),
                                                  ),
                                            );
                                          },
                                          label: "Thêm mới",
                                          icon: Icons.add,
                                          backgroundColor: themeController.buttonColor,
                                        ),
                                        const SizedBox(width: 10),

                                        // update
                                        AnimatedButton(
                                          onPressed:
                                              isSale
                                                  ? () async {
                                                    if (selectedProductId == null ||
                                                        selectedProductId!.isEmpty) {
                                                      showSnackBarError(
                                                        context,
                                                        'Vui lòng chọn sản phẩm cần sửa',
                                                      );
                                                      return;
                                                    }

                                                    try {
                                                      final result = await ProductService()
                                                          .getProductByField(
                                                            field: 'productId',
                                                            keyword: selectedProductId!,
                                                          );

                                                      if (!context.mounted) {
                                                        return;
                                                      }

                                                      // Defensive null checks
                                                      if (result['products'] == null) {
                                                        showSnackBarError(
                                                          context,
                                                          'Dữ liệu trả về không hợp lệ',
                                                        );
                                                        return;
                                                      }

                                                      final products =
                                                          result['products'] as List<Product>? ??
                                                          [];

                                                      if (products.isEmpty) {
                                                        showSnackBarError(
                                                          context,
                                                          'Không tìm thấy khách hàng',
                                                        );
                                                        return;
                                                      }

                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (_) => ProductDialog(
                                                              product: products.first,
                                                              onProductAddOrUpdate:
                                                                  () => loadProduct(),
                                                            ),
                                                      );
                                                    } catch (e, s) {
                                                      AppLogger.e(
                                                        "Error in getProductById: $e",
                                                        stackTrace: s,
                                                      );
                                                      showSnackBarError(
                                                        context,
                                                        'Có lỗi xảy ra, vui lòng thử lại sau',
                                                      );
                                                    }
                                                  }
                                                  : null,
                                          label: "Sửa",
                                          icon: Symbols.construction,
                                          backgroundColor: themeController.buttonColor,
                                        ),
                                        const SizedBox(width: 10),

                                        //delete
                                        AnimatedButton(
                                          onPressed:
                                              isSale &&
                                                      selectedProductId != null &&
                                                      selectedProductId!.isNotEmpty
                                                  ? () async {
                                                    await showDeleteConfirmHelper(
                                                      context: context,
                                                      title: "⚠️ Xác nhận xoá",
                                                      content:
                                                          "Bạn có chắc chắn muốn xoá sản phẩm này?",
                                                      onDelete: () async {
                                                        await ProductService().deleteProduct(
                                                          productId: selectedProductId!,
                                                        );
                                                      },
                                                      onSuccess: () {
                                                        setState(() => selectedProductId = null);
                                                        loadProduct();
                                                      },
                                                    );
                                                  }
                                                  : null,
                                          label: "Xóa",
                                          icon: Icons.delete,
                                          backgroundColor: const Color(0xffEA4346),
                                        ),
                                      ],
                                    )
                                    : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // table
            Expanded(
              child: FutureBuilder(
                future: futureProduct,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: SizedBox(
                        height: 400,
                        child: buildShimmerSkeletonTable(context: context, rowCount: 10),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!['products'].isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có khách hàng nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final products = data['products'] as List<Product>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  productDataSource = ProductDataSource(
                    context: context,
                    products: products,
                    selectedProductId: selectedProductId,
                  );
                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: SfDataGrid(
                          source: productDataSource,
                          isScrollbarAlwaysShown: true,
                          columnWidthMode: ColumnWidthMode.fill,
                          gridLinesVisibility: GridLinesVisibility.both,
                          headerGridLinesVisibility: GridLinesVisibility.both,
                          selectionMode: SelectionMode.single,
                          headerRowHeight: 45,
                          rowHeight: 40,
                          columns: ColumnWidthTable.applySavedWidths(
                            columns: columns,
                            widths: columnWidths,
                          ),

                          //auto resize
                          allowColumnsResizing: true,
                          columnResizeMode: ColumnResizeMode.onResize,

                          onColumnResizeStart: GridResizeHelper.onResizeStart,
                          onColumnResizeUpdate:
                              (details) => GridResizeHelper.onResizeUpdate(
                                details: details,
                                columns: columns,
                                setState: setState,
                              ),
                          onColumnResizeEnd:
                              (details) => GridResizeHelper.onResizeEnd(
                                details: details,
                                tableKey: 'product',
                                columnWidths: columnWidths,
                                setState: setState,
                              ),

                          onSelectionChanged: (addedRows, removedRows) {
                            if (addedRows.isNotEmpty) {
                              final selectedRow = addedRows.first;
                              final productId =
                                  selectedRow
                                      .getCells()
                                      .firstWhere((cell) => cell.columnName == 'productId')
                                      .value
                                      .toString();

                              final selectedProduct = products.firstWhere(
                                (product) => product.productId == productId,
                              );

                              setState(() {
                                selectedProductId = selectedProduct.productId;
                              });
                            } else {
                              setState(() {
                                selectedProductId = null;
                              });
                            }
                          },
                        ),
                      ),

                      // Nút chuyển trang
                      PaginationControls(
                        currentPage: currentPg,
                        totalPages: totalPgs,
                        onPrevious: () {
                          setState(() {
                            currentPage--;
                            loadProduct();
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadProduct();
                          });
                        },
                        onJumpToPage: (page) {
                          setState(() {
                            currentPage = page;
                            loadProduct();
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadProduct(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
