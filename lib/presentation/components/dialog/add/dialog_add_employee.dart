import 'package:dongtam/data/models/employee/employee_basic_info.dart';
import 'package:dongtam/data/models/employee/employee_company_info.dart';
import 'package:dongtam/service/employee_service.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/cardForm/building_card_form.dart';
import 'package:dongtam/utils/helper/cardForm/format_key_value_card.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/helper/reponsive/reponsive_dialog.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/validation/validation_employee.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
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
  String? employeeCodeError;

  final List<String> itemGender = ["Nam", "Nữ"];
  late String typeGender = "Nam";

  final List<String> itemStatusWorking = ["Đang Làm Việc", "Nghỉ Việc", "Tạm Nghỉ"];
  late String typeStatusWorking = "Đang Làm Việc";

  final _fullNameController = TextEditingController();
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
  final _emergencyContactController = TextEditingController();

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
    AppLogger.i("Khởi tạo form với employeeId=${employee.employeeId}");

    _fullNameController.text = employee.fullName;
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
    _emergencyContactController.text = companyInfo?.emergencyContact ?? "";

    //dropdown
    typeGender = employee.gender;
    typeStatusWorking = companyInfo!.status;

    //date
    birthday = employee.birthday;
    _birthdayController.text = (birthday != null) ? DateFormat('dd/MM/yyyy').format(birthday!) : "";

    citizenIssuedDate = employee.citizenIssuedDate;
    _citizenIssuedDateController.text =
        (citizenIssuedDate != null) ? DateFormat('dd/MM/yyyy').format(citizenIssuedDate!) : "";

    joinDate = companyInfo.joinDate;
    _joinDateController.text = (joinDate != null) ? DateFormat('dd/MM/yyyy').format(joinDate!) : "";
  }

  void submit() async {
    if (!formKey.currentState!.validate()) {
      AppLogger.w("Form không hợp lệ, dừng submit");
      return;
    }

    final newCompanyInfoEmpl = EmployeeCompanyInfo(
      companyInfoId: 0,
      employeeCode: _employeeCodeController.text.toUpperCase(),
      joinDate: joinDate ?? DateTime.now(),
      department: _departmentController.text,
      position: _positionController.text,
      emergencyPhone: _emergencyPhoneController.text,
      emergencyContact: _emergencyContactController.text,
      status: typeStatusWorking,
    );

    final newEmployee = EmployeeBasicInfo(
      employeeId: 0,
      fullName: _fullNameController.text,
      gender: typeGender,
      birthday: birthday ?? DateTime.now(),
      birthPlace: _birthPlaceController.text,
      homeTown: _homeTownController.text,
      educationLevel: _educationLevelController.text,
      phoneNumber: _phoneNumberController.text,
      educationSystem: _educationSystemController.text,
      major: _majorController.text,
      citizenId: _citizenIdController.text,
      citizenIssuedDate: citizenIssuedDate ?? DateTime.now(),
      citizenIssuedPlace: _citizenIssuedPlaceController.text,
      permanentAddress: _permanentAddressController.text,
      temporaryAddress: _temporaryAddressController.text,
      ethnicity: _ethnicityController.text,
      companyInfo: newCompanyInfoEmpl,
    );

    try {
      final bool isAdd = widget.employee == null;

      AppLogger.i(
        isAdd ? "Thêm nhân viên mới" : "Cập nhật nhân viên: ${widget.employee!.fullName}",
      );

      isAdd
          ? await EmployeeService().addEmployee(employeeData: newEmployee.toJson())
          : await EmployeeService().updateEmployee(
            employeeId: widget.employee!.employeeId,
            updateEmployeeData: newEmployee.toJson(),
          );

      // Show loading
      if (!mounted) return;
      showLoadingDialog(context);
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.pop(context); // đóng dialog loading

      // Thông báo thành công
      if (!mounted) return;
      showSnackBarSuccess(context, isAdd ? "Thêm thành công" : "Cập nhật thành công");

      widget.onEmployeeAddOrUpdate();

      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (e.errorCode == 'EMPLOYEE_CODE_EXISTS') {
        setState(() {
          employeeCodeError = "Mã nhân viên này đã tồn tại";
        });
      } else {
        showSnackBarError(context, 'Có lỗi xảy ra, vui lòng thử lại');
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState!.validate();
      });
    } catch (e, s) {
      if (!mounted) return;
      if (widget.employee == null) {
        AppLogger.e("Lỗi khi thêm nhân viên", error: e, stackTrace: s);
      } else {
        AppLogger.e("Lỗi khi sửa nhân viên", error: e, stackTrace: s);
      }
      showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
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
    _emergencyContactController.dispose();
    _birthdayController.dispose();
    _citizenIssuedDateController.dispose();
    _joinDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.employee != null;

    final List<Map<String, dynamic>> basicInfoRows = [
      {
        "leftKey": "Tên Nhân Viên",
        "leftValue": ValidationEmployee.validateInput(
          label: "Tên Nhân Viên",
          controller: _fullNameController,
          icon: Symbols.person,
        ),
      },

      {
        "leftKey": "Số Điện Thoại",
        "leftValue": ValidationEmployee.validateInput(
          label: "Số Điện Thoại",
          controller: _phoneNumberController,
          icon: Symbols.phone,
        ),
        "rightKey": "Giới Tính",
        "rightValue": ValidationOrder.dropdownForTypes(
          items: itemGender,
          type: typeGender,
          onChanged: (value) {
            setState(() {
              typeGender = value!;
            });
          },
        ),
      },

      {
        "leftKey": "Ngày Sinh",
        "leftValue": ValidationEmployee.validateInput(
          label: "Ngày Sinh",
          controller: _birthdayController,
          icon: Symbols.calendar_month,
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: birthday ?? DateTime.now(),
              firstDate: DateTime(1970),
              lastDate: DateTime(2100),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                    dialogTheme: DialogThemeData(backgroundColor: Colors.white12),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              setState(() {
                birthday = pickedDate;
                _birthdayController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
              });
            }
          },
        ),
        "rightKey": "Nơi Sinh",
        "rightValue": ValidationEmployee.validateInput(
          label: "Nơi Sinh",
          controller: _birthPlaceController,
          icon: Symbols.place,
        ),
      },

      {
        "leftKey": "Nguyên Quán",
        "leftValue": ValidationEmployee.validateInput(
          label: "Nguyên Quán",
          controller: _homeTownController,
          icon: Symbols.home_pin,
        ),
        "rightKey": "Trình Độ Văn Hóa",
        "rightValue": ValidationEmployee.validateInput(
          label: "Trình Độ Văn Hóa",
          controller: _educationLevelController,
          icon: Symbols.book_ribbon,
        ),
      },
      {
        "leftKey": "Hệ Đào Tạo",
        "leftValue": ValidationEmployee.validateInput(
          label: "Hệ Đào Tạo",
          controller: _educationSystemController,
          icon: Symbols.book_5,
        ),
        "rightKey": "Chuyên Ngành",
        "rightValue": ValidationEmployee.validateInput(
          label: "Chuyên Ngành",
          controller: _majorController,
          icon: Symbols.menu_book,
        ),
      },
    ];

    final List<Map<String, dynamic>> cccdInfoRows = [
      {
        "leftKey": "Số CCCD",
        "leftValue": ValidationEmployee.validateInput(
          label: "Số CCCD",
          controller: _citizenIdController,
          icon: Symbols.numbers,
        ),
        "rightKey": "Dân Tộc",
        "rightValue": ValidationEmployee.validateInput(
          label: "Dân Tộc",
          controller: _ethnicityController,
          icon: Symbols.accessibility,
        ),
      },

      {
        "leftKey": "Ngày Cấp",
        "leftValue": ValidationEmployee.validateInput(
          label: "Ngày Cấp",
          controller: _citizenIssuedDateController,
          icon: Symbols.calendar_month,
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: citizenIssuedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                    dialogTheme: DialogThemeData(backgroundColor: Colors.white12),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              setState(() {
                citizenIssuedDate = pickedDate;
                _citizenIssuedDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
              });
            }
          },
        ),
        "rightKey": "Nơi Cấp",
        "rightValue": ValidationEmployee.validateInput(
          label: "Nơi Cấp",
          controller: _citizenIssuedPlaceController,
          icon: Symbols.location_on,
        ),
      },

      {
        "leftKey": "ĐC Thường Trú",
        "leftValue": ValidationEmployee.validateInput(
          label: "ĐC Thường Trú",
          controller: _permanentAddressController,
          icon: Symbols.add_location,
        ),
      },

      {
        "leftKey": "ĐC Tạm Trú",
        "leftValue": ValidationEmployee.validateInput(
          label: "ĐC Tạm Trú",
          controller: _temporaryAddressController,
          icon: Symbols.edit_location,
        ),
      },
    ];

    final List<Map<String, dynamic>> companyInfoRows = [
      {
        "leftKey": "Mã Nhân Viên",
        "leftValue": ValidationEmployee.validateInput(
          label: "Mã Nhân Viên",
          controller: _employeeCodeController,
          icon: Symbols.person_pin,
          externalError: employeeCodeError,
          onChanged: (val) {
            if (employeeCodeError != null) setState(() => employeeCodeError = null);
          },
        ),
        "rightKey": "Ngày Vào Làm",
        "rightValue": ValidationEmployee.validateInput(
          label: "Ngày Vào Làm",
          controller: _joinDateController,
          icon: Symbols.calendar_month,
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: joinDate ?? DateTime.now(),
              firstDate: DateTime(2019),
              lastDate: DateTime(2100),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                    dialogTheme: DialogThemeData(backgroundColor: Colors.white12),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              setState(() {
                joinDate = pickedDate;
                _joinDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
              });
            }
          },
        ),
      },

      {
        "leftKey": "Bộ Phận",
        "leftValue": ValidationEmployee.validateInput(
          label: "Bộ Phận",
          controller: _departmentController,
          icon: Symbols.business,
        ),
        "rightKey": "Chức Vụ",
        "rightValue": ValidationEmployee.validateInput(
          label: "Chức Vụ",
          controller: _positionController,
          icon: Symbols.home_repair_service,
        ),
      },

      {
        "leftKey": "SDT Liên Hệ",
        "leftValue": ValidationEmployee.validateInput(
          label: "Số LH Khẩn Cấp",
          controller: _emergencyPhoneController,
          icon: Symbols.emergency,
        ),
        "rightKey": "Người Liên Hệ",
        "rightValue": ValidationEmployee.validateInput(
          label: "Người LH Khẩn Cấp",
          controller: _emergencyContactController,
          icon: Symbols.emergency,
        ),
      },

      {
        "leftKey": "Tình Trạng",
        "leftValue": ValidationOrder.dropdownForTypes(
          items: itemStatusWorking,
          type: typeStatusWorking,
          onChanged: (value) {
            setState(() {
              typeStatusWorking = value!;
            });
          },
        ),
        "rightKey": "",
        "rightValue": const SizedBox(),
      },
    ];

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
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                //basic info
                const SizedBox(height: 10),
                buildingCard(
                  title: "Thông Tin Cơ Bản",
                  children: formatKeyValueRows(
                    rows: basicInfoRows,
                    columnCount: 2,
                    labelWidth: 150,
                    centerAlign: true,
                  ),
                ),
                const SizedBox(height: 10),

                //CCCD info
                buildingCard(
                  title: "Thông Tin CCCD",
                  children: formatKeyValueRows(
                    rows: cccdInfoRows,
                    columnCount: 2,
                    labelWidth: 150,
                    centerAlign: true,
                  ),
                ),
                const SizedBox(height: 10),

                //company info
                buildingCard(
                  title: "Thông Tin Trong CTY",
                  children: formatKeyValueRows(
                    rows: companyInfoRows,
                    columnCount: 2,
                    labelWidth: 150,
                    centerAlign: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Hủy",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black54),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
