import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/presentation/components/dialog/qc/dialog_inspection_check.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_machine_box.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/sources/planning/machine_box_data_source.dart';
import 'package:dongtam/service/quality_control_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InspectionBoxCheck extends StatefulWidget {
  const InspectionBoxCheck({super.key});

  @override
  State<InspectionBoxCheck> createState() => _InspectionBoxCheckState();
}

class _InspectionBoxCheckState extends State<InspectionBoxCheck> {
  late Future<List<PlanningBox>> futurePlanning;
  late MachineBoxDatasource machineBoxDatasource;
  late List<GridColumn> columns;

  //controller
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  Map<String, double> columnWidths = {};
  List<String> selectedPlanningIds = [];
  List<PlanningBox> planningList = [];

  String machine = "Máy In";

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
      futurePlanning = ensureMinLoading(
        QualityControlService().getManufactureProducing(
          machine: machine,
          isPaper: "box",
          fromJson: (json) => PlanningBox.fromJson(json),
        ),
      );

      selectedPlanningIds.clear();
    });
  }

  void changeMachine(String selectedMachine) {
    AppLogger.i("changeMachine | from=$machine -> to=$selectedMachine");
    setState(() {
      machine = selectedMachine;
      selectedPlanningIds.clear();
      loadPlanning();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //dialog inspection check
                                  AnimatedButton(
                                    onPressed:
                                        selectedPlanningIds.isNotEmpty
                                            ? () async {
                                              try {
                                                final int selectedPlanningBoxId = int.parse(
                                                  selectedPlanningIds.first,
                                                );

                                                final selectedPlanning = planningList.firstWhere(
                                                  (p) => p.planningBoxId == selectedPlanningBoxId,
                                                  orElse:
                                                      () =>
                                                          throw Exception(
                                                            "Không tìm thấy kế hoạch",
                                                          ),
                                                );

                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (_) => DialogInspectionCheck(
                                                        isPaper: false,
                                                        machine: machine,
                                                        planningBoxId:
                                                            selectedPlanning.planningBoxId,
                                                        onSubmit: () {
                                                          loadPlanning();
                                                        },
                                                      ),
                                                );
                                              } catch (e, s) {
                                                if (selectedPlanningIds.isEmpty) {
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

                  final data = snapshot.data as List<PlanningBox>;
                  planningList = data;

                  machineBoxDatasource = MachineBoxDatasource(
                    planning: data,
                    selectedPlanningIds: selectedPlanningIds,
                    showGroup: true,
                    page: 'production',
                    machine: machine,
                  );

                  return SfDataGrid(
                    controller: dataGridController,
                    source: machineBoxDatasource,
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
                              () =>
                                  formatColumn(label: 'Số Lượng', themeController: themeController),
                            ),
                          ),
                          StackedHeaderCell(
                            columnNames: ["inMatTruoc", "inMatSau"],
                            child: Obx(
                              () => formatColumn(label: 'In Ấn', themeController: themeController),
                            ),
                          ),
                          StackedHeaderCell(
                            columnNames: ["dan_1_Manh", "dan_2_Manh"],
                            child: Obx(
                              () => formatColumn(label: 'Dán', themeController: themeController),
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
                          setState: setState,
                        ),
                    onColumnResizeEnd:
                        (details) => GridResizeHelper.onResizeEnd(
                          details: details,
                          tableKey: 'queueBox',
                          columnWidths: columnWidths,
                          setState: setState,
                        ),

                    onSelectionChanged: (addedRows, removedRows) {
                      if (addedRows.isEmpty && removedRows.isEmpty) return;

                      setState(() {
                        // Lấy selection thật sự từ controller
                        final selectedRows = dataGridController.selectedRows;

                        selectedPlanningIds =
                            selectedRows
                                .map((row) {
                                  final cell = row.getCells().firstWhere(
                                    (c) => c.columnName == 'planningBoxId',
                                    orElse:
                                        () => const DataGridCell(
                                          columnName: 'planningBoxId',
                                          value: '',
                                        ),
                                  );
                                  return cell.value.toString();
                                })
                                .where((id) => id.isNotEmpty)
                                .toList();

                        // cập nhật cho datasource
                        machineBoxDatasource.selectedPlanningIds = selectedPlanningIds;
                        machineBoxDatasource.notifyListeners();
                      });
                    },
                  );
                },
              ),
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
