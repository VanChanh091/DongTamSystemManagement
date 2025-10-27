import 'package:dongtam/data/models/employee/employee_basic_info.dart';
import 'package:dongtam/utils/helper/reponsive_size.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/validation/validation_employee.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class EmployeeDialog extends StatefulWidget {
  final EmployeeBasicInfo? employee;
  final VoidCallback onEmployeeAddOrUpdate;

  const EmployeeDialog({super.key, this.employee, required this.onEmployeeAddOrUpdate});

  @override
  State<EmployeeDialog> createState() => _EmployeeDialogState();
}

class _EmployeeDialogState extends State<EmployeeDialog> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = true;

  final _employeeIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _homeTownController = TextEditingController();
  final _educationLevelController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _educationSystemController = TextEditingController();
  final _majorController = TextEditingController();
  final _citizenIdController = TextEditingController();
  final _citizenIssuedPlaceController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _temporaryAddressController = TextEditingController();
  final _ethnicityController = TextEditingController();
  final _employeeCodeController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _statusController = TextEditingController();

  final _birthdayController = TextEditingController();
  final _citizenIssuedDateController = TextEditingController();
  final _joinDateController = TextEditingController();
  DateTime? birthday;
  DateTime? citizenIssuedDate;
  DateTime? joinDate;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      employeeInitState();
    }
  }

  void employeeInitState() {
    final employee = widget.employee!;
    final companyInfo = widget.employee!.companyInfo;
    AppLogger.i("Khởi tạo form với customerId=${employee.employeeId}");

    _employeeIdController.text = employee.employeeId.toString();
    _fullNameController.text = employee.fullName;
    _genderController.text = employee.gender;
    _birthPlaceController.text = employee.birthPlace;
    _homeTownController.text = employee.homeTown ?? "";
    _educationLevelController.text = employee.educationLevel;
    _phoneNumberController.text = employee.phoneNumber;
    _educationSystemController.text = employee.educationSystem ?? "";
    _majorController.text = employee.major ?? "";
    _citizenIdController.text = employee.citizenId;
    _citizenIssuedPlaceController.text = employee.citizenIssuedPlace;
    _permanentAddressController.text = employee.permanentAddress;
    _temporaryAddressController.text = employee.temporaryAddress;
    _ethnicityController.text = employee.ethnicity;
    _employeeCodeController.text = companyInfo?.employeeCode ?? "";
    _departmentController.text = companyInfo?.department ?? "";
    _positionController.text = companyInfo?.position ?? "";
    _emergencyPhoneController.text = companyInfo?.emergencyPhone ?? "";
    _statusController.text = companyInfo?.status ?? "";

    birthday = employee.birthday;
    _birthdayController.text = (birthday != null) ? DateFormat('dd/MM/yyyy').format(birthday!) : "";

    citizenIssuedDate = employee.citizenIssuedDate;
    _citizenIssuedDateController.text =
        (citizenIssuedDate != null) ? DateFormat('dd/MM/yyyy').format(citizenIssuedDate!) : "";

    joinDate = companyInfo!.joinDate;
    _joinDateController.text = (joinDate != null) ? DateFormat('dd/MM/yyyy').format(joinDate!) : "";
  }

  void submit() async {}

  @override
  void dispose() {
    _employeeIdController.dispose();
    _fullNameController.dispose();
    _genderController.dispose();
    _birthPlaceController.dispose();
    _homeTownController.dispose();
    _educationLevelController.dispose();
    _phoneNumberController.dispose();
    _educationSystemController.dispose();
    _majorController.dispose();
    _citizenIdController.dispose();
    _citizenIssuedPlaceController.dispose();
    _permanentAddressController.dispose();
    _temporaryAddressController.dispose();
    _ethnicityController.dispose();
    _employeeCodeController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _emergencyPhoneController.dispose();
    _statusController.dispose();
    _birthdayController.dispose();
    _citizenIssuedDateController.dispose();
    _joinDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.employee != null;

    // final List<Map<String, dynamic>> employeeBasicInfo = [];
    // final List<Map<String, dynamic>> employeeCompanyInfo = [];

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(
          isEdit ? "Cập nhật nhân viên" : "Thêm nhân viên",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      content: SizedBox(
        width: ResponsiveSize.getWidth(context, ResponsiveType.large),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Tên Nhân Viên",
                          controller: _fullNameController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Giới Tính",
                          controller: _genderController,
                          icon: Symbols.general_device_rounded,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Ngày Sinh",
                          controller: _birthdayController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Nơi Sinh",
                          controller: _birthPlaceController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Nguyên Quán",
                          controller: _homeTownController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Trình Độ Văn Hóa",
                          controller: _educationLevelController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Số Điện Thoại",
                          controller: _phoneNumberController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Hệ Đào Tạo",
                          controller: _educationSystemController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Chuyên Ngành",
                          controller: _majorController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Số CCCD",
                          controller: _citizenIdController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Nơi Cấp",
                          controller: _citizenIssuedPlaceController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Ngày Cấp",
                          controller: _citizenIssuedDateController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "ĐC Thường Trú",
                          controller: _permanentAddressController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "ĐC Tạm Trú",
                          controller: _temporaryAddressController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Dân Tộc",
                          controller: _ethnicityController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Mã Nhân Viên",
                          controller: _employeeCodeController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Bộ Phận",
                          controller: _departmentController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Chức Vụ",
                          controller: _positionController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Liên Hệ Khẩn Cấp",
                          controller: _emergencyPhoneController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Trạng Thái Làm Việc",
                          controller: _statusController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Ngày Sinh",
                          controller: _birthdayController,
                          icon: Symbols.near_me,
                        ),

                        const SizedBox(height: 15),
                        ValidationEmployee.validateInput(
                          label: "Ngày Tham Gia",
                          controller: _joinDateController,
                          icon: Symbols.near_me,
                        ),
                      ],
                    ),
                  ),
                ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions:
          isLoading
              ? []
              : [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Hủy",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    isEdit ? "Cập nhật" : "Thêm",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
    );
  }
}
