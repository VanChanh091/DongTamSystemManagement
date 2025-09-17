import 'package:dongtam/data/models/report/report_planning_box.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_reportBox.dart';
import 'package:dongtam/presentation/sources/report_box_datasource.dart';
import 'package:dongtam/service/report_planning_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/pagination_controls.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportPlanningBox extends StatefulWidget {
  const ReportPlanningBox({super.key});

  @override
  State<ReportPlanningBox> createState() => _ReportPlanningBoxState();
}

class _ReportPlanningBoxState extends State<ReportPlanningBox> {
  late Future<Map<String, dynamic>> futureReportBox;
  late ReportBoxDatasource reportBoxDatasource;
  late List<GridColumn> columns;
  TextEditingController searchController = TextEditingController();
  String searchType = "Tất cả";
  String machine = "Máy In";
  int? selectedReportId;
  bool isTextFieldEnabled = false;

  int currentPage = 1;
  int pageSize = 3;
  int pageSizeSearch = 20;

  @override
  void initState() {
    super.initState();
    loadReportBox(true);

    columns = buildReportBoxColumn();
  }

  void loadReportBox(bool refresh) {
    setState(() {
      futureReportBox = ReportPlanningService().getReportBox(
        machine,
        currentPage,
        pageSize,
        refresh,
      );
    });
  }

  void searchReportBox() {}

  void changeMachine(String selectedMachine) {
    setState(() {
      machine = selectedMachine;
      selectedReportId = null;
      loadReportBox(true);
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
                            onSubmitted: (_) => searchReportBox(),
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
                          onPressed: () => searchReportBox(),
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
                                  'Máy In',
                                  "Máy Bế",
                                  "Máy Xả",
                                  "Máy Dán",
                                  'Máy Cấn Lằn',
                                  "Máy Cắt Khe",
                                  "Máy Cán Màng",
                                  "Máy Đóng Ghim",
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
                future: futureReportBox,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData ||
                      snapshot.data!['reportBoxes'].isEmpty) {
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
                  final reportBoxes =
                      data['reportBoxes'] as List<ReportBoxModel>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  reportBoxDatasource = ReportBoxDatasource(
                    reportPapers: reportBoxes,
                    selectedReportId: selectedReportId,
                  );

                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: SfDataGrid(
                          source: reportBoxDatasource,
                          columns: columns,
                          isScrollbarAlwaysShown: true,
                          allowExpandCollapseGroup: true, // Bật grouping
                          autoExpandGroups: true,
                          columnWidthMode: ColumnWidthMode.auto,
                          selectionMode: SelectionMode.single,
                          headerRowHeight: 40,
                          rowHeight: 45,
                          stackedHeaderRows: <StackedHeaderRow>[
                            StackedHeaderRow(cells: [   ],
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
                                            cell.columnName == 'reportBoxId',
                                      )
                                      .value
                                      .toString();

                              final selectedReport = reportBoxes.firstWhere(
                                (report) =>
                                    report.reportBoxId.toString() ==
                                    reportPaperId,
                              );

                              setState(() {
                                selectedReportId = selectedReport.reportBoxId;
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
                            loadReportBox(false);
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadReportBox(false);
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
        onPressed: () => loadReportBox(true),
        backgroundColor: Color(0xff78D761),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
