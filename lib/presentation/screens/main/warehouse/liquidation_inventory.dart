import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/inventory/liquidation_inventory_model.dart';
import 'package:dongtam/presentation/components/headerTable/warehouse/inventory/header_liquidation_inv.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/presentation/sources/warehouse/inventory/liquidation_inv_data_source.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/presentation/components/shared/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class LiquidationInventory extends StatefulWidget {
  const LiquidationInventory({super.key});

  @override
  State<LiquidationInventory> createState() => _LiquidationInventoryState();
}

class _LiquidationInventoryState extends State<LiquidationInventory> {
  late Future<Map<String, dynamic>> futureLiquidation;
  late LiquidationInvDataSource liquidationDataSource;
  late List<GridColumn> columns;
  final dataGridController = DataGridController();
  final themeController = Get.find<ThemeController>();

  // String searchType = "Tất cả";
  // final Map<String, String> searchFieldMap = {
  //   "Theo Mã Đơn": "orderId",
  //   "Theo Tên KH": "customerName",
  // };

  List<int> selectedLiquidationId = [];
  Map<String, double> columnWidths = {};

  // TextEditingController searchController = TextEditingController();
  final headerScrollController = ScrollController();

  // bool isTextFieldEnabled = false;
  // bool isSearching = false; //dùng để phân trang cho tìm kiếm

  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  @override
  void initState() {
    super.initState();
    loadInventory();

    columns = buildLiquidationColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'liquidation', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadInventory() {
    setState(() {
      futureLiquidation = ensureMinLoading(
        WarehouseService().getLiquidationInv(page: currentPage, pageSize: pageSize),
      );
    });

    selectedLiquidationId.clear();
  }

  @override
  void dispose() {
    super.dispose();
    // searchController.dispose();
    headerScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.backgroundColor.value,
      body: Column(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadInventory(),
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
          "TỒN KHO THANH LÝ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 8),

        //button
        LayoutBuilder(
          builder: (context, constraints) {
            return Scrollbar(
              controller: headerScrollController,
              child: SingleChildScrollView(
                controller: headerScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: []),
                    ),

                    //total price
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Tổng Giá Trị: ",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          FutureBuilder(
                            future: futureLiquidation,
                            builder: (context, snapshot) {
                              final double totalValue =
                                  snapshot.hasData
                                      ? (double.tryParse(
                                            snapshot.data!['totalValueInventory']?.toString() ??
                                                '0',
                                          ) ??
                                          0.0)
                                      : 0.0;

                              return Text(
                                "${OrderModel.formatCurrency(totalValue)} VNĐ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.green.shade500,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
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
      future: futureLiquidation,
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
        } else if (!snapshot.hasData || snapshot.data!['liquidations'].isEmpty) {
          return Container(
            color: themeController.backgroundColor.value,
            child: Center(
              child: Text(
                "Không có đơn thanh lý nào",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final liquidations = data['liquidations'] as List<LiquidationInventoryModel>;

        final currentPg = data['currentPage'];
        final totalPgs = data['totalPages'];

        liquidationDataSource = LiquidationInvDataSource(
          liquidations: liquidations,
          selectedLiquidationId: selectedLiquidationId,
          currentPage: currentPage,
          pageSize: pageSize,
        );

        return Column(
          children: [
            //table
            Expanded(
              child: SfDataGrid(
                controller: dataGridController,
                source: liquidationDataSource,
                isScrollbarAlwaysShown: true,
                allowExpandCollapseGroup: true, // Bật grouping
                autoExpandGroups: true,
                columnWidthMode: ColumnWidthMode.fill,
                navigationMode: GridNavigationMode.row,
                selectionMode: SelectionMode.multiple,
                headerRowHeight: 30,
                rowHeight: 40,
                columns: ColumnWidthTable.applySavedWidths(columns: columns, widths: columnWidths),
                stackedHeaderRows: <StackedHeaderRow>[
                  StackedHeaderRow(
                    cells: [
                      StackedHeaderCell(
                        columnNames: ["qtyTransferred", "qtySold", "qtyRemaining"],
                        child: formatColumn(label: 'Số Lượng', themeController: themeController),
                      ),
                    ],
                  ),
                ],

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
                      tableKey: 'liquidation',
                      columnWidths: columnWidths,
                      setState: setState,
                    ),

                onSelectionChanged: (addedRows, removedRows) {
                  if (addedRows.isEmpty && removedRows.isEmpty) return;

                  setState(() {
                    final selectedRows = dataGridController.selectedRows;

                    selectedLiquidationId =
                        selectedRows
                            .map((row) {
                              final cell = row.getCells().firstWhere(
                                (c) => c.columnName == 'liquidationId',
                                orElse:
                                    () =>
                                        const DataGridCell(columnName: 'liquidationId', value: ''),
                              );

                              return int.tryParse(cell.value.toString());
                            })
                            .where((id) => id != null)
                            .cast<int>()
                            .toList();

                    liquidationDataSource.selectedLiquidationId = selectedLiquidationId;
                    liquidationDataSource.notifyListeners();
                  });
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
                  loadInventory();
                });
              },
              onNext: () {
                setState(() {
                  currentPage++;
                  loadInventory();
                });
              },
              onJumpToPage: (page) {
                setState(() {
                  currentPage = page;
                  loadInventory();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
