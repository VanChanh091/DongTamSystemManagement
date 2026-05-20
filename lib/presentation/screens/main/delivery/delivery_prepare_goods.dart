import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/delivery/delivery_item_model.dart';
import 'package:dongtam/data/models/delivery/delivery_schedule_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_temp_item.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_outbound.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_delivery_schedule.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/sources/delivery/delivery_schedule_data_source.dart';
import 'package:dongtam/service/delivery_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/socket/socket_service.dart';
import 'package:dongtam/utils/extension/extension_helper.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/socket/init_socket_prepare_goods.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DeliveryPrepareGoods extends StatefulWidget {
  const DeliveryPrepareGoods({super.key});

  @override
  State<DeliveryPrepareGoods> createState() => _DeliveryPrepareGoodsState();
}

class _DeliveryPrepareGoodsState extends State<DeliveryPrepareGoods> {
  late Future<List<DeliveryScheduleModel>> futureDelivery;
  late DeliveryScheduleDataSource deliveryDatasource;
  late InitSocketPrepareGoods _initSocket;
  late List<GridColumn> columns;

  final socketService = SocketService();
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final badgesController = Get.find<BadgesController>();
  final formatter = DateFormat('dd/MM/yyyy');

  List<OutboundTempItem>? initialItems;

  Map<String, double> columnWidths = {};
  List<int> selectedDeliveryIds = [];

  bool isLoading = false;
  bool showGroup = true;
  int? currentDeliveryId;

  TextEditingController dayStartController = TextEditingController();
  TextEditingController employeeCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _initSocket = InitSocketPrepareGoods(
      context: context,
      socketService: socketService,
      onLoadData: loadDeliveryPrepareGoods,
    );

    _initSocket.registerSocket();

    final now = DateTime.now();
    dayStartController.text =
        "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";

    loadDeliveryPrepareGoods();

    columns = buildDeliveryScheduleColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'DeliveryPrepareGoods', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadDeliveryPrepareGoods() {
    setState(() {
      final parsedDate = formatter.parse(dayStartController.text);

      futureDelivery = ensureMinLoading(
        DeliveryService().getRequestPrepareGoods(deliveryDate: parsedDate),
      );

      selectedDeliveryIds.clear();
    });
  }

  @override
  void dispose() {
    _initSocket.stop();
    dayStartController.dispose();
    employeeCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        "LỆNH XUẤT HÀNG",
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

                                      loadDeliveryPrepareGoods();
                                    }
                                  },
                                ),
                                const SizedBox(width: 15),

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
                                                      plan.deliveryItems ?? <DeliveryItemModel>[],
                                                )
                                                .toList();
                                        final selectedItems =
                                            allItems
                                                .where(
                                                  (item) => selectedDeliveryIds.contains(
                                                    item.deliveryItemId,
                                                  ),
                                                )
                                                .toList();

                                        initialItems =
                                            selectedItems
                                                .map(
                                                  (item) =>
                                                      OutboundTempItem.fromDeliveryItemModel(item),
                                                )
                                                .toList();
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        showSnackBarError(context, "Lấy dữ liệu xuất kho thất bại");
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
                                              loadDeliveryPrepareGoods();
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

                                //complete
                                AnimatedButton(
                                  onPressed:
                                      selectedDeliveryIds.length == 1
                                          ? () async {
                                            employeeCodeController.clear();

                                            await showInputQtyDialog(
                                              context: context,
                                              title: "Xác nhận hoàn tất",
                                              onConfirm: () async {
                                                try {
                                                  final success = await DeliveryService()
                                                      .requestOrPrepareGoods(
                                                        deliveryItemId: selectedDeliveryIds.first,
                                                        isRequest: false,
                                                        empCode:
                                                            'DTGH-${employeeCodeController.trimmed}',
                                                      );

                                                  if (success) {
                                                    if (context.mounted) {
                                                      showSnackBarSuccess(
                                                        context,
                                                        "Đã hoàn thành chuẩn bị hàng",
                                                      );
                                                    }

                                                    badgesController.fetchPrepareGoods();

                                                    loadDeliveryPrepareGoods();
                                                    return true;
                                                  }
                                                  return false;
                                                } on ApiException catch (e) {
                                                  final errorText = switch (e.errorCode) {
                                                    'EMPLOYEE_NOT_FOUND' => e.message!,
                                                    _ => 'Có lỗi xảy ra, vui lòng thử lại',
                                                  };

                                                  if (context.mounted) {
                                                    showSnackBarError(context, errorText);
                                                  }
                                                  return false;
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    showSnackBarError(
                                                      context,
                                                      "Chuẩn bị hàng thất bại",
                                                    );
                                                  }
                                                  return false;
                                                }
                                              },
                                            );
                                          }
                                          : null,
                                  label: "Hoàn Tất",
                                  icon: Symbols.check,
                                  backgroundColor:
                                      selectedDeliveryIds.length == 1
                                          ? themeController.buttonColor
                                          : Colors.grey,
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

                  final List<DeliveryScheduleModel> data = snapshot.data!;

                  currentDeliveryId ??= data.first.deliveryId;

                  deliveryDatasource = DeliveryScheduleDataSource(
                    delivery: data,
                    selectedDeliveryId: selectedDeliveryIds,
                    showGroup: true,
                    page: 'prepare',
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
                    headerRowHeight: 30,
                    rowHeight: 37,
                    columns: ColumnWidthTable.applySavedWidths(
                      columns: columns,
                      widths: columnWidths,
                    ),
                    stackedHeaderRows: <StackedHeaderRow>[
                      StackedHeaderRow(
                        cells: [
                          StackedHeaderCell(
                            columnNames: ["qtyRegistered", "qtyOutbound"],
                            child: Obx(
                              () =>
                                  formatColumn(label: 'Số Lượng', themeController: themeController),
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
                          setState: setState,
                        ),
                    onColumnResizeEnd:
                        (details) => GridResizeHelper.onResizeEnd(
                          details: details,
                          tableKey: 'DeliveryPrepareGoods',
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
          onPressed: () => loadDeliveryPrepareGoods(),
          backgroundColor: themeController.buttonColor.value,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }

  Future<bool?> showInputQtyDialog({
    required BuildContext context,
    required String title,
    required Future<bool> Function() onConfirm,
  }) async {
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              content: SizedBox(
                width: 350,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: employeeCodeController,
                        decoration: const InputDecoration(
                          labelText: "Nhập mã nhân viên",
                          labelStyle: TextStyle(fontSize: 15),
                          prefixText: "DTGH-",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Không được để trống";
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    "Hủy",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffEA4346),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              final success = await onConfirm();
                              if (context.mounted) {
                                if (success) {
                                  Navigator.pop(context, true);
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            }
                          },
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                          : const Text(
                            'Xác nhận',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
