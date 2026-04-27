import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/inventory/liquidation_inventory_model.dart';
import 'package:dongtam/presentation/components/headerTable/warehouse/inventory/header_liquidation_inv.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/presentation/sources/warehouse/inventory/liquidation_inv_data_source.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
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
  // bool isTextFieldEnabled = false;
  // bool isSearching = false; //dùng để phân trang cho tìm kiếm

  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 25;

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
  Widget build(BuildContext context) {
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
                        "TỒN KHO THANH LÝ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: themeController.currentColor.value,
                        ),
                      ),
                    ),
                  ),

                  //button
                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: []),
                  ),
                ],
              ),
            ),

            //table
            Expanded(
              child: FutureBuilder(
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
                    return const Center(
                      child: Text(
                        "Không có báo cáo nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final liquidations = data['liquidations'] as List<LiquidationInventoryModel>;

                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  final double totalValueInventory =
                      double.tryParse(data['totalValueInventory']?.toString() ?? '0') ?? 0.0;

                  liquidationDataSource = LiquidationInvDataSource(
                    liquidations: liquidations,
                    selectedLiquidationId: selectedLiquidationId,
                  );

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, right: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Tổng Giá Trị Tồn: ",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              "${Order.formatCurrency(totalValueInventory)} VNĐ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),

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
                          columns: ColumnWidthTable.applySavedWidths(
                            columns: columns,
                            widths: columnWidths,
                          ),
                          stackedHeaderRows: <StackedHeaderRow>[
                            StackedHeaderRow(
                              cells: [
                                StackedHeaderCell(
                                  columnNames: ["qtyTransferred", "qtySold", "qtyRemaining"],
                                  child: formatColumn(
                                    label: 'Số Lượng',
                                    themeController: themeController,
                                  ),
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
                                              () => const DataGridCell(
                                                columnName: 'liquidationId',
                                                value: '',
                                              ),
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
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadInventory(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
