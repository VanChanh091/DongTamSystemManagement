import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/planning/planning_box_model.dart";
import "package:dongtam/presentation/components/dialog/export/dialog_export_orders.dart";
import "package:dongtam/presentation/components/headerTable/synthetic/orders/header_synthetic_order_detail.dart";
import "package:dongtam/presentation/components/headerTable/synthetic/orders/header_synthetic_orders.dart";
import "package:dongtam/presentation/components/shared/animation/animated_button.dart";
import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/presentation/components/shared/left_button_search.dart";
import "package:dongtam/presentation/components/shared/pagination_controls.dart";
import "package:dongtam/presentation/components/shared/planning/widgets_planning.dart";
import "package:dongtam/presentation/components/shared/slider_zoom.dart";
import "package:dongtam/presentation/sources/synthetic/order/synthetic_box_detail_data_source.dart";
import "package:dongtam/presentation/sources/synthetic/order/synthetic_orders_data_source.dart";
import "package:dongtam/service/synthetic_service.dart";
import "package:dongtam/utils/handleError/api_exception.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/helper/grid_resize_helper.dart";
import "package:dongtam/utils/helper/skeleton/skeleton_loading.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/storage/sharedPreferences/column_width_table.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:syncfusion_flutter_core/theme.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class SyntheticOrder extends StatefulWidget {
  const SyntheticOrder({super.key});

  @override
  State<SyntheticOrder> createState() => _SyntheticOrderState();
}

class _SyntheticOrderState extends State<SyntheticOrder> {
  late Future<Map<String, dynamic>> futureOrders;
  late List<GridColumn> columnsOrders;
  late List<GridColumn> columnsBoxes;

  //controllers
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  //width column
  Map<String, double> columnWidthOrders = {}; //map header table
  Map<String, double> columnWidthBoxes = {};

  //notifiers
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedOrderIdsNotifier = ValueNotifier<List<String>>([]);
  // List<String> selectedOrderIds = [];

  //datasource and cache
  List<OrderModel>? _cachedOrders;
  SyntheticOrdersDataSource? _cachedDatasource;
  List<PlanningBoxModel> selectedBoxesDetail = [];

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "orderId": "Mã Đơn Hàng",
    "customerName": "Tên Khách Hàng",
    "dayReceiveOrder": "Ngày Nhận Đơn",
    "fullName": "Nhân Viên",
  };

  //filter by status
  String filterType = "all";
  final Map<String, String> filterOptions = {
    "all": "Tất cả",
    "accept": "Chờ Lên Kế Hoạch",
    "planning": "Chưa Hoàn Thành",
    "completed": "Hoàn Thành",
  };

  //text controller
  TextEditingController searchController = TextEditingController();

  //date range
  DateTime? startDate;
  DateTime? endDate;

  //flag
  late bool isPlan;
  late bool isAccountant;
  bool isSearching = false;
  bool isTextFieldEnabled = false;
  bool _isSelectionChange = false;

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  @override
  void initState() {
    super.initState();
    loadOrders();

    isPlan = userController.hasPermission(permission: "plan");
    isAccountant = userController.hasPermission(permission: "accountant");

    columnsOrders = buildSyntheticOrderColumn(themeController: themeController);
    columnsBoxes = buildSyntheticBoxesColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: "syntheticOrders", columns: columnsOrders).then((w) {
      setState(() {
        columnWidthOrders = w;
      });
    });

    ColumnWidthTable.loadWidths(tableKey: "syntheticBoxes", columns: columnsBoxes).then((w) {
      setState(() {
        columnWidthBoxes = w;
      });
    });
  }

  void _fetchData() {
    final String keyword = searchController.text.trim().toLowerCase();
    final String selectedField =
        searchFieldMap.entries
            .firstWhere((e) => e.value == searchType, orElse: () => const MapEntry("", ""))
            .key;

    // Điều kiện để xác định có thực hiện search hay load mặc định
    final bool shouldSearch = (searchType != "Tất cả");
    final bool isDateSearch = searchType == "Ngày Nhận Đơn";

    futureOrders = ensureMinLoading(
      SyntheticService().getAllSyntheticOrders(
        page: currentPage,
        pageSize: pageSize,
        status: filterType,
        allOrders: filterType,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? keyword : null,
        startDate: (shouldSearch && isDateSearch) ? startDate : null,
        endDate: (shouldSearch && isDateSearch) ? endDate : null,
      ),
    );

    selectedBoxesDetail = [];
    _selectedOrderIdsNotifier.value = [];
    dataGridController.selectedRows = [];
  }

  void loadOrders() {
    setState(() => _fetchData());
  }

  void searchOrders() {
    final bool isDateSearch = searchType == "Ngày Nhận Đơn";
    final String keyword = searchController.text.trim().toLowerCase();

    if (isDateSearch) {
      if (startDate == null || endDate == null) {
        AppLogger.w("searchOrders => chưa chọn khoảng thời gian");
        return;
      }
    } else if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchOrders => searchType=$searchType nhưng keyword rỗng");
      return;
    }

    currentPage = 1;
    setState(() => _fetchData());
  }

  void _updateSelectedIdsFromRows(List<DataGridRow> rows) async {
    final List<String> currentSelectedIds =
        dataGridController.selectedRows.map((row) {
          return row.getCells().firstWhere((cell) => cell.columnName == 'orderId').value.toString();
        }).toList();

    // Cập nhật danh sách ID và tạm thời xóa chi tiết cũ
    setState(() {
      _selectedOrderIdsNotifier.value = currentSelectedIds;
      selectedBoxesDetail = [];
    });

    if (currentSelectedIds.length == 1) {
      try {
        final detail = await SyntheticService().getSyntheticBoxDetail(
          orderId: currentSelectedIds.first,
        );

        setState(() {
          if (detail != null) {
            selectedBoxesDetail = [detail];
          }
        });
      } catch (e) {
        AppLogger.e("Lỗi khi lấy chi tiết làm thùng: $e");
      }
    }
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    _zoomNotifier.dispose();
    _selectedOrderIdsNotifier.dispose();
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
                                "TỔNG HỢP ĐƠN HÀNG",
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
                                      "Tất cả",
                                      "Mã Đơn Hàng",
                                      "Tên Khách Hàng",
                                      "Ngày Nhận Đơn",
                                      "Nhân Viên",
                                    ],
                                    onTypeChanged: (value) {
                                      setState(() {
                                        searchType = value;
                                        isTextFieldEnabled = value != "Tất cả";

                                        startDate = null;
                                        endDate = null;

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
                                    onSearch: () => searchOrders(),
                                    customInputBuilder: (inputWidth) {
                                      if (searchType != "Ngày Nhận Đơn") return null;

                                      return SizedBox(
                                        width: inputWidth,
                                        height: 50,
                                        child: InkWell(
                                          onTap: () async {
                                            final now = DateTime.now();
                                            final size = MediaQuery.of(context).size;

                                            final DateTimeRange? picked = await showDateRangePicker(
                                              context: context,
                                              firstDate: DateTime(2025),
                                              lastDate: DateTime(2100),
                                              initialDateRange:
                                                  (startDate != null && endDate != null)
                                                      ? DateTimeRange(
                                                        start: startDate!,
                                                        end: endDate!,
                                                      )
                                                      : DateTimeRange(
                                                        start: now.subtract(
                                                          const Duration(days: 7),
                                                        ),
                                                        end: now,
                                                      ),
                                              builder: (context, child) {
                                                return Center(
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      maxWidth: size.width * 0.3,
                                                      maxHeight: size.height * 0.8,
                                                    ),
                                                    child: Material(
                                                      borderRadius: BorderRadius.circular(16),
                                                      clipBehavior: Clip.antiAlias,
                                                      child: child!,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );

                                            if (picked != null) {
                                              final displayStart = DateFormat(
                                                "dd/MM/yyyy",
                                              ).format(picked.start);
                                              final displayEnd = DateFormat(
                                                "dd/MM/yyyy",
                                              ).format(picked.end);

                                              setState(() {
                                                startDate = picked.start;
                                                endDate = picked.end;
                                                searchController.text =
                                                    "$displayStart - $displayEnd";
                                              });
                                            }
                                          },
                                          child: IgnorePointer(
                                            child: TextField(
                                              controller: searchController,
                                              decoration: InputDecoration(
                                                hintText: "Chọn khoảng thời gian...",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                suffixIcon: const Icon(Icons.date_range),
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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
                                      valueListenable: _selectedOrderIdsNotifier,
                                      builder: (context, selectedOrderIds, _) {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            //export excel
                                            isAccountant
                                                ? AnimatedButton(
                                                  onPressed: () async {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) => DialogExportOrders(),
                                                    );
                                                  },
                                                  label: "Xuất Excel",
                                                  icon: Symbols.export_notes,
                                                  backgroundColor: themeController.buttonColor,
                                                )
                                                : const SizedBox.shrink(),
                                            const SizedBox(width: 10),

                                            //complete order
                                            isPlan
                                                ? AnimatedButton(
                                                  onPressed:
                                                      selectedOrderIds.isEmpty
                                                          ? null
                                                          : () async {
                                                            try {
                                                              final bool
                                                              confirm = await showConfirmDialog(
                                                                context: context,
                                                                title:
                                                                    "Xác nhận hoàn thành đơn hàng",
                                                                content:
                                                                    "Bạn có chắc chắn muốn hoàn thành đơn hàng này?",
                                                                confirmText: "Xác nhận",
                                                              );

                                                              if (confirm) {
                                                                final success =
                                                                    await SyntheticService()
                                                                        .completeOrders(
                                                                          orderIds:
                                                                              selectedOrderIds,
                                                                        );

                                                                if (success) {
                                                                  if (context.mounted) {
                                                                    showSnackBarSuccess(
                                                                      context,
                                                                      "Đơn hàng đã được hoàn thành thành công.",
                                                                    );

                                                                    setState(() {
                                                                      selectedOrderIds.clear();
                                                                      loadOrders();
                                                                    });
                                                                  }
                                                                }
                                                                return true;
                                                              }
                                                              return false;
                                                            } on ApiException catch (e) {
                                                              final errorText = switch (e
                                                                  .errorCode) {
                                                                "EMPLOYEE_NOT_FOUND" => e.message!,
                                                                "INVALID_ORDER_STATUS" =>
                                                                  e.message!,
                                                                "ZERO_QTY_PRODUCED" => e.message!,
                                                                _ =>
                                                                  'Có lỗi xảy ra, vui lòng thử lại',
                                                              };

                                                              if (context.mounted) {
                                                                showSnackBarError(
                                                                  context,
                                                                  errorText,
                                                                );
                                                              }
                                                              return false;
                                                            } catch (e) {
                                                              if (context.mounted) {
                                                                showSnackBarError(
                                                                  context,
                                                                  "Hoàn thành đơn hàng thất bại",
                                                                );
                                                              }
                                                              return false;
                                                            }
                                                          },
                                                  label: "Hoàn Thành",
                                                  icon: Symbols.export_notes,
                                                  backgroundColor: themeController.buttonColor,
                                                )
                                                : const SizedBox.shrink(),
                                            const SizedBox(width: 10),

                                            //filter
                                            buildDropdownItems(
                                              value: filterType,
                                              items: const [
                                                "all",
                                                "accept",
                                                "planning",
                                                "completed",
                                              ],
                                              width: 180,
                                              onChanged:
                                                  (value) => {
                                                    setState(() {
                                                      filterType = value!;
                                                      selectedOrderIds.clear();
                                                      selectedBoxesDetail = [];
                                                      currentPage = 1;
                                                      loadOrders();
                                                    }),
                                                  },
                                              itemLabelBuilder:
                                                  (value) => filterOptions[value] ?? value,
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

                    // table
                    Expanded(
                      child: FutureBuilder(
                        future: futureOrders,
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
                          } else if (!snapshot.hasData || snapshot.data!["orders"].isEmpty) {
                            return const Center(
                              child: Text(
                                "Không có đơn hàng nào",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            );
                          }

                          final data = snapshot.data!;
                          final orders = data["orders"] as List<OrderModel>;
                          final currentPg = data["currentPage"];
                          final totalPgs = data["totalPages"];

                          if (_cachedOrders == null || _cachedOrders != orders) {
                            _cachedOrders = orders;
                            _cachedDatasource = SyntheticOrdersDataSource(
                              orders: orders,
                              selectedOrderIds: _selectedOrderIdsNotifier.value,
                              currentPage: currentPg,
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
                                      data: SfDataGridThemeData(
                                        selectionColor: Colors.blue.withValues(alpha: 0.3),
                                        currentCellStyle: const DataGridCurrentCellStyle(
                                          borderColor: Colors.transparent,
                                          borderWidth: 0,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: SfDataGrid(
                                              controller: dataGridController,
                                              source: _cachedDatasource!,
                                              isScrollbarAlwaysShown: true,
                                              columnWidthMode: ColumnWidthMode.auto,
                                              selectionMode: SelectionMode.multiple,
                                              headerRowHeight: 35,
                                              rowHeight: 40,
                                              columns: ColumnWidthTable.applySavedWidths(
                                                columns: columnsOrders,
                                                widths: columnWidthOrders,
                                              ),
                                              stackedHeaderRows: <StackedHeaderRow>[
                                                StackedHeaderRow(
                                                  cells: [
                                                    StackedHeaderCell(
                                                      columnNames: [
                                                        "sizeCust",
                                                        "lengthCust",
                                                        "sizeManu",
                                                        "lengthManu",
                                                      ],
                                                      child: Obx(
                                                        () => formatColumn(
                                                          label: "Quy Cách",
                                                          themeController: themeController,
                                                        ),
                                                      ),
                                                    ),
                                                    StackedHeaderCell(
                                                      columnNames: [
                                                        "quantityCustomer",
                                                        "qtyOutbound",
                                                        "qtyInventory",
                                                        "qtyVariance",
                                                        "qtyWasteNorm",
                                                      ],
                                                      child: Obx(
                                                        () => formatColumn(
                                                          label: "Số Lượng",
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
                                                    columns: columnsOrders,
                                                    setState: localSetState,
                                                  ),
                                              onColumnResizeEnd:
                                                  (details) => GridResizeHelper.onResizeEnd(
                                                    details: details,
                                                    tableKey: "syntheticOrders",
                                                    columnWidths: columnWidthOrders,
                                                    setState: setState,
                                                  ),

                                              onSelectionChanging: (addedRows, removedRows) {
                                                if (_isSelectionChange) return true;

                                                // Kiểm tra trạng thái bấm phím từ bàn phím
                                                final keys =
                                                    HardwareKeyboard.instance.logicalKeysPressed;
                                                final isShiftPressed =
                                                    keys.contains(LogicalKeyboardKey.shiftLeft) ||
                                                    keys.contains(LogicalKeyboardKey.shiftRight);
                                                final isCtrlPressed =
                                                    keys.contains(LogicalKeyboardKey.controlLeft) ||
                                                    keys.contains(LogicalKeyboardKey.controlRight);

                                                // TH 1: Click bình thường (Không nhấn Shift & Ctrl)
                                                if (!isShiftPressed && !isCtrlPressed) {
                                                  if (addedRows.isNotEmpty) {
                                                    final latestRow = addedRows.last;

                                                    _isSelectionChange = true;
                                                    dataGridController.selectedRows = [latestRow];
                                                    _isSelectionChange = false;

                                                    _updateSelectedIdsFromRows(
                                                      dataGridController.selectedRows,
                                                    );
                                                    return false;
                                                  } else if (removedRows.isNotEmpty &&
                                                      dataGridController.selectedRows.length > 1) {
                                                    // Nếu đang chọn nhiều dòng, click vào 1 dòng bất kỳ không giữ phím -> Reset về duy nhất dòng đó
                                                    final clickedRow = removedRows.first;

                                                    _isSelectionChange = true;
                                                    dataGridController.selectedRows = [clickedRow];
                                                    _isSelectionChange = false;

                                                    _updateSelectedIdsFromRows(
                                                      dataGridController.selectedRows,
                                                    );
                                                    return false;
                                                  }
                                                }

                                                // TH 2: Giữ phím Shift (Chọn một dải dòng liên tiếp)
                                                if (isShiftPressed &&
                                                    dataGridController.selectedRows.isNotEmpty &&
                                                    addedRows.isNotEmpty) {
                                                  final lastSelected =
                                                      dataGridController.selectedRows.last;
                                                  final newlyClicked = addedRows.last;

                                                  final allRows = _cachedDatasource!.rows;
                                                  final startIdx = allRows.indexOf(lastSelected);
                                                  final endIdx = allRows.indexOf(newlyClicked);

                                                  if (startIdx != -1 && endIdx != -1) {
                                                    final min =
                                                        startIdx < endIdx ? startIdx : endIdx;
                                                    final max =
                                                        startIdx > endIdx ? startIdx : endIdx;

                                                    final List<DataGridRow> rangeSelection = [];
                                                    for (int i = min; i <= max; i++) {
                                                      rangeSelection.add(allRows[i]);
                                                    }

                                                    _isSelectionChange = true;
                                                    dataGridController.selectedRows = List.from(
                                                      rangeSelection,
                                                    );
                                                    _isSelectionChange = false;

                                                    _updateSelectedIdsFromRows(rangeSelection);
                                                    return false;
                                                  }
                                                }

                                                // TH 3: Giữ phím Ctrl
                                                return true;
                                              },

                                              onSelectionChanged: (addedRows, removedRows) async {
                                                if (_isSelectionChange) return;
                                                _updateSelectedIdsFromRows(
                                                  dataGridController.selectedRows,
                                                );
                                              },
                                            ),
                                          ),

                                          selectedBoxesDetail.isNotEmpty
                                              ? Expanded(
                                                flex: 1,
                                                child: AnimatedSize(
                                                  duration: const Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                  child: SfDataGrid(
                                                    source: SyntheticBoxDetail(
                                                      boxes: selectedBoxesDetail,
                                                    ),
                                                    isScrollbarAlwaysShown: true,
                                                    headerRowHeight: 30,
                                                    rowHeight: 35,
                                                    columnWidthMode: ColumnWidthMode.fill,
                                                    selectionMode: SelectionMode.single,
                                                    columns: ColumnWidthTable.applySavedWidths(
                                                      columns: columnsBoxes,
                                                      widths: columnWidthBoxes,
                                                    ),

                                                    //auto resize
                                                    allowColumnsResizing: true,
                                                    columnResizeMode: ColumnResizeMode.onResize,

                                                    onColumnResizeStart:
                                                        GridResizeHelper.onResizeStart,
                                                    onColumnResizeUpdate:
                                                        (details) =>
                                                            GridResizeHelper.onResizeUpdate(
                                                              details: details,
                                                              columns: columnsBoxes,
                                                              setState: setState,
                                                            ),
                                                    onColumnResizeEnd:
                                                        (details) => GridResizeHelper.onResizeEnd(
                                                          details: details,
                                                          tableKey: "boxesDetail",
                                                          columnWidths: columnWidthBoxes,
                                                          setState: setState,
                                                        ),
                                                  ),
                                                ),
                                              )
                                              : const SizedBox.shrink(),
                                        ],
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
                                    loadOrders();
                                  });
                                },
                                onNext: () {
                                  setState(() {
                                    currentPage++;
                                    loadOrders();
                                  });
                                },
                                onJumpToPage: (page) {
                                  setState(() {
                                    currentPage = page;
                                    loadOrders();
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
        onPressed: () => loadOrders(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
