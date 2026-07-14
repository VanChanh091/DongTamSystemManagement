import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/inventory/inventory_model.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_outbound.dart';
import 'package:dongtam/presentation/components/dialog/export/dialog_export_inventory.dart';
import 'package:dongtam/presentation/components/dialog/other/dialog_transfer_qty.dart';
import 'package:dongtam/presentation/components/headerTable/warehouse/inventory/header_inventory.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/warehouse/inventory/inventory_data_source.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_temp_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  late Future<Map<String, dynamic>> futureInventory;
  late List<GridColumn> columns;

  //controllers
  final dataGridController = DataGridController();
  final themeController = Get.find<ThemeController>();

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
    "Tên Nhân Viên": "fullName",
  };

  //filter by qtyInventory
  String filterType = "gtZero";
  final Map<String, String> filterOptions = {'gtZero': 'Còn SL Tồn', 'ltZero': 'Âm SL Tồn'};

  //notifiers
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedInventoryIdsNotifier = ValueNotifier<List<int>>([]);

  //datasource and cache
  List<InventoryModel>? _cachedInventory;
  InventoryDataSource? _cachedDatasource;

  List<OutboundTempItemModel>? initialItems;
  Map<String, double> columnWidths = {};

  //text controller
  final searchController = TextEditingController();
  final qtyController = TextEditingController();
  final reasonController = TextEditingController();

  //flag
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm
  bool _isSelectionChange = false;

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

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

  void _fetchData() {
    final String keyword = searchController.text.trim().toLowerCase();
    final String selectedField = searchFieldMap[searchType] ?? "";

    // Điều kiện để xác định có thực hiện search hay load mặc định
    final bool shouldSearch = isSearching && searchType != "Tất cả";

    futureInventory = ensureMinLoading(
      WarehouseService().getInventory(
        page: currentPage,
        pageSize: pageSize,
        filter: filterType,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? keyword : null,
      ),
    );

    _selectedInventoryIdsNotifier.value = [];
    dataGridController.selectedRows = [];
  }

  void loadInventory() {
    setState(() => _fetchData());
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
      _fetchData();
    });
  }

  void _updateSelectedIdsFromRows(List<DataGridRow> rows) {
    final newIds =
        rows
            .map((row) {
              final cell = row.getCells().firstWhere(
                (c) => c.columnName == 'inventoryId',
                orElse: () => const DataGridCell(columnName: 'inventoryId', value: ''),
              );

              return int.tryParse(cell.value.toString());
            })
            .where((id) => id != null)
            .cast<int>()
            .toList();

    _selectedInventoryIdsNotifier.value = newIds;
    _cachedDatasource?.selectedInventoryId = newIds;
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    qtyController.dispose();
    reasonController.dispose();
    _zoomNotifier.dispose();
    _selectedInventoryIdsNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Container(
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
                                "TỒN KHO THÀNH PHẨM",
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
                                    types: const [
                                      'Tất cả',
                                      "Mã Đơn Hàng",
                                      "Tên Khách Hàng",
                                      "Tên Nhân Viên",
                                    ],
                                    onTypeChanged: (value) {
                                      setState(() {
                                        searchType = value;
                                        isTextFieldEnabled = searchType != 'Tất cả';

                                        if (searchType == "Tất cả" &&
                                            searchController.text.isNotEmpty) {
                                          searchController.clear();
                                          currentPage = 1;
                                          _fetchData();
                                        }
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 10,
                                    ),
                                    child: ValueListenableBuilder(
                                      valueListenable: _selectedInventoryIdsNotifier,
                                      builder: (context, selectedInventoryId, _) {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            //outbound
                                            AnimatedButton(
                                              onPressed: () async {
                                                if (!context.mounted) return;

                                                if (selectedInventoryId.isNotEmpty) {
                                                  try {
                                                    final data = await futureInventory;
                                                    final inventoryList =
                                                        data['inventories'] as List<InventoryModel>;
                                                    final selectedModels =
                                                        inventoryList
                                                            .where(
                                                              (i) => selectedInventoryId.contains(
                                                                i.inventoryId,
                                                              ),
                                                            )
                                                            .toList();
                                                    initialItems =
                                                        selectedModels
                                                            .map(
                                                              (i) =>
                                                                  OutboundTempItemModel.fromInventoryModel(
                                                                    i,
                                                                  ),
                                                            )
                                                            .toList();
                                                  } catch (e) {
                                                    if (!context.mounted) return;
                                                    showSnackBarError(
                                                      context,
                                                      "Lấy dữ liệu xuất kho thất bại",
                                                    );
                                                    return;
                                                  }
                                                }

                                                if (!context.mounted) return;
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
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

                                            //transfer qty to other order
                                            AnimatedButton(
                                              onPressed:
                                                  selectedInventoryId.length == 1
                                                      ? () async {
                                                        final inventory = await futureInventory;
                                                        final selectedInv = inventory['inventories']
                                                            .firstWhere(
                                                              (i) =>
                                                                  i.inventoryId ==
                                                                  selectedInventoryId.first,
                                                            );

                                                        if (context.mounted) {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (_) => DialogTransferQty(
                                                                  inventory: selectedInv,
                                                                  onLoad: () => loadInventory(),
                                                                ),
                                                          );
                                                        }
                                                      }
                                                      : null,
                                              label: "Chuyển SL",
                                              icon: Symbols.input,
                                              backgroundColor: themeController.buttonColor,
                                            ),
                                            const SizedBox(width: 10),

                                            //filter
                                            buildDropdownItems(
                                              width: 140,
                                              value: filterType,
                                              items: const ['gtZero', 'ltZero'],
                                              onChanged:
                                                  (value) => {
                                                    setState(() {
                                                      filterType = value!;
                                                      selectedInventoryId.clear();
                                                      loadInventory();
                                                    }),
                                                  },
                                              itemLabelBuilder:
                                                  (value) => filterOptions[value] ?? value,
                                            ),
                                            const SizedBox(width: 10),

                                            //popup menu
                                            PopupMenuButton<String>(
                                              icon: const Icon(
                                                Icons.more_vert,
                                                color: Colors.black,
                                              ),
                                              color: Colors.white,
                                              onSelected: (value) async {
                                                if (value == 'liquidation') {
                                                  await showInputQtyDialog(
                                                    context: context,
                                                    title: "Thanh Lý Tồn Kho",
                                                    onConfirm: (inputQty, inputReason) async {
                                                      try {
                                                        final success = await WarehouseService()
                                                            .transferQtyToOrderOrQilidation(
                                                              action: 'TRANSFER_TO_LIQUIDATION',
                                                              inventoryId:
                                                                  selectedInventoryId.first,
                                                              qtyTransfer: inputQty,
                                                              reason: inputReason,
                                                            );

                                                        if (success) {
                                                          if (context.mounted) {
                                                            showSnackBarSuccess(
                                                              context,
                                                              "Xác nhận thanh lý tồn kho thành công",
                                                            );
                                                          }

                                                          if (context.mounted) {
                                                            // Show loading
                                                            showLoadingDialog(context);
                                                            await Future.delayed(
                                                              const Duration(seconds: 1),
                                                            );

                                                            if (!context.mounted) return false;
                                                            Navigator.pop(context); // Hide loading
                                                          }

                                                          loadInventory();
                                                          return true;
                                                        }
                                                        return false;
                                                      } on ApiException catch (e) {
                                                        final errorText = switch (e.errorCode) {
                                                          "INSUFFICIENT_QUANTITY" =>
                                                            'Không đủ số lượng trong tồn kho để chuyển giao',
                                                          _ => 'Có lỗi xảy ra, vui lòng thử lại',
                                                        };

                                                        if (!context.mounted) return false;

                                                        showSnackBarError(context, errorText);
                                                        return false;
                                                      } catch (e) {
                                                        if (context.mounted) {
                                                          showSnackBarError(
                                                            context,
                                                            "Thanh lý tồn kho thất bại",
                                                          );
                                                        }
                                                        return false;
                                                      }
                                                    },
                                                  );
                                                } else if (value == 'export') {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => DialogExportInventory(),
                                                  );
                                                }
                                              },
                                              itemBuilder:
                                                  (BuildContext context) => [
                                                    const PopupMenuItem<String>(
                                                      value: 'liquidation',
                                                      child: ListTile(
                                                        leading: Icon(Symbols.output),
                                                        title: Text('Thanh Lý Tồn'),
                                                      ),
                                                    ),
                                                    const PopupMenuItem<String>(
                                                      value: 'export',
                                                      child: ListTile(
                                                        leading: Icon(Symbols.download),
                                                        title: Text('Xuất Excel'),
                                                      ),
                                                    ),
                                                  ],
                                            ),
                                            const SizedBox(width: 10),
                                          ],
                                        );
                                      },
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
                              double.tryParse(data['totalValueInventory']?.toString() ?? '0') ??
                              0.0;

                          if (_cachedInventory == null || _cachedInventory != inventory) {
                            _cachedInventory = inventory;
                            _cachedDatasource = InventoryDataSource(
                              inventory: inventory,
                              selectedInventoryId: _selectedInventoryIdsNotifier.value,
                              currentPage: currentPage,
                              pageSize: pageSize,
                            );
                          }

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
                                      "${OrderModel.formatCurrency(totalValueInventory)} VNĐ",
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
                                child: StatefulBuilder(
                                  builder: (context, localSetState) {
                                    return SfDataGridTheme(
                                      data: SfDataGridThemeData(
                                        selectionColor: Colors.blue.withValues(alpha: 0.3),
                                        currentCellStyle: const DataGridCurrentCellStyle(
                                          borderColor: Colors.transparent,
                                          borderWidth: 0,
                                        ),
                                      ),
                                      child: SfDataGrid(
                                        controller: dataGridController,
                                        source: _cachedDatasource!,
                                        isScrollbarAlwaysShown: true,
                                        allowExpandCollapseGroup: true, // Bật grouping
                                        autoExpandGroups: true,
                                        columnWidthMode: ColumnWidthMode.auto,
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
                                                columnNames: [
                                                  'quantityOrd',
                                                  'runningPlanProd',
                                                  'qtyProduced',
                                                ],
                                                child: Obx(
                                                  () => formatColumn(
                                                    label: 'Số Lượng',
                                                    themeController: themeController,
                                                  ),
                                                ),
                                              ),
                                              StackedHeaderCell(
                                                columnNames: [
                                                  "totalQtyInbound",
                                                  "totalQtyOutbound",
                                                  "qtyTransfer",
                                                  "qtyInventory",
                                                ],
                                                child: Obx(
                                                  () => formatColumn(
                                                    label: 'Số Lượng',
                                                    themeController: themeController,
                                                  ),
                                                ),
                                              ),
                                              StackedHeaderCell(
                                                columnNames: ["totalPrice", "totalPriceVAT"],
                                                child: Obx(
                                                  () => formatColumn(
                                                    label: 'Tổng Tiền',
                                                    themeController: themeController,
                                                  ),
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
                                              setState: localSetState,
                                            ),
                                        onColumnResizeEnd:
                                            (details) => GridResizeHelper.onResizeEnd(
                                              details: details,
                                              tableKey: 'inventory',
                                              columnWidths: columnWidths,
                                              setState: setState,
                                            ),

                                        onSelectionChanging: (addedRows, removedRows) {
                                          if (_isSelectionChange) return true;

                                          final keys = HardwareKeyboard.instance.logicalKeysPressed;
                                          final isShiftPressed =
                                              keys.contains(LogicalKeyboardKey.shiftLeft) ||
                                              keys.contains(LogicalKeyboardKey.shiftRight);

                                          // Nếu đè phím Shift và trước đó đã có dòng được chọn
                                          if (isShiftPressed &&
                                              dataGridController.selectedRows.isNotEmpty &&
                                              addedRows.isNotEmpty) {
                                            final lastSelected =
                                                dataGridController.selectedRows.last;
                                            final newlyClicked = addedRows.last;

                                            // Lấy tất cả các dòng dữ liệu trong datasource (không bao gồm caption row)
                                            final allRows = _cachedDatasource!.rows;
                                            final startIdx = allRows.indexOf(lastSelected);
                                            final endIdx = allRows.indexOf(newlyClicked);

                                            if (startIdx != -1 && endIdx != -1) {
                                              final min = startIdx < endIdx ? startIdx : endIdx;
                                              final max = startIdx > endIdx ? startIdx : endIdx;

                                              // Tự gom tất cả các dòng dữ liệu nằm giữa khoảng click
                                              final List<DataGridRow> rangeSelection = [];
                                              for (int i = min; i <= max; i++) {
                                                rangeSelection.add(allRows[i]);
                                              }

                                              // Ép controller chọn dải dòng
                                              _isSelectionChange = true;
                                              dataGridController.selectedRows = List.from(
                                                rangeSelection,
                                              );
                                              _isSelectionChange = false;

                                              // Cập nhật ID đơn hàng
                                              Future.microtask(() {
                                                _isSelectionChange = true;
                                                dataGridController.selectedRows = List.from(
                                                  rangeSelection,
                                                );
                                                _isSelectionChange = false;

                                                _updateSelectedIdsFromRows(rangeSelection);
                                              });
                                              return false;
                                            }
                                          }
                                          return true;
                                        },

                                        onSelectionChanged: (addedRows, removedRows) {
                                          if (addedRows.isEmpty && removedRows.isEmpty) return;

                                          // bắt sự kiện từ bàn phím
                                          final keys = HardwareKeyboard.instance.logicalKeysPressed;
                                          final isCtrlPressed =
                                              keys.contains(LogicalKeyboardKey.controlLeft) ||
                                              keys.contains(LogicalKeyboardKey.controlRight);
                                          final isShiftPressed =
                                              keys.contains(LogicalKeyboardKey.shiftLeft) ||
                                              keys.contains(LogicalKeyboardKey.shiftRight);

                                          if (!isCtrlPressed && !isShiftPressed) {
                                            if (addedRows.isNotEmpty) {
                                              // Nếu click vào một dòng mới thì Xóa hết các dòng cũ, chỉ chọn duy nhất dòng này
                                              final latestRow = addedRows.last;

                                              _isSelectionChange = true;
                                              dataGridController.selectedRows = [latestRow];

                                              _isSelectionChange = false;
                                            } else if (removedRows.isNotEmpty &&
                                                dataGridController.selectedRows.isNotEmpty) {
                                              //ép chọn lại dòng vừa click vào nếu xóa hết các dòng cũ
                                              final clickedRow = removedRows.first;
                                              _isSelectionChange = true;
                                              dataGridController.selectedRows = [clickedRow];
                                              _isSelectionChange = false;
                                            }
                                          }

                                          _updateSelectedIdsFromRows(
                                            dataGridController.selectedRows,
                                          );
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
            ),

            //slider zoom
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, _) {
                return SliderZoom(
                  zoomLevel: zoom,
                  onZoomChanged: _updateZoom,
                  initialMargin: Offset(73, 125),
                  buttonColor: themeController.buttonColor.value,
                );
              },
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

  Future<bool?> showInputQtyDialog({
    required BuildContext context,
    required String title,
    required Future<bool> Function(int qty, String reason) onConfirm,
  }) async {
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              content: SizedBox(
                width: 350,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: "Số lượng thanh lý",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Không được để trống";
                          final n = int.tryParse(value);
                          if (n == null || n <= 0) return "Số lượng phải lớn hơn 0";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: reasonController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Lý do thanh lý",
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.edit_note),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Vui lòng nhập lý do";
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Hủy",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffEA4346),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            if (formKey.currentState!.validate()) {
                              setState(() => isLoading = true);

                              // Truyền cả 2 giá trị vào onConfirm
                              final success = await onConfirm(
                                int.parse(qtyController.text),
                                reasonController.text,
                              );

                              if (context.mounted) {
                                if (success) {
                                  Navigator.pop(context, true);
                                } else {
                                  setState(() => isLoading = false);
                                }
                              }
                            }
                          },
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                          : const Text(
                            'Xác nhận',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
