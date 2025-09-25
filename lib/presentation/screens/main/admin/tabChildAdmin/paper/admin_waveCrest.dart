import 'package:dongtam/data/controller/userController.dart';
import 'package:dongtam/data/models/admin/admin_waveCrest_model.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminWaveCrest extends StatefulWidget {
  const AdminWaveCrest({super.key});

  @override
  State<AdminWaveCrest> createState() => AdminWaveCrestState();
}

class AdminWaveCrestState extends State<AdminWaveCrest> {
  late Future<List<AdminWaveCrestModel>> futureAdminWaveCrest;
  final userController = Get.find<UserController>();
  int? selectedWaveCrest;
  List<int> isSelected = [];
  List<AdminWaveCrestModel> updatedWaveCrest = [];
  bool selectedAll = false;

  @override
  void initState() {
    super.initState();

    if (userController.hasAnyRole(["admin"])) {
      loadWaveCrest();
    } else {
      futureAdminWaveCrest = Future.error("NO_PERMISSION");
    }
  }

  void loadWaveCrest() {
    setState(() {
      futureAdminWaveCrest = AdminService().getAllWaveCrest();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAccept = userController.hasAnyRole(["admin"]);

    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            //button
            SizedBox(
              height: 65,
              width: double.infinity,
              child:
                  isAccept
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //left
                          const SizedBox(),

                          //right
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                            child: Row(
                              children: [
                                // update
                                AnimatedButton(
                                  onPressed: () async {
                                    if (isSelected.isEmpty) {
                                      showSnackBarError(
                                        context,
                                        "Chưa chọn thông tin cần cập nhật",
                                      );
                                      return;
                                    }

                                    final dataToUpdate =
                                        updatedWaveCrest
                                            .where(
                                              (item) => isSelected.contains(
                                                item.waveCrestCoefficientId,
                                              ),
                                            )
                                            .toList();

                                    for (final item in dataToUpdate) {
                                      print(
                                        '⏫ Updating waveCrestId: ${item.waveCrestCoefficientId}',
                                      );

                                      await AdminService().updateWaveCrest(
                                        item.waveCrestCoefficientId,
                                        {
                                          "fluteE_1": item.fluteE_1,
                                          "fluteE_2": item.fluteE_2,
                                          "fluteB": item.fluteB,
                                          "fluteC": item.fluteC,
                                          "machineName": item.machineName,
                                        },
                                      );
                                    }
                                    loadWaveCrest();
                                    showSnackBarSuccess(
                                      context,
                                      'Đã cập nhật thành công',
                                    );
                                  },
                                  label: "Lưu Thay Đổi",
                                  icon: Symbols.save,
                                ),
                                const SizedBox(width: 10),

                                //delete customers
                                AnimatedButton(
                                  onPressed:
                                      isSelected.isNotEmpty
                                          ? () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                bool isDeleting = false;

                                                return StatefulBuilder(
                                                  builder: (
                                                    context,
                                                    setStateDialog,
                                                  ) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                      title: const Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .warning_amber_rounded,
                                                            color: Colors.red,
                                                            size: 30,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            "Xác nhận xoá",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      content:
                                                          isDeleting
                                                              ? const Row(
                                                                children: [
                                                                  CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 12,
                                                                  ),
                                                                  Text(
                                                                    "Đang xoá...",
                                                                  ),
                                                                ],
                                                              )
                                                              : const Text(
                                                                'Bạn có chắc chắn muốn xoá?',
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          16,
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
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          Colors
                                                                              .black54,
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
                                                                        Colors
                                                                            .white,
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            8,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onPressed: () async {
                                                                    setStateDialog(
                                                                      () {
                                                                        isDeleting =
                                                                            true;
                                                                      },
                                                                    );

                                                                    for (int id
                                                                        in isSelected) {
                                                                      await AdminService()
                                                                          .deleteWaveCrest(
                                                                            id,
                                                                          );
                                                                    }

                                                                    await Future.delayed(
                                                                      const Duration(
                                                                        seconds:
                                                                            1,
                                                                      ),
                                                                    );

                                                                    setState(() {
                                                                      isSelected
                                                                          .clear();
                                                                      futureAdminWaveCrest =
                                                                          AdminService()
                                                                              .getAllWaveCrest();
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
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
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
                                  label: "Xóa",
                                  icon: Icons.delete,
                                  backgroundColor: Color(0xffEA4346),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                      : const SizedBox.shrink(),
            ),

            //table
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: FutureBuilder<List<AdminWaveCrestModel>>(
                  future: futureAdminWaveCrest,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      if (snapshot.error.toString().contains("NO_PERMISSION")) {
                        return const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: Colors.redAccent,
                                size: 35,
                              ),
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      );
                    }

                    final data = snapshot.data!;
                    updatedWaveCrest = data;

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 25,
                        headingRowColor: const WidgetStatePropertyAll(
                          Color(0xffcfa381),
                        ),
                        columns: [
                          DataColumn(
                            label: Theme(
                              data: Theme.of(context).copyWith(
                                checkboxTheme: CheckboxThemeData(
                                  fillColor:
                                      MaterialStateProperty.resolveWith<Color>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          MaterialState.selected,
                                        )) {
                                          return Colors.red;
                                        }
                                        return Colors.white;
                                      }),
                                  checkColor: MaterialStateProperty.all<Color>(
                                    Colors.white,
                                  ),
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Checkbox(
                                value: selectedAll,
                                onChanged: (value) {
                                  setState(() {
                                    selectedAll = value!;
                                    if (selectedAll) {
                                      isSelected =
                                          data
                                              .map(
                                                (e) => e.waveCrestCoefficientId,
                                              )
                                              .toList();
                                    } else {
                                      isSelected.clear();
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          DataColumn(label: styleText("Đầu E1")),
                          DataColumn(label: styleText("Đầu E2")),
                          DataColumn(label: styleText("Đầu B")),
                          DataColumn(label: styleText("Đầu C")),
                          DataColumn(label: styleText("Loại Máy")),
                        ],
                        rows: List<DataRow>.generate(data.length, (index) {
                          final waveCrest = data[index];
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
                                      side: const BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Checkbox(
                                    value: isSelected.contains(
                                      waveCrest.waveCrestCoefficientId,
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          isSelected.add(
                                            waveCrest.waveCrestCoefficientId,
                                          );
                                        } else {
                                          isSelected.remove(
                                            waveCrest.waveCrestCoefficientId,
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
                                styleCellAdmin(waveCrest.fluteE_1.toString(), (
                                  value,
                                ) {
                                  setState(() {
                                    waveCrest.fluteE_1 =
                                        double.tryParse(value) ?? 0;
                                  });
                                }),
                              ),
                              DataCell(
                                styleCellAdmin(waveCrest.fluteE_2.toString(), (
                                  value,
                                ) {
                                  setState(() {
                                    waveCrest.fluteE_2 =
                                        double.tryParse(value) ?? 0;
                                  });
                                }),
                              ),
                              DataCell(
                                styleCellAdmin(waveCrest.fluteB.toString(), (
                                  value,
                                ) {
                                  setState(() {
                                    waveCrest.fluteB =
                                        double.tryParse(value) ?? 0;
                                  });
                                }),
                              ),
                              DataCell(
                                styleCellAdmin(waveCrest.fluteC.toString(), (
                                  value,
                                ) {
                                  setState(() {
                                    waveCrest.fluteC =
                                        double.tryParse(value) ?? 0;
                                  });
                                }),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  waveCrest.machineName.toString(),
                                  null,
                                ),
                              ),
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
      ),
      floatingActionButton:
          isAccept
              ? FloatingActionButton(
                onPressed: loadWaveCrest,
                backgroundColor: const Color(0xff78D761),
                child: const Icon(Icons.refresh, color: Colors.white),
              )
              : null,
    );
  }
}
