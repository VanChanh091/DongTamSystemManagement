import "package:dongtam/data/models/user/user_admin_model.dart";
import "package:dongtam/service/admin_service.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:flutter/material.dart";

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
  Map<String, String> rolesMap = {
    "admin": "Quản trị viên",
    "manager": "Quản lý",
    "user": "Người dùng",
  };

  Map<String, String> departmentsMap = {
    "Operation": "Nghiệp Vụ",
    "HR": "Nhân sự",
    "Accountant": "Kế toán",
    "Sale": "Kinh doanh",
    "Production": "Sản xuất",
    "QC": "Chất Lượng",
    "Delivery": "Kho Vận",
    "Marketing": "Marketing",
  };

  Map<String, String> permissionsMap = {
    "sale": "Kinh doanh",
    "plan": "Kế hoạch",
    "HR": "Nhân sự",
    "production": "Sản xuất",
    "machine1350": "Máy 1350",
    "machine1900": "Máy 1900",
    "machine2Layer": "Máy 2 Lớp",
    "MachineRollPaper": "Máy Quấn Cuộn",
    "step2Production": "Công Đoạn 2",
    "QC": "Chất Lượng",
    "accountant": "Kế toán",
    "design": "Thiết kế",
    "delivery": "Giao Hàng",
    "read": "Chỉ đọc",
  };

  late int originalUserId;
  late String chosenRole;
  late String chosenDepartment;

  final ValueNotifier<String?> selectedOption = ValueNotifier<String?>("role");
  late Set<String> chosenPermissions;

  @override
  void initState() {
    super.initState();
    originalUserId = widget.userAdmin.userId;
    chosenRole = widget.userAdmin.role;
    chosenDepartment = widget.userAdmin.department;
    chosenPermissions = Set.from(widget.userAdmin.permissions);
  }

  @override
  void dispose() {
    super.dispose();
    selectedOption.dispose();
  }

  Future<void> submit() async {
    try {
      bool success = false;
      final option = selectedOption.value;

      if (option == "role") {
        success = await AdminService().updateInfoUser(userId: originalUserId, newRole: chosenRole);
      } else if (option == "department") {
        success = await AdminService().updateInfoUser(
          userId: originalUserId,
          newDepartment: chosenDepartment,
        );
      } else if (option == "permission") {
        success = await AdminService().updateInfoUser(
          userId: originalUserId,
          permissions: chosenPermissions.toList(),
        );
      }

      if (success) {
        if (mounted) {
          showSnackBarSuccess(context, "Cập nhật thành công!");
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            widget.onPermissionOrRole();
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e, s) {
      if (!mounted) return;
      AppLogger.e("Lỗi khi lưu thông tin người dùng", error: e, stackTrace: s);
      showSnackBarError(context, "Lỗi: Không thể lưu dữ liệu");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Cập nhật thông tin người dùng"),
      content: SizedBox(
        width: 360,
        child: ValueListenableBuilder<String?>(
          valueListenable: selectedOption,
          builder: (context, value, _) {
            return RadioGroup<String>(
              groupValue: value,
              onChanged: (val) {
                if (val != null) selectedOption.value = val;
              },
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Option Vai trò
                    RadioListTile<String>(
                      title: const Text("Vai trò", style: TextStyle(fontSize: 16)),
                      value: "role",
                    ),
                    if (value == 'role') ...[
                      _buildDropdown(
                        optionsMap: rolesMap,
                        selectedValue: chosenRole,
                        onChanged: (val) => setState(() => chosenRole = val!),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // 2. Option Phòng ban
                    RadioListTile<String>(
                      title: const Text("Phòng ban", style: TextStyle(fontSize: 16)),
                      value: "department",
                    ),
                    if (value == 'department') ...[
                      _buildDropdown(
                        optionsMap: departmentsMap,
                        selectedValue: chosenDepartment,
                        onChanged: (val) => setState(() => chosenDepartment = val!),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // 3. Option Quyền truy cập
                    RadioListTile<String>(
                      title: const Text("Quyền truy cập", style: TextStyle(fontSize: 16)),
                      value: "permission",
                    ),
                    if (value == 'permission') ...[
                      // Đã bỏ ListView/SizedBox thừa, render trực tiếp danh sách Checkbox
                      ...permissionsMap.entries.map((entry) {
                        final isChecked = chosenPermissions.contains(entry.key);
                        return CheckboxListTile(
                          activeColor: Colors.red,
                          title: Text(entry.value),
                          value: isChecked,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                chosenPermissions.add(entry.key);
                              } else {
                                chosenPermissions.remove(entry.key);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Huỷ",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        ElevatedButton(
          onPressed: submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffEA4346),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Lưu", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required Map<String, String> optionsMap,
    required String selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        initialValue: optionsMap.containsKey(selectedValue) ? selectedValue : null,
        items:
            optionsMap.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
