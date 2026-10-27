import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/warehouse/debt_deduction_request_model.dart";
import "package:dongtam/presentation/components/dialog/export/dialog_export_debt_deduction.dart";
import "package:dongtam/presentation/components/headerTable/debt/header_table_debt_deduction.dart";
import "package:dongtam/presentation/components/shared/animation/animated_button.dart";
import "package:dongtam/presentation/components/shared/grid_resize_helper.dart";
import "package:dongtam/presentation/components/shared/pagination_controls.dart";
import "package:dongtam/presentation/components/shared/slider_zoom.dart";
import "package:dongtam/presentation/components/sources/debt/debt_deduction_data_source.dart";
import "package:dongtam/service/debt_service.dart";
import "package:dongtam/utils/helper/skeleton/skeleton_loading.dart";
import "package:dongtam/utils/storage/sharedPreferences/column_width_table.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:syncfusion_flutter_core/theme.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class ReportDebtDeduction extends StatefulWidget {
  const ReportDebtDeduction({super.key});

  @override
  State<ReportDebtDeduction> createState() => _ReportDebtDeductionState();
}

class _ReportDebtDeductionState extends State<ReportDebtDeduction> {
  late Future<Map<String, dynamic>> futureDebtDeduction;
  late List<GridColumn> columnsDebtDeduction;
  final formatter = DateFormat("dd/MM/yyyy");

  //controller
  final headerScrollController = ScrollController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final searchController = TextEditingController();

  //field search & filter
  String searchType = "Tất cả";

  //notifiers
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedRequestIdNotifier = ValueNotifier<int?>(null);
  Map<String, double> columnWidths = {};

  //datasource and cache
  DebtDeductionRequestModel? selectedDebtDeduction;
  DebtDeductionDataSource? _cachedDatasource;
  List<DebtDeductionRequestModel>? _cachedDebtDeduction;

  //flag
  bool isSearching = false;
  bool isTextFieldEnabled = false;

  //paging
  int currentPage = 1;
  int pageSize = 35;

  @override
  void initState() {
    super.initState();
    loadReportDebtDeduction();
    columnsDebtDeduction = buildDebtDeductionColumn(
      themeController: themeController,
      isReport: true,
    );

    ColumnWidthTable.loadWidths(
      tableKey: "report_debt_deduction",
      columns: columnsDebtDeduction,
    ).then((w) {
      if (mounted) {
        setState(() {
          columnWidths = w;
        });
      }
    });
  }

  void _fetchData() {
    futureDebtDeduction = ensureMinLoading(
      DebtService().getDebtDeductionRequests(
        page: currentPage,
        pageSize: pageSize,
        status: ["approved"],
      ),
    );
    _selectedRequestIdNotifier.value = null;
    selectedDebtDeduction = null;
  }

  void loadReportDebtDeduction() {
    setState(() => _fetchData());
  }

  void searchDebtDeduction() {
    final String keyword = searchController.text.trim();
    if (isTextFieldEnabled && keyword.isEmpty) return;

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
    _zoomNotifier.dispose();
    searchController.dispose();
    _selectedRequestIdNotifier.dispose();
    headerScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.backgroundColor.value,
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
                  Container(padding: const EdgeInsets.all(12), child: _buildHeaderBar()),
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
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, _) {
                return SliderZoom(
                  zoomLevel: zoom,
                  onZoomChanged: _updateZoom,
                  initialMargin: const Offset(73, 152),
                  buttonColor: themeController.buttonColor.value,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadReportDebtDeduction(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Column(
      children: [
        Text(
          "LỊCH SỬ YÊU CẦU CẤN TRỪ CÔNG NỢ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 8),

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
                      // Cụm tìm kiếm + Lọc trạng thái
                      const SizedBox(),
                      const SizedBox(width: 20),

                      // Cụm nút hành động
                      ValueListenableBuilder(
                        valueListenable: _selectedRequestIdNotifier,
                        builder: (context, selectedRequestId, _) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //export excel
                              AnimatedButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (_) => DialogExportDebtDeduction(),
                                  );
                                },
                                label: "Xuất Excel",
                                icon: Symbols.file_download,
                                backgroundColor: themeController.buttonColor,
                              ),
                              const SizedBox(width: 8),
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
      future: futureDebtDeduction,
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
        } else if (!snapshot.hasData || (snapshot.data!["debtDeductions"] as List).isEmpty) {
          return Container(
            color: themeController.backgroundColor.value,
            child: const Center(
              child: Text(
                "Không có dữ liệu lịch sử",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final debtDeductions = (data["debtDeductions"] as List).cast<DebtDeductionRequestModel>();
        final currentPg = data["currentPage"] ?? 1;
        final totalPgs = data["totalPages"] ?? 1;

        if (_cachedDebtDeduction != debtDeductions || _cachedDatasource == null) {
          _cachedDebtDeduction = debtDeductions;
          _cachedDatasource = DebtDeductionDataSource(
            debtDeductions: debtDeductions,
            isReport: true,
            currentPage: currentPage,
            pageSize: pageSize,
            selectedRequestId: _selectedRequestIdNotifier.value,
          );
        }

        return Column(
          children: [
            Expanded(
              child: StatefulBuilder(
                builder: (context, localSetState) {
                  return SfDataGridTheme(
                    data: SfDataGridThemeData(selectionColor: Colors.blue.withValues(alpha: 0.3)),
                    child: SfDataGrid(
                      source: _cachedDatasource!,
                      isScrollbarAlwaysShown: true,
                      columnWidthMode: ColumnWidthMode.auto,
                      selectionMode: SelectionMode.single,
                      headerRowHeight: 30,
                      rowHeight: 40,
                      columns: ColumnWidthTable.applySavedWidths(
                        columns: columnsDebtDeduction,
                        widths: columnWidths,
                      ),
                      allowColumnsResizing: true,
                      columnResizeMode: ColumnResizeMode.onResize,
                      onColumnResizeStart: GridResizeHelper.onResizeStart,
                      onColumnResizeUpdate:
                          (details) => GridResizeHelper.onResizeUpdate(
                            details: details,
                            columns: columnsDebtDeduction,
                            setState: localSetState,
                          ),
                      onColumnResizeEnd:
                          (details) => GridResizeHelper.onResizeEnd(
                            details: details,
                            tableKey: "report_debt_deduction",
                            columnWidths: columnWidths,
                            setState: setState,
                          ),
                      onSelectionChanged: (addedRows, removedRows) async {
                        if (addedRows.isNotEmpty) {
                          final selectedRow = addedRows.first;
                          final requestId =
                              selectedRow
                                      .getCells()
                                      .firstWhere((cell) => cell.columnName == "requestId")
                                      .value
                                  as int?;

                          _selectedRequestIdNotifier.value = requestId;
                          try {
                            selectedDebtDeduction = _cachedDebtDeduction?.firstWhere(
                              (item) => item.requestId == requestId,
                            );
                          } catch (_) {
                            selectedDebtDeduction = null;
                          }
                        } else {
                          _selectedRequestIdNotifier.value = null;
                          selectedDebtDeduction = null;
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            PaginationControls(
              currentPage: currentPg,
              totalPages: totalPgs,
              onPrevious: () {
                setState(() {
                  currentPage--;
                  loadReportDebtDeduction();
                });
              },
              onNext: () {
                setState(() {
                  currentPage++;
                  loadReportDebtDeduction();
                });
              },
              onJumpToPage: (page) {
                setState(() {
                  currentPage = page;
                  loadReportDebtDeduction();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
