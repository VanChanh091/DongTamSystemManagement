import 'package:dongtam/data/models/user/user_admin_model.dart';
import 'package:dongtam/service/admin_Service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminMangeUser extends StatefulWidget {
  const AdminMangeUser({super.key});

  @override
  State<AdminMangeUser> createState() => _AdminMangeUserState();
}

class _AdminMangeUserState extends State<AdminMangeUser> {
  late Future<List<UserAdminModel>> futureUserAdmin;
  TextEditingController searchController = TextEditingController();
  List<int> selectedUserIds = [];
  bool selectedAll = false;
  bool isTextFieldEnabled = false;
  String searchType = "Tất cả";

  @override
  void initState() {
    super.initState();
    futureUserAdmin = AdminService().getAllUsers();
  }

  void searchProduct() {
    String keyword = searchController.text.trim().toLowerCase();

    if (isTextFieldEnabled && keyword.isEmpty) return;

    if (searchType == "Tất cả") {
      setState(() {
        futureUserAdmin = AdminService().getAllUsers();
      });
    } else if (searchType == "Theo Tên") {
      setState(() {
        futureUserAdmin = AdminService().getUserByName(keyword);
      });
    } else if (searchType == "Theo SDT") {
      setState(() {
        futureUserAdmin = AdminService().getUserByPhone(keyword);
      });
    } else if (searchType == "Theo Quyền ") {
      setState(() {
        // futureUserAdmin = AdminService().getUserByPermission();
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
                //left button
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
                          onSubmitted: (_) => searchProduct(),
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
                          searchProduct();
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
                    ],
                  ),
                ),

                //right button
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      // refresh
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            futureUserAdmin = AdminService().getAllUsers();
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

                      //permission
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (selectedUserIds.isEmpty) {
                            showSnackBarError(
                              context,
                              "Chưa chọn người dùng cần phân quyền",
                            );
                            return;
                          }

                          final user = await futureUserAdmin;
                        },
                        label: Text(
                          "Phân Quyền",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Symbols.graph_5, color: Colors.white),
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
                            selectedUserIds.isNotEmpty
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
                                                      'Bạn có chắc chắn muốn xoá ${selectedUserIds.length} sản phẩm?',
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
                                                              in selectedUserIds) {
                                                            await AdminService()
                                                                .deleteUserById(
                                                                  id,
                                                                );
                                                          }

                                                          await Future.delayed(
                                                            const Duration(
                                                              seconds: 1,
                                                            ),
                                                          );

                                                          setState(() {
                                                            selectedUserIds
                                                                .clear();
                                                            futureUserAdmin =
                                                                AdminService()
                                                                    .getAllUsers();
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
                        label: const Text(
                          "Xoá",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: const Icon(Icons.delete, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffEA4346),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      //popup menu
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.black),
                        color: Colors.white,
                        onSelected: (value) async {
                          if (value == 'changeRole') {
                            if (selectedUserIds.isEmpty) {
                              showSnackBarError(
                                context,
                                "Chưa chọn người dùng cần bổ nhiệm",
                              );
                              return;
                            }
                            final planning = await futureUserAdmin;

                            // showDialog(
                            //   context: context,
                            //   builder:
                            //       (_) => ChangeMachineDialog(
                            //         planning:
                            //             planning
                            //                 .where(
                            //                   (p) => selectedPlanningIds
                            //                       .contains(p.orderId),
                            //                 )
                            //                 .toList(),
                            //         onChangeMachine: loadPlanning,
                            //       ),
                            // );
                          } else if (value == 'resetPassword') {
                            if (selectedUserIds.isEmpty) {
                              showSnackBarError(
                                context,
                                "Chưa chọn người dùng cần bổ nhiệm",
                              );
                              return;
                            }
                            final planning = await futureUserAdmin;
                          }
                        },
                        itemBuilder:
                            (BuildContext context) => [
                              PopupMenuItem<String>(
                                value: 'changeRole',
                                child: ListTile(
                                  leading: Icon(Symbols.magic_exchange),
                                  title: Text('Bổ nhiệm vai trò'),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'resetPassword',
                                child: ListTile(
                                  leading: Icon(Symbols.lock_reset),
                                  title: Text('Đặt lại mật khẩu'),
                                ),
                              ),
                            ],
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // table
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: FutureBuilder<List<UserAdminModel>>(
                future: futureUserAdmin,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
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
                                    selectedUserIds =
                                        data.map((e) => e.userId).toList();
                                  } else {
                                    selectedUserIds.clear();
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        DataColumn(label: styleText("Họ Tên")),
                        DataColumn(label: styleText("Email")),
                        DataColumn(label: styleText("Giới Tính")),
                        DataColumn(label: styleText("Số Điện Thoại")),
                        DataColumn(label: styleText("Vai Trò")),
                        DataColumn(label: styleText("Quyền Truy Cập")),
                        DataColumn(label: styleText("Hình Ảnh")),
                      ],
                      rows: List<DataRow>.generate(data.length, (index) {
                        final user = data[index];
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
                                  value: selectedUserIds.contains(user.userId),
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        selectedUserIds.add(user.userId);
                                      } else {
                                        selectedUserIds.remove(user.userId);
                                      }
                                      selectedAll =
                                          selectedUserIds.length == data.length;
                                    });
                                  },
                                ),
                              ),
                            ),
                            DataCell(styleCell(user.fullName)),
                            DataCell(styleCell(user.email)),
                            DataCell(styleCell(user.sex ?? "")),
                            DataCell(styleCell(user.phone ?? "")),
                            DataCell(styleCell(user.role)),
                            DataCell(styleCell(user.permissions.join(', '))),
                            DataCell(
                              user.avatar != null && user.avatar!.isNotEmpty
                                  ? TextButton(
                                    onPressed: () {
                                      print(
                                        'Attempting to show image from URL: ${user.avatar}',
                                      );
                                      showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (_) {
                                          return GestureDetector(
                                            onTap:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: Scaffold(
                                              backgroundColor: Colors.black54,
                                              body: Center(
                                                child: GestureDetector(
                                                  onTap:
                                                      () {}, // Ngăn không cho nhấn vào ảnh đóng dialog
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    child: SizedBox(
                                                      width: 600,
                                                      height: 600,
                                                      child: Image.network(
                                                        user.avatar!,
                                                        fit: BoxFit.contain,
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          print(
                                                            'Image loading error: $error',
                                                          );
                                                          print(
                                                            'StackTrace: $stackTrace',
                                                          );
                                                          return Container(
                                                            width: 300,
                                                            height: 300,
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade300,
                                                            alignment:
                                                                Alignment
                                                                    .center,
                                                            child: const Text(
                                                              "Lỗi ảnh",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      'Xem ảnh',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  )
                                  : const Text('Không có ảnh'),
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
    );
  }

  Widget styleText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 17,
        color: Colors.white,
      ),
    );
  }

  Widget styleCell(String text) {
    return SizedBox(
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
      ),
    );
  }
}
