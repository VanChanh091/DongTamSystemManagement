import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/planning/requirements/paper_requirement_ghep_kho_summary.dart";
import "package:dongtam/data/models/planning/requirements/paper_requirement_layers.dart";
import "package:dongtam/data/models/planning/requirements/paper_requirement_model.dart";
import "package:dongtam/presentation/components/headerTable/planning/requirements/header_table_layer_requirement.dart";
import "package:dongtam/presentation/components/headerTable/planning/requirements/header_table_paper_requirement.dart";
import "package:dongtam/presentation/components/shared/left_button_search.dart";
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
  final searchController = TextEditingController();

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
  bool isTextFieldEnabled = false;
  bool isSearching = false;

  // Search & Filter
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
    "Ghép Khổ": "ghepKho",
  };

  //cache grand totals paper required for smooth animated
  double _lastPaperRequired = 0;
  double _lastTotalPrice = 0;

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
    final String keyword = searchController.text.trim().toLowerCase();
    final String selectedField = searchFieldMap[searchType] ?? "";
    final bool shouldSearch = (searchType != "Tất cả");

    futureRequirements = ensureMinLoading(
      PlanningService().getPaperRequirementsList(
        machine: machine,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? keyword : null,
      ),
    );

    selectedPaperLayers = [];
    _selectedRequirementIdsNotifier.value = [];
    dataGridController.selectedRows = [];
  }

  void loadPaperRequirements() {
    setState(() => _fetchData());
  }

  void searchRequirement() {
    String keyword = searchController.text.trim().toLowerCase();
    if (isTextFieldEnabled && keyword.isEmpty) return;

    setState(() {
      isSearching = (searchType != "Tất cả");
      _fetchData();
    });
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
    searchController.dispose();
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title
        Center(
          child: Text(
            "ĐỊNH MỨC GIẤY SẢN XUẤT",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: themeController.currentColor.value,
            ),
          ),
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Cụm tìm kiếm bên trái
            LeftButtonSearch(
              selectedType: searchType,
              types: const ['Tất cả', 'Mã Đơn Hàng', 'Tên Khách Hàng', 'Ghép Khổ'],
              onTypeChanged: (value) {
                setState(() {
                  searchType = value;
                  isTextFieldEnabled = value != 'Tất cả';

                  if (searchType == "Tất cả" && searchController.text.isNotEmpty) {
                    searchController.clear();
                    loadPaperRequirements();
                  }
                });
              },
              controller: searchController,
              textFieldEnabled: isTextFieldEnabled,
              buttonColor: themeController.buttonColor,
              onSearch: searchRequirement,
            ),

            const SizedBox(width: 16),

            // Dropdown chọn máy bên phải
            buildDropdownItems(
              value: machine,
              items: const ['Máy 1350', "Máy 1900", "Máy 2 Lớp", "Máy Quấn Cuồn"],
              onChanged: (value) {
                setState(() {
                  machine = value!;
                  _selectedRequirementIdsNotifier.value = [];
                  selectedPaperLayers = [];
                  loadPaperRequirements();
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 4),

        //pill tab ghepKho
        _buildSummaryByGhepKhoSection(),
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
                      headerRowHeight: 42,
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

  // pill tab hiển thị tổng hợp theo Ghép Khổ
  Widget _buildSummaryByGhepKhoSection() {
    return FutureBuilder(
      future: futureRequirements,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data;

        double totalRequiredQty = 0;
        double totalPrice = 0;
        int totalRecords = 0;
        List<PaperRequirementGhepKhoSummary> summaryList = [];

        if (snapshot.hasData && data != null) {
          totalRequiredQty = double.tryParse(data['totalRequiredQty']?.toString() ?? "") ?? 0.0;
          totalPrice = double.tryParse(data['totalPrice']?.toString() ?? "") ?? 0.0;
          totalRecords = int.tryParse(data['totalRecords']?.toString() ?? "") ?? 0;

          _lastPaperRequired = totalRequiredQty;
          _lastTotalPrice = totalPrice;

          final rawSummary = data['summaryByGhepKho'] as List?;
          if (rawSummary != null) {
            summaryList =
                rawSummary
                    .map((e) => PaperRequirementGhepKhoSummary.fromJson(e as Map<String, dynamic>))
                    .toList();

            summaryList.sort((a, b) {
              final valA = double.tryParse(a.ghepKho.toString()) ?? 0;
              final valB = double.tryParse(b.ghepKho.toString()) ?? 0;
              return valA.compareTo(valB);
            });
          }
        }

        final primaryColor = Colors.blue.shade600;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isLoading ? 0.4 : 1.0,
          child: Scrollbar(
            controller: headerScrollController,
            child: SingleChildScrollView(
              controller: headerScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 5),
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Chip "Tất cả khổ"
                  _buildSummaryPill(
                    label: "Tất Cả",
                    count: "$totalRecords đơn",
                    qty: _lastPaperRequired,
                    price: _lastTotalPrice,
                    isSelected: searchType == "Tất cả",
                    activeColor: primaryColor,
                    onTap: () {
                      if (searchType != "Tất cả") {
                        setState(() {
                          searchType = "Tất cả";
                          isTextFieldEnabled = false;
                          searchController.clear();
                          loadPaperRequirements();
                        });
                      }
                    },
                  ),

                  // Vạch phân cách nhẹ
                  Container(
                    height: 26,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.grey.shade400,
                  ),

                  // Danh sách từng khổ
                  ...summaryList.map((item) {
                    final isCurrentSelected =
                        searchType == "Ghép Khổ" &&
                        searchController.text.trim() == item.ghepKho.toString();

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _buildSummaryPill(
                        label: "Khổ ${item.ghepKho}",
                        count: "${item.count} đơn",
                        qty: item.totalQty,
                        price: item.totalPrice,
                        isSelected: isCurrentSelected,
                        activeColor: primaryColor,
                        onTap: () {
                          setState(() {
                            if (isCurrentSelected) {
                              searchType = "Tất cả";
                              isTextFieldEnabled = false;
                              searchController.clear();
                            } else {
                              searchType = "Ghép Khổ";
                              isTextFieldEnabled = true;
                              searchController.text = item.ghepKho.toString();
                            }
                            loadPaperRequirements();
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget Pill hiển thị 1 dòng nằm ngang
  Widget _buildSummaryPill({
    required String label,
    required String count,
    required double qty,
    required double price,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final Color bgColor =
        isSelected ? activeColor.withValues(alpha: 0.12) : const Color(0xFFF8FAFC);

    final Color borderColor = isSelected ? activeColor : const Color(0xFFCBD5E1);

    final Color textColor = isSelected ? activeColor : const Color(0xFF1E293B);
    final Color subTextColor =
        isSelected ? activeColor.withValues(alpha: 0.85) : Colors.grey.shade600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: isSelected ? 1.4 : 1.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hàng 1: Tên khổ & Số đơn
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "•",
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? activeColor.withValues(alpha: 0.5) : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),

              // Hàng 2: Khối lượng (kg) & Thành tiền (đ)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Khối lượng kg
                  _buildAnimatedCounter(
                    targetValue: qty,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    "kg",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),

                  const SizedBox(width: 6),
                  Text(
                    "|",
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? activeColor.withValues(alpha: 0.4) : Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Thành tiền đ
                  _buildAnimatedCounter(
                    targetValue: price,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? activeColor : const Color(0xFF0F766E),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    "đ",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? activeColor : const Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
