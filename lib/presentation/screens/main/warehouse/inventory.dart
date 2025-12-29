import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/models/warehouse/inventory_model.dart';
import 'package:dongtam/presentation/components/headerTable/warehouse/header_inventory.dart';
import 'package:dongtam/presentation/sources/warehouse/inventory_data_source.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  late Future<Map<String, dynamic>> futureInventory;
  late InventoryDataSource inventoryDataSource;
  late List<GridColumn> columns;
  final dataGridController = DataGridController();
  final themeController = Get.find<ThemeController>();

  List<int> selectedInventoryId = [];
  TextEditingController searchController = TextEditingController();
  Map<String, double> columnWidths = {};
  String searchType = "Tất cả";
  bool isTextFieldEnabled = false;
  bool isSearching = false;

  int currentPage = 1;
  int pageSize = 30;
  int pageSizeSearch = 20;

  @override
  void initState() {
    super.initState();
    loadReportInbound();

    columns = buildInventoryColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'inventory', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadReportInbound() {
    setState(() {
      futureInventory = ensureMinLoading(
        WarehouseService().getAllInventory(page: currentPage, pageSize: pageSize),
      );
    });

    selectedInventoryId.clear();
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
                      child: Obx(
                        () => Text(
                          "HÀNG TỒN KHO",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: themeController.currentColor.value,
                          ),
                        ),
                      ),
                    ),
                  ),

                  //button
                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //left button
                        SizedBox(),

                        //right button
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                //export excel
                                // AnimatedButton(
                                //   // onPressed: () async {
                                //   //   showDialog(
                                //   //     context: context,
                                //   //     builder:
                                //   //         (_) => DialogSelectExportExcel(
                                //   //           selectedInventoryId: selectedInventoryId,
                                //   //           onPlanningIdsOrRangeDate: () => loadReportInbound(),
                                //   //           machine: machine,
                                //   //         ),
                                //   //   );
                                //   // },
                                //   onPressed: () {},
                                //   label: "Xuất Excel",
                                //   icon: Symbols.export_notes,
                                //   backgroundColor: themeController.buttonColor,
                                // ),
                                // const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //table
            Expanded(
              child: FutureBuilder(
                future: futureInventory,
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
                  } else if (!snapshot.hasData || snapshot.data!['inventories'].isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có báo cáo nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final inventory = data['inventories'] as List<InventoryModel>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  inventoryDataSource = InventoryDataSource(
                    inventory: inventory,
                    selectedInventoryId: selectedInventoryId,
                  );

                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: SfDataGrid(
                          controller: dataGridController,
                          source: inventoryDataSource,
                          isScrollbarAlwaysShown: true,
                          allowExpandCollapseGroup: true, // Bật grouping
                          autoExpandGroups: true,
                          columnWidthMode: ColumnWidthMode.fill,
                          navigationMode: GridNavigationMode.row,
                          selectionMode: SelectionMode.multiple,
                          headerRowHeight: 35,
                          rowHeight: 40,
                          columns: ColumnWidthTable.applySavedWidths(
                            columns: columns,
                            widths: columnWidths,
                          ),
                          // stackedHeaderRows: <StackedHeaderRow>[
                          //   StackedHeaderRow(
                          //     cells: [
                          //       StackedHeaderCell(
                          //         columnNames: ['quantityOrd', 'qtyPaper', 'qtyInbound'],
                          //         child: Obx(
                          //           () => formatColumn(
                          //             label: 'Số Lượng',
                          //             themeController: themeController,
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ],

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
                                tableKey: 'inventory',
                                columnWidths: columnWidths,
                                setState: setState,
                              ),

                          onSelectionChanged: (addedRows, removedRows) {
                            if (addedRows.isEmpty && removedRows.isEmpty) return;

                            setState(() {
                              final selectedRows = dataGridController.selectedRows;

                              selectedInventoryId =
                                  selectedRows
                                      .map((row) {
                                        final cell = row.getCells().firstWhere(
                                          (c) => c.columnName == 'inventoryId',
                                          orElse:
                                              () => const DataGridCell(
                                                columnName: 'inventoryId',
                                                value: '',
                                              ),
                                        );

                                        return int.tryParse(cell.value.toString());
                                      })
                                      .where((id) => id != null)
                                      .cast<int>()
                                      .toList();

                              inventoryDataSource.selectedInventoryId = selectedInventoryId;
                              inventoryDataSource.notifyListeners();
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
                            loadReportInbound();
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadReportInbound();
                          });
                        },
                        onJumpToPage: (page) {
                          setState(() {
                            currentPage = page;
                            loadReportInbound();
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
        onPressed: () => loadReportInbound(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
