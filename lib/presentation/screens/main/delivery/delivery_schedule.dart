import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/delivery/delivery_item_model.dart';
import 'package:dongtam/data/models/delivery/delivery_schedule_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_temp_item.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_outbound.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_delivery_schedule.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/delivery/delivery_schedule_data_source.dart';
import 'package:dongtam/service/delivery_service.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/socket/socket_service.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/socket/init_socket_delivery_schedule.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DeliverySchedule extends StatefulWidget {
  const DeliverySchedule({super.key});

  @override
  State<DeliverySchedule> createState() => _DeliveryScheduleState();
}

class _DeliveryScheduleState extends State<DeliverySchedule> {
  late Future<List<DeliveryScheduleModel>> futureDelivery;
  late InitSocketDeliverySchedule _initSocket;
  late List<GridColumn> columns;

  final socketService = SocketService();
  final formatter = DateFormat('dd/MM/yyyy');
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final badgesController = Get.find<BadgesController>();

  List<OutboundTempItemModel>? initialItems;

  Map<String, double> columnWidths = {};

  //notifiers
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedDeliveryIdsNotifier = ValueNotifier<List<int>>([]);
  // List<int> selectedDeliveryIds = [];

  //datasource and cache
  List<DeliveryScheduleModel>? _cachedDelivery;
  DeliveryScheduleDataSource? _cachedDatasource;

  //flag
  late bool isAdmin;
  late bool isPlan;
  late bool isDelivery;
  int? currentDeliveryId;
  String? selectedStatus;
  bool isLoading = false;
  bool showGroup = true;
  bool _cachedShowGroup = false;
  bool _isSelectionChange = false;

  //text controller
  final dayStartController = TextEditingController();
  final lisencePlateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    dayStartController.text =
        "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";

    _initSocket = InitSocketDeliverySchedule(
      context: context,
      socketService: socketService,
      onLoadData: loadDeliverySchedule,
      deliveryDate: formatter.parse(dayStartController.text),
    );

    _initSocket.registerSocket();
    loadDeliverySchedule();

    // check role and permission
    isAdmin = userController.hasAnyRole(roles: ['admin']);
    isPlan = userController.hasAnyPermission(permission: ["plan"]);
    isDelivery = userController.hasAnyPermission(permission: ["delivery", "plan"]);

    columns = buildDeliveryScheduleColumn(themeController: themeController, page: 'schedule');
    ColumnWidthTable.loadWidths(tableKey: 'deliverySchedule', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadDeliverySchedule() {
    final parsedDate = formatter.parse(dayStartController.text);
    _initSocket.changeDeliveryDate(parsedDate);

    setState(() {
      futureDelivery = ensureMinLoading(
        DeliveryService().getScheduleDelivery(deliveryDate: parsedDate),
      );

      selectedStatus = null;
      dataGridController.selectedRows = [];
      _selectedDeliveryIdsNotifier.value = [];
    });
  }

  void _updateSelectedIdsFromRows(List<DataGridRow> rows) {
    final newIds =
        rows.map((row) {
          return row.getCells().firstWhere((cell) => cell.columnName == 'deliveryItemId').value
              as int;
        }).toList();

    // Lấy status của dòng được chọn (chỉ khi chọn đúng 1 dòng)
    if (rows.length == 1) {
      selectedStatus =
          rows.first.getCells().firstWhere((cell) => cell.columnName == 'status').value as String?;
    } else {
      selectedStatus = null;
    }

    _selectedDeliveryIdsNotifier.value = newIds;
    _cachedDatasource?.selectedDeliveryId = newIds;
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    _initSocket.stop();
    dayStartController.dispose();
    lisencePlateController.dispose();
    _zoomNotifier.dispose();
    _selectedDeliveryIdsNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isActionable =
        isDelivery && selectedStatus != 'completed' && (selectedStatus != 'cancelled' || isAdmin);

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
                    //title & button
                    SizedBox(
                      height: 105,
                      width: double.infinity,
                      child: Column(
                        children: [
                          //title
                          SizedBox(
                            height: 45,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "LỊCH GIAO HÀNG",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: themeController.currentColor.value,
                                ),
                              ),
                            ),
                          ),

                          //button
                          SizedBox(
                            height: 60,
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
                                      valueListenable: _selectedDeliveryIdsNotifier,
                                      builder: (context, selectedDeliveryIds, _) {
                                        final bool hasSelection = selectedDeliveryIds.isNotEmpty;

                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            // Ngày giao
                                            buildLabelAndUnderlineInput(
                                              label: "Ngày giao:",
                                              controller: dayStartController,
                                              width: 120,
                                              readOnly: true,
                                              onTap: () async {
                                                final selected = await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2026),
                                                  lastDate: DateTime(2100),
                                                  builder: (BuildContext context, Widget? child) {
                                                    return Theme(
                                                      data: Theme.of(context).copyWith(
                                                        colorScheme: ColorScheme.light(
                                                          primary: Colors.blue,
                                                          onPrimary: Colors.white,
                                                          onSurface: Colors.black,
                                                        ),
                                                        dialogTheme: DialogThemeData(
                                                          backgroundColor: Colors.white12,
                                                        ),
                                                      ),
                                                      child: child!,
                                                    );
                                                  },
                                                );

                                                if (selected != null) {
                                                  setState(() {
                                                    dayStartController.text = DateFormat(
                                                      'dd/MM/yyyy',
                                                    ).format(selected);

                                                    selectedDeliveryIds.clear();
                                                  });

                                                  loadDeliverySchedule();
                                                }
                                              },
                                            ),
                                            const SizedBox(width: 15),

                                            //export file
                                            AnimatedButton(
                                              onPressed: () async {
                                                bool confirm = await showConfirmDialog(
                                                  context: context,
                                                  title: "Xuất Lịch Giao Hàng",
                                                  content:
                                                      "Xuất lịch giao hàng cho ngày ${dayStartController.text}?",
                                                  confirmText: "Xác Nhận",
                                                );

                                                if (confirm) {
                                                  final parsedDate = formatter.parse(
                                                    dayStartController.text,
                                                  );

                                                  final file = await DeliveryService()
                                                      .exportDeliverySchedule(
                                                        deliveryDate: parsedDate,
                                                      );

                                                  if (file != null && context.mounted) {
                                                    showSnackBarSuccess(
                                                      context,
                                                      "Xuất file thành công",
                                                    );
                                                  } else if (context.mounted) {
                                                    showSnackBarError(
                                                      context,
                                                      "Xuất file thất bại",
                                                    );
                                                  }
                                                }
                                              },
                                              label: "Xuất File",
                                              icon: Symbols.export_notes,
                                              backgroundColor: themeController.buttonColor,
                                            ),
                                            const SizedBox(width: 10),

                                            //outbound
                                            AnimatedButton(
                                              onPressed: () async {
                                                if (!context.mounted) return;

                                                if (selectedDeliveryIds.isNotEmpty) {
                                                  try {
                                                    final data = await futureDelivery;
                                                    final allItems =
                                                        data
                                                            .expand(
                                                              (plan) =>
                                                                  plan.deliveryItems ??
                                                                  <DeliveryItemModel>[],
                                                            )
                                                            .toList();
                                                    final selectedItems =
                                                        allItems
                                                            .where(
                                                              (item) => selectedDeliveryIds
                                                                  .contains(item.deliveryItemId),
                                                            )
                                                            .toList();

                                                    initialItems =
                                                        selectedItems
                                                            .map(
                                                              (item) =>
                                                                  OutboundTempItemModel.fromDeliveryItemModel(
                                                                    item,
                                                                  ),
                                                            )
                                                            .toList();
                                                  } catch (e) {
                                                    if (!context.mounted) return;
                                                    showSnackBarError(
                                                      context,
                                                      "Lấy dữ liệu xuất kho thất bại",
                                                    );
                                                    return;
                                                  }
                                                }

                                                if (!context.mounted) return;
                                                showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder:
                                                      (_) => OutBoundDialog(
                                                        outbound: null,
                                                        onOutboundHistory: () {
                                                          //cập nhật lại badge
                                                          badgesController.fetchPrepareGoods();
                                                          loadDeliverySchedule();
                                                        },
                                                        initialItems: initialItems,
                                                      ),
                                                );
                                              },

                                              label: "Xuất Kho",
                                              icon: Symbols.input,
                                              backgroundColor: themeController.buttonColor,
                                            ),
                                            const SizedBox(width: 10),

                                            //request prepare goods
                                            AnimatedButton(
                                              onPressed:
                                                  isActionable && hasSelection
                                                      ? () async {
                                                        lisencePlateController.clear();

                                                        await showInputQtyDialog(
                                                          context: context,
                                                          title: "Yêu cầu chuẩn bị hàng",
                                                          labelText: "Nhập vào biển số xe",
                                                          controller: lisencePlateController,
                                                          onConfirm: () async {
                                                            showSnackBarSuccess(
                                                              context,
                                                              "Đã gửi yêu cầu chuẩn bị hàng",
                                                            );

                                                            final success = await DeliveryService()
                                                                .requestOrPreparedGoods(
                                                                  isRequest: true,
                                                                  deliveryItemIds:
                                                                      selectedDeliveryIds,
                                                                  lisencePlate:
                                                                      lisencePlateController.text,
                                                                );

                                                            if (success) {
                                                              if (context.mounted) {
                                                                showSnackBarSuccess(
                                                                  context,
                                                                  "Đã gửi yêu cầu chuẩn bị hàng",
                                                                );

                                                                await DeliveryService()
                                                                    .notifyRequestPrepareGoods();

                                                                badgesController
                                                                    .fetchPrepareGoods();
                                                                loadDeliverySchedule();
                                                              }
                                                            }
                                                            return true;
                                                          },
                                                        );
                                                      }
                                                      : null,
                                              label: "YC Xuất Hàng",
                                              icon: Symbols.request_quote,
                                              backgroundColor:
                                                  isActionable
                                                      ? themeController.buttonColor
                                                      : Colors.grey,
                                            ),
                                            const SizedBox(width: 10),

                                            isPlan
                                                ? Row(
                                                  children: [
                                                    AnimatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          showGroup = !showGroup;
                                                        });
                                                      },
                                                      label: showGroup ? 'Tắt nhóm' : 'Bật nhóm',
                                                      icon:
                                                          showGroup
                                                              ? Symbols.ungroup
                                                              : Symbols.ad_group,
                                                      backgroundColor: themeController.buttonColor,
                                                    ),
                                                    const SizedBox(width: 10),

                                                    //complete
                                                    AnimatedButton(
                                                      onPressed:
                                                          isActionable && hasSelection
                                                              ? () async {
                                                                await handleDeliveryAction(
                                                                  context: context,
                                                                  deliveryId: currentDeliveryId!,
                                                                  selectedItemIds:
                                                                      selectedDeliveryIds,
                                                                  action: "complete",
                                                                  title:
                                                                      "Xác Nhận Hoàn Thành Giao Hàng",
                                                                  content:
                                                                      "Hoàn thành các kế hoạch giao hàng đã chọn?",
                                                                  successMessage:
                                                                      "Hoàn thành giao hàng thành công",
                                                                  errorMessage:
                                                                      "Hoàn thành giao hàng thất bại",
                                                                  onSuccess: () {
                                                                    loadDeliverySchedule();
                                                                  },
                                                                );
                                                              }
                                                              : null,
                                                      label: "Hoàn Thành",
                                                      icon: Symbols.check,
                                                      backgroundColor:
                                                          isActionable
                                                              ? themeController.buttonColor
                                                              : Colors.grey,
                                                    ),
                                                    const SizedBox(width: 10),

                                                    //cancel
                                                    AnimatedButton(
                                                      onPressed:
                                                          isActionable && hasSelection
                                                              ? () async {
                                                                await handleDeliveryAction(
                                                                  context: context,
                                                                  deliveryId: currentDeliveryId!,
                                                                  selectedItemIds:
                                                                      selectedDeliveryIds,
                                                                  action: "cancel",
                                                                  title: "Xác Nhận Hủy Giao Hàng",
                                                                  content:
                                                                      "Hủy các kế hoạch giao hàng đã chọn?",
                                                                  successMessage:
                                                                      "Hủy giao hàng thành công",
                                                                  errorMessage:
                                                                      "Hủy giao hàng thất bại",
                                                                  onSuccess: () {
                                                                    loadDeliverySchedule();
                                                                  },
                                                                );
                                                              }
                                                              : null,
                                                      label: "Hủy Giao",
                                                      icon: Symbols.cancel,
                                                      backgroundColor:
                                                          isActionable
                                                              ? const Color(0xffEA4346)
                                                              : Colors.grey,
                                                    ),
                                                    const SizedBox(width: 10),
                                                  ],
                                                )
                                                : const SizedBox.shrink(),
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
                        future: futureDelivery,
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
                            if (snapshot.error.toString().contains("NO_PERMISSION")) {
                              return const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock_outline, color: Colors.redAccent, size: 35),
                                    SizedBox(width: 8),
                                    Text(
                                      "Bạn không có quyền xem chức năng này",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Center(child: Text("Lỗi: ${snapshot.error}"));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                "Không có đơn hàng nào",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            );
                          }

                          final List<DeliveryScheduleModel> data = snapshot.data!;

                          currentDeliveryId ??= data.first.deliveryId;

                          if (_cachedDelivery == null ||
                              _cachedDelivery != data ||
                              _cachedShowGroup != showGroup) {
                            _cachedDelivery = data;
                            _cachedShowGroup = showGroup;
                            _cachedDatasource = DeliveryScheduleDataSource(
                              delivery: data,
                              selectedDeliveryId: _selectedDeliveryIdsNotifier.value,
                              showGroup: showGroup,
                              page: 'schedule',
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
                                  headerRowHeight: 30,
                                  rowHeight: 38,
                                  columns: ColumnWidthTable.applySavedWidths(
                                    columns: columns,
                                    widths: columnWidths,
                                  ),
                                  stackedHeaderRows: <StackedHeaderRow>[
                                    StackedHeaderRow(
                                      cells: [
                                        StackedHeaderCell(
                                          columnNames: [
                                            "qtyRegistered",
                                            "qtyOutbound",
                                            "qtyCustomer",
                                            "totalQtyOutbound",
                                          ],
                                          child: Obx(
                                            () => formatColumn(
                                              label: 'Số Lượng',
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
                                        tableKey: 'deliverySchedule',
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

                                    if (addedRows.isEmpty && removedRows.isEmpty) return;

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
          ],
        ),
      ),

      floatingActionButton: Obx(
        () => FloatingActionButton(
          onPressed: () => loadDeliverySchedule(),
          backgroundColor: themeController.buttonColor.value,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> handleDeliveryAction({
    required BuildContext context,
    required int deliveryId,
    required List<int> selectedItemIds,
    required String action,
    required String title,
    required String content,
    required String successMessage,
    required String errorMessage,
    required VoidCallback onSuccess,
  }) async {
    if (selectedItemIds.isEmpty) {
      showSnackBarError(context, "Chưa chọn kế hoạch cần thực hiện");
      return;
    }

    try {
      final bool confirm = await showConfirmDialog(
        context: context,
        title: title,
        content: content,
        confirmText: "Xác Nhận",
      );

      if (confirm) {
        final success = await DeliveryService().cancelOrCompleteDelivery(
          deliveryId: deliveryId,
          itemIds: selectedItemIds,
          action: action,
        );

        if (success) {
          if (context.mounted) {
            showSnackBarSuccess(context, successMessage);
            badgesController.fetchDeliveryRequest();
            onSuccess();
          }
        }
      }
    } on ApiException catch (e) {
      if (!context.mounted) return;

      switch (e.errorCode) {
        case "ITEMS_ALREADY_CANCELLED":
          showSnackBarError(context, e.message!);
          break;
        default:
          showSnackBarError(context, "Có lỗi xảy ra khi thao tác");
      }
    } catch (e) {
      if (!context.mounted) return;
      showSnackBarError(context, errorMessage);
    }
  }
}
