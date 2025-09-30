import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/admin/admin_waste_norm_model.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminWasteNorm extends StatefulWidget {
  const AdminWasteNorm({super.key});

  @override
  State<AdminWasteNorm> createState() => _AdminWasteNormState();
}

class _AdminWasteNormState extends State<AdminWasteNorm> {
  late Future<List<AdminWasteNormModel>> futureAdminWasteNorm;
  final userController = Get.find<UserController>();
  int? selectedWasteNorm;
  List<int> isSelected = [];
  List<AdminWasteNormModel> updatedWasteNorms = [];
  bool selectedAll = false;

  @override
  void initState() {
    super.initState();

    if (userController.hasAnyRole(["admin"])) {
      loadWasteNorm();
    } else {
      futureAdminWasteNorm = Future.error("NO_PERMISSION");
    }
  }

  void loadWasteNorm() {
    setState(() {
      futureAdminWasteNorm = AdminService().getAllWasteNorm();
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
              height: 90,
              width: double.infinity,
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "ĐỊNH MỨC PHẾ LIỆU GIẤY",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color(0xffcfa381),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
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
                                              updatedWasteNorms
                                                  .where(
                                                    (item) =>
                                                        isSelected.contains(
                                                          item.wasteNormId,
                                                        ),
                                                  )
                                                  .toList();

                                          for (final item in dataToUpdate) {
                                            // print(
                                            //   '⏫ Updating wasteNormId: ${item.wasteNormId}',
                                            // );

                                            await AdminService().updateWasteNorm(
                                              item.wasteNormId,
                                              {
                                                "waveCrest": item.waveCrest,
                                                "waveCrestSoft":
                                                    item.waveCrestSoft,
                                                "lossInProcess":
                                                    item.lossInProcess,
                                                "lossInSheetingAndSlitting":
                                                    item.lossInSheetingAndSlitting,
                                                "machineName": item.machineName,
                                              },
                                            );
                                          }

                                          if (!context.mounted) return;

                                          loadWasteNorm();

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
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                  size: 30,
                                                                ),
                                                                SizedBox(
                                                                  width: 8,
                                                                ),
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
                                                                          width:
                                                                              12,
                                                                        ),
                                                                        Text(
                                                                          "Đang xoá...",
                                                                        ),
                                                                      ],
                                                                    )
                                                                    : const Text(
                                                                      'Bạn có chắc chắn muốn xoá?',
                                                                      style: TextStyle(
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
                                                                                FontWeight.bold,
                                                                            color:
                                                                                Colors.black54,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                          backgroundColor: const Color(
                                                                            0xffEA4346,
                                                                          ),
                                                                          foregroundColor:
                                                                              Colors.white,
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              8,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        onPressed: () async {
                                                                          setStateDialog(() {
                                                                            isDeleting =
                                                                                true;
                                                                          });

                                                                          for (int
                                                                              id
                                                                              in isSelected) {
                                                                            await AdminService().deleteWasteNorm(
                                                                              id,
                                                                            );
                                                                          }

                                                                          await Future.delayed(
                                                                            const Duration(
                                                                              seconds:
                                                                                  1,
                                                                            ),
                                                                          );

                                                                          if (!context
                                                                              .mounted) {
                                                                            return;
                                                                          }

                                                                          setState(() {
                                                                            isSelected.clear();
                                                                            futureAdminWasteNorm =
                                                                                AdminService().getAllWasteNorm();
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
                                        label: "Xóa",
                                        icon: Icons.delete,
                                        backgroundColor: const Color(
                                          0xffEA4346,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                            : const SizedBox.shrink(),
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
                    updatedWasteNorms = data;

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
                                  fillColor: WidgetStateProperty.resolveWith<
                                    Color
                                  >((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return Colors.red;
                                    }
                                    return Colors.white;
                                  }),
                                  checkColor: WidgetStateProperty.all<Color>(
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
                                              .map((e) => e.wasteNormId)
                                              .toList();
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
                          DataColumn(
                            label: styleText("Hao phí Quá Trình Chạy"),
                          ),
                          DataColumn(
                            label: styleText("Hao Phí Xả Tờ - Chia Khổ"),
                          ),
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
                                          WidgetStateProperty.resolveWith<
                                            Color
                                          >((states) {
                                            if (states.contains(
                                              WidgetState.selected,
                                            )) {
                                              return Colors.red;
                                            }
                                            return Colors.white;
                                          }),
                                      checkColor:
                                          WidgetStateProperty.all<Color>(
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
                                styleCellAdmin(
                                  '${wasteNorm.waveCrest.toString()}m',
                                  (value) {
                                    setState(() {
                                      wasteNorm.waveCrest =
                                          double.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  '${wasteNorm.waveCrestSoft.toString()}m',
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
                                  '${wasteNorm.lossInProcess.toString()}%',
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
                                  '${wasteNorm.lossInSheetingAndSlitting.toString()}m',
                                  (value) {
                                    setState(() {
                                      wasteNorm.lossInSheetingAndSlitting =
                                          double.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  wasteNorm.machineName.toString(),
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
                onPressed: loadWasteNorm,
                backgroundColor: const Color(0xff78D761),
                child: const Icon(Icons.refresh, color: Colors.white),
              )
              : null,
    );
  }
}
