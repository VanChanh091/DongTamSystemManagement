import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/inventory_model.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_outbound.dart';
import 'package:dongtam/presentation/components/headerTable/warehouse/header_inventory.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/sources/warehouse/inventory_data_source.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_temp_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
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

  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Theo Mã Đơn": "orderId",
    "Theo Tên KH": "customerName",
  };

  List<int> selectedInventoryId = [];
  Map<String, double> columnWidths = {};

  TextEditingController searchController = TextEditingController();
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm

  int currentPage = 1;
  int pageSize = 25;
  int pageSizeSearch = 20;

  @override
  void initState() {
    super.initState();
    loadInventory();

    columns = buildInventoryColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'inventory', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadInventory() {
    setState(() {
      final String selectedField = searchFieldMap[searchType] ?? "";
      String keyword = searchController.text.trim().toLowerCase();

      if (isSearching && searchType != "Tất cả") {
        futureInventory = ensureMinLoading(
          WarehouseService().getInventory(
            page: currentPage,
            pageSize: pageSizeSearch,
            field: selectedField,
            keyword: keyword,
          ),
        );
      } else {
        futureInventory = ensureMinLoading(
          WarehouseService().getInventory(page: currentPage, pageSize: pageSize),
        );
      }
    });

    selectedInventoryId.clear();
  }

  void searchInventory() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchInventory: searchType=$searchType, keyword='$keyword'");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchInventory: search bị bỏ qua vì keyword trống");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");

      if (searchType == "Tất cả") {
        futureInventory = ensureMinLoading(
          WarehouseService().getInventory(page: currentPage, pageSize: pageSize),
        );
      } else {
        final selectedField = searchFieldMap[searchType] ?? "";

        futureInventory = ensureMinLoading(
          WarehouseService().getInventory(
            field: selectedField,
            keyword: keyword,
            page: currentPage,
            pageSize: pageSizeSearch,
          ),
        );
      }
    });
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
                        "HÀNG TỒN KHO",
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //left button
                        Expanded(
                          flex: 1,
                          child: LeftButtonSearch(
                            selectedType: searchType,
                            types: const ['Tất cả', "Theo Mã Đơn", "Theo Tên KH"],
                            onTypeChanged: (value) {
                              setState(() {
                                searchType = value;
                                isTextFieldEnabled = searchType != 'Tất cả';
                                searchController.clear();
                              });
                            },
                            controller: searchController,
                            textFieldEnabled: isTextFieldEnabled,
                            buttonColor: themeController.buttonColor,

                            onSearch: () => searchInventory(),
                          ),
                        ),

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
                                //   //     builder: (_) => DialogExportCusOrProd(),
                                //   //   );
                                //   // },
                                //   onPressed: () {},
                                //   label: "Xuất Excel",
                                //   icon: Symbols.export_notes,
                                //   backgroundColor: themeController.buttonColor,
                                // ),

                                //outbound
                                AnimatedButton(
                                  onPressed: () async {
                                    if (!context.mounted) return;

                                    List<OutboundTempItem>? initialItems;
                                    if (selectedInventoryId.isNotEmpty) {
                                      try {
                                        final data = await futureInventory;
                                        final inventoryList =
                                            data['inventories'] as List<InventoryModel>;
                                        final selectedModels =
                                            inventoryList
                                                .where(
                                                  (i) =>
                                                      selectedInventoryId.contains(i.inventoryId),
                                                )
                                                .toList();
                                        initialItems =
                                            selectedModels
                                                .map((i) => OutboundTempItem.fromInventoryModel(i))
                                                .toList();
                                      } catch (e) {
                                        // Ignore error if future fails
                                      }
                                    }

                                    if (!context.mounted) return;
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => OutBoundDialog(
                                            outbound: null,
                                            onOutboundHistory: () {
                                              loadInventory();
                                            },
                                            initialItems: initialItems,
                                          ),
                                    );
                                  },
                                  label: "Xuất Kho",
                                  icon: Symbols.input,
                                  backgroundColor: themeController.buttonColor,
                                ),
                                const SizedBox(width: 10),
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

                  final double totalValueInventory =
                      double.tryParse(data['totalValueInventory']?.toString() ?? '0') ?? 0.0;

                  inventoryDataSource = InventoryDataSource(
                    inventory: inventory,
                    selectedInventoryId: selectedInventoryId,
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
                          source: inventoryDataSource,
                          isScrollbarAlwaysShown: true,
                          allowExpandCollapseGroup: true, // Bật grouping
                          autoExpandGroups: true,
                          columnWidthMode: ColumnWidthMode.auto,
                          navigationMode: GridNavigationMode.row,
                          selectionMode: SelectionMode.multiple,
                          headerRowHeight: 35,
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
