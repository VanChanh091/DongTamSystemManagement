import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/admin/admin_machine_paper_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_machine_paper.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/sources/machine_paper_data_source.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class AdminMachinePaper extends StatefulWidget {
  const AdminMachinePaper({super.key});

  @override
  State<AdminMachinePaper> createState() => _AdminMachinePaperState();
}

class _AdminMachinePaperState extends State<AdminMachinePaper> {
  late Future<List<AdminMachinePaperModel>> futureMachinePaper;
  MachinePaperDataSource? machineDatasource;
  late List<GridColumn> columns;

  //controller
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  List<int> selectedPaperIds = [];
  Map<String, double> columnWidths = {}; //map header table

  @override
  void initState() {
    super.initState();
    loadMachinePaper();

    columns = buildMachinePaperColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'machinePaper', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadMachinePaper() {
    machineDatasource = null;
    setState(() {
      futureMachinePaper = ensureMinLoading(AdminService().getMachinePapers());
      selectedPaperIds.clear();
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
                        "THỜI GIAN VÀ TỐC ĐỘ MÁY SÓNG",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: themeController.currentColor.value,
                        ),
                      ),
                    ),
                  ),

                  //button
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 70,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //left button
                          Expanded(flex: 1, child: SizedBox()),

                          //right button
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedButton(
                                    onPressed: () async {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      await Future.delayed(const Duration(milliseconds: 100));

                                      if (selectedPaperIds.isEmpty) {
                                        if (context.mounted) {
                                          showSnackBarError(
                                            context,
                                            "Chưa chọn thông tin cần cập nhật",
                                          );
                                          return;
                                        }
                                      }

                                      final dataToUpdate =
                                          machineDatasource!.machinePapers
                                              .where(
                                                (item) => selectedPaperIds.contains(item.machineId),
                                              )
                                              .toList();

                                      for (final item in dataToUpdate) {
                                        await AdminService().updateMachinePaper(
                                          machineId: item.machineId,
                                          machineUpdate: item.toJson(),
                                        );
                                      }

                                      loadMachinePaper();

                                      if (!context.mounted) return;
                                      showSnackBarSuccess(context, 'Đã cập nhật thành công');
                                    },
                                    label: "Lưu Thay Đổi",
                                    icon: Symbols.save,
                                    backgroundColor: themeController.buttonColor,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // table
            Expanded(
              child: FutureBuilder(
                future: futureMachinePaper,
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
                        "Không có máy nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    );
                  }

                  final data = snapshot.data!;

                  if (machineDatasource == null) {
                    machineDatasource = MachinePaperDataSource(
                      machinePapers: data,
                      selectedPaperIds: selectedPaperIds,
                    );
                  } else {
                    machineDatasource!.selectedPaperIds = selectedPaperIds;
                  }

                  return SfDataGrid(
                    controller: dataGridController,
                    source: machineDatasource!,
                    allowEditing: true, // Bật tính năng chỉnh sửa
                    navigationMode: GridNavigationMode.cell, // chọn cell để edit
                    editingGestureType: EditingGestureType.tap, // double tap để edit
                    // showCheckboxColumn: true,
                    // checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    isScrollbarAlwaysShown: true,
                    columnWidthMode: ColumnWidthMode.fill,
                    selectionMode: SelectionMode.multiple,
                    headerRowHeight: 30,
                    rowHeight: 40,
                    columns: ColumnWidthTable.applySavedWidths(
                      columns: columns,
                      widths: columnWidths,
                    ),
                    stackedHeaderRows: <StackedHeaderRow>[
                      StackedHeaderRow(
                        cells: [
                          StackedHeaderCell(
                            columnNames: [
                              "speed2Layer",
                              "speed3Layer",
                              "speed4Layer",
                              "speed5Layer",
                              "speed6Layer",
                              "speed7Layer",
                              "machineRollPaper",
                            ],
                            child: Obx(
                              () => formatColumn(
                                label: 'Tốc Độ Máy',
                                themeController: themeController,
                              ),
                            ),
                          ),
                          StackedHeaderCell(
                            columnNames: ["changeDiffSize", "changeSameSize"],
                            child: Obx(
                              () => formatColumn(
                                label: 'Thời Gian Đổi',
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
                          tableKey: 'machinePaper',
                          columnWidths: columnWidths,
                          setState: setState,
                        ),

                    onSelectionChanged: (addedRows, removedRows) {
                      if (addedRows.isEmpty && removedRows.isEmpty) return;

                      // Lấy selection thật sự từ controller
                      final selectedRows = dataGridController.selectedRows;

                      selectedPaperIds =
                          selectedRows.map((row) {
                            final cell = row.getCells().firstWhere(
                              (c) => c.columnName == 'machineId',
                              orElse: () => const DataGridCell(columnName: 'machineId', value: 0),
                            );
                            return cell.value as int;
                          }).toList();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadMachinePaper(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
