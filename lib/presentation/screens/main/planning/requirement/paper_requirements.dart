import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/planning/requirements/paper_requirement_layers.dart";
import "package:dongtam/data/models/planning/requirements/paper_requirement_model.dart";
import "package:dongtam/presentation/components/headerTable/planning/requirements/header_table_layer_requirement.dart";
import "package:dongtam/presentation/components/headerTable/planning/requirements/header_table_paper_requirement.dart";
import "package:dongtam/presentation/components/shared/planning/widgets_planning.dart";
import "package:dongtam/presentation/components/shared/slider_zoom.dart";
import "package:dongtam/presentation/sources/planning/requirements/layer_requirement_data_source.dart";
import "package:dongtam/presentation/sources/planning/requirements/paper_requirement_data_source.dart";
import "package:dongtam/service/planning_service.dart";
import "package:dongtam/presentation/components/shared/grid_resize_helper.dart";
import "package:dongtam/utils/helper/skeleton/skeleton_loading.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/storage/sharedPreferences/column_width_table.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:syncfusion_flutter_core/theme.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class PaperRequirements extends StatefulWidget {
  const PaperRequirements({super.key});

  @override
  State<PaperRequirements> createState() => _PaperRequirementsState();
}

class _PaperRequirementsState extends State<PaperRequirements> {
  late Future<Map<String, dynamic>> futureRequirements;
  late List<GridColumn> columnsRequirements;
  late List<GridColumn> columnsLayers;

  //controllers
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final headerScrollController = ScrollController();

  //width column
  Map<String, double> columnWidthRequirements = {}; //map header table
  Map<String, double> columnWidthLayers = {};

  //notifiers
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedRequirementIdsNotifier = ValueNotifier<List<int>>([]);

  //datasource and cache
  List<PaperRequirementModel>? _cachedRequirements;
  PaperRequirementsDataSource? _cachedDatasource;
  List<PaperRequirementLayerModel> selectedPaperLayers = [];

  String machine = "Máy 1350";
  bool _isSelectionChange = false;

  //cache grand totals paper required for smooth animated
  double _lastPaperRequired = 0;

  @override
  void initState() {
    super.initState();
    loadPaperRequirements();

    columnsRequirements = buildPaperRequirementColumns(themeController: themeController);
    columnsLayers = buildLayerRequirementColumns(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: "requirements", columns: columnsRequirements).then((w) {
      setState(() {
        columnWidthRequirements = w;
      });
    });

    ColumnWidthTable.loadWidths(tableKey: "layers", columns: columnsLayers).then((w) {
      setState(() {
        columnWidthLayers = w;
      });
    });
  }

  void _fetchData() {
    futureRequirements = ensureMinLoading(
      PlanningService().getPaperRequirementsList(machine: machine),
    );

    selectedPaperLayers = [];
    _selectedRequirementIdsNotifier.value = [];
    dataGridController.selectedRows = [];
  }

  void loadPaperRequirements() {
    setState(() => _fetchData());
  }

  void _updateSelectedIdsFromRows(List<DataGridRow> rows) async {
    final List<int> currentSelectedIds =
        dataGridController.selectedRows.map((row) {
          final value =
              row.getCells().firstWhere((cell) => cell.columnName == 'requirementId').value;
          return value as int;
        }).toList();

    List<PaperRequirementLayerModel> initialLayers = [];
    if (currentSelectedIds.length == 1 && _cachedRequirements != null) {
      final reqId = currentSelectedIds.first;
      for (var r in _cachedRequirements!) {
        if (r.requirementId == reqId) {
          if (r.layers != null && r.layers!.isNotEmpty) {
            initialLayers = r.layers!;
          }
          break;
        }
      }
    }

    setState(() {
      _selectedRequirementIdsNotifier.value = currentSelectedIds;
      selectedPaperLayers = initialLayers;
    });

    if (currentSelectedIds.length == 1) {
      try {
        final layers = await PlanningService().getLayersByRequirementId(
          requirementId: currentSelectedIds.first,
        );

        if (mounted) {
          setState(() {
            selectedPaperLayers = layers;
          });
        }
      } catch (e) {
        AppLogger.e("Error fetching layers for requirement ID ${currentSelectedIds.first}: $e");
      }
    }
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    _zoomNotifier.dispose();
    _selectedRequirementIdsNotifier.dispose();
    headerScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

            //slider zoom
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, _) {
                return SliderZoom(
                  zoomLevel: zoom,
                  onZoomChanged: _updateZoom,
                  // initialMargin: Offset(73, 125),
                  initialMargin: Offset(73, 152),
                  buttonColor: themeController.buttonColor.value,
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => loadPaperRequirements(),
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
          "ĐỊNH MỨC GIẤY SẢN XUẤT",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 8),

        //button
        LayoutBuilder(
          builder: (context, constraints) {
            return Scrollbar(
              controller: headerScrollController,
              child: SingleChildScrollView(
                controller: headerScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //left button
                          const SizedBox(),

                          //right button
                          ValueListenableBuilder(
                            valueListenable: _selectedRequirementIdsNotifier,
                            builder: (context, selectedOrderIds, _) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //change machine
                                  buildDropdownItems(
                                    value: machine,
                                    items: const [
                                      'Máy 1350',
                                      "Máy 1900",
                                      "Máy 2 Lớp",
                                      "Máy Quấn Cuồn",
                                    ],
                                    onChanged:
                                        (value) => {
                                          setState(() {
                                            machine = value!;
                                            _selectedRequirementIdsNotifier.value = [];
                                            selectedPaperLayers = [];
                                            loadPaperRequirements();
                                          }),
                                        },
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    //total qty paper required
                    Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: FutureBuilder(
                        future: futureRequirements,
                        builder: (context, snapshot) {
                          final isLoading = snapshot.connectionState == ConnectionState.waiting;

                          if (snapshot.hasData) {
                            final rawValue = snapshot.data?['totalRequiredQty'];
                            final double totalValue =
                                double.tryParse(rawValue?.toString() ?? "") ?? 0.0;

                            _lastPaperRequired = totalValue;
                          }

                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 400),
                            opacity: isLoading ? 0.4 : 1.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  "Tổng khối lượng yêu cầu: ",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                _buildAnimatedCounter(
                                  targetValue: _lastPaperRequired,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.green.shade500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
      future: futureRequirements,
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
        } else if (!snapshot.hasData || snapshot.data!["requirements"].isEmpty) {
          return Container(
            color: themeController.backgroundColor.value,
            child: Center(
              child: Text(
                "Không có dữ liệu",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final requirements = data["requirements"] as List<PaperRequirementModel>;

        if (_cachedRequirements == null || _cachedRequirements != requirements) {
          _cachedRequirements = requirements;
          _cachedDatasource = PaperRequirementsDataSource(requirements: requirements);
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
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: SfDataGrid(
                      controller: dataGridController,
                      source: _cachedDatasource!,
                      isScrollbarAlwaysShown: true,
                      columnWidthMode: ColumnWidthMode.auto,
                      selectionMode: SelectionMode.multiple,
                      headerRowHeight: 38,
                      rowHeight: 40,
                      columns: ColumnWidthTable.applySavedWidths(
                        columns: columnsRequirements,
                        widths: columnWidthRequirements,
                      ),

                      //auto resize
                      allowColumnsResizing: true,
                      columnResizeMode: ColumnResizeMode.onResize,

                      onColumnResizeStart: GridResizeHelper.onResizeStart,
                      onColumnResizeUpdate:
                          (details) => GridResizeHelper.onResizeUpdate(
                            details: details,
                            columns: columnsRequirements,
                            setState: localSetState,
                          ),
                      onColumnResizeEnd:
                          (details) => GridResizeHelper.onResizeEnd(
                            details: details,
                            tableKey: "requirements",
                            columnWidths: columnWidthRequirements,
                            setState: setState,
                          ),

                      onSelectionChanging: (addedRows, removedRows) {
                        if (_isSelectionChange) return true;

                        // Kiểm tra trạng thái bấm phím từ bàn phím
                        final keys = HardwareKeyboard.instance.logicalKeysPressed;
                        final isShiftPressed =
                            keys.contains(LogicalKeyboardKey.shiftLeft) ||
                            keys.contains(LogicalKeyboardKey.shiftRight);
                        final isCtrlPressed =
                            keys.contains(LogicalKeyboardKey.controlLeft) ||
                            keys.contains(LogicalKeyboardKey.controlRight);

                        // TH 1: Click bình thường (Không nhấn Shift & Ctrl)
                        if (!isShiftPressed && !isCtrlPressed) {
                          if (addedRows.isNotEmpty) {
                            final latestRow = addedRows.last;

                            _isSelectionChange = true;
                            dataGridController.selectedRows = [latestRow];
                            _isSelectionChange = false;

                            _updateSelectedIdsFromRows(dataGridController.selectedRows);
                            return false;
                          } else if (removedRows.isNotEmpty &&
                              dataGridController.selectedRows.length > 1) {
                            // Nếu đang chọn nhiều dòng, click vào 1 dòng bất kỳ không giữ phím -> Reset về duy nhất dòng đó
                            final clickedRow = removedRows.first;

                            _isSelectionChange = true;
                            dataGridController.selectedRows = [clickedRow];
                            _isSelectionChange = false;

                            _updateSelectedIdsFromRows(dataGridController.selectedRows);
                            return false;
                          }
                        }

                        // TH 2: Giữ phím Shift (Chọn một dải dòng liên tiếp)
                        if (isShiftPressed &&
                            dataGridController.selectedRows.isNotEmpty &&
                            addedRows.isNotEmpty) {
                          final lastSelected = dataGridController.selectedRows.last;
                          final newlyClicked = addedRows.last;

                          final allRows = _cachedDatasource!.rows;
                          final startIdx = allRows.indexOf(lastSelected);
                          final endIdx = allRows.indexOf(newlyClicked);

                          if (startIdx != -1 && endIdx != -1) {
                            final min = startIdx < endIdx ? startIdx : endIdx;
                            final max = startIdx > endIdx ? startIdx : endIdx;

                            final List<DataGridRow> rangeSelection = [];
                            for (int i = min; i <= max; i++) {
                              rangeSelection.add(allRows[i]);
                            }

                            _isSelectionChange = true;
                            dataGridController.selectedRows = List.from(rangeSelection);
                            _isSelectionChange = false;

                            _updateSelectedIdsFromRows(rangeSelection);
                            return false;
                          }
                        }

                        // TH 3: Giữ phím Ctrl
                        return true;
                      },

                      onSelectionChanged: (addedRows, removedRows) async {
                        if (_isSelectionChange) return;
                        _updateSelectedIdsFromRows(dataGridController.selectedRows);
                      },
                    ),
                  ),

                  selectedPaperLayers.isNotEmpty
                      ? Expanded(
                        flex: 1,
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: SfDataGrid(
                            source: LayerRequirementDataSource(layers: selectedPaperLayers),
                            isScrollbarAlwaysShown: true,
                            headerRowHeight: 30,
                            rowHeight: 35,
                            columnWidthMode: ColumnWidthMode.fill,
                            selectionMode: SelectionMode.single,
                            columns: ColumnWidthTable.applySavedWidths(
                              columns: columnsLayers,
                              widths: columnWidthLayers,
                            ),

                            //auto resize
                            allowColumnsResizing: true,
                            columnResizeMode: ColumnResizeMode.onResize,

                            onColumnResizeStart: GridResizeHelper.onResizeStart,
                            onColumnResizeUpdate:
                                (details) => GridResizeHelper.onResizeUpdate(
                                  details: details,
                                  columns: columnsLayers,
                                  setState: setState,
                                ),
                            onColumnResizeEnd:
                                (details) => GridResizeHelper.onResizeEnd(
                                  details: details,
                                  tableKey: "layers",
                                  columnWidths: columnWidthLayers,
                                  setState: setState,
                                ),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //helper animation
  Widget _buildAnimatedCounter({required num targetValue, required TextStyle style}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: targetValue.toDouble()),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(OrderModel.formatCurrency(value), style: style);
      },
    );
  }
}
