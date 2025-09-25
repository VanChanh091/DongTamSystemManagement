import 'package:dongtam/data/models/user/user_admin_model.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';

class DialogPermissionRole extends StatefulWidget {
  final UserAdminModel userAdmin;
  final VoidCallback onPermissionOrRole;
  const DialogPermissionRole({
    super.key,
    required this.userAdmin,
    required this.onPermissionOrRole,
  });

  @override
  State<DialogPermissionRole> createState() => _DialogPermissionRoleState();
}

class _DialogPermissionRoleState extends State<DialogPermissionRole> {
  final formKey = GlobalKey<FormState>();

  final List<String> roles = ['admin', 'manager', 'user'];
  final Map<String, String> roleLabels = {
    'admin': 'Quản trị viên',
    'manager': 'Quản lý',
    'user': 'Người dùng',
  };

  final List<String> permissions = [
    "sale",
    "plan",
    "HR",
    "accountant",
    "design",
    "production",
    "machine1350",
    "machine1900",
    "machine2Layer",
    "MachineRollPaper",
    "step2Production",
    "read",
  ];
  final Map<String, String> permissionsLabels = {
    "sale": "Kinh doanh",
    "plan": "Kế hoạch",
    "HR": "Nhân sự",
    "accountant": "Kế toán",
    "design": "Thiết kế",
    "production": "Sản xuất",
    "machine1350": "Máy 1350",
    "machine1900": "Máy 1900",
    "machine2Layer": "Máy 2 Lớp",
    "MachineRollPaper": "Máy Quấn Cuồn",
    "step2Production": "Công Đoạn 2",
    "read": "Chỉ đọc",
  };

  late int originalUserId;
  bool success = false;
  late List<String> chosenPermissions;
  late String chosenRole;

  ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);
  Map<String, ValueNotifier<bool>> permissionCheckStates = {};

  @override
  void initState() {
    super.initState();
    originalUserId = widget.userAdmin.userId;
    chosenPermissions = List.from(widget.userAdmin.permissions);
    chosenRole = widget.userAdmin.role;

    // Khởi tạo trạng thái checkbox cho từng quyền
    for (final p in permissions) {
      permissionCheckStates[p] = ValueNotifier<bool>(
        chosenPermissions.contains(p),
      );
    }
  }

  @override
  void dispose() {
    for (final notifier in permissionCheckStates.values) {
      notifier.dispose();
    }
    selectedOption.dispose();
    super.dispose();
  }

  void handleSave() async {
    if (!formKey.currentState!.validate()) return;

    try {
      if (selectedOption.value == 'role') {
        success = await AdminService().updateUserRole(
          originalUserId,
          chosenRole,
        );
      } else if (selectedOption.value == 'permission') {
        List<String> updatedPermissions =
            permissionCheckStates.entries
                .where((entry) => entry.value.value)
                .map((entry) => entry.key)
                .toList();

        success = await AdminService().updateUserPermissions(
          originalUserId,
          updatedPermissions,
        );
      }

      if (success) {
        showSnackBarSuccess(context, 'Cập nhật thành công!');
        await Future.delayed(Duration(milliseconds: 500));
      }

      widget.onPermissionOrRole();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error: $e");
      showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Cập nhật Role / Permissions"),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Radio group
              ValueListenableBuilder<String?>(
                valueListenable: selectedOption,
                builder: (context, value, _) {
                  return Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text(
                          "Vai trò",
                          style: TextStyle(fontSize: 16),
                        ),
                        value: 'role',
                        groupValue: value,
                        onChanged: (val) => selectedOption.value = val,
                      ),
                      RadioListTile<String>(
                        title: const Text(
                          "Quyền truy cập",
                          style: TextStyle(fontSize: 16),
                        ),
                        value: 'permission',
                        groupValue: value,
                        onChanged: (val) => selectedOption.value = val,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 15),

              // Dropdown role
              ValueListenableBuilder<String?>(
                valueListenable: selectedOption,
                builder: (context, value, _) {
                  if (value != 'role') return const SizedBox();
                  return dropdownForTypes(
                    roles,
                    chosenRole,
                    (val) => setState(() => chosenRole = val!),
                    labelMap: roleLabels,
                  );
                },
              ),

              // Checkbox list permission
              SizedBox(
                height: 300,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ValueListenableBuilder<String?>(
                    valueListenable: selectedOption,
                    builder: (context, value, _) {
                      if (value != 'permission') return const SizedBox();
                      return Column(
                        children:
                            permissions.map((perm) {
                              return ValueListenableBuilder<bool>(
                                valueListenable: permissionCheckStates[perm]!,
                                builder: (context, checked, _) {
                                  return Theme(
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
                                    child: CheckboxListTile(
                                      title: Text(
                                        permissionsLabels[perm] ?? perm,
                                      ),
                                      value: checked,
                                      onChanged: (val) {
                                        permissionCheckStates[perm]!.value =
                                            val ?? false;
                                      },
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Huỷ",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffEA4346),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Lưu",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget dropdownForTypes(
    List<String> items,
    String type,
    ValueChanged<String?> onChanged, {
    Map<String, String>? labelMap,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(type) ? type : null,
      items:
          items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Text(
                    labelMap?[value] ?? value, //show vn
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
      style: const TextStyle(fontSize: 16, color: Colors.black),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
