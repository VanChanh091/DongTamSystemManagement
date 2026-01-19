import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/delivery/delivery_plan_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_delivery_schedule.dart';
import 'package:dongtam/presentation/sources/delivery/delivery_schedule_data_source.dart';
import 'package:dongtam/service/delivery_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
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

  final dataGridController = DataGridController();
  final themeController = Get.find<ThemeController>();
  final userController = Get.find<UserController>();
  final formatter = DateFormat('dd/MM/yyyy');

  Map<String, double> columnWidths = {};
  List<int> selectedDeliveryIds = [];

  bool isLoading = false;
  bool showGroup = true;

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
    final bool isPlan = userController.hasAnyPermission(permission: ["plan", 'sale']);

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
                                //complete
                                AnimatedButton(
                                  onPressed: () {},
                                  label: "Hoàn Thành",
                                  icon: Symbols.ac_unit,
                                ),
                                const SizedBox(width: 10),

                                //cancel
                                AnimatedButton(
                                  onPressed: () {},
                                  label: "Hủy Giao",
                                  icon: Symbols.ac_unit,
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
                    stackedHeaderRows: <StackedHeaderRow>[],

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
                                      .firstWhere((cell) => cell.columnName == 'deliveryId')
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
        () =>
            isPlan
                ? FloatingActionButton(
                  onPressed: () => loadDeliverySchedule(),
                  backgroundColor: themeController.buttonColor.value,
                  child: const Icon(Icons.refresh, color: Colors.white),
                )
                : SizedBox.shrink(),
      ),
    );
  }
}
