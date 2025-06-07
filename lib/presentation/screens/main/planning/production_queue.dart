import 'package:dongtam/data/models/planning/planning_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_machine.dart';
import 'package:dongtam/presentation/sources/machine_DataSource.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProductionQueue extends StatefulWidget {
  const ProductionQueue({super.key});

  @override
  State<ProductionQueue> createState() => _ProductionQueueState();
}

class _ProductionQueueState extends State<ProductionQueue> {
  late Future<List<Planning>> futurePlanning;
  late MachineDatasource machineDatasource;
  TextEditingController searchController = TextEditingController();
  String searchType = "Tất cả";
  String machine = "Máy 1350";
  String? selectedPlanningId;
  int? selectedRowIndex;
  bool isTextFieldEnabled = false;
  final formatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    loadPlanning();
  }

  void loadPlanning() {
    setState(() {
      futurePlanning = PlanningService().getPlanningByMachine(machine);
    });
  }

  void searchPlanning() {}

  void changeMachine(String selected) {
    setState(() {
      machine = selected;
      loadPlanning();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(5),
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
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: searchType,
                          items:
                              ['Tất cả', "Theo Mã", "Theo Tên SP"].map((
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
                          onSubmitted: (_) => searchPlanning(),
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
                      ElevatedButton.icon(
                        onPressed: () {
                          searchPlanning();
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
                        onPressed: () {
                          setState(() {
                            loadPlanning();
                          });
                        },
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

                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      // print pdf
                      ElevatedButton.icon(
                        onPressed: () {},
                        label: Text(
                          "Xuất pdf",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Symbols.print, color: Colors.white),
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

                      //choose machine
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: machine,
                          items:
                              ['Máy 1350', "Máy 1900", "Máy 2 Lớp"].map((
                                String value,
                              ) {
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

                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_upward),
                            onPressed:
                                selectedRowIndex != null &&
                                        selectedRowIndex! > 0
                                    ? () {
                                      setState(() {
                                        machineDatasource.moveRowUp(
                                          selectedRowIndex!,
                                        );
                                        selectedRowIndex =
                                            selectedRowIndex! - 1;
                                      });
                                    }
                                    : null,
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_downward),
                            onPressed:
                                selectedRowIndex != null &&
                                        selectedRowIndex! <
                                            machineDatasource.planning.length -
                                                1
                                    ? () {
                                      setState(() {
                                        machineDatasource.moveRowDown(
                                          selectedRowIndex!,
                                        );
                                        selectedRowIndex =
                                            selectedRowIndex! + 1;
                                      });
                                    }
                                    : null,
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
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
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Không có đơn hàng nào"));
                }

                final List<Planning> data = snapshot.data!;

                machineDatasource = MachineDatasource(
                  planning: data,
                  selectedPlanningId: selectedPlanningId,
                );

                return SfDataGrid(
                  source: machineDatasource,
                  columns: buildMachineColumns(),
                  isScrollbarAlwaysShown: true,
                  columnResizeMode: ColumnResizeMode.onResize,
                  columnWidthMode: ColumnWidthMode.auto,
                  navigationMode: GridNavigationMode.row,
                  selectionMode: SelectionMode.multiple,
                  onSelectionChanged: (addedRows, removedRows) {
                    if (addedRows.isNotEmpty) {
                      final selectedRow = addedRows.first;

                      final orderId =
                          selectedRow.getCells()[0].value.toString();
                      final selectedIndex = data.indexWhere(
                        (p) => p.orderId == orderId,
                      );

                      setState(() {
                        selectedPlanningId = orderId;
                        selectedRowIndex = selectedIndex;
                      });
                    } else {
                      setState(() {
                        selectedPlanningId = null;
                      });
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget styleText(String text) {
  return Text(text, style: TextStyle(fontWeight: FontWeight.bold));
}

Widget styleCell(double? width, String text) {
  return SizedBox(width: width, child: Text(text, maxLines: 3));
}
