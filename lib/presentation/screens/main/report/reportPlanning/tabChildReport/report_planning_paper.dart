import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/models/report/report_paper_model.dart';
import 'package:dongtam/presentation/components/dialog/export/dialog_export_excel_report.dart';
import 'package:dongtam/presentation/components/headerTable/report/header_table_report_paper.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/report/report_paper_data_source.dart';
import 'package:dongtam/service/report_planning_service.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportPlanningPaper extends StatefulWidget {
  const ReportPlanningPaper({super.key});

  @override
  State<ReportPlanningPaper> createState() => _ReportPlanningPaperState();
}

class _ReportPlanningPaperState extends State<ReportPlanningPaper> {
  late Future<Map<String, dynamic>> futureReportPaper;
  late List<GridColumn> columns;

  //controller
  final themeController = Get.find<ThemeController>();

  String searchType = "Tất cả";
  String machine = "Máy 1350";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
    "Ngày Báo Cáo": "dayReported",
    "Trưởng Máy": "shiftManagement",
  };

  Map<String, double> columnWidths = {}; //map header table
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedReportIdNotifier = ValueNotifier<int?>(null);

  //datasource and cache
  List<ReportPaperModel>? _cachedReportPapers;
  ReportPaperDatasource? _cachedDatasource;

  //text controller
  TextEditingController dateController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  //flag
  bool isTextFieldEnabled = false;
  bool isSearching = false;

  //date range
  DateTime? startDate;
  DateTime? endDate;

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  @override
  void initState() {
    super.initState();
    loadReportPaper();

    columns = buildReportPaperColumn(themeController: themeController);
    ColumnWidthTable.loadWidths(tableKey: 'reportPaper', columns: columns).then((w) {
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
    final bool isDateSearch = searchType == "Ngày Báo Cáo";

    futureReportPaper = ensureMinLoading(
      ReportPlanningService().getReportPapers(
        page: currentPage,
        pageSize: pageSize,
        machine: machine,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? keyword : null,
        startDate: (shouldSearch && isDateSearch) ? startDate : null,
        endDate: (shouldSearch && isDateSearch) ? endDate : null,
      ),
    );

    _selectedReportIdNotifier.value = null;
  }

  void loadReportPaper() {
    setState(() => _fetchData());
  }

  void searchReportPaper() {
    String keyword = searchController.text.trim().toLowerCase();
    final bool isDateSearch = searchType == "Ngày Báo Cáo";

    if (isDateSearch) {
      if (startDate == null || endDate == null) {
        AppLogger.w("searchOrders => chưa chọn khoảng thời gian");
        return;
      }
    } else if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchReportPaper => searchType=$searchType nhưng keyword rỗng");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");
      _fetchData();
    });
  }

  void changeMachine(String selectedMachine) {
    AppLogger.i("changeMachine | from=$machine -> to=$selectedMachine");
    setState(() {
      machine = selectedMachine;
      _selectedReportIdNotifier.value = null;
      loadReportPaper();
    });
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    dateController.dispose();
    _zoomNotifier.dispose();
    _selectedReportIdNotifier.dispose();
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
                              child: Obx(
                                () => Text(
                                  "LỊCH SỬ BÁO CÁO GIẤY TẤM",
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
                                Expanded(
                                  flex: 1,
                                  child: LeftButtonSearch(
                                    selectedType: searchType,
                                    types: const [
                                      'Tất cả',
                                      "Mã Đơn Hàng",
                                      "Tên Khách Hàng",
                                      "Ngày Báo Cáo",
                                      "Trưởng Máy",
                                    ],
                                    onTypeChanged: (value) {
                                      setState(() {
                                        searchType = value;
                                        isTextFieldEnabled = value != 'Tất cả';

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
                                    onSearch: () => searchReportPaper(),
                                    customInputBuilder: (inputWidth) {
                                      if (searchType != 'Ngày Báo Cáo') return null;

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
                                                'dd/MM/yyyy',
                                              ).format(picked.start);
                                              final displayEnd = DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(picked.end);

                                              setState(() {
                                                startDate = picked.start;
                                                endDate = picked.end;
                                                searchController.text =
                                                    '$displayStart - $displayEnd';
                                              });
                                            }
                                          },
                                          child: IgnorePointer(
                                            child: TextField(
                                              controller: searchController,
                                              decoration: InputDecoration(
                                                hintText: 'Chọn ngày...',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                suffixIcon: const Icon(Icons.calendar_today),
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
                                      valueListenable: _selectedReportIdNotifier,
                                      builder: (context, selectedReportId, _) {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            //export excel
                                            AnimatedButton(
                                              onPressed: () async {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (_) => DialogSelectExportExcel(
                                                        onPlanningIdsOrRangeDate:
                                                            () => loadReportPaper(),
                                                        machine: machine,
                                                      ),
                                                );
                                              },
                                              label: "Xuất Excel",
                                              icon: Symbols.export_notes,
                                              backgroundColor: themeController.buttonColor,
                                            ),
                                            const SizedBox(width: 10),

                                            //choose machine
                                            buildDropdownItems(
                                              value: machine,
                                              items: const [
                                                'Máy 1350',
                                                "Máy 1900",
                                                "Máy 2 Lớp",
                                                "Máy Quấn Cuồn",
                                              ],
                                              onChanged: (value) {
                                                if (value != null) {
                                                  changeMachine(value);
                                                }
                                              },
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
                        future: futureReportPaper,
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
                          } else if (!snapshot.hasData || snapshot.data!['reportPapers'].isEmpty) {
                            return const Center(
                              child: Text(
                                "Không có báo cáo nào",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            );
                          }

                          final data = snapshot.data!;
                          final reportPapers = data['reportPapers'] as List<ReportPaperModel>;
                          final currentPg = data['currentPage'];
                          final totalPgs = data['totalPages'];
                          final summaryByDate = data['summaryByDate'] as Map<String, dynamic>;

                          if (_cachedReportPapers != reportPapers || _cachedDatasource == null) {
                            _cachedReportPapers = reportPapers;
                            _cachedDatasource = ReportPaperDatasource(
                              reportPapers: reportPapers,
                              selectedReportId: _selectedReportIdNotifier.value,
                              currentPage: currentPage,
                              pageSize: pageSize,
                              summaryByDate: summaryByDate,
                            );
                          }

                          // reportPaperDatasource.notifyListeners();

                          return Column(
                            children: [
                              //table
                              Expanded(
                                child: StatefulBuilder(
                                  builder: (context, localSetState) {
                                    return SfDataGridTheme(
                                      data: SfDataGridThemeData(
                                        selectionColor: Colors.blue.withValues(alpha: 0.3),
                                      ),
                                      child: SfDataGrid(
                                        source: _cachedDatasource!,
                                        isScrollbarAlwaysShown: true,
                                        allowExpandCollapseGroup: true, // Bật grouping
                                        autoExpandGroups: true,
                                        columnWidthMode: ColumnWidthMode.auto,
                                        selectionMode: SelectionMode.single,
                                        headerRowHeight: 35,
                                        rowHeight: 40,
                                        columns: ColumnWidthTable.applySavedWidths(
                                          columns: columns,
                                          widths: columnWidths,
                                        ),
                                        frozenColumnsCount: 7,
                                        stackedHeaderRows: <StackedHeaderRow>[
                                          StackedHeaderRow(
                                            cells: [
                                              StackedHeaderCell(
                                                columnNames: [
                                                  'quantityOrd',
                                                  'runningPlanProd',
                                                  'qtyReported',
                                                  "lackOfQty",
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
                                                  'bottom',
                                                  'fluteE',
                                                  'fluteB',
                                                  'fluteC',
                                                  'knife',
                                                  'totalLoss',
                                                ],
                                                child: Obx(
                                                  () => formatColumn(
                                                    label: 'Định Mức Phế Liệu (Kg)',
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
                                              tableKey: 'reportPaper',
                                              columnWidths: columnWidths,
                                              setState: setState,
                                            ),

                                        onSelectionChanged: (addedRows, removedRows) {
                                          if (addedRows.isNotEmpty) {
                                            final selectedRow = addedRows.first;
                                            final selectedReportId =
                                                selectedRow
                                                        .getCells()
                                                        .firstWhere(
                                                          (cell) =>
                                                              cell.columnName == 'reportPaperId',
                                                        )
                                                        .value
                                                    as int?;

                                            _selectedReportIdNotifier.value = selectedReportId;
                                          } else {
                                            _selectedReportIdNotifier.value = null;
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
                                    loadReportPaper();
                                  });
                                },
                                onNext: () {
                                  setState(() {
                                    currentPage++;
                                    loadReportPaper();
                                  });
                                },
                                onJumpToPage: (page) {
                                  setState(() {
                                    currentPage = page;
                                    loadReportPaper();
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
                  initialMargin: Offset(73, 173),
                  buttonColor: themeController.buttonColor.value,
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => loadReportPaper(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
