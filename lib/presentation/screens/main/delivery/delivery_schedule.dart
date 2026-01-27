import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/delivery/delivery_plan_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_delivery_schedule.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/sources/delivery/delivery_schedule_data_source.dart';
import 'package:dongtam/service/delivery_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DeliverySchedule extends StatefulWidget {
  const DeliverySchedule({super.key});

  @override
  State<DeliverySchedule> createState() => _DeliveryScheduleState();
}

class _DeliveryScheduleState extends State<DeliverySchedule> {
  late Future<List<DeliveryPlanModel>> futureDelivery;
  late DeliveryScheduleDataSource deliveryDatasource;
  late List<GridColumn> columns;

  final themeController = Get.find<ThemeController>();
  final userController = Get.find<UserController>();
  final dataGridController = DataGridController();
  final formatter = DateFormat('dd/MM/yyyy');

  Map<String, double> columnWidths = {};
  List<int> selectedDeliveryIds = [];

  bool isLoading = false;
  bool showGroup = true;
  int? currentDeliveryId;

  TextEditingController dayStartController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    dayStartController.text =
        "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";

    loadDeliverySchedule();

    columns = buildDeliveryScheduleColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'deliverySchedule', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  bool get _isEditable {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    try {
      final selectedDate = DateFormat('dd/MM/yyyy').parse(dayStartController.text);

      // Cho phép sửa nếu >= hôm qua
      return !selectedDate.isBefore(yesterday);
    } catch (e) {
      return false;
    }
  }

  void loadDeliverySchedule() {
    setState(() {
      final parsedDate = formatter.parse(dayStartController.text);
      futureDelivery = ensureMinLoading(
        DeliveryService().getScheduleDelivery(deliveryDate: parsedDate),
      );

      selectedDeliveryIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDelivery =
        _isEditable && userController.hasAnyPermission(permission: ["delivery", 'plan']);

    return Scaffold(
      body: Container(
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
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: Row(
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
                                      final parsedDate = formatter.parse(dayStartController.text);

                                      final file = await DeliveryService().exportExcelCustomer(
                                        deliveryDate: parsedDate,
                                      );

                                      if (file != null && context.mounted) {
                                        showSnackBarSuccess(context, "Xuất file thành công");
                                      } else if (context.mounted) {
                                        showSnackBarError(context, "Xuất file thất bại");
                                      }
                                    }
                                  },
                                  label: "Xuất File",
                                  icon: Symbols.export_notes,
                                  backgroundColor: themeController.buttonColor,
                                ),
                                const SizedBox(width: 10),

                                //complete
                                AnimatedButton(
                                  onPressed:
                                      isDelivery
                                          ? () async {
                                            await handleDeliveryAction(
                                              context: context,
                                              deliveryId: currentDeliveryId!,
                                              selectedItemIds: selectedDeliveryIds,
                                              action: "complete",
                                              title: "Xác Nhận Hoàn Thành Giao Hàng",
                                              content: "Hoàn thành các kế hoạch giao hàng đã chọn?",
                                              successMessage: "Hoàn thành giao hàng thành công",
                                              errorMessage: "Hoàn thành giao hàng thất bại",
                                              onSuccess: () {
                                                loadDeliverySchedule();
                                              },
                                            );
                                          }
                                          : null,
                                  label: "Hoàn Thành",
                                  icon: Symbols.check,
                                  backgroundColor:
                                      _isEditable ? themeController.buttonColor : Colors.grey,
                                ),
                                const SizedBox(width: 10),

                                //cancel
                                AnimatedButton(
                                  onPressed:
                                      isDelivery
                                          ? () async {
                                            await handleDeliveryAction(
                                              context: context,
                                              deliveryId: currentDeliveryId!,
                                              selectedItemIds: selectedDeliveryIds,
                                              action: "cancel",
                                              title: "Xác Nhận Hủy Giao Hàng",
                                              content: "Hủy các kế hoạch giao hàng đã chọn?",
                                              successMessage: "Hủy giao hàng thành công",
                                              errorMessage: "Hủy giao hàng thất bại",
                                              onSuccess: () {
                                                loadDeliverySchedule();
                                              },
                                            );
                                          }
                                          : null,
                                  label: "Hủy Giao",
                                  icon: Symbols.cancel,
                                  backgroundColor:
                                      _isEditable ? const Color(0xffEA4346) : Colors.grey,
                                ),
                                const SizedBox(width: 10),
                              ],
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

                  final List<DeliveryPlanModel> data = snapshot.data!;

                  currentDeliveryId ??= data.first.deliveryId;

                  deliveryDatasource = DeliveryScheduleDataSource(
                    delivery: data,
                    selectedDeliveryId: selectedDeliveryIds,
                  );

                  return SfDataGrid(
                    controller: dataGridController,
                    source: deliveryDatasource,
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

                    //auto resize
                    allowColumnsResizing: true,
                    columnResizeMode: ColumnResizeMode.onResize,

                    onColumnResizeStart: GridResizeHelper.onResizeStart,
                    onColumnResizeUpdate:
                        (details) => GridResizeHelper.onResizeUpdate(
                          details: details,
                          columns: columns,
                          setState: setState,
                        ),
                    onColumnResizeEnd:
                        (details) => GridResizeHelper.onResizeEnd(
                          details: details,
                          tableKey: 'deliverySchedule',
                          columnWidths: columnWidths,
                          setState: setState,
                        ),

                    onSelectionChanged: (addedRows, removedRows) {
                      if (addedRows.isEmpty && removedRows.isEmpty) return;

                      setState(() {
                        // Lấy selection thật sự từ controller
                        final selectedRows = dataGridController.selectedRows;

                        selectedDeliveryIds =
                            selectedRows.map((row) {
                              return row
                                      .getCells()
                                      .firstWhere((cell) => cell.columnName == 'deliveryItemId')
                                      .value
                                  as int;
                            }).toList();

                        // cập nhật cho datasource
                        deliveryDatasource.selectedDeliveryId = selectedDeliveryIds;
                        deliveryDatasource.notifyListeners();
                      });
                    },
                  );
                },
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

    bool confirm = await showConfirmDialog(
      context: context,
      title: title,
      content: content,
      confirmText: "Xác Nhận",
    );

    if (confirm) {
      try {
        final success = await DeliveryService().updateStatusDelivery(
          deliveryId: deliveryId,
          itemIds: selectedItemIds,
          action: action,
        );

        if (!context.mounted) return;
        if (success) {
          showSnackBarSuccess(context, successMessage);
          onSuccess();
        }
      } catch (e) {
        if (!context.mounted) return;
        showSnackBarError(context, errorMessage);
      }
    }
  }
}
