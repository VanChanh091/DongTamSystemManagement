import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_product.dart';
import 'package:dongtam/presentation/components/dialog/export/dialog_export_cus_or_prod.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_product.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/product_data_source.dart';
import 'package:dongtam/service/product_service.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<Map<String, dynamic>> futureProduct;
  late List<GridColumn> columns;

  //controller
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Sản Phẩm": "productId",
    "Tên Sản Phẩm": "productName",
  };

  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedProductIdNotifier = ValueNotifier<String?>(null);
  Map<String, double> columnWidths = {}; //map header table

  //datasource and cache
  List<ProductModel>? _cachedProducts;
  ProductDataSource? _cachedDatasource;

  //text controller
  final searchController = TextEditingController();
  final headerScrollController = ScrollController();

  //flag
  late bool isSale;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm
  bool selectedAll = false;
  bool isTextFieldEnabled = false;

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  @override
  void initState() {
    super.initState();
    loadProduct();

    isSale = userController.hasPermission(permission: "sale");

    columns = buildProductColumn(themeController: themeController);
    ColumnWidthTable.loadWidths(tableKey: 'product', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void _fetchData() {
    final String keyword = searchController.text.trim().toLowerCase();
    final String selectedField = searchFieldMap[searchType] ?? "";

    // Điều kiện để xác định có thực hiện search hay load mặc định
    final bool shouldSearch = isSearching && searchType != "Tất cả";

    futureProduct = ensureMinLoading(
      ProductService().getProducts(
        page: currentPage,
        pageSize: pageSize,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? keyword : null,
      ),
    );

    _selectedProductIdNotifier.value = null;
  }

  void loadProduct() {
    setState(() => _fetchData());
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
      _fetchData();
    });
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    _zoomNotifier.dispose();
    _selectedProductIdNotifier.dispose();
    headerScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.backgroundColor.value, // Nền xám nhạt giúp bảng nổi bật
      body: Listener(
        onPointerSignal:
            (pointerSignal) => handleScrollZoom(
              pointerSignal: pointerSignal,
              currentZoom: _zoomNotifier.value,
              onZoomChanged: _updateZoom,
            ),

        child: Stack(
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, cachedChild) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: OverflowBox(
                        minWidth: constraints.maxWidth / zoom,
                        maxWidth: constraints.maxWidth / zoom,
                        minHeight: constraints.maxHeight / zoom,
                        maxHeight: constraints.maxHeight / zoom,
                        alignment: Alignment.topLeft,
                        child: Transform.scale(
                          scale: zoom,
                          alignment: Alignment.topLeft,
                          child: cachedChild,
                        ),
                      ),
                    );
                  },
                );
              },

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title & buttons
                  Container(padding: const EdgeInsets.all(12), child: _buildHeaderBar()),

                  //table & pagination
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildTableSection(),
                    ),
                  ),
                ],
              ),
            ),

            //slider zoom
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, _) {
                return SliderZoom(
                  zoomLevel: zoom,
                  onZoomChanged: _updateZoom,
                  // initialMargin: Offset(142, 56),
                  initialMargin: Offset(73, 152),
                  buttonColor: themeController.buttonColor.value,
                );
              },
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

  Widget _buildHeaderBar() {
    return Column(
      children: [
        //title
        Text(
          "DANH SÁCH SẢN PHẨM",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 8),

        //search & button
        LayoutBuilder(
          builder: (context, constraints) {
            return Scrollbar(
              controller: headerScrollController,
              child: SingleChildScrollView(
                controller: headerScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 5),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //search
                      LeftButtonSearch(
                        selectedType: searchType,
                        types: const ['Tất cả', "Mã Sản Phẩm", "Tên Sản Phẩm"],
                        onTypeChanged: (value) {
                          setState(() {
                            searchType = value;
                            isTextFieldEnabled = value != 'Tất cả';

                            if (searchType == "Tất cả" && searchController.text.isNotEmpty) {
                              searchController.clear();
                              currentPage = 1;
                              _fetchData();
                            }
                          });
                        },
                        controller: searchController,
                        textFieldEnabled: isTextFieldEnabled,
                        buttonColor: themeController.buttonColor,
                        onSearch: () => searchProduct(),
                      ),
                      const SizedBox(width: 20),

                      //right button
                      if (isSale)
                        ValueListenableBuilder(
                          valueListenable: _selectedProductIdNotifier,
                          builder: (context, selectedProductId, _) {
                            final bool hasSelection =
                                selectedProductId != null && selectedProductId.isNotEmpty;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                //export excel
                                AnimatedButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (_) => DialogExportCusOrProd(isProduct: true),
                                    );
                                  },
                                  label: "Xuất Excel",
                                  icon: Symbols.file_download,
                                  backgroundColor: themeController.buttonColor,
                                ),
                                const SizedBox(width: 8),

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
                                const SizedBox(width: 8),

                                // update
                                AnimatedButton(
                                  onPressed:
                                      hasSelection ? () => _handleEdit(selectedProductId) : null,
                                  label: "Sửa",
                                  icon: Symbols.construction,
                                  backgroundColor: themeController.buttonColor,
                                ),
                                const SizedBox(width: 8),

                                //delete
                                AnimatedButton(
                                  onPressed:
                                      hasSelection ? () => _handleDelete(selectedProductId) : null,
                                  label: "Xóa",
                                  icon: Icons.delete,
                                  backgroundColor: const Color(0xffEA4346),
                                ),
                                const SizedBox(width: 3),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTableSection() {
    return FutureBuilder(
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
          return Container(
            color: themeController.backgroundColor.value,
            child: Center(
              child: Text(
                "Không có sản phẩm nào",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final products = data['products'] as List<ProductModel>;
        final currentPg = data['currentPage'];
        final totalPgs = data['totalPages'];

        if (_cachedProducts != products || _cachedDatasource == null) {
          _cachedProducts = products;
          _cachedDatasource = ProductDataSource(
            context: context,
            products: products,
            selectedProductId: _selectedProductIdNotifier.value,
            currentPage: currentPage,
            pageSize: pageSize,
          );
        }

        return Column(
          children: [
            //table
            Expanded(
              child: StatefulBuilder(
                builder: (context, localSetState) {
                  return SfDataGridTheme(
                    data: SfDataGridThemeData(selectionColor: Colors.blue.withValues(alpha: 0.3)),
                    child: SfDataGrid(
                      source: _cachedDatasource!,
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
                            setState: localSetState,
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

                          _selectedProductIdNotifier.value = productId;
                        } else {
                          setState(() {
                            _selectedProductIdNotifier.value = null;
                          });
                        }
                      },
                    ),
                  );
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
    );
  }

  // ==================== ACTION HANDLERS ====================

  Future<void> _handleEdit(String productId) async {
    try {
      final productsData = await futureProduct;
      final productList = (productsData['products'] as List? ?? []).cast<ProductModel>();
      final selectedProduct = productList.firstWhere(
        (product) => product.productId == productId,
        orElse: () => throw Exception('Không tìm thấy sản phẩm'),
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) =>
                ProductDialog(product: selectedProduct, onProductAddOrUpdate: () => loadProduct()),
      );
    } catch (e, s) {
      AppLogger.e("Error in getProductById: $e", stackTrace: s);

      if (!context.mounted) return;
      showSnackBarError(context, 'Có lỗi xảy ra, vui lòng thử lại sau');
    }
  }

  Future<void> _handleDelete(String productId) async {
    await showDeleteConfirmHelper(
      context: context,
      title: "⚠️ Xác nhận xoá",
      content: "Bạn có chắc chắn muốn xoá sản phẩm này?",
      onDelete: () async {
        await ProductService().deleteProduct(productId: productId);
      },
      onSuccess: () {
        _selectedProductIdNotifier.value = null;
        loadProduct();
      },
    );
  }
}
