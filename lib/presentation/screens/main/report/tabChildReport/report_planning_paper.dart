import 'package:dongtam/data/models/report/report_planning_paper.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_reportPaper.dart';
import 'package:dongtam/presentation/sources/report_paper_dataSource.dart';
import 'package:dongtam/service/report_planning_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/pagination_controls.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportPlanningPaper extends StatefulWidget {
  const ReportPlanningPaper({super.key});

  @override
  State<ReportPlanningPaper> createState() => _ReportPlanningPaperState();
}

class _ReportPlanningPaperState extends State<ReportPlanningPaper> {
  late Future<Map<String, dynamic>> futureReportPaper;
  late ReportPaperDatasource reportPaperDatasource;
  late List<GridColumn> columns;
  TextEditingController searchController = TextEditingController();
  String searchType = "Tất cả";
  String machine = "Máy 1350";
  int? selectedReportId;
  bool isTextFieldEnabled = false;

  int currentPage = 1;
  int pageSize = 3;
  int pageSizeSearch = 20;

  @override
  void initState() {
    super.initState();
    loadReportPaper(true);

    columns = buildReportPaperColumn();
  }

  void loadReportPaper(bool refresh) {
    setState(() {
      futureReportPaper = ReportPlanningService().getReportPaper(
        machine,
        currentPage,
        pageSize,
        refresh,
      );
    });
  }

  void searchReportPaper() {}

  void changeMachine(String selectedMachine) {
    setState(() {
      machine = selectedMachine;
      selectedReportId = null;
      loadReportPaper(true);
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
              height: 70,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //left button
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Row(
                      children: [
                        //dropdown
                        SizedBox(
                          width: 160,
                          child: DropdownButtonFormField<String>(
                            value: searchType,
                            items:
                                [
                                  'Tất cả',
                                  'Mã Đơn Hàng',
                                  'Tên KH',
                                  "Sóng",
                                  'Khổ Cấp Giấy',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                searchType = value!;
                                isTextFieldEnabled = searchType != 'Tất cả';

                                if (!isTextFieldEnabled) {
                                  searchController.clear();
                                }
                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),

                        // input
                        SizedBox(
                          width: 250,
                          height: 50,
                          child: TextField(
                            controller: searchController,
                            enabled: isTextFieldEnabled,
                            onSubmitted: (_) => searchReportPaper(),
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // find
                        AnimatedButton(
                          onPressed: () => searchReportPaper(),
                          label: "Tìm kiếm",
                          icon: Icons.search,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),

                  //right button
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Row(
                      children: [
                        //choose machine
                        SizedBox(
                          width: 175,
                          child: DropdownButtonFormField<String>(
                            value: machine,
                            items:
                                [
                                  'Máy 1350',
                                  "Máy 1900",
                                  "Máy 2 Lớp",
                                  "Máy Quấn Cuồn",
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                changeMachine(value);
                              }
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //table
            Expanded(
              child: FutureBuilder(
                future: futureReportPaper,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData ||
                      snapshot.data!['reportPapers'].isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có báo cáo nào",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final reportPapers =
                      data['reportPapers'] as List<ReportPaperModel>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  reportPaperDatasource = ReportPaperDatasource(
                    reportPapers: reportPapers,
                    selectedReportId: selectedReportId,
                  );

                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: SfDataGrid(
                          source: reportPaperDatasource,
                          columns: columns,
                          isScrollbarAlwaysShown: true,
                          allowExpandCollapseGroup: true, // Bật grouping
                          autoExpandGroups: true,
                          columnWidthMode: ColumnWidthMode.auto,
                          selectionMode: SelectionMode.single,
                          headerRowHeight: 40,
                          rowHeight: 45,
                          stackedHeaderRows: <StackedHeaderRow>[
                            StackedHeaderRow(
                              cells: [
                                StackedHeaderCell(
                                  columnNames: [
                                    'quantityOrd',
                                    'runningPlanProd',
                                    'qtyProduced',
                                    'qtyReported',
                                  ],
                                  child: formatColumn('Số Lượng'),
                                ),
                                StackedHeaderCell(
                                  columnNames: [
                                    'bottom',
                                    'fluteE',
                                    'fluteB',
                                    'fluteC',
                                    'knife',
                                    'totalLoss',
                                  ],
                                  child: formatColumn('Định Mức Phế Liệu'),
                                ),
                                StackedHeaderCell(
                                  columnNames: [
                                    'inMatTruoc',
                                    'inMatSau',
                                    'canLanBox',
                                    'canMang',
                                    'xa',
                                    'catKhe',
                                    'be',
                                    'dan_1_Manh',
                                    'dan_2_Manh',
                                    'dongGhimMotManh',
                                    'dongGhimHaiManh',
                                    'chongTham',
                                    'dongGoi',
                                    'maKhuon',
                                  ],
                                  child: formatColumn('Công Đoạn 2'),
                                ),
                              ],
                            ),
                          ],
                          onSelectionChanged: (addedRows, removedRows) {
                            if (addedRows.isNotEmpty) {
                              final selectedRow = addedRows.first;
                              final reportPaperId =
                                  selectedRow
                                      .getCells()
                                      .firstWhere(
                                        (cell) =>
                                            cell.columnName == 'reportPaperId',
                                      )
                                      .value
                                      .toString();

                              final selectedReport = reportPapers.firstWhere(
                                (report) =>
                                    report.reportPaperId.toString() ==
                                    reportPaperId,
                              );

                              setState(() {
                                selectedReportId = selectedReport.reportPaperId;
                              });
                            } else {
                              setState(() {
                                selectedReportId = null;
                              });
                            }
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
                            loadReportPaper(false);
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadReportPaper(false);
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadReportPaper(true),
        backgroundColor: Color(0xff78D761),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
