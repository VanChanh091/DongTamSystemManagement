import "package:flutter/material.dart";
import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/synthetic/production/production_stage1_report_model.dart";
import "package:dongtam/presentation/components/headerTable/synthetic/report/production/header_table_production_report.dart";
import "package:dongtam/presentation/components/shared/grid_resize_helper.dart";
import "package:dongtam/presentation/components/shared/slider_zoom.dart";
import "package:dongtam/presentation/sources/synthetic/report/production/production_report_data_source.dart";
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
  late Future<List<ProductionReportModel>> futureReport;
  late List<GridColumn> columns;
  late bool isManager;

  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final headerScrollController = ScrollController();

  //notifiers
  Map<String, double> columnWidths = {};
  final _zoomNotifier = ValueNotifier<double>(1.0);

  // Filters
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  String selectedType = "machine"; // "machine" | "worker"

  // Datasource & Cache
  List<ProductionReportModel>? _cachedProductionReport;
  ProductionReportDataSource? _cachedDatasource;

  @override
  void initState() {
    super.initState();
    isManager = userController.hasAnyRole(roles: ["admin", "manager"]);

    _loadReport();
    _initColumns();
  }

  void _initColumns() {
    columns = buildProductionReportColumns(
      themeController: themeController,
      isMachine: selectedType == "machine",
    );
    ColumnWidthTable.loadWidths(tableKey: "production_report_$selectedType", columns: columns).then(
      (w) {
        if (mounted) setState(() => columnWidths = w);
      },
    );
  }

  void _loadReport() {
    final startStr = DateFormat("yyyy-MM-dd").format(selectedStartDate);
    final endStr = DateFormat("yyyy-MM-dd").format(selectedEndDate);

    setState(() {
      _cachedProductionReport = null;
      _cachedDatasource = null;
      futureReport = SyntheticService().getProductionReport(
        type: selectedType,
        startDate: startStr,
        endDate: endStr,
      );
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
                  // title & buttons
                  Container(padding: const EdgeInsets.all(12), child: _buildHeaderBar()),

                  //table & pagination
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
                  initialMargin: const Offset(73, 200),
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
        //title
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Switch Loại Báo Cáo: Máy vs Thợ
                      Row(
                        children: [
                          _buildTypeButton(title: "Theo Máy", type: "machine"),
                          const SizedBox(width: 10),
                          _buildTypeButton(title: "Theo Thợ", type: "worker"),
                        ],
                      ),

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
    return FutureBuilder<List<ProductionReportModel>>(
      future: futureReport,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildShimmerSkeletonTable(context: context, rowCount: 8);
        }
        if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
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

        if (_cachedProductionReport != items || _cachedDatasource == null) {
          _cachedProductionReport = items;
          _cachedDatasource = ProductionReportDataSource(
            items: items,
            isMachine: selectedType == "machine",
          );
        }

        return StatefulBuilder(
          builder: (context, localSetState) {
            return SfDataGridTheme(
              data: SfDataGridThemeData(selectionColor: Colors.blue.withValues(alpha: 0.3)),
              child: SfDataGrid(
                source: _cachedDatasource!,
                isScrollbarAlwaysShown: true,
                columnWidthMode: ColumnWidthMode.fill,
                selectionMode: SelectionMode.single,
                headerRowHeight: 37,
                rowHeight: 40,
                frozenColumnsCount: 2,
                columns: ColumnWidthTable.applySavedWidths(columns: columns, widths: columnWidths),

                //table summary
                tableSummaryRows: [
                  GridTableSummaryRow(
                    showSummaryInRow: false,
                    title: "Tổng cộng",
                    position: GridTableSummaryRowPosition.bottom,
                    columns: [
                      const GridSummaryColumn(
                        name: "totalPaperTon",
                        columnName: "totalPaperTon",
                        summaryType: GridSummaryType.sum,
                      ),
                      const GridSummaryColumn(
                        name: "totalLength",
                        columnName: "totalLength",
                        summaryType: GridSummaryType.sum,
                      ),
                      const GridSummaryColumn(
                        name: "totalScrapKg",
                        columnName: "totalScrapKg",
                        summaryType: GridSummaryType.sum,
                      ),
                      const GridSummaryColumn(
                        name: "totalRevenue",
                        columnName: "totalRevenue",
                        summaryType: GridSummaryType.sum,
                      ),
                      const GridSummaryColumn(
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
                onColumnResizeUpdate:
                    (details) => GridResizeHelper.onResizeUpdate(
                      details: details,
                      columns: columns,
                      setState: localSetState,
                    ),
                onColumnResizeEnd:
                    (details) => GridResizeHelper.onResizeEnd(
                      details: details,
                      tableKey: "production_report_$selectedType",
                      columnWidths: columnWidths,
                      setState: setState,
                    ),
              ),
            );
          },
        );
      },
    );
  }

  //========================= WIDGETS =========================
  Widget _buildTypeButton({required String title, required String type}) {
    final isSelected = selectedType == type;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? themeController.currentColor.value : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? themeController.currentColor.value : Colors.grey.shade300,
          ),
        ),
      ),
      onPressed: () {
        if (!isSelected) {
          setState(() {
            selectedType = type;
            _initColumns();
            _loadReport();
          });
        }
      },
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
