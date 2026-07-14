import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/models/qualityControl/qcInspection/qc_inspection_paper_model.dart";
import "package:dongtam/presentation/components/headerTable/report/header_table_inspection_paper.dart";
import "package:dongtam/presentation/components/shared/pagination_controls.dart";
import "package:dongtam/presentation/components/shared/planning/widgets_planning.dart";
import "package:dongtam/presentation/components/shared/slider_zoom.dart";
import "package:dongtam/presentation/sources/report/inspection_paper_data_source.dart";
import "package:dongtam/service/quality_control_service.dart";
import "package:dongtam/utils/helper/grid_resize_helper.dart";
import "package:dongtam/utils/helper/skeleton/skeleton_loading.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:dongtam/utils/storage/sharedPreferences/column_width_table.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:syncfusion_flutter_core/theme.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class ReportInspectionPaper extends StatefulWidget {
  const ReportInspectionPaper({super.key});

  @override
  State<ReportInspectionPaper> createState() => _ReportInspectionPaperState();
}

class _ReportInspectionPaperState extends State<ReportInspectionPaper> {
  late Future<Map<String, dynamic>> futureReportPaper;
  late List<GridColumn> columns;

  //controller
  final themeController = Get.find<ThemeController>();

  String machine = "Máy 1350";
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
    "Ngày Báo Cáo": "dayReported",
    "Trưởng Máy": "shiftManagement",
  };

  Map<String, double> columnWidths = {}; //map header table
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedPaperIdsNotifier = ValueNotifier<int?>(null);

  //datasource and cache
  List<QcInspectionPaperModel>? _cachedInspecPapers;
  InspectionPaperDataSource? _cachedDatasource;

  //text controller
  TextEditingController searchController = TextEditingController();
  TextEditingController dateController = TextEditingController();

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
    loadInspectionPaper();

    columns = buildInspectionPaperColumn(themeController: themeController);
    ColumnWidthTable.loadWidths(tableKey: "inspectionPaper", columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void _fetchData() {
    // final String keyword = searchController.text.trim().toLowerCase();
    // final String selectedField = searchFieldMap[searchType] ?? "";

    // Điều kiện để xác định có thực hiện search hay load mặc định
    // final bool shouldSearch = isSearching && searchType != "Tất cả";
    // final bool isDateSearch = searchType == "Ngày Báo Cáo";

    futureReportPaper = ensureMinLoading(
      QualityControlService().getQcInspection(
        isPaper: "paper",
        page: currentPage,
        pageSize: pageSize,
        machine: machine,
        fromJson: (json) => QcInspectionPaperModel.fromJson(json),
      ),
    );

    _selectedPaperIdsNotifier.value = null;
  }

  void loadInspectionPaper() {
    setState(() => _fetchData());
  }

  // void searchReportPaper() {
  //   String keyword = searchController.text.trim().toLowerCase();
  //   final bool isDateSearch = searchType == "Ngày Báo Cáo";

  //   if (isDateSearch) {
  //     if (startDate == null || endDate == null) {
  //       AppLogger.w("searchOrders => chưa chọn khoảng thời gian");
  //       return;
  //     }
  //   } else if (isTextFieldEnabled && keyword.isEmpty) {
  //     AppLogger.w("searchReportPaper => searchType=$searchType nhưng keyword rỗng");
  //     return;
  //   }

  //   setState(() {
  //     currentPage = 1;
  //     isSearching = (searchType != "Tất cả");
  //     _fetchData();
  //   });
  // }

  // void changeMachine(String selectedMachine) {
  //   AppLogger.i("changeMachine | from=$machine -> to=$selectedMachine");
  //   setState(() {
  //     machine = selectedMachine;
  //     selectedPaperIds.clear();
  //     loadInspectionPaper();
  //   });
  // }

  void changeMachine(String selectedMachine) {
    setState(() {
      machine = selectedMachine;
      _selectedPaperIdsNotifier.value = null;
      loadInspectionPaper();
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
    _selectedPaperIdsNotifier.dispose();
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
                                  "LỊCH SỬ KIỂM TRA CHẤT LƯỢNG GIẤY TẤM",
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
                                const SizedBox(),

                                //right button
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 10,
                                    ),
                                    child: ValueListenableBuilder(
                                      valueListenable: _selectedPaperIdsNotifier,
                                      builder: (context, selectedReportId, _) {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
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
                          } else if (!snapshot.hasData ||
                              snapshot.data!["inspectionPapers"].isEmpty) {
                            return const Center(
                              child: Text(
                                "Không có báo cáo nào",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            );
                          }

                          final data = snapshot.data!;
                          final inspectionPapers =
                              data["inspectionPapers"] as List<QcInspectionPaperModel>;
                          final currentPg = data["currentPage"];
                          final totalPgs = data["totalPages"];

                          if (_cachedInspecPapers != inspectionPapers ||
                              _cachedDatasource == null) {
                            _cachedInspecPapers = inspectionPapers;
                            _cachedDatasource = InspectionPaperDataSource(
                              inspectionPapers: inspectionPapers,
                              selectedPaperIds: _selectedPaperIdsNotifier.value,
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
                                      ),
                                      child: SfDataGrid(
                                        source: _cachedDatasource!,
                                        isScrollbarAlwaysShown: true,
                                        allowExpandCollapseGroup: true, // Bật grouping
                                        autoExpandGroups: true,
                                        columnWidthMode: ColumnWidthMode.auto,
                                        selectionMode: SelectionMode.single,
                                        headerRowHeight: 35,
                                        rowHeight: 38,
                                        columns: ColumnWidthTable.applySavedWidths(
                                          columns: columns,
                                          widths: columnWidths,
                                        ),
                                        stackedHeaderRows: <StackedHeaderRow>[
                                          StackedHeaderRow(
                                            cells: [
                                              StackedHeaderCell(
                                                columnNames: [
                                                  "orderId",
                                                  "customerName",
                                                  "productName",
                                                  "structure",
                                                  "flute",
                                                  "sizePaper",
                                                  "lengthPaper",
                                                  "runningPlan",
                                                ],
                                                child: Obx(
                                                  () => formatColumn(
                                                    label: "Thông Tin Đơn Hàng",
                                                    themeController: themeController,
                                                  ),
                                                ),
                                              ),
                                              StackedHeaderCell(
                                                columnNames: [
                                                  "timeInspection",
                                                  "numberPallet",
                                                  "machineSpeed",
                                                  "moisture",
                                                  "steamPressure",
                                                  "preheaterTemp",
                                                  "fctValue",
                                                  "patValue",
                                                ],
                                                child: Obx(
                                                  () => formatColumn(
                                                    label: "Thông Tin Kiểm Tra",
                                                    themeController: themeController,
                                                  ),
                                                ),
                                              ),
                                              StackedHeaderCell(
                                                columnNames: [
                                                  "blishter",
                                                  "wrongWidth",
                                                  "wrongLength",
                                                  "wrongScoringSpec",
                                                  "poorScoring",
                                                  "drityLiner",
                                                  "losseLiner",
                                                  "earDefect",
                                                  "skewedFlute",
                                                  "warppage",
                                                  "wrongStructure",
                                                  "waveHeight",
                                                  "poorTrim",
                                                  "misalignment",
                                                  "glueDripping",
                                                  "trimScrap",
                                                  "poorBundling",
                                                  "totalWidthErr",
                                                  "wrongProductInfo",
                                                ],
                                                child: formatColumn(
                                                  label: "Lỗi",
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
                                              setState: localSetState,
                                            ),
                                        onColumnResizeEnd:
                                            (details) => GridResizeHelper.onResizeEnd(
                                              details: details,
                                              tableKey: "inspectionPaper",
                                              columnWidths: columnWidths,
                                              setState: setState,
                                            ),

                                        onSelectionChanged: (addedRows, removedRows) {
                                          if (addedRows.isNotEmpty) {
                                            final selectedRow = addedRows.first;
                                            final selectedInspecPaperId =
                                                selectedRow
                                                        .getCells()
                                                        .firstWhere(
                                                          (cell) =>
                                                              cell.columnName == 'inspecPaperId',
                                                        )
                                                        .value
                                                    as int?;

                                            _selectedPaperIdsNotifier.value = selectedInspecPaperId;
                                          } else {
                                            _selectedPaperIdsNotifier.value = null;
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
                                    loadInspectionPaper();
                                  });
                                },
                                onNext: () {
                                  setState(() {
                                    currentPage++;
                                    loadInspectionPaper();
                                  });
                                },
                                onJumpToPage: (page) {
                                  setState(() {
                                    currentPage = page;
                                    loadInspectionPaper();
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
        onPressed: () => loadInspectionPaper(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
