import "package:flutter/material.dart";
import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/synthetic/production/production_stage1_report_model.dart";
import "package:dongtam/presentation/components/headerTable/synthetic/report/production/header_table_production_report.dart";
import "package:dongtam/presentation/components/shared/grid_resize_helper.dart";
import "package:dongtam/presentation/components/shared/slider_zoom.dart";
import "package:dongtam/presentation/components/sources/synthetic/report/production/production_report_data_source.dart";
import "package:dongtam/service/synthetic_service.dart";
import "package:dongtam/utils/helper/skeleton/skeleton_loading.dart";
import "package:dongtam/utils/helper/picker_date_helper.dart";
import "package:dongtam/utils/storage/sharedPreferences/column_width_table.dart";
import "package:get/get.dart";
import "package:intl/intl.dart";
import "package:syncfusion_flutter_core/theme.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class SyntheticProductionReport extends StatefulWidget {
  const SyntheticProductionReport({super.key});

  @override
  State<SyntheticProductionReport> createState() => _SyntheticProductionReportState();
}

class _SyntheticProductionReportState extends State<SyntheticProductionReport> {
  late Future<ProductionCombinedReportModel> futureReport;
  late List<GridColumn> machineColumns;
  late List<GridColumn> workerColumns;
  late bool isManager;

  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final headerScrollController = ScrollController();

  // Column widths
  Map<String, double> machineColumnWidths = {};
  Map<String, double> workerColumnWidths = {};
  final _zoomNotifier = ValueNotifier<double>(1.0);

  // Filters
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();

  // Datasources & Cache
  ProductionCombinedReportModel? _cachedProductionReport;
  ProductionReportDataSource? _cachedMachineDatasource;
  ProductionReportDataSource? _cachedWorkerDatasource;

  @override
  void initState() {
    super.initState();
    isManager = userController.hasAnyRole(roles: ["admin", "manager"]);

    _loadReport();
    _initColumns();
  }

  void _initColumns() {
    machineColumns = buildProductionReportColumns(
      themeController: themeController,
      isMachine: true,
    );
    workerColumns = buildProductionReportColumns(
      themeController: themeController,
      isMachine: false,
    );

    ColumnWidthTable.loadWidths(
      tableKey: "production_report_machine",
      columns: machineColumns,
    ).then((w) {
      if (mounted) setState(() => machineColumnWidths = w);
    });
    ColumnWidthTable.loadWidths(tableKey: "production_report_worker", columns: workerColumns).then((
      w,
    ) {
      if (mounted) setState(() => workerColumnWidths = w);
    });
  }

  void _loadReport() {
    final startStr = DateFormat("yyyy-MM-dd").format(selectedStartDate);
    final endStr = DateFormat("yyyy-MM-dd").format(selectedEndDate);

    setState(() {
      _cachedProductionReport = null;
      _cachedMachineDatasource = null;
      _cachedWorkerDatasource = null;
      futureReport = SyntheticService().getProductionReport(startDate: startStr, endDate: endStr);
    });
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    _zoomNotifier.dispose();
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
                  // Header bar
                  Container(padding: const EdgeInsets.all(12), child: _buildHeaderBar()),

                  // Tables
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                  initialMargin: const Offset(75, 150),
                  buttonColor: themeController.buttonColor.value,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadReport,
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Column(
      children: [
        // Title
        Text(
          "BÁO CÁO SẢN XUẤT GIẤY TẤM",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Nút chọn ngày / khoảng ngày
                      PickerDateHelper(
                        width: 240,
                        height: 38,
                        startDate: selectedStartDate,
                        endDate: selectedEndDate,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Chọn ngày...",
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                          prefixIcon: const Icon(
                            Icons.calendar_month_outlined,
                            size: 19,
                            color: Color(0xFF2563EB),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        ),
                        onDateRangeChanged: (range) {
                          setState(() {
                            selectedStartDate = range.start;
                            selectedEndDate = range.end;
                          });
                          _loadReport();
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
    return FutureBuilder<ProductionCombinedReportModel>(
      future: futureReport,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildShimmerSkeletonTable(context: context, rowCount: 10);
        }
        if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        }

        final reportData = snapshot.data;
        final hasMachines = reportData != null && reportData.machines.isNotEmpty;
        final hasWorkers = reportData != null && reportData.workers.isNotEmpty;

        if (!hasMachines && !hasWorkers) {
          return Center(
            child: Text(
              "Không có dữ liệu trong khoảng thời gian đã chọn",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          );
        }

        if (_cachedProductionReport != reportData ||
            _cachedMachineDatasource == null ||
            _cachedWorkerDatasource == null) {
          _cachedProductionReport = reportData;
          _cachedMachineDatasource = ProductionReportDataSource(
            items: reportData.machines,
            isMachine: true,
          );
          _cachedWorkerDatasource = ProductionReportDataSource(
            items: reportData.workers,
            isMachine: false,
          );
        }

        return Column(
          children: [
            // table machine
            Expanded(
              child: _buildTableCard(
                title: "BẢNG TỔNG HỢP THEO MÁY",
                icon: Icons.precision_manufacturing_outlined,
                columns: machineColumns,
                columnWidths: machineColumnWidths,
                datasource: _cachedMachineDatasource!,
                tableKey: "production_report_machine",
                onResizeUpdate:
                    (details, localSetState) => GridResizeHelper.onResizeUpdate(
                      details: details,
                      columns: machineColumns,
                      setState: localSetState,
                    ),
                onResizeEnd: (details) {
                  GridResizeHelper.onResizeEnd(
                    details: details,
                    tableKey: "production_report_machine",
                    columnWidths: machineColumnWidths,
                    setState: setState,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            //table worker
            Expanded(
              child: _buildTableCard(
                title: "BẢNG TỔNG HỢP THEO THỢ",
                icon: Icons.people_alt_outlined,
                columns: workerColumns,
                columnWidths: workerColumnWidths,
                datasource: _cachedWorkerDatasource!,
                tableKey: "production_report_worker",
                onResizeUpdate:
                    (details, localSetState) => GridResizeHelper.onResizeUpdate(
                      details: details,
                      columns: workerColumns,
                      setState: localSetState,
                    ),
                onResizeEnd: (details) {
                  GridResizeHelper.onResizeEnd(
                    details: details,
                    tableKey: "production_report_worker",
                    columnWidths: workerColumnWidths,
                    setState: setState,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTableCard({
    required String title,
    required IconData icon,
    required List<GridColumn> columns,
    required Map<String, double> columnWidths,
    required ProductionReportDataSource datasource,
    required String tableKey,
    required bool Function(ColumnResizeUpdateDetails, StateSetter) onResizeUpdate,
    required void Function(ColumnResizeEndDetails) onResizeEnd,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table header title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: themeController.currentColor.value),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: themeController.currentColor.value,
                  ),
                ),
              ],
            ),
          ),
          // DataGrid
          Expanded(
            child: StatefulBuilder(
              builder: (context, localSetState) {
                return SfDataGridTheme(
                  data: SfDataGridThemeData(selectionColor: Colors.blue.withValues(alpha: 0.3)),
                  child: SfDataGrid(
                    source: datasource,
                    isScrollbarAlwaysShown: true,
                    columnWidthMode: ColumnWidthMode.fill,
                    selectionMode: SelectionMode.single,
                    headerRowHeight: 37,
                    rowHeight: 38,
                    frozenColumnsCount: 2,
                    columns: ColumnWidthTable.applySavedWidths(
                      columns: columns,
                      widths: columnWidths,
                    ),
                    tableSummaryRows: [
                      GridTableSummaryRow(
                        showSummaryInRow: false,
                        title: "Tổng cộng",
                        position: GridTableSummaryRowPosition.bottom,
                        columns: const [
                          GridSummaryColumn(
                            name: "totalPaperTon",
                            columnName: "totalPaperTon",
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: "totalLength",
                            columnName: "totalLength",
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: "totalScrapKg",
                            columnName: "totalScrapKg",
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: "totalRevenue",
                            columnName: "totalRevenue",
                            summaryType: GridSummaryType.sum,
                          ),
                          GridSummaryColumn(
                            name: "totalQcErrors",
                            columnName: "totalQcErrors",
                            summaryType: GridSummaryType.sum,
                          ),
                        ],
                      ),
                    ],
                    allowColumnsResizing: true,
                    columnResizeMode: ColumnResizeMode.onResize,
                    onColumnResizeStart: GridResizeHelper.onResizeStart,
                    onColumnResizeUpdate: (details) => onResizeUpdate(details, localSetState),
                    onColumnResizeEnd: onResizeEnd,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
