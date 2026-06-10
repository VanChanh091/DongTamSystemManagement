import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/scrap/scrap_report_model.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_scrap_report.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_scrap_report.dart';
import 'package:dongtam/presentation/sources/scrap_report_data_source.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/service/scrap_report_service.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ScrapReportPaper extends StatefulWidget {
  const ScrapReportPaper({super.key});

  @override
  State<ScrapReportPaper> createState() => _ScrapReportPaperState();
}

class _ScrapReportPaperState extends State<ScrapReportPaper> {
  late Future<List<ScrapReportModel>> futureScrap;
  late ScrapReportDataSource scrapReportDatasource;
  late List<GridColumn> columns;

  //controller
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  List<int> selectedScrapIds = [];
  Map<String, double> columnWidths = {}; //map header table

  @override
  void initState() {
    super.initState();
    loadScrapReports();

    columns = buildScrapReportColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'scrapReport', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadScrapReports() {
    setState(() {
      futureScrap = ensureMinLoading(ScrapReportService().getScrapReportWaitingCheck());
      selectedScrapIds = [];
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
                        "BÁO CÁO PHẾ LIỆU",
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // update
                                AnimatedButton(
                                  onPressed: () async {
                                    try {
                                      final data = await futureScrap;
                                      final scraps = data;
                                      final selectedScrapReport = scraps.firstWhere(
                                        (scrap) => selectedScrapIds.contains(scrap.scrapId),
                                      );

                                      if (!context.mounted) return;

                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder:
                                            (_) => ScrapReportDialog(
                                              scrapReport: selectedScrapReport,
                                              onSubmit: () => loadScrapReports(),
                                            ),
                                      );
                                    } catch (e, s) {
                                      AppLogger.e(
                                        "Lỗi không tìm thấy phiếu xuất kho",
                                        error: e,
                                        stackTrace: s,
                                      );
                                    }
                                  },
                                  label: "Sửa Báo Cáo",
                                  icon: Symbols.construction,
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
                ],
              ),
            ),

            // table
            Expanded(
              child: FutureBuilder(
                future: futureScrap,
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
                        "Không có báo cáo thanh lý nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final scrapReports = data;

                  scrapReportDatasource = ScrapReportDataSource(
                    scrapReports: scrapReports,
                    selectedScrapIds: selectedScrapIds,
                    currentPage: 1,
                    pageSize: 35,
                  );

                  return SfDataGrid(
                    controller: dataGridController,
                    source: scrapReportDatasource,
                    isScrollbarAlwaysShown: true,
                    columnWidthMode: ColumnWidthMode.auto,
                    selectionMode: SelectionMode.single,
                    headerRowHeight: 35,
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
                              "qtyForklift",
                              "qtyInventory",
                              "qtyCoreTube",
                              "qtyProduction",
                              "qtyOther",
                            ],
                            child: Obx(
                              () => formatColumn(
                                label: "Số Lượng Phế Liệu (Kg)",
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
                          tableKey: 'scrapReport',
                          columnWidths: columnWidths,
                          setState: setState,
                        ),

                    onSelectionChanged: (addedRows, removedRows) async {
                      if (addedRows.isEmpty && removedRows.isEmpty) return;

                      setState(() {
                        // Lấy selection thật sự từ controller
                        final selectedRows = dataGridController.selectedRows;

                        selectedScrapIds =
                            selectedRows.map((row) {
                              final cell = row.getCells().firstWhere(
                                (c) => c.columnName == 'scrapId',
                              );
                              return cell.value as int;
                            }).toList();

                        // cập nhật cho datasource
                        scrapReportDatasource.selectedScrapIds = selectedScrapIds;
                        scrapReportDatasource.notifyListeners();
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
        onPressed: () => loadScrapReports(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
