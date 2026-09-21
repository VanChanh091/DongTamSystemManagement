import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/synthetic/errorProduction/yearly_error_production_model.dart';
import 'package:dongtam/presentation/components/dialog/other/dialog_picker_year.dart';
import 'package:dongtam/presentation/components/headerTable/synthetic/report/errProduction/header_table_yearly_err_production.dart';
import 'package:dongtam/presentation/components/shared/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/screens/main/synthetic/report/errorProduction/top_tab_err_production.dart';
import 'package:dongtam/presentation/sources/synthetic/report/errProduction/yearly_err_production_data_source.dart';
import 'package:dongtam/service/admin/admin_service.dart';
import 'package:dongtam/service/employee_service.dart';
import 'package:dongtam/service/synthetic_service.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SyntheticYearlyErrProduction extends StatefulWidget {
  final ErrScope scope;

  const SyntheticYearlyErrProduction({super.key, this.scope = ErrScope.synthetic});

  @override
  State<SyntheticYearlyErrProduction> createState() => _SyntheticYearlyErrProductionState();
}

class _SyntheticYearlyErrProductionState extends State<SyntheticYearlyErrProduction> {
  late Future<Map<String, dynamic>> futureSynthetic;
  late List<GridColumn> columns;

  // Controllers
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  final headerScrollController = ScrollController();

  // Notifiers
  Map<String, double> columnWidths = {};
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedItemNotifier = ValueNotifier<String?>(null);

  // Filters
  final String selectedType = "paper"; // Màn hình tập trung vào giấy tấm
  late int selectedYear;

  // Machine filter
  String selectedMachine = "Tất cả";
  List<String> machineItems = ["Tất cả"];

  // Employee filter
  String selectedEmpUser = "Tất cả";
  List<String> empUserItems = ["Tất cả"];
  Map<String, int?> empUserMap = {"Tất cả": null};

  // Datasource & Cache
  List<YearlyErrorReportRow>? _cachedReportRows;
  YearlyErrProductionDataSource? _cachedDatasource;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedYear = now.year;

    _loadMachines();
    _loadEmployees();
    _fetchData();

    columns = buildYearlyErrProductionColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'yearly_err_production', columns: columns).then((w) {
      if (mounted) setState(() => columnWidths = w);
    });
  }

  Future<void> _loadMachines() async {
    try {
      final List<String> list = ["Tất cả"];
      final machines = await AdminService().getMachinePapers();
      for (final m in machines) {
        final name = m.machineName.trim();
        if (name.isNotEmpty && !list.contains(name)) {
          list.add(name);
        }
      }

      if (mounted) {
        setState(() {
          machineItems = list;
          if (!machineItems.contains(selectedMachine)) {
            selectedMachine = "Tất cả";
          }
        });
      }
    } catch (e, s) {
      AppLogger.e("Lỗi tải danh sách máy giấy: $e", error: e, stackTrace: s);
    }
  }

  Future<void> _loadEmployees() async {
    try {
      final users = await EmployeeService().getEmployeeByPosition();

      if (mounted) {
        setState(() {
          final Map<String, int?> newMap = {"Tất cả": null};
          final List<String> newItems = ["Tất cả"];

          for (final user in users) {
            final name = user.fullName.trim();
            if (name.isNotEmpty) {
              String displayName = name;
              if (newMap.containsKey(displayName)) {
                displayName = "$name (${user.employeeId})";
              }
              newItems.add(displayName);
              newMap[displayName] = user.employeeId;
            }
          }

          empUserMap = newMap;
          empUserItems = newItems;
          if (!empUserItems.contains(selectedEmpUser)) {
            selectedEmpUser = "Tất cả";
          }
        });
      }
    } catch (e, s) {
      AppLogger.e("Lỗi tải danh sách nhân viên: $e", error: e, stackTrace: s);
    }
  }

  void _fetchData() {
    final empId = empUserMap[selectedEmpUser];
    final machine = selectedMachine == "Tất cả" ? null : selectedMachine;

    futureSynthetic = ensureMinLoading(
      SyntheticService().getErrorProductionReport<YearlyErrorReportRow>(
        type: selectedType,
        action: "yearly",
        year: selectedYear,
        machine: machine,
        employeeId: empId,
        dataKey: "errorProduction",
        fromJson: (json) => YearlyErrorReportRow.fromJson(json),
      ),
    );
  }

  void _loadReport() {
    setState(() => _fetchData());
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
                  // Title & Filter Header
                  Container(padding: const EdgeInsets.all(12), child: _buildHeaderBar()),

                  // Table Section
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

            // Zoom Control Floating Button
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
        // Title
        Text(
          "THỐNG KÊ TỶ LỆ LỖI",
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
                      const SizedBox(width: 12),

                      ValueListenableBuilder(
                        valueListenable: _selectedItemNotifier,
                        builder: (context, selectedItemNotifier, _) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Year Picker
                              SizedBox(
                                width: 170,
                                child: InkWell(
                                  onTap: () async {
                                    final result = await showYearRangePickerDialog(
                                      context: context,
                                      initialFromYear: selectedYear,
                                      initialToYear: selectedYear,
                                      maxYears: 1,
                                    );

                                    if (result != null) {
                                      if (selectedYear != result.fromYear) {
                                        setState(() {
                                          selectedYear = result.fromYear;
                                        });
                                        _loadReport();
                                      }
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: "Năm báo cáo",
                                      filled: true,
                                      fillColor: Colors.white,
                                      suffixIcon: const Icon(Icons.calendar_today, size: 18),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: Text(
                                      "Năm $selectedYear",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Dropdown machine
                              buildDropdownItems(
                                value:
                                    machineItems.contains(selectedMachine)
                                        ? selectedMachine
                                        : machineItems.first,
                                items: machineItems,
                                width: 180,
                                itemLabelBuilder: (item) => item == "Tất cả" ? "Máy: Tất cả" : item,
                                onChanged: (value) {
                                  if (value != null && value != selectedMachine) {
                                    setState(() {
                                      selectedMachine = value;
                                    });
                                    _loadReport();
                                  }
                                },
                              ),
                              const SizedBox(width: 12),

                              // Dropdown employee
                              buildDropdownItems(
                                value:
                                    empUserItems.contains(selectedEmpUser)
                                        ? selectedEmpUser
                                        : empUserItems.first,
                                items: empUserItems,
                                width: 180,
                                onChanged: (value) {
                                  if (value != null && value != selectedEmpUser) {
                                    setState(() {
                                      selectedEmpUser = value;
                                    });
                                    _loadReport();
                                  }
                                },
                              ),
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
      future: futureSynthetic,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildShimmerSkeletonTable(context: context, rowCount: 10);
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Lỗi tải dữ liệu: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final responseMap = snapshot.data;
        var rawList = responseMap?["errorProduction"] as List<YearlyErrorReportRow>?;

        if (responseMap == null || rawList == null || rawList.isEmpty) {
          return Container(
            color: themeController.backgroundColor.value,
            child: const Center(
              child: Text(
                "Không có dữ liệu báo cáo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          );
        }

        YearlyErrorReportSummary? summary;
        if (responseMap['summary'] != null && responseMap['summary'] is Map<String, dynamic>) {
          summary = YearlyErrorReportSummary.fromJson(
            responseMap['summary'] as Map<String, dynamic>,
          );
        }

        if (_cachedReportRows != rawList || _cachedDatasource == null) {
          _cachedReportRows = rawList;
          _cachedDatasource = YearlyErrProductionDataSource(rowsData: rawList, summary: summary);
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
                      headerRowHeight: 33,
                      rowHeight: 38,
                      frozenColumnsCount: 5,
                      columns: ColumnWidthTable.applySavedWidths(
                        columns: columns,
                        widths: columnWidths,
                      ),
                      stackedHeaderRows: <StackedHeaderRow>[
                        StackedHeaderRow(
                          cells: [
                            StackedHeaderCell(
                              columnNames: const ["totalTonnage", "totalErrors", "totalErrorRate"],
                              child: Obx(
                                () => formatColumn(
                                  label: "Cả Năm $selectedYear",
                                  themeController: themeController,
                                ),
                              ),
                            ),
                            for (int m = 1; m <= 12; m++)
                              StackedHeaderCell(
                                columnNames: ["m_${m}_tonnage", "m_${m}_errors", "m_${m}_rate"],
                                child: Obx(
                                  () => formatColumn(
                                    label: "Tháng $m",
                                    themeController: themeController,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],

                      // Table summary row
                      tableSummaryRows: [
                        GridTableSummaryRow(
                          showSummaryInRow: false,
                          title: "Tổng",
                          position: GridTableSummaryRowPosition.bottom,
                          columns: [
                            const GridSummaryColumn(
                              name: "totalTonnage",
                              columnName: "totalTonnage",
                              summaryType: GridSummaryType.sum,
                            ),
                            const GridSummaryColumn(
                              name: "totalErrors",
                              columnName: "totalErrors",
                              summaryType: GridSummaryType.sum,
                            ),
                            const GridSummaryColumn(
                              name: "totalErrorRate",
                              columnName: "totalErrorRate",
                              summaryType: GridSummaryType.sum,
                            ),
                            for (int m = 1; m <= 12; m++) ...[
                              GridSummaryColumn(
                                name: "m_${m}_tonnage",
                                columnName: "m_${m}_tonnage",
                                summaryType: GridSummaryType.sum,
                              ),
                              GridSummaryColumn(
                                name: "m_${m}_errors",
                                columnName: "m_${m}_errors",
                                summaryType: GridSummaryType.sum,
                              ),
                              GridSummaryColumn(
                                name: "m_${m}_rate",
                                columnName: "m_${m}_rate",
                                summaryType: GridSummaryType.sum,
                              ),
                            ],
                          ],
                        ),
                      ],

                      // Auto resize columns
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
                            tableKey: 'yearly_err_production',
                            columnWidths: columnWidths,
                            setState: setState,
                          ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
