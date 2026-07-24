import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/user/user_admin_model.dart';
import 'package:dongtam/presentation/components/dialog/other/dialog_permission_role.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
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

  String deptType = "Sale";
  String searchType = "Tất cả";
  List<int> selectedUserIds = [];

  bool selectedAll = false;
  bool isTextFieldEnabled = false;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() {
    setState(() {
      futureUserAdmin = AdminService().getUsersAdmin();
      selectedUserIds.clear();
      selectedAll = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
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
              height: 105,
              width: double.infinity,
              child: Column(
                children: [
                  //title
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

                  //button
                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //left button
                        Expanded(flex: 1, child: const SizedBox()),

                        //right button
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                //permission/role
                                AnimatedButton(
                                  onPressed:
                                      selectedUserIds.isNotEmpty
                                          ? () async {
                                            if (selectedUserIds.length > 1) {
                                              showSnackBarError(
                                                context,
                                                "Chỉ được cập nhật mỗi lần 1 user",
                                              );
                                              return;
                                            }

                                            final users = await futureUserAdmin;

                                            final selectedUser = users.firstWhere(
                                              (u) => selectedUserIds.contains(u.userId),
                                              orElse: () {
                                                AppLogger.e(
                                                  'Selected user not found after loading list.',
                                                );
                                                return users.first;
                                              },
                                            );

                                            if (context.mounted) {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (_) => DialogPermissionRole(
                                                      userAdmin: selectedUser,
                                                      onPermissionOrRole: () => loadUsers(),
                                                    ),
                                              );
                                            }
                                          }
                                          : null,
                                  label: "Phân Quyền/Vai Trò",
                                  icon: Symbols.graph_5,
                                  backgroundColor: themeController.buttonColor,
                                ),
                                const SizedBox(width: 10),

                                //reset password
                                AnimatedButton(
                                  onPressed:
                                      selectedUserIds.isNotEmpty
                                          ? () async {
                                            bool confirm = await showConfirmDialog(
                                              context: context,
                                              title: "Xác nhận đặt lại",
                                              content:
                                                  "Bạn có muốn mặt lại mật khẩu cho ${selectedUserIds.length} người dùng?",
                                              confirmText: "Xác nhận",
                                            );

                                            if (confirm) {
                                              try {
                                                await Future.delayed(
                                                  const Duration(milliseconds: 500),
                                                );

                                                await AdminService().updateInfoUser(
                                                  userIds: selectedUserIds,
                                                  newPassword: "baobidongtam2025",
                                                );

                                                if (!context.mounted) return;

                                                showSnackBarSuccess(
                                                  context,
                                                  "Đặt lại mật khẩu thành công. Mật khẩu mặc định là baobidongtam2025",
                                                );

                                                loadUsers();
                                              } catch (e) {
                                                if (!context.mounted) return;
                                                showSnackBarError(context, "Lỗi: $e");
                                              }
                                            }
                                          }
                                          : null,
                                  label: "Đặt lại mật khẩu",
                                  icon: Symbols.lock_reset,
                                  backgroundColor: themeController.buttonColor,
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
                                                  builder: (context, setStateDialog) {
                                                    return AlertDialog(
                                                      backgroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      title: const Row(
                                                        children: [
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
                                                                'Bạn có chắc chắn muốn xoá ${selectedUserIds.length} người dùng này?',
                                                                style: const TextStyle(
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                      actions:
                                                          isDeleting
                                                              ? []
                                                              : [
                                                                TextButton(
                                                                  onPressed:
                                                                      () => Navigator.pop(context),
                                                                  child: const Text(
                                                                    "Huỷ",
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Colors.black54,
                                                                    ),
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor: const Color(
                                                                      0xffEA4346,
                                                                    ),
                                                                    foregroundColor: Colors.white,
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(8),
                                                                    ),
                                                                  ),
                                                                  onPressed: () async {
                                                                    setStateDialog(() {
                                                                      isDeleting = true;
                                                                    });

                                                                    for (int id
                                                                        in selectedUserIds) {
                                                                      await AdminService()
                                                                          .deleteUser(userId: id);
                                                                    }

                                                                    await Future.delayed(
                                                                      const Duration(
                                                                        milliseconds: 500,
                                                                      ),
                                                                    );

                                                                    if (!context.mounted) {
                                                                      return;
                                                                    }

                                                                    loadUsers();
                                                                    Navigator.pop(context);

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
                                                                      fontWeight: FontWeight.bold,
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
                    ),
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
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            if (snapshot.error.toString().contains("NO_PERMISSION")) {
                              return const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock_outline, color: Colors.redAccent, size: 35),
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
                                "Không có người dùng nào",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
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
                                        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return Colors.red;
                                          }
                                          return Colors.white;
                                        }),
                                        checkColor: WidgetStateProperty.all<Color>(Colors.white),
                                        side: const BorderSide(color: Colors.black, width: 1),
                                      ),
                                    ),
                                    child: Checkbox(
                                      value: selectedAll,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedAll = value!;
                                          if (selectedAll) {
                                            selectedUserIds = data.map((e) => e.userId).toList();
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
                                DataColumn(label: styleText("Vai Trò")),
                                DataColumn(label: styleText("Phòng Ban")),
                                DataColumn(label: styleText("Quyền Truy Cập")),
                              ],
                              rows: List<DataRow>.generate(data.length, (index) {
                                final user = data[index];
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          checkboxTheme: CheckboxThemeData(
                                            fillColor: WidgetStateProperty.resolveWith<Color>((
                                              states,
                                            ) {
                                              if (states.contains(WidgetState.selected)) {
                                                return Colors.red;
                                              }
                                              return Colors.white;
                                            }),
                                            checkColor: WidgetStateProperty.all<Color>(
                                              Colors.white,
                                            ),
                                            side: const BorderSide(color: Colors.black, width: 1),
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
                                              selectedAll = selectedUserIds.length == data.length;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    DataCell(styleCell(label: user.fullName)),
                                    DataCell(styleCell(label: user.email)),
                                    DataCell(
                                      styleCell(label: UserAdminModel.formatRole(role: user.role)),
                                    ),
                                    DataCell(
                                      styleCell(
                                        label: UserAdminModel.formatDepartment(
                                          department: user.department,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      styleCell(
                                        label: UserAdminModel.formatPermissions(user.permissions),
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

                  //text
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        "Mật khẩu mặc định sau reset: baobidongtam2025",
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadUsers(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
