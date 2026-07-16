import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/presentation/components/dialog/qc/dialog_inspection_check.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_machine_box.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/planning/machine_box_data_source.dart';
import 'package:dongtam/service/manufacture_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InspectionBoxCheck extends StatefulWidget {
  const InspectionBoxCheck({super.key});

  @override
  State<InspectionBoxCheck> createState() => _InspectionBoxCheckState();
}

class _InspectionBoxCheckState extends State<InspectionBoxCheck> {
  late Future<List<PlanningBoxModel>> futurePlanning;
  late List<GridColumn> columns;

  //controller
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  //notifiters
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedPlanningBoxIdsNotifier = ValueNotifier<List<String>>([]);

  //datasource and cache
  List<PlanningBoxModel>? _cachedBoxes;
  MachineBoxDatasource? _cachedDatasource;

  String machine = "Máy In";
  bool _isSelectionChange = false;
  Map<String, double> columnWidths = {};
  List<PlanningBoxModel> planningList = [];

  @override
  void initState() {
    super.initState();
    loadPlanning();

    columns = buildMachineBoxColumns(
      machine: machine,
      themeController: themeController,
      page: 'production',
    );
    ColumnWidthTable.loadWidths(tableKey: 'queueBox', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadPlanning() {
    setState(() {
      futurePlanning = ensureMinLoading(ManufactureService().getPlanningBox(machine: machine));
    });
    _selectedPlanningBoxIdsNotifier.value = [];
    dataGridController.selectedRows = [];
  }

  void changeMachine(String selectedMachine) {
    AppLogger.i("changeMachine | from=$machine -> to=$selectedMachine");
    setState(() {
      machine = selectedMachine;
      _selectedPlanningBoxIdsNotifier.value = [];
      loadPlanning();
    });
  }

  void _updateSelectedIdsFromRows(List<DataGridRow> rows) {
    final newIds =
        rows
            .map((row) {
              final cell = row.getCells().firstWhere(
                (c) => c.columnName == 'planningBoxId',
                orElse: () => const DataGridCell(columnName: 'planningBoxId', value: ''),
              );
              return cell.value.toString();
            })
            .where((id) => id.isNotEmpty)
            .toList();

    _selectedPlanningBoxIdsNotifier.value = newIds;
    _cachedDatasource!.selectedPlanningIds = newIds;
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    _zoomNotifier.dispose();
    _selectedPlanningBoxIdsNotifier.dispose();
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
                                "DANH SÁCH ĐƠN THÙNG CHỜ KIỂM TRA",
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
                                      valueListenable: _selectedPlanningBoxIdsNotifier,
                                      builder: (context, selectedPlanningBoxIds, _) {
                                        return SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          reverse: true,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              //dialog inspection check
                                              AnimatedButton(
                                                onPressed:
                                                    selectedPlanningBoxIds.isNotEmpty
                                                        ? () async {
                                                          try {
                                                            final int selectedPlanningBoxId =
                                                                int.parse(
                                                                  selectedPlanningBoxIds.first,
                                                                );

                                                            final selectedPlanning = planningList
                                                                .firstWhere(
                                                                  (p) =>
                                                                      p.planningBoxId ==
                                                                      selectedPlanningBoxId,
                                                                  orElse:
                                                                      () =>
                                                                          throw Exception(
                                                                            "Không tìm thấy kế hoạch",
                                                                          ),
                                                                );

                                                            showDialog(
                                                              barrierDismissible: false,
                                                              context: context,
                                                              builder:
                                                                  (_) => DialogInspectionCheck(
                                                                    isQC: true,
                                                                    isPaper: false,
                                                                    machine: machine,
                                                                    planningBoxId:
                                                                        selectedPlanning
                                                                            .planningBoxId,
                                                                    onSubmit: () {
                                                                      loadPlanning();
                                                                    },
                                                                  ),
                                                            );
                                                          } catch (e, s) {
                                                            if (selectedPlanningBoxIds.isEmpty) {
                                                              showSnackBarError(
                                                                context,
                                                                "Vui lòng chọn một kế hoạch để kiểm tra",
                                                              );
                                                            } else {
                                                              AppLogger.e(
                                                                "Lỗi khi mở dialog",
                                                                error: e,
                                                                stackTrace: s,
                                                              );
                                                              showSnackBarError(
                                                                context,
                                                                "Đã xảy ra lỗi khi mở form kiểm tra.",
                                                              );
                                                            }
                                                          }
                                                        }
                                                        : null,
                                                label: "Kiểm Tra",
                                                icon: Icons.check_circle,
                                                backgroundColor: themeController.buttonColor,
                                              ),
                                              const SizedBox(width: 10),

                                              //choose machine
                                              buildDropdownItems(
                                                value: machine,
                                                items: const [
                                                  'Máy In',
                                                  "Máy Bế",
                                                  "Máy Xả",
                                                  "Máy Dán",
                                                  'Máy Cấn Lằn',
                                                  "Máy Cắt Khe",
                                                  "Máy Cán Màng",
                                                  "Máy Đóng Ghim",
                                                ],
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    changeMachine(value);
                                                  }
                                                },
                                              ),
                                              const SizedBox(width: 10),
                                            ],
                                          ),
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

                          final data = snapshot.data as List<PlanningBoxModel>;
                          planningList = data;

                          if (_cachedBoxes == null || _cachedBoxes != data) {
                            _cachedBoxes = data;
                            _cachedDatasource = MachineBoxDatasource(
                              planning: data,
                              selectedPlanningIds: _selectedPlanningBoxIdsNotifier.value,
                              showGroup: true,
                              page: 'production',
                              machine: machine,
                              onRowTap: (PlanningBoxModel item) {
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => DialogInspectionCheck(
                                        isQC: false,
                                        isPaper: false,
                                        planningBoxId: item.planningBoxId,
                                        machine: machine,
                                        onSubmit: () {},
                                      ),
                                );
                              },
                            );
                          }

                          return StatefulBuilder(
                            builder: (context, localSetState) {
                              return SfDataGridTheme(
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
                                            'qtyPrinted',
                                            'qtyCanLan',
                                            'qtyCanMang',
                                            'qtyXa',
                                            'qtyCatKhe',
                                            'qtyBe',
                                            'qtyDan',
                                            'qtyDongGhim',
                                          ],
                                          child: Obx(
                                            () => formatColumn(
                                              label: 'Số Lượng Của Các Công Đoạn',
                                              themeController: themeController,
                                            ),
                                          ),
                                        ),
                                        StackedHeaderCell(
                                          columnNames: ["quantityOrd", "qtyPaper", "needProd"],
                                          child: Obx(
                                            () => formatColumn(
                                              label: 'Số Lượng',
                                              themeController: themeController,
                                            ),
                                          ),
                                        ),
                                        StackedHeaderCell(
                                          columnNames: ["inMatTruoc", "inMatSau"],
                                          child: Obx(
                                            () => formatColumn(
                                              label: 'In Ấn',
                                              themeController: themeController,
                                            ),
                                          ),
                                        ),
                                        StackedHeaderCell(
                                          columnNames: ["dan_1_Manh", "dan_2_Manh"],
                                          child: Obx(
                                            () => formatColumn(
                                              label: 'Dán',
                                              themeController: themeController,
                                            ),
                                          ),
                                        ),
                                        StackedHeaderCell(
                                          columnNames: ["dongGhim1Manh", "dongGhim2Manh"],
                                          child: Obx(
                                            () => formatColumn(
                                              label: 'Đóng Ghim',
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
                                        tableKey: 'queueBox',
                                        columnWidths: columnWidths,
                                        setState: setState,
                                      ),

                                  onSelectionChanging: (addedRows, removedRows) {
                                    if (_isSelectionChange) return true;

                                    final keys = HardwareKeyboard.instance.logicalKeysPressed;
                                    final isShiftPressed =
                                        keys.contains(LogicalKeyboardKey.shiftLeft) ||
                                        keys.contains(LogicalKeyboardKey.shiftRight);

                                    // Nếu đè phím Shift và trước đó đã có dòng được chọn
                                    if (isShiftPressed &&
                                        dataGridController.selectedRows.isNotEmpty &&
                                        addedRows.isNotEmpty) {
                                      final lastSelected = dataGridController.selectedRows.last;
                                      final newlyClicked = addedRows.last;

                                      // Lấy tất cả các dòng dữ liệu trong datasource (không bao gồm caption row)
                                      final allRows = _cachedDatasource!.rows;
                                      final startIdx = allRows.indexOf(lastSelected);
                                      final endIdx = allRows.indexOf(newlyClicked);

                                      if (startIdx != -1 && endIdx != -1) {
                                        final min = startIdx < endIdx ? startIdx : endIdx;
                                        final max = startIdx > endIdx ? startIdx : endIdx;

                                        // Tự gom tất cả các dòng dữ liệu nằm giữa khoảng click
                                        final List<DataGridRow> rangeSelection = [];
                                        for (int i = min; i <= max; i++) {
                                          rangeSelection.add(allRows[i]);
                                        }

                                        // Ép controller chọn dải dòng
                                        _isSelectionChange = true;
                                        dataGridController.selectedRows = List.from(rangeSelection);
                                        _isSelectionChange = false;

                                        // Cập nhật ID đơn hàng
                                        Future.microtask(() {
                                          _isSelectionChange = true;
                                          dataGridController.selectedRows = List.from(
                                            rangeSelection,
                                          );
                                          _isSelectionChange = false;

                                          _updateSelectedIdsFromRows(rangeSelection);
                                        });
                                        return false;
                                      }
                                    }
                                    return true;
                                  },

                                  onSelectionChanged: (addedRows, removedRows) {
                                    if (_isSelectionChange) return;
                                    if (addedRows.isEmpty && removedRows.isEmpty) return;

                                    // bắt sự kiện từ bàn phím
                                    final keys = HardwareKeyboard.instance.logicalKeysPressed;
                                    final isCtrlPressed =
                                        keys.contains(LogicalKeyboardKey.controlLeft) ||
                                        keys.contains(LogicalKeyboardKey.controlRight);
                                    final isShiftPressed =
                                        keys.contains(LogicalKeyboardKey.shiftLeft) ||
                                        keys.contains(LogicalKeyboardKey.shiftRight);

                                    if (!isCtrlPressed && !isShiftPressed) {
                                      if (addedRows.isNotEmpty) {
                                        // Nếu click vào một dòng mới thì Xóa hết các dòng cũ, chỉ chọn duy nhất dòng này
                                        final latestRow = addedRows.last;

                                        _isSelectionChange = true;
                                        dataGridController.selectedRows = [latestRow];
                                        _isSelectionChange = false;
                                      } else if (removedRows.isNotEmpty &&
                                          dataGridController.selectedRows.isNotEmpty) {
                                        //ép chọn lại dòng vừa click vào nếu xóa hết các dòng cũ
                                        final clickedRow = removedRows.first;

                                        _isSelectionChange = true;
                                        dataGridController.selectedRows = [clickedRow];
                                        _isSelectionChange = false;
                                      }
                                    }

                                    _updateSelectedIdsFromRows(dataGridController.selectedRows);
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
                  initialMargin: Offset(73, 173),
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
}
