import "package:dongtam/data/controller/badges_controller.dart";
import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/planning/planning_paper_model.dart";
import "package:dongtam/presentation/components/headerTable/planning/header_table_machine_paper.dart";
import "package:dongtam/presentation/components/sources/planning/machine_paper_data_source.dart";
import "package:dongtam/presentation/components/shared/other/slider_zoom.dart";
import "package:syncfusion_flutter_core/theme.dart";
import "package:dongtam/service/planning_service.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/presentation/components/shared/animation/animated_button.dart";
import "package:dongtam/presentation/components/shared/other/dialog_shared.dart";
import "package:dongtam/presentation/components/shared/other/grid_resize_helper.dart";
import "package:dongtam/presentation/components/shared/other/pagination_controls.dart";
import "package:dongtam/utils/helper/skeleton/skeleton_loading.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/storage/sharedPreferences/column_width_table.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:get/get.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class PlanningStop extends StatefulWidget {
  const PlanningStop({super.key});

  @override
  State<PlanningStop> createState() => _PlanningStopState();
}

class _PlanningStopState extends State<PlanningStop> {
  late Future<Map<String, dynamic>> futurePlanning;
  final _zoomNotifier = ValueNotifier<double>(1.0);
  MachinePaperDatasource? _cachedDatasource;
  List<PlanningPaperModel>? _cachedPlannings;
  late List<GridColumn> columns;
  final DataGridController dataGridController = DataGridController();
  final badgesController = Get.find<BadgesController>();
  final themeController = Get.find<ThemeController>();
  final userController = Get.find<UserController>();
  final formatter = DateFormat("dd/MM/yyyy");

  TextEditingController searchController = TextEditingController();
  Map<String, double> columnWidths = {}; //map header table
  bool selectedAll = false;
  bool isTextFieldEnabled = false;

  List<String> selectedPlanningIds = [];

  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  @override
  void initState() {
    super.initState();
    loadPlanning();

    columns = buildMachinePaperColumns(
      themeController: themeController,
      page: "planning",
      zoomNotifier: _zoomNotifier,
    );

    ColumnWidthTable.loadWidths(tableKey: "planningStop", columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadPlanning() {
    setState(() {
      futurePlanning = ensureMinLoading(
        PlanningService().getPlanningStop(page: currentPage, pageSize: pageSize),
      );

      badgesController.fetchPlanningStop();
      selectedPlanningIds.clear();
    });
  }

  void _updateZoom(double newZoom) {
    final clamped = newZoom.clamp(0.5, 1.5);
    _zoomNotifier.value = clamped;
    if (_cachedDatasource != null) {
      _cachedDatasource!.zoom = clamped;
      _cachedDatasource!.notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    _zoomNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlan = userController.hasPermission(permission: "plan");

    return Scaffold(
      backgroundColor: themeController.backgroundColor.value, // Nền xám nhạt giúp bảng nổi bật
      body: Listener(
        onPointerSignal:
            (pointerSignal) => handleScrollZoom(
              pointerSignal: pointerSignal,
              currentZoom: _zoomNotifier.value,
              onZoomChanged: _updateZoom,
            ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title & buttons
                Container(padding: const EdgeInsets.all(12), child: _buildHeaderBar(isPlan)),

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

            //slider zoom
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
        onPressed: () => loadPlanning(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderBar(bool isPlan) {
    return Column(
      children: [
        //title
        Text(
          "DANH SÁCH KẾ HOẠCH BỊ DỪNG",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 8),

        //button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //left button
            Expanded(flex: 2, child: SizedBox()),

            //right button
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  handleCancelOrContinue(
                    isPlan: isPlan,
                    action: "planning",
                    label: "Tiếp Tục Chạy",
                    iconData: Symbols.check,
                  ),
                  const SizedBox(width: 10),

                  handleCancelOrContinue(
                    isPlan: isPlan,
                    action: "cancel",
                    label: "Hủy Đơn",
                    iconData: Symbols.cancel,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableSection() {
    return FutureBuilder(
      future: futurePlanning,
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
        } else if (!snapshot.hasData || snapshot.data!["plannings"].isEmpty) {
          return Container(
            color: themeController.backgroundColor.value,
            child: Center(
              child: Text(
                "Không có đơn hàng nào",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final plannings = data["plannings"] as List<PlanningPaperModel>;
        final currentPg = data["currentPage"];
        final totalPgs = data["totalPages"];

        if (_cachedPlannings == null || _cachedPlannings != plannings) {
          _cachedPlannings = plannings;
          _cachedDatasource = MachinePaperDatasource(
            planning: plannings,
            selectedPlanningIds: selectedPlanningIds,
            showGroup: true,
            page: "planning",
            zoom: _zoomNotifier.value,
          );
        }

        return ValueListenableBuilder<double>(
          valueListenable: _zoomNotifier,
          builder: (context, zoom, _) {
            return StatefulBuilder(
              builder: (context, localSetState) {
                return Column(
                  children: [
                    //table
                    Expanded(
                      child: SfDataGridTheme(
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
                          allowExpandCollapseGroup: true, // Bật grouping
                          autoExpandGroups: true,
                          isScrollbarAlwaysShown: true,
                          columnWidthMode: ColumnWidthMode.auto,
                          navigationMode: GridNavigationMode.row,
                          selectionMode: SelectionMode.multiple,
                          headerRowHeight: (35 * zoom).clamp(24.0, 60.0),
                          rowHeight: (40 * zoom).clamp(24.0, 60.0),
                          columns: ColumnWidthTable.applySavedWidths(
                            columns: columns,
                            widths: columnWidths,
                            zoom: zoom,
                          ),
                          frozenColumnsCount: 8,
                          stackedHeaderRows: buildPlanningStopSHR(
                            themeController: themeController,
                            zoom: zoom,
                          ),

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
                                tableKey: "planningStop",
                                columnWidths: columnWidths,
                                setState: setState,
                              ),

                          onSelectionChanged: (addedRows, removedRows) {
                            if (addedRows.isEmpty && removedRows.isEmpty) return;

                            setState(() {
                              final selectedRows = dataGridController.selectedRows;

                              selectedPlanningIds =
                                  selectedRows
                                      .map((row) {
                                        final cell = row.getCells().firstWhere(
                                          (c) => c.columnName == "planningId",
                                          orElse:
                                              () => const DataGridCell(
                                                columnName: "planningId",
                                                value: "",
                                              ),
                                        );
                                        return cell.value.toString();
                                      })
                                      .where((id) => id.isNotEmpty)
                                      .toList();

                              _cachedDatasource!.selectedPlanningIds = selectedPlanningIds;
                              _cachedDatasource!.notifyListeners();
                            });
                          },
                        ),
                      ),
                    ),

                    // Nút chuyển trang
                    PaginationControls(
                      currentPage: currentPg,
                      totalPages: totalPgs,
                      onPrevious: () {
                        setState(() {
                          currentPage--;
                          loadPlanning();
                        });
                      },
                      onNext: () {
                        setState(() {
                          currentPage++;
                          loadPlanning();
                        });
                      },
                      onJumpToPage: (page) {
                        setState(() {
                          currentPage = page;
                          loadPlanning();
                        });
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget handleCancelOrContinue({
    required bool isPlan,
    required String action,
    required String label,
    required IconData iconData,
  }) {
    return AnimatedButton(
      onPressed:
          isPlan && selectedPlanningIds.isNotEmpty
              ? () async {
                final confirm = await showConfirmDialog(
                  context: context,
                  title: "⚠️ Xác nhận",
                  content: "Bạn có chắc muốn thực hiện thao tác này?",
                  confirmText: "Ok",
                  confirmColor: const Color(0xffEA4346),
                );

                if (!confirm) return;

                if (!mounted) return;
                showLoadingDialog(context);

                try {
                  final success = await PlanningService().cancelOrContinuePlannning(
                    planningId:
                        selectedPlanningIds
                            .map((e) => int.tryParse(e.toString()))
                            .whereType<int>()
                            .toList(),
                    action: action,
                  );

                  if (success) {
                    badgesController.fetchPlanningStop();
                    loadPlanning();
                  }

                  if (!mounted) return;
                  Navigator.of(context).pop();
                  showSnackBarSuccess(context, "Thao tác thành công");
                } catch (e, s) {
                  if (mounted) Navigator.of(context).pop();
                  AppLogger.e("Error in cancelOrContinue: $e", stackTrace: s);

                  if (mounted) {
                    showSnackBarError(context, "Có lỗi xảy ra, vui lòng thử lại");
                  }
                }
              }
              : null,
      label: label,
      icon: iconData,
      backgroundColor: action == "cancel" ? const Color(0xffEA4346) : themeController.buttonColor,
    );
  }
}
