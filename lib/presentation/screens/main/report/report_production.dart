import 'package:dongtam/data/models/report/report_production_model.dart';
import 'package:dongtam/service/report_production_service.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportProduction extends StatefulWidget {
  const ReportProduction({super.key});

  @override
  State<ReportProduction> createState() => _ReportProductionState();
}

class _ReportProductionState extends State<ReportProduction> {
  late Future<List<ReportProductionModel>> futureReportProduction;
  TextEditingController searchController = TextEditingController();
  List<String> isSelected = [];
  bool selectedAll = false;
  bool isTextFieldEnabled = false;
  String searchType = "Tất cả";
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    loadReportProduction();
  }

  void loadReportProduction() {
    setState(() {
      futureReportProduction =
          ReportProductionService().getAllReportProduction();
      isSelected.clear();
      selectedAll = false;
    });
  }

  void searchReport() {
    String keyword = searchController.text.trim().toLowerCase();

    if (searchType == "Tất cả") {
      setState(() {
        futureReportProduction =
            ReportProductionService().getAllReportProduction();
      });
    } else if (searchType == "Theo Quản Ca") {
      if (keyword.isEmpty) return;
      setState(() {
        futureReportProduction = ReportProductionService()
            .getReportByShiftManagement(keyword);
      });
    } else if (searchType == "Theo Ngày") {
      if (fromDate == null || toDate == null) {
        showSnackBarError(context, "Vui lòng chọn khoảng thời gian.");
        return;
      }
      setState(() {
        futureReportProduction = ReportProductionService()
            .getReportByDayCompleted(fromDate!, toDate!);
      });
    }
  }

  Future<void> pickDateRange() async {
    final picked = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) {
        final defaultRange = DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now(),
        );

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
            child: Material(
              elevation: 12,
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: DateRangePickerDialog(
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDateRange:
                    (fromDate != null && toDate != null)
                        ? DateTimeRange(start: fromDate!, end: toDate!)
                        : defaultRange,
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          //button
          SizedBox(
            height: 80,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //dropdown
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      //dropdown
                      SizedBox(
                        width: 170,
                        child: DropdownButtonFormField<String>(
                          value: searchType,
                          items:
                              ['Tất cả', "Theo Quản Ca", "Theo Ngày"].map((
                                String value,
                              ) {
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
                          onSubmitted: (_) => searchReport(),
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

                      // Nút chọn ngày
                      ElevatedButton.icon(
                        onPressed: pickDateRange,
                        icon: Icon(Icons.date_range, color: Colors.white),
                        label: Text(
                          fromDate != null && toDate != null
                              ? "${DateFormat('dd/MM/yyyy').format(fromDate!)} - ${DateFormat('dd/MM/yyyy').format(toDate!)}"
                              : "Chọn ngày",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff78D761),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),

                      // find
                      ElevatedButton.icon(
                        onPressed: () {
                          searchReport();
                        },
                        label: Text(
                          "Tìm kiếm",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Icons.search, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff78D761),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // refresh
                      ElevatedButton.icon(
                        onPressed: loadReportProduction,
                        label: Text(
                          "Tải lại",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Icons.refresh, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff78D761),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),

                SizedBox(),
              ],
            ),
          ),

          // table
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: FutureBuilder<List<ReportProductionModel>>(
                future: futureReportProduction,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu'));
                  }

                  final data = snapshot.data!;

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 25,
                      headingRowColor: WidgetStatePropertyAll(
                        Color(0xffcfa381),
                      ),
                      columns: [
                        DataColumn(label: styleText("Mã Đơn Hàng")),
                        DataColumn(label: styleText("Số Lượng Thực Tế")),
                        DataColumn(label: styleText('Phế Liệu Thực Tế')),
                        DataColumn(label: styleText("Ngày Hoàn Thành")),
                        DataColumn(label: styleText("Quản Ca")),
                        DataColumn(label: styleText('Ca Sản Xuất')),
                        DataColumn(label: styleText("Ghi Chú")),
                      ],
                      rows: List<DataRow>.generate(data.length, (index) {
                        final report = data[index];
                        return DataRow(
                          cells: [
                            DataCell(styleCell(report.planning!.orderId)),
                            DataCell(styleCell(report.qtyActually.toString())),
                            DataCell(styleCell(report.qtyWasteNorm.toString())),
                            DataCell(
                              styleCell(
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(report.dayCompleted),
                              ),
                            ),
                            DataCell(styleCell(report.shiftManagement)),
                            DataCell(styleCell(report.shiftProduction)),
                            DataCell(styleCell(report.note!)),
                          ],
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
