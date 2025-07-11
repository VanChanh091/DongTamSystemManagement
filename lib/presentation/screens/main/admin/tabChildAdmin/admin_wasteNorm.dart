import 'package:dongtam/data/models/admin/admin_wasteNorm_model.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminWasteNorm extends StatefulWidget {
  const AdminWasteNorm({super.key});

  @override
  State<AdminWasteNorm> createState() => _AdminWasteNormState();
}

class _AdminWasteNormState extends State<AdminWasteNorm> {
  late Future<List<AdminWasteNormModel>> futureAdminWasteNorm;
  int? selectedWasteNorm;
  List<int> isSelected = [];
  List<AdminWasteNormModel> updatedWasteNorms = [];
  bool selectedAll = false;

  @override
  void initState() {
    super.initState();
    loadWasteNorm();
  }

  void loadWasteNorm() {
    setState(() {
      futureAdminWasteNorm = AdminService().getAllWasteNorm();
    });
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
                SizedBox(),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      // refresh
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            futureAdminWasteNorm =
                                AdminService().getAllWasteNorm();
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

                      // update
                      ElevatedButton.icon(
                        onPressed: () async {
                          for (final item in updatedWasteNorms) {
                            await AdminService()
                                .updateWasteNorm(item.wasteNormId, {
                                  "waveCrest": item.waveCrest,
                                  "waveCrestSoft": item.waveCrestSoft,
                                  "lossInProcess": item.lossInProcess,
                                  "lossInSheetingAndSlitting":
                                      item.lossInSheetingAndSlitting,
                                  "machineName": item.machineName,
                                });
                          }

                          loadWasteNorm();

                          showSnackBarSuccess(
                            context,
                            'Đã cập nhật thành công',
                          );
                        },
                        label: Text(
                          "Lưu Thay Đổi",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Symbols.save, color: Colors.white),
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

                      //delete customers
                      ElevatedButton.icon(
                        onPressed:
                            isSelected.isNotEmpty
                                ? () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      bool isDeleting = false;

                                      return StatefulBuilder(
                                        builder: (context, setStateDialog) {
                                          return AlertDialog(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            title: Row(
                                              children: const [
                                                Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: Colors.red,
                                                  size: 30,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  "Xác nhận xoá",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            content:
                                                isDeleting
                                                    ? Row(
                                                      children: const [
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                        SizedBox(width: 12),
                                                        Text("Đang xoá..."),
                                                      ],
                                                    )
                                                    : Text(
                                                      'Bạn có chắc chắn muốn xoá?',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                            actions:
                                                isDeleting
                                                    ? []
                                                    : [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text(
                                                          "Huỷ",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              const Color(
                                                                0xffEA4346,
                                                              ),
                                                          foregroundColor:
                                                              Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                        ),
                                                        onPressed: () async {
                                                          setStateDialog(() {
                                                            isDeleting = true;
                                                          });

                                                          for (int id
                                                              in isSelected) {
                                                            await AdminService()
                                                                .deleteWasteNorm(
                                                                  id,
                                                                );
                                                          }

                                                          await Future.delayed(
                                                            const Duration(
                                                              seconds: 1,
                                                            ),
                                                          );

                                                          setState(() {
                                                            isSelected.clear();
                                                            futureAdminWasteNorm =
                                                                AdminService()
                                                                    .getAllWasteNorm();
                                                          });

                                                          Navigator.pop(
                                                            context,
                                                          );

                                                          // Optional: Show success toast
                                                          showSnackBarSuccess(
                                                            context,
                                                            'Xoá thành công',
                                                          );
                                                        },
                                                        child: const Text(
                                                          "Xoá",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                }
                                : null,
                        label: Text(
                          "Xóa",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Icons.delete, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffEA4346),
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
                    ],
                  ),
                ),
              ],
            ),
          ),

          //table
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: FutureBuilder<List<AdminWasteNormModel>>(
                future: futureAdminWasteNorm,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu'));
                  }

                  final data = snapshot.data!;
                  updatedWasteNorms = data;

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 25,
                      headingRowColor: WidgetStatePropertyAll(
                        Color(0xffcfa381),
                      ),
                      columns: [
                        DataColumn(
                          label: Theme(
                            data: Theme.of(context).copyWith(
                              checkboxTheme: CheckboxThemeData(
                                fillColor: MaterialStateProperty.resolveWith<
                                  Color
                                >((states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.red;
                                  }
                                  return Colors.white;
                                }),
                                checkColor: MaterialStateProperty.all<Color>(
                                  Colors.white,
                                ),
                                side: BorderSide(color: Colors.black, width: 1),
                              ),
                            ),
                            child: Checkbox(
                              value: selectedAll,
                              onChanged: (value) {
                                setState(() {
                                  selectedAll = value!;
                                  if (selectedAll) {
                                    isSelected =
                                        data.map((e) => e.wasteNormId).toList();
                                  } else {
                                    isSelected.clear();
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        DataColumn(label: styleText("Vô Giấy Đầu Sóng")),
                        DataColumn(label: styleText("Ra Giấy Đầu Mềm")),
                        DataColumn(label: styleText("Hao phí Quá Trình Chạy")),
                        DataColumn(label: styleText("Hao Phí Xả Tờ - Cắt Khổ")),
                        DataColumn(label: styleText("Loại Máy")),
                      ],
                      rows: List<DataRow>.generate(data.length, (index) {
                        final wasteNorm = data[index];
                        return DataRow(
                          cells: [
                            DataCell(
                              Theme(
                                data: Theme.of(context).copyWith(
                                  checkboxTheme: CheckboxThemeData(
                                    fillColor:
                                        MaterialStateProperty.resolveWith<
                                          Color
                                        >((states) {
                                          if (states.contains(
                                            MaterialState.selected,
                                          )) {
                                            return Colors.red;
                                          }
                                          return Colors.white;
                                        }),
                                    checkColor:
                                        MaterialStateProperty.all<Color>(
                                          Colors.white,
                                        ),
                                    side: BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Checkbox(
                                  value: isSelected.contains(
                                    wasteNorm.wasteNormId,
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        isSelected.add(wasteNorm.wasteNormId);
                                      } else {
                                        isSelected.remove(
                                          wasteNorm.wasteNormId,
                                        );
                                      }

                                      selectedAll =
                                          isSelected.length == data.length;
                                    });
                                  },
                                ),
                              ),
                            ),
                            DataCell(
                              styleCellAdmin(wasteNorm.waveCrest.toString(), (
                                value,
                              ) {
                                setState(() {
                                  wasteNorm.waveCrest =
                                      double.tryParse(value) ?? 0;
                                });
                              }),
                            ),
                            DataCell(
                              styleCellAdmin(
                                wasteNorm.waveCrestSoft.toString(),
                                (value) {
                                  setState(() {
                                    wasteNorm.waveCrestSoft =
                                        double.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                            DataCell(
                              styleCellAdmin(
                                wasteNorm.lossInProcess.toString(),
                                (value) {
                                  setState(() {
                                    wasteNorm.lossInProcess =
                                        double.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                            DataCell(
                              styleCellAdmin(
                                wasteNorm.lossInSheetingAndSlitting.toString(),
                                (value) {
                                  setState(() {
                                    wasteNorm.lossInSheetingAndSlitting =
                                        double.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                            DataCell(Text(wasteNorm.machineName.toString())),
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
