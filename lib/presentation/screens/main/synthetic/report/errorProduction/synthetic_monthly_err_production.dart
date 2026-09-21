import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/synthetic/errorProduction/monthly_error_production_model.dart';
import 'package:dongtam/presentation/components/dialog/other/dialog_picker_month.dart';
import 'package:dongtam/presentation/components/headerTable/synthetic/report/errProduction/header_table_monthly_err_production.dart';
import 'package:dongtam/presentation/components/shared/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/screens/main/synthetic/report/errorProduction/top_tab_err_production.dart';
import 'package:dongtam/presentation/sources/synthetic/report/errProduction/monthly_err_production_data_source.dart';
import 'package:dongtam/service/admin/admin_service.dart';
import 'package:dongtam/service/employee_service.dart';
import 'package:dongtam/service/synthetic_service.dart';
import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SyntheticMonthlyErrProduction extends StatefulWidget {
  final ErrScope scope;

  const SyntheticMonthlyErrProduction({super.key, this.scope = ErrScope.synthetic});

  @override
  State<SyntheticMonthlyErrProduction> createState() => _SyntheticMonthlyErrProductionState();
}

class _SyntheticMonthlyErrProductionState extends State<SyntheticMonthlyErrProduction> {
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
  String selectedType = "paper"; // "paper" | "box"
  late int selectedMonth;
  late int selectedYear;

  // Machine filter
  String selectedMachine = "Tất cả";
  List<String> machineItems = ["Tất cả"];

  // Employee filter
  String selectedEmpUser = "Tất cả";
  List<String> empUserItems = ["Tất cả"];
  Map<String, int?> empUserMap = {"Tất cả": null};

  // Datasource & Cache
  List<MonthlyErrorReportRow>? _cachedReportRows;
  MonthlyErrProductionDataSource? _cachedDatasource;
  int _cachedDaysInMonth = 31;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;

    _loadMachines();
    _loadEmployees();
    _fetchData();

    columns = buildMonthlyErrProductionColumn(
      themeController: themeController,
      daysInMonth: _cachedDaysInMonth,
    );

    ColumnWidthTable.loadWidths(tableKey: 'monthly_err_production', columns: columns).then((w) {
      if (mounted) setState(() => columnWidths = w);
    });
  }

  Future<void> _loadMachines() async {
    try {
      final List<String> list = ["Tất cả"];
      if (selectedType == "paper") {
        final machines = await AdminService().getMachinePapers();
        for (final m in machines) {
          final name = m.machineName.trim();
          if (name.isNotEmpty && !list.contains(name)) {
            list.add(name);
          }
        }
      } else {
        final machines = await AdminService().getAllMachineBox();
        for (final m in machines) {
          final name = m.machineName.trim();
          if (name.isNotEmpty && !list.contains(name)) {
            list.add(name);
          }
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
      AppLogger.e("Lỗi tải danh sách máy: $e", error: e, stackTrace: s);
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
      SyntheticService().getErrorProductionReport<MonthlyErrorReportRow>(
        type: selectedType,
        action: "monthly",
        year: selectedYear,
        month: selectedMonth,
        machine: machine,
        employeeId: empId,
        dataKey: "errorProduction",
        fromJson: (json) => MonthlyErrorReportRow.fromJson(json),
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
          "THỐNG KÊ LỖI VẬN HÀNH",
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

                      //buttons
                      ValueListenableBuilder(
                        valueListenable: _selectedItemNotifier,
                        builder: (context, selectedCustomerId, _) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //dropdown type: giấy tấm / thùng carton
                              buildDropdownItems(
                                value: selectedType == "paper" ? "Giấy Tấm" : "Thùng Carton",
                                items: const ["Giấy Tấm", "Thùng Carton"],
                                width: 160,
                                onChanged: (val) {
                                  if (val != null) {
                                    final newType = val == "Giấy Tấm" ? "paper" : "box";
                                    if (newType != selectedType) {
                                      setState(() {
                                        selectedType = newType;
                                        selectedMachine = "Tất cả";
                                      });
                                      _loadMachines();
                                      _loadReport();
                                    }
                                  }
                                },
                              ),
                              const SizedBox(width: 12),

                              // Month / Year Picker
                              SizedBox(
                                width: 165,
                                child: InkWell(
                                  onTap: () async {
                                    final result = await showMonthYearPickerDialog(
                                      context: context,
                                      initialMonth: selectedMonth,
                                      initialYear: selectedYear,
                                    );

                                    if (result != null) {
                                      // Kiểm tra nếu tháng hoặc năm có sự thay đổi
                                      final hasChanged =
                                          selectedMonth != result.month ||
                                          selectedYear != result.year;

                                      if (hasChanged) {
                                        setState(() {
                                          selectedMonth = result.month;
                                          selectedYear = result.year;
                                        });
                                        _loadReport();
                                      }
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: "Thời gian",
                                      filled: true,
                                      fillColor: Colors.white,
                                      suffixIcon: const Icon(Icons.calendar_month, size: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: Text(
                                      "Tháng $selectedMonth / $selectedYear",
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
                                width: 170,
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
                                itemLabelBuilder: (item) => item,
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
        var rawList = responseMap?["errorProduction"] as List<MonthlyErrorReportRow>?;

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

        final int daysInMonth = toInt(responseMap['daysInMonth']);
        final effectiveDaysInMonth = daysInMonth > 0 ? daysInMonth : 31;

        MonthlyErrorReportSummary? summary;
        if (responseMap['summary'] != null && responseMap['summary'] is Map<String, dynamic>) {
          summary = MonthlyErrorReportSummary.fromJson(
            responseMap['summary'] as Map<String, dynamic>,
          );
        }

        // Rebuild columns nếu daysInMonth thay đổi
        if (_cachedDaysInMonth != effectiveDaysInMonth) {
          _cachedDaysInMonth = effectiveDaysInMonth;
          columns = buildMonthlyErrProductionColumn(
            themeController: themeController,
            daysInMonth: effectiveDaysInMonth,
          );
        }

        if (_cachedReportRows != rawList || _cachedDatasource == null) {
          _cachedReportRows = rawList;
          _cachedDatasource = MonthlyErrProductionDataSource(
            rowsData: rawList,
            summary: summary,
            daysInMonth: effectiveDaysInMonth,
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
                      headerRowHeight: 33,
                      rowHeight: 38,
                      frozenColumnsCount: 4,
                      columns: ColumnWidthTable.applySavedWidths(
                        columns: columns,
                        widths: columnWidths,
                      ),
                      stackedHeaderRows: <StackedHeaderRow>[
                        StackedHeaderRow(
                          cells: [
                            StackedHeaderCell(
                              columnNames: List.generate(effectiveDaysInMonth, (i) => 'd_${i + 1}'),
                              child: Obx(
                                () => formatColumn(
                                  label: 'Ngày Trong Tháng',
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
                              name: "totalErrors",
                              columnName: "totalErrors",
                              summaryType: GridSummaryType.sum,
                            ),
                            for (int d = 1; d <= effectiveDaysInMonth; d++)
                              GridSummaryColumn(
                                name: "d_$d",
                                columnName: "d_$d",
                                summaryType: GridSummaryType.sum,
                              ),
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
                            tableKey: 'monthly_err_production',
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
