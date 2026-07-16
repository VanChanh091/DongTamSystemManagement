import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/dialog/other/dialog_check_qc.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_machine_paper.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/waitingCheck/waiting_check_paper_data_source.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class WaitingCheckPaper extends StatefulWidget {
  const WaitingCheckPaper({super.key});

  @override
  State<WaitingCheckPaper> createState() => _WaitingCheckPaperState();
}

class _WaitingCheckPaperState extends State<WaitingCheckPaper> {
  late Future<List<PlanningPaperModel>> futurePlanning;
  late List<GridColumn> columns;

  //controllers
  final formatter = DateFormat('dd/MM/yyyy');
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  Map<String, double> columnWidths = {}; //map header table
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedPlanningIdNotifier = ValueNotifier<List<String>>([]);

  //datasource and cache
  List<PlanningPaperModel>? _cachedPapers;
  WaitingCheckPaperDataSource? _cachedDatasource;

  List<PlanningPaperModel> planningList = [];
  bool showGroup = true;

  @override
  void initState() {
    super.initState();
    loadPaperWaiting();

    columns = buildMachinePaperColumns(themeController: themeController, page: "checking");
    ColumnWidthTable.loadWidths(tableKey: 'queuePaper', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadPaperWaiting() {
    setState(() {
      futurePlanning = ensureMinLoading(WarehouseService().getPaperWaitingChecked(isPaper: "true"));
    });
    _selectedPlanningIdNotifier.value = [];
    dataGridController.selectedRows = [];
  }

  bool canExecuteAction({
    required List<int> selectedPlanningIds,
    required List<PlanningPaperModel> planningList,
  }) {
    if (selectedPlanningIds.length != 1) return false;

    final selectedPlanning = planningList.firstWhere(
      (p) => p.planningId == selectedPlanningIds.first,
      orElse: () => throw Exception("Không tìm thấy kế hoạch"),
    );

    // disable nếu đã complete
    if (selectedPlanning.statusRequest == "finalize") return false;

    return true;
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    _zoomNotifier.dispose();
    _selectedPlanningIdNotifier.dispose();
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
              //container contain button and table
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
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
                                "DANH SÁCH GIẤY TẤM CHỜ KIỂM ABC",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: themeController.currentColor.value,
                                ),
                              ),
                            ),
                          ),

                          //button menu
                          SizedBox(
                            height: 70,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                      valueListenable: _selectedPlanningIdNotifier,
                                      builder: (context, selectedPlanningIds, _) {
                                        //QC Check
                                        final bool qcCheck =
                                            userController.hasPermission(permission: 'QC') &&
                                            canExecuteAction(
                                              selectedPlanningIds:
                                                  _selectedPlanningIdNotifier.value
                                                      .map(int.parse)
                                                      .toList(),
                                              planningList: planningList,
                                            );

                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            //inbound warehouse
                                            AnimatedButton(
                                              onPressed:
                                                  qcCheck
                                                      ? () async {
                                                        final int selectedPlanningId = int.parse(
                                                          selectedPlanningIds.first,
                                                        );

                                                        final selectedPlanning = planningList
                                                            .firstWhere(
                                                              (p) =>
                                                                  p.planningId ==
                                                                  selectedPlanningId,
                                                              orElse:
                                                                  () =>
                                                                      throw Exception(
                                                                        "Không tìm thấy kế hoạch",
                                                                      ),
                                                            );

                                                        final int remainQty =
                                                            (selectedPlanning.qtyProduced ?? 0) -
                                                            selectedPlanning.getTotalQtyInbound;

                                                        showDialog(
                                                          context: context,
                                                          builder:
                                                              (_) => DialogCheckQC(
                                                                planningId:
                                                                    selectedPlanning.planningId,
                                                                onQcSessionAddOrUpdate:
                                                                    () => loadPaperWaiting(),
                                                                type: 'paper',
                                                                valueInbound: remainQty,
                                                              ),
                                                        );
                                                      }
                                                      : null,
                                              label: "Nhập Kho",
                                              icon: Symbols.input,
                                              backgroundColor: themeController.buttonColor,
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
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                "Không có đơn hàng nào",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            );
                          }

                          final data = snapshot.data as List<PlanningPaperModel>;
                          planningList = data;

                          if (_cachedPapers != data || _cachedDatasource == null) {
                            _cachedPapers = data;
                            _cachedDatasource = WaitingCheckPaperDataSource(
                              planning: data,
                              selectedPlanningIds: _selectedPlanningIdNotifier.value,
                              showGroup: showGroup,
                            );
                          }

                          return StatefulBuilder(
                            builder: (context, localSetState) {
                              return SfDataGridTheme(
                                data: SfDataGridThemeData(
                                  selectionColor: Colors.blue.withValues(alpha: 0.3),
                                ),
                                child: SfDataGrid(
                                  controller: dataGridController,
                                  source: _cachedDatasource!,
                                  allowExpandCollapseGroup: true, // Bật grouping
                                  autoExpandGroups: true,
                                  isScrollbarAlwaysShown: true,
                                  columnWidthMode: ColumnWidthMode.auto,
                                  selectionMode: SelectionMode.single,
                                  headerRowHeight: 35,
                                  rowHeight: 40,
                                  frozenColumnsCount: 7,
                                  columns: ColumnWidthTable.applySavedWidths(
                                    columns: columns,
                                    widths: columnWidths,
                                  ),
                                  stackedHeaderRows: <StackedHeaderRow>[
                                    StackedHeaderRow(
                                      cells: [
                                        StackedHeaderCell(
                                          columnNames: ['qtyProduced', "inboundQty"],
                                          child: formatColumn(
                                            label: 'Số Lượng',
                                            themeController: themeController,
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
                                          child: formatColumn(
                                            label: 'Định Mức Phế Liệu',
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
                                        tableKey: 'queuePaper',
                                        columnWidths: columnWidths,
                                        setState: setState,
                                      ),

                                  onSelectionChanged: (addedRows, removedRows) {
                                    if (addedRows.isEmpty && removedRows.isEmpty) return;

                                    final selectedRows = dataGridController.selectedRows;

                                    final newIds =
                                        selectedRows
                                            .map((row) {
                                              final cell = row.getCells().firstWhere(
                                                (c) => c.columnName == 'planningId',
                                                orElse:
                                                    () => const DataGridCell(
                                                      columnName: 'planningId',
                                                      value: '',
                                                    ),
                                              );
                                              return cell.value.toString();
                                            })
                                            .where((id) => id.isNotEmpty)
                                            .toList();

                                    // cập nhật cho datasource
                                    _selectedPlanningIdNotifier.value = newIds;
                                    _cachedDatasource?.selectedPlanningIds = newIds;
                                    localSetState(() {});
                                  },
                                ),
                              );
                            },
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
        onPressed: () => loadPaperWaiting(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
