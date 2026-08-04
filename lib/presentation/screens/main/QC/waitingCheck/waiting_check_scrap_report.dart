import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/scrap/scrap_report_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_scrap_report.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/sources/scrap_report_data_source.dart';
import 'package:dongtam/service/quality_control_service.dart';
import 'package:dongtam/service/scrap_report_service.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class WaitingCheckScrapReport extends StatefulWidget {
  const WaitingCheckScrapReport({super.key});

  @override
  State<WaitingCheckScrapReport> createState() => _WaitingCheckScrapReportState();
}

class _WaitingCheckScrapReportState extends State<WaitingCheckScrapReport> {
  late Future<Map<String, dynamic>> futureScrap;
  late ScrapReportDataSource scrapReportDatasource;
  late List<GridColumn> columns;

  //controller
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final badgesController = Get.find<BadgesController>();
  final headerScrollController = ScrollController();

  List<int> selectedScrapIds = [];
  Map<String, double> columnWidths = {}; //map header table

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Người Báo Cáo": "reportedBy",
    "Ngày Báo Cáo": "reportedAt",
  };

  //filter by machine & status
  String machine = "Máy 1350";

  String filterType = "pending";
  final Map<String, String> filterOptions = {
    "pending": "Chờ Kiểm Tra",
    "confirmed": "Đã Xác Nhận",
    "allocated": "Đã Phân Bổ",
  };

  //text controller
  final searchController = TextEditingController();
  final reasonController = TextEditingController();

  //date range
  DateTime? startDate;
  DateTime? endDate;

  //flag
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

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

  void _fetchData() {
    final String keyword = searchController.text.trim().toLowerCase();
    final String selectedField = searchFieldMap[searchType] ?? "";

    // Điều kiện để xác định có thực hiện search hay load mặc định
    final bool shouldSearch = (searchType != "Tất cả");
    final bool isDateSearch = searchType == "Ngày Báo Cáo";

    futureScrap = ensureMinLoading(
      ScrapReportService().getAllScrapReports(
        page: currentPage,
        pageSize: pageSize,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? keyword : null,
        startDate: (shouldSearch && isDateSearch) ? startDate : null,
        endDate: (shouldSearch && isDateSearch) ? endDate : null,
        status: filterType,
        machine: machine,
      ),
    );

    selectedScrapIds.clear();
  }

  void loadScrapReports() {
    setState(() => _fetchData());
  }

  void searchScrapReports() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchScrapReports: searchType=$searchType, keyword='$keyword'");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchScrapReports: search bị bỏ qua vì keyword trống");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");
      _fetchData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    reasonController.dispose();
    headerScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.backgroundColor.value, // Nền xám nhạt giúp bảng nổi bật
      body: Column(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadScrapReports(),
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
          "BÁO CÁO PHẾ LIỆU CHỜ KIỂM TRA",
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //left button
                      const SizedBox(), const SizedBox(width: 20),

                      //right button
                      Row(
                        children: [
                          // allocate
                          AnimatedButton(
                            onPressed: () async {
                              try {
                                if (selectedScrapIds.isEmpty) {
                                  showSnackBarError(context, "Chưa chọn dòng để phân bổ phế liệu");
                                  return;
                                }

                                bool success = await showConfirmDialog(
                                  context: context,
                                  title: "Phân bổ báo cáo phế liệu",
                                  content: "Xác nhận phân bổ các báo cáo phế liệu đã chọn không?",
                                  confirmText: "Phân bổ",
                                );

                                if (success) {
                                  final scrapReports = await futureScrap;
                                  final List<ScrapReportModel> scrapReportList =
                                      (scrapReports['scrapReports'] as List? ?? [])
                                          .cast<ScrapReportModel>();
                                  final selectedScrap = scrapReportList.firstWhere(
                                    (scrap) => scrap.scrapId == selectedScrapIds.first,
                                    orElse: () => throw Exception("Không tìm thấy báo cáo"),
                                  );

                                  await QualityControlService().handleUpdateScrapReport(
                                    scrapIds: selectedScrapIds,
                                    machine: machine,
                                    dayCompleted: selectedScrap.dayCompleted,
                                    shiftProduction: selectedScrap.shiftProduction,
                                    action: "ALLOCATE_SCRAP_REPORT",
                                  );

                                  if (context.mounted) {
                                    showSnackBarSuccess(
                                      context,
                                      "Phân bổ báo cáo phế liệu thành công",
                                    );

                                    loadScrapReports();
                                  }
                                }
                              } on ApiException catch (e) {
                                final errorText = switch (e.errorCode) {
                                  "INVALID_SCRAP_REPORT_STATUS" => e.message!,
                                  "MISSING_SCRAP_REPORTS_IN_BATCH" => e.message!,
                                  _ => "Có lỗi xảy ra, vui lòng thử lại",
                                };
                                if (context.mounted) showSnackBarError(context, errorText);
                              } catch (e) {
                                if (context.mounted) {
                                  showSnackBarError(context, "Đã xảy ra lỗi không mong muốn");
                                }
                              }
                            },
                            label: "Phân bổ",
                            icon: Symbols.account_tree,
                            backgroundColor: themeController.buttonColor,
                          ),
                          const SizedBox(width: 8),

                          //confirm
                          _buildScrapButton(isConfirm: true),
                          const SizedBox(width: 8),

                          //reject
                          _buildScrapButton(isConfirm: false),
                          const SizedBox(width: 8),

                          buildDropdownItems(
                            width: 160,
                            value: machine,
                            items: const ['Máy 1350', "Máy 1900", "Máy 2 Lớp", "Máy Quấn Cuồn"],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                machine = value;
                                selectedScrapIds.clear();
                                loadScrapReports();
                              });
                            },
                          ),
                          const SizedBox(width: 8),

                          //filter
                          buildDropdownItems(
                            width: 155,
                            value: filterType,
                            items: const ["pending", "confirmed", "allocated"],
                            onChanged: (value) {
                              setState(() {
                                filterType = value!;
                                selectedScrapIds.clear();
                                loadScrapReports();
                              });
                            },
                            itemLabelBuilder: (value) => filterOptions[value] ?? value,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
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
        } else if (!snapshot.hasData || snapshot.data!['scrapReports'].isEmpty) {
          return Container(
            color: themeController.backgroundColor.value,
            child: Center(
              child: Text(
                "Không có báo cáo phế liệu chờ kiểm nào",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final scrapReports = data['scrapReports'] as List<ScrapReportModel>;
        final currentPg = data['currentPage'];
        final totalPgs = data['totalPages'];

        scrapReportDatasource = ScrapReportDataSource(
          scrapReports: scrapReports,
          selectedScrapIds: selectedScrapIds,
          currentPage: currentPage,
          pageSize: pageSize,
        );

        return Column(
          children: [
            //table
            Expanded(
              child: SfDataGrid(
                controller: dataGridController,
                source: scrapReportDatasource,
                isScrollbarAlwaysShown: true,
                columnWidthMode: ColumnWidthMode.auto,
                selectionMode: SelectionMode.multiple,
                headerRowHeight: 35,
                rowHeight: 40,
                columns: ColumnWidthTable.applySavedWidths(columns: columns, widths: columnWidths),
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
                          final cell = row.getCells().firstWhere((c) => c.columnName == 'scrapId');
                          return cell.value as int;
                        }).toList();

                    // cập nhật cho datasource
                    scrapReportDatasource.selectedScrapIds = selectedScrapIds;
                    scrapReportDatasource.notifyListeners();
                  });
                },
              ),
            ),

            // Nút chuyển trang
            PaginationControls(
              currentPage: currentPg,
              totalPages: totalPgs,
              onPrevious: () {
                setState(() {
                  currentPage--;
                  loadScrapReports();
                });
              },
              onNext: () {
                setState(() {
                  currentPage++;
                  loadScrapReports();
                });
              },
              onJumpToPage: (page) {
                setState(() {
                  currentPage = page;
                  loadScrapReports();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildScrapButton({required bool isConfirm}) {
    return AnimatedButton(
      label: isConfirm ? "Xác nhận" : "Từ chối",
      icon: isConfirm ? Icons.fact_check : Icons.close,
      backgroundColor: isConfirm ? themeController.buttonColor : Colors.red.shade600,
      onPressed: () async {
        if (isConfirm) {
          // --- LOGIC XÁC NHẬN ---
          try {
            bool success = await showConfirmDialog(
              context: context,
              title: "Xác nhận báo cáo phế liệu",
              content: "Bạn có chắc chắn muốn xác nhận các báo cáo phế liệu đã chọn không?",
              confirmText: "Xác nhận",
            );

            if (success) {
              await QualityControlService().handleUpdateScrapReport(
                scrapIds: selectedScrapIds,
                action: "CONFIRM_OR_REJECT",
                status: "confirmed",
              );

              if (mounted) {
                showSnackBarSuccess(context, "Xác nhận báo cáo phế liệu thành công");

                badgesController.fetchScrapReportWaitingCheck();
                loadScrapReports();
              }
            }
          } on ApiException catch (e) {
            _codeCheckError(e);
          } catch (e) {
            if (mounted) {
              showSnackBarError(context, "Lỗi xảy ra không mong muốn");
            }
          }
        } else {
          // --- LOGIC TỪ CHỐI ---
          final formKey = GlobalKey<FormState>();
          reasonController.clear();

          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text(
                    'Nhập lý do từ chối',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  content: SizedBox(
                    width: 350,
                    height: 80,
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        controller: reasonController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Nhập lý do...',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Vui lòng nhập lý do từ chối'
                                    : null,
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy', style: TextStyle(fontSize: 16, color: Colors.black)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                      onPressed: () async {
                        try {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(context);

                            await QualityControlService().handleUpdateScrapReport(
                              scrapIds: [selectedScrapIds.first],
                              action: "CONFIRM_OR_REJECT",
                              status: "rejected",
                              rejectReason: reasonController.text,
                            );

                            if (context.mounted) {
                              showSnackBarSuccess(context, "Từ chối báo cáo phế liệu thành công");

                              badgesController.fetchScrapReportWaitingCheck();
                              loadScrapReports();

                              setState(() {
                                reasonController.clear();
                              });
                            }
                          }
                        } on ApiException catch (e) {
                          _codeCheckError(e);
                        } catch (e) {
                          if (context.mounted) {
                            showSnackBarError(context, "Lỗi xảy ra không mong muốn");
                          }
                        }
                      },
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
          );
        }
      },
    );
  }

  void _codeCheckError(ApiException e) {
    final errorText = switch (e.errorCode) {
      "INVALID_SCRAP_REPORT_STATUS" => e.message!,
      _ => "Có lỗi xảy ra, vui lòng thử lại",
    };
    if (context.mounted) showSnackBarError(context, errorText);
  }
}
