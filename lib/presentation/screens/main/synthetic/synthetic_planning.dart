import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/presentation/components/dialog/export/dialog_export_db_planning.dart';
import 'package:dongtam/presentation/components/headerTable/synthetic/header_table_db_planning.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_stages.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/synthetic/synthetic_planning_data_source.dart';
import 'package:dongtam/presentation/sources/planning/stages_data_source.dart';
import 'package:dongtam/service/synthetic_service.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SyntheticPlanning extends StatefulWidget {
  const SyntheticPlanning({super.key});

  @override
  State<SyntheticPlanning> createState() => _SyntheticPlanningState();
}

class _SyntheticPlanningState extends State<SyntheticPlanning> {
  late Future<Map<String, dynamic>> futureDbPaper;
  late List<GridColumn> columnsPaper;
  late List<GridColumn> columnsStages;

  //controllers
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Theo Mã Đơn": "orderId",
    "Ghép Khổ": "ghepKho",
    "Theo Máy": "machine",
    "Tên Khách Hàng": "customerName",
    "Tên Công Ty": "companyName",
  };

  String status = "Hoàn Thành";
  final Map<String, String> statusFieldMap = {
    "Hoàn Thành": "complete",
    "Đã Sắp Xếp": "planning",
    "Thiếu Số Lượng": "lackQty",
    "Bị Dừng": "stop",
    "Bị Hủy": "cancel",
  };

  Map<String, double> columnWidthsPlanning = {};
  Map<String, double> columnWidthsStage = {};

  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedDbPaperIdNotifier = ValueNotifier<int?>(null);
  // int? selectedDbPaperId;

  //datasource and cache
  DashboardPaperDataSource? _cachedDatasource;
  List<PlanningPaperModel>? _cachedPapers;
  List<PlanningStageModel> selectedStages = [];

  //flag
  bool selectedAll = false;
  bool isSearching = false;
  bool isTextFieldEnabled = false;
  bool _isSelectionChange = false;

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  //text controller
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDashboard();

    columnsPaper = buildDbPaperColumn(themeController: themeController, page: "dashboard");
    columnsStages = buildStageColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'dashboard', columns: columnsPaper).then((w) {
      setState(() {
        columnWidthsPlanning = w;
      });
    });

    ColumnWidthTable.loadWidths(tableKey: 'stage', columns: columnsStages).then((w) {
      setState(() {
        columnWidthsStage = w;
      });
    });
  }

  void loadDashboard() {
    setState(() {
      final String selectedField = searchFieldMap[searchType] ?? "";
      final String selectedStatus = statusFieldMap[status] ?? "";

      String keyword = searchController.text.trim().toLowerCase();

      if (isSearching && searchType != "Tất cả") {
        AppLogger.i("loadDbPaper: isSearching=true, keyword='$keyword'");

        futureDbPaper = ensureMinLoading(
          SyntheticService().getSyntheticPlanningByFields(
            field: selectedField,
            keyword: keyword,
            page: currentPage,
            pageSize: pageSizeSearch,
          ),
        );
      } else {
        futureDbPaper = ensureMinLoading(
          SyntheticService().getAllSyntheticPlanning(
            page: currentPage,
            pageSize: pageSize,
            status: selectedStatus,
          ),
        );
      }

      selectedStages = [];
      _selectedDbPaperIdNotifier.value = null;
      dataGridController.selectedRows = [];
    });
  }

  void searchDashboard() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchDbPaper: searchType=$searchType, keyword='$keyword'");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchDbPaper: search bị bỏ qua vì keyword trống");
      return;
    }

    setState(() {
      final String selectedStatus = statusFieldMap[status] ?? "";

      currentPage = 1;
      isSearching = (searchType != "Tất cả");

      if (searchType == "Tất cả") {
        futureDbPaper = ensureMinLoading(
          SyntheticService().getAllSyntheticPlanning(
            page: currentPage,
            pageSize: pageSize,
            status: selectedStatus,
          ),
        );
      } else {
        final selectedField = searchFieldMap[searchType] ?? "";

        futureDbPaper = ensureMinLoading(
          SyntheticService().getSyntheticPlanningByFields(
            field: selectedField,
            keyword: keyword,
            page: currentPage,
            pageSize: pageSizeSearch,
          ),
        );
      }

      _selectedDbPaperIdNotifier.value = null;
      selectedStages = [];
    });
  }

  void changeStatus(String selectedStatus) {
    AppLogger.i("changeStatusDbPaper | from=$status -> to=$selectedStatus");

    setState(() {
      status = selectedStatus;
      selectedStages.clear();
      loadDashboard();
    });
  }

  void _updateSelectedIdsFromRows(List<DataGridRow> rows) async {
    final planningId =
        rows.first.getCells().firstWhere((cell) => cell.columnName == 'planningId').value;

    setState(() {
      _selectedDbPaperIdNotifier.value = planningId;
      selectedStages = [];
    });

    if (planningId != null) {
      final stages = await SyntheticService().getSyntheticPlanningDetail(planningId: planningId);
      setState(() {
        selectedStages = stages;
      });
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
    _selectedDbPaperIdNotifier.dispose();
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
                                "TỔNG HỢP SẢN XUẤT",
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
                                      "Theo Mã Đơn",
                                      "Ghép Khổ",
                                      "Theo Máy",
                                      "Tên Khách Hàng",
                                      "Tên Công Ty",
                                      "Tên Nhân Viên",
                                    ],
                                    onTypeChanged: (value) {
                                      setState(() {
                                        searchType = value;
                                        isTextFieldEnabled = value != 'Tất cả';

                                        if (searchType == "Tất cả" &&
                                            searchController.text.isNotEmpty) {
                                          searchController.clear();
                                          currentPage = 1;
                                          loadDashboard();
                                        }
                                      });
                                    },
                                    controller: searchController,
                                    textFieldEnabled: isTextFieldEnabled,
                                    buttonColor: themeController.buttonColor,
                                    onSearch: () => searchDashboard(),
                                    minDropdownWidth: 170,
                                    maxDropdownWidth: 200,
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
                                      valueListenable: _selectedDbPaperIdNotifier,
                                      builder: (context, selectedPlanningIds, _) {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            //export excel
                                            AnimatedButton(
                                              onPressed: () async {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => DialogExportDbPlannings(),
                                                );
                                              },
                                              label: "Xuất Excel",
                                              icon: Symbols.export_notes,
                                              backgroundColor: themeController.buttonColor,
                                            ),
                                            const SizedBox(width: 10),

                                            //choose machine
                                            SizedBox(
                                              width: 180,
                                              child: DropdownButtonFormField<String>(
                                                initialValue: status,
                                                items:
                                                    [
                                                      "Hoàn Thành",
                                                      "Đã Sắp Xếp",
                                                      "Thiếu Số Lượng",
                                                      "Bị Dừng",
                                                      "Bị Hủy",
                                                    ].map((String value) {
                                                      return DropdownMenuItem<String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    changeStatus(value);
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: const BorderSide(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                                ),
                                              ),
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
                        future: futureDbPaper,
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
                          } else if (!snapshot.hasData || snapshot.data!['dashboard'].isEmpty) {
                            return const Center(
                              child: Text(
                                "Không có đơn hàng nào",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            );
                          }

                          final data = snapshot.data!;
                          final dbPlanning = data['dashboard'] as List<PlanningPaperModel>;
                          final currentPg = data['currentPage'];
                          final totalPgs = data['totalPages'];

                          if (_cachedPapers == null || _cachedPapers != dbPlanning) {
                            _cachedPapers = dbPlanning;
                            _cachedDatasource = DashboardPaperDataSource(
                              dbPlanning: dbPlanning,
                              selectedDbPaperId: _selectedDbPaperIdNotifier.value,
                              page: "dashboard",
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
                                              rowHeight: 38,
                                              columns: ColumnWidthTable.applySavedWidths(
                                                columns: columnsPaper,
                                                widths: columnWidthsPlanning,
                                              ),
                                              stackedHeaderRows: <StackedHeaderRow>[
                                                StackedHeaderRow(
                                                  cells: [
                                                    StackedHeaderCell(
                                                      columnNames: [
                                                        "dayReceive",
                                                        "dateShipping",
                                                        "dayStartProduction",
                                                        "dayCompletedProd",
                                                        "dayCompletedOvfl",
                                                      ],
                                                      child: Obx(
                                                        () => formatColumn(
                                                          label: 'Ngày',
                                                          themeController: themeController,
                                                        ),
                                                      ),
                                                    ),
                                                    StackedHeaderCell(
                                                      columnNames: [
                                                        'quantityOrd',
                                                        'qtyProduced',
                                                        'runningPlanProd',
                                                        "totalOutbound",
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
                                                      columnNames: [
                                                        'timeRunningProd',
                                                        'timeRunningOvfl',
                                                      ],
                                                      child: Obx(
                                                        () => formatColumn(
                                                          label: 'Thời Gian',
                                                          themeController: themeController,
                                                        ),
                                                      ),
                                                    ),
                                                    StackedHeaderCell(
                                                      columnNames: [
                                                        'bottom',
                                                        'fluteE',
                                                        'fluteE2',
                                                        'fluteB',
                                                        'fluteC',
                                                        'knife',
                                                        'totalLoss',
                                                      ],
                                                      child: Obx(
                                                        () => formatColumn(
                                                          label: 'Định Mức Phế Liệu',
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
                                                    columns: columnsPaper,
                                                    setState: localSetState,
                                                  ),
                                              onColumnResizeEnd:
                                                  (details) => GridResizeHelper.onResizeEnd(
                                                    details: details,
                                                    tableKey: 'dashboard',
                                                    columnWidths: columnWidthsPlanning,
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

                                          selectedStages.isNotEmpty
                                              ? Expanded(
                                                flex: 1,
                                                child: AnimatedSize(
                                                  duration: const Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                  child: SfDataGrid(
                                                    source: StagesDataSource(
                                                      stages: selectedStages,
                                                    ),
                                                    isScrollbarAlwaysShown: true,
                                                    headerRowHeight: 30,
                                                    rowHeight: 35,
                                                    columnWidthMode: ColumnWidthMode.fill,
                                                    selectionMode: SelectionMode.single,
                                                    columns: ColumnWidthTable.applySavedWidths(
                                                      columns: columnsStages,
                                                      widths: columnWidthsStage,
                                                    ),
                                                    stackedHeaderRows: <StackedHeaderRow>[
                                                      StackedHeaderRow(
                                                        cells: [
                                                          StackedHeaderCell(
                                                            columnNames: [
                                                              "dayStart",
                                                              "dayCompleted",
                                                              "dayCompletedOvfl",
                                                            ],
                                                            child: Obx(
                                                              () => formatColumn(
                                                                label: 'Ngày',
                                                                themeController: themeController,
                                                              ),
                                                            ),
                                                          ),
                                                          StackedHeaderCell(
                                                            columnNames: [
                                                              "timeRunning",
                                                              "timeRunningOvfl",
                                                            ],
                                                            child: Obx(
                                                              () => formatColumn(
                                                                label: 'Thời Gian',
                                                                themeController: themeController,
                                                              ),
                                                            ),
                                                          ),
                                                          StackedHeaderCell(
                                                            columnNames: [
                                                              "runningPlan",
                                                              "qtyProduced",
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
                                                              "wasteBox",
                                                              "rpWasteLoss",
                                                            ],
                                                            child: Obx(
                                                              () => formatColumn(
                                                                label: 'Phế Liệu',
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

                                                    onColumnResizeStart:
                                                        GridResizeHelper.onResizeStart,
                                                    onColumnResizeUpdate:
                                                        (details) =>
                                                            GridResizeHelper.onResizeUpdate(
                                                              details: details,
                                                              columns: columnsStages,
                                                              setState: setState,
                                                            ),
                                                    onColumnResizeEnd:
                                                        (details) => GridResizeHelper.onResizeEnd(
                                                          details: details,
                                                          tableKey: 'stage',
                                                          columnWidths: columnWidthsStage,
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
                                    loadDashboard();
                                  });
                                },
                                onNext: () {
                                  setState(() {
                                    currentPage++;
                                    loadDashboard();
                                  });
                                },
                                onJumpToPage: (page) {
                                  setState(() {
                                    currentPage = page;
                                    loadDashboard();
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
        onPressed: () => loadDashboard(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
