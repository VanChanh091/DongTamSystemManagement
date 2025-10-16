import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/user/user_admin_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_permission_role.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminMangeUser extends StatefulWidget {
  const AdminMangeUser({super.key});

  @override
  State<AdminMangeUser> createState() => _AdminMangeUserState();
}

class _AdminMangeUserState extends State<AdminMangeUser> {
  late Future<List<UserAdminModel>> futureUserAdmin;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  TextEditingController searchController = TextEditingController();
  List<int> selectedUserIds = [];
  bool selectedAll = false;
  bool isTextFieldEnabled = false;
  String searchType = "Tất cả";

  @override
  void initState() {
    super.initState();

    if (userController.hasAnyRole(["admin"])) {
      futureUserAdmin = AdminService().getAllUsers();
    } else {
      futureUserAdmin = Future.error("NO_PERMISSION");
    }
  }

  void searchUser() {
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
    } else if (searchType == "Theo Quyền") {
      List<String> permissions =
          keyword
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      if (permissions.isEmpty) return;
      setState(() {
        futureUserAdmin = AdminService().getUserByPermission(permissions);
      });
    }
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
              height: 105,
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    height: 35,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "QUẢN LÝ TÀI KHOẢN NGƯỜI DÙNG",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: themeController.currentColor.value,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child:
                        isAccept
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //left button
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 10,
                                    ),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final maxWidth = constraints.maxWidth;
                                        final dropdownWidth = (maxWidth * 0.2)
                                            .clamp(120.0, 170.0);
                                        final textInputWidth = (maxWidth * 0.3)
                                            .clamp(200.0, 250.0);

                                        return Row(
                                          children: [
                                            //dropdown
                                            SizedBox(
                                              width: dropdownWidth,
                                              child: DropdownButtonFormField<
                                                String
                                              >(
                                                value: searchType,
                                                items:
                                                    [
                                                      'Tất cả',
                                                      "Theo Tên",
                                                      "Theo SDT",
                                                      "Theo Quyền",
                                                    ].map((String value) {
                                                      return DropdownMenuItem<
                                                        String
                                                      >(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    searchType = value!;
                                                    isTextFieldEnabled =
                                                        searchType != 'Tất cả';

                                                    if (!isTextFieldEnabled) {
                                                      searchController.clear();
                                                    }
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),

                                            // input
                                            SizedBox(
                                              width: textInputWidth,
                                              height: 50,
                                              child: TextField(
                                                controller: searchController,
                                                enabled: isTextFieldEnabled,
                                                onSubmitted:
                                                    (_) => searchUser(),
                                                decoration: InputDecoration(
                                                  hintText: 'Tìm kiếm...',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),

                                            // find
                                            AnimatedButton(
                                              onPressed: () {
                                                searchUser();
                                              },
                                              label: "Tìm kiếm",
                                              icon: Icons.search,
                                              backgroundColor:
                                                  themeController.buttonColor,
                                            ),
                                            const SizedBox(width: 10),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                //right button
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        //permission/role
                                        AnimatedButton(
                                          onPressed: () async {
                                            if (selectedUserIds.isEmpty) {
                                              showSnackBarError(
                                                context,
                                                "Chưa chọn người dùng cần phân quyền/vai trò",
                                              );
                                              return;
                                            }

                                            if (selectedUserIds.length > 1) {
                                              showSnackBarError(
                                                context,
                                                "Chỉ được cập nhật mỗi lần 1 user",
                                              );
                                              return;
                                            }

                                            final users = await futureUserAdmin;

                                            if (!mounted) {
                                              // Dùng AppLogger để ghi lại rằng widget đã bị hủy
                                              AppLogger.w(
                                                'Widget AdminMangeUser disposed before user data loaded.',
                                              );
                                              return;
                                            }
                                            final selectedUser = users.firstWhere(
                                              (u) => selectedUserIds.contains(
                                                u.userId,
                                              ),
                                              orElse: () {
                                                AppLogger.e(
                                                  'Selected user not found after loading list.',
                                                );
                                                return users.first;
                                              },
                                            );

                                            if (!context.mounted) return;

                                            showDialog(
                                              context: context,
                                              builder:
                                                  (_) => DialogPermissionRole(
                                                    userAdmin: selectedUser,
                                                    onPermissionOrRole: () {
                                                      setState(() {
                                                        futureUserAdmin =
                                                            AdminService()
                                                                .getAllUsers();
                                                      });
                                                    },
                                                  ),
                                            );
                                          },
                                          label: "Phân Quyền/Vai Trò",
                                          icon: Symbols.graph_5,
                                          backgroundColor:
                                              themeController.buttonColor,
                                        ),
                                        const SizedBox(width: 10),

                                        //reset password
                                        AnimatedButton(
                                          onPressed: () async {
                                            if (selectedUserIds.isEmpty) {
                                              if (!mounted) return;
                                              showSnackBarError(
                                                context,
                                                "Chưa chọn người dùng cần đặt lại mật khẩu",
                                              );
                                              return;
                                            }

                                            final confirm = await showDialog<
                                              bool
                                            >(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    title: const Text(
                                                      "Xác nhận đặt lại",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: Text(
                                                      "Bạn có muốn mặt lại mật khẩu cho ${selectedUserIds.length} người dùng?",
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                              false,
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
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: const Text(
                                                          "Xác nhận",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );

                                            if (confirm == true) {
                                              try {
                                                await Future.delayed(
                                                  const Duration(
                                                    milliseconds: 500,
                                                  ),
                                                );

                                                await AdminService()
                                                    .resetUserPassword(
                                                      userIds: selectedUserIds,
                                                    );

                                                if (!context.mounted) return;

                                                showSnackBarSuccess(
                                                  context,
                                                  "Đặt lại mật khẩu thành công. Mật khẩu mặc định là 12345678",
                                                );

                                                setState(() {
                                                  futureUserAdmin =
                                                      AdminService()
                                                          .getAllUsers();
                                                  selectedUserIds.clear();
                                                  selectedAll = false;
                                                });
                                              } catch (e) {
                                                if (!context.mounted) return;
                                                showSnackBarError(
                                                  context,
                                                  "Lỗi: $e",
                                                );
                                              }
                                            }
                                          },
                                          label: "Đặt lại mật khẩu",
                                          icon: Symbols.lock_reset,
                                          backgroundColor:
                                              themeController.buttonColor,
                                        ),
                                        const SizedBox(width: 10),

                                        //delete user
                                        AnimatedButton(
                                          onPressed:
                                              selectedUserIds.isNotEmpty
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
                                                                      ? Row(
                                                                        children: const [
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
                                                                      : Text(
                                                                        'Bạn có chắc chắn muốn xoá ${selectedUserIds.length} người dùng này?',
                                                                        style: const TextStyle(
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
                                                                                in selectedUserIds) {
                                                                              await AdminService().deleteUserById(
                                                                                id,
                                                                              );
                                                                            }

                                                                            await Future.delayed(
                                                                              const Duration(
                                                                                milliseconds:
                                                                                    500,
                                                                              ),
                                                                            );

                                                                            if (!context.mounted) {
                                                                              return;
                                                                            }

                                                                            setState(() {
                                                                              selectedUserIds.clear();
                                                                              futureUserAdmin =
                                                                                  AdminService().getAllUsers();
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
                                          label: "Xoá",
                                          icon: Icons.delete,
                                          backgroundColor: Color(0xffEA4346),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // table
            Expanded(
              child: Column(
                children: [
                  //table
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: FutureBuilder<List<UserAdminModel>>(
                        future: futureUserAdmin,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            if (snapshot.error.toString().contains(
                              "NO_PERMISSION",
                            )) {
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
                            return Center(
                              child: Text("Lỗi: ${snapshot.error}"),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                "Không có người dùng nào",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            );
                          }

                          final data = snapshot.data!;

                          return SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              columnSpacing: 25,
                              headingRowColor: WidgetStatePropertyAll(
                                themeController.currentColor.value,
                              ),
                              columns: [
                                DataColumn(
                                  label: Theme(
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
                                      value: selectedAll,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedAll = value!;
                                          if (selectedAll) {
                                            selectedUserIds =
                                                data
                                                    .map((e) => e.userId)
                                                    .toList();
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
                              rows: List<DataRow>.generate(data.length, (
                                index,
                              ) {
                                final user = data[index];
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
                                          value: selectedUserIds.contains(
                                            user.userId,
                                          ),
                                          onChanged: (val) {
                                            setState(() {
                                              if (val == true) {
                                                selectedUserIds.add(
                                                  user.userId,
                                                );
                                              } else {
                                                selectedUserIds.remove(
                                                  user.userId,
                                                );
                                              }
                                              selectedAll =
                                                  selectedUserIds.length ==
                                                  data.length;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    DataCell(styleCell(user.fullName)),
                                    DataCell(styleCell(user.email)),
                                    DataCell(
                                      styleCell(
                                        UserAdminModel.formatSex(
                                          user.sex ?? "",
                                        ),
                                      ),
                                    ),
                                    DataCell(styleCell(user.phone ?? "")),
                                    DataCell(
                                      styleCell(
                                        UserAdminModel.formatRole(user.role),
                                      ),
                                    ),
                                    DataCell(
                                      styleCell(
                                        UserAdminModel.formatPermissions(
                                          user.permissions,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      user.avatar != null &&
                                              user.avatar!.isNotEmpty
                                          ? TextButton(
                                            onPressed: () {
                                              // print(
                                              //   'Attempting to show image from URL: ${user.avatar}',
                                              // );
                                              showDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                builder: (_) {
                                                  return GestureDetector(
                                                    onTap:
                                                        () =>
                                                            Navigator.of(
                                                              context,
                                                            ).pop(),
                                                    child: Scaffold(
                                                      backgroundColor:
                                                          Colors.black54,
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
                                                                fit:
                                                                    BoxFit
                                                                        .contain,
                                                                errorBuilder: (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) {
                                                                  AppLogger.e(
                                                                    "Lỗi khi tải hình ảnh",
                                                                    error:
                                                                        error,
                                                                    stackTrace:
                                                                        stackTrace,
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
                                                                            Colors.black,
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
                                            child: const Text(
                                              'Xem ảnh',
                                              style: TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline,
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

                  //text
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        "Mật khẩu mặc định là: 12345678",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: themeController.currentColor.value,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          isAccept
              ? FloatingActionButton(
                onPressed: () async {
                  setState(() {
                    futureUserAdmin = AdminService().getAllUsers();
                  });
                },
                backgroundColor: themeController.buttonColor.value,
                child: const Icon(Icons.refresh, color: Colors.white),
              )
              : null,
    );
  }
}
