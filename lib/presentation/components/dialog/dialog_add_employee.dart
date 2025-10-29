import 'package:dongtam/data/models/employee/employee_basic_info.dart';
import 'package:dongtam/data/models/employee/employee_company_info.dart';
import 'package:dongtam/service/employee_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/building_card_form.dart';
import 'package:dongtam/utils/helper/reponsive_size.dart';
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
  List<EmployeeBasicInfo> allEmployees = [];
  bool isLoading = true;

  final List<String> itemGender = ["Nam", "Nữ", "Khác"];
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
    fetchAllCustomer();
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

  //get all employee to check employeeCode
  Future<void> fetchAllCustomer() async {
    try {
      final result = await EmployeeService().getAllEmployees(refresh: false, noPaging: true);

      allEmployees = result['employees'] as List<EmployeeBasicInfo>;

      AppLogger.i('Load all data employee succesfully');
    } catch (e, s) {
      AppLogger.e("Lỗi khi tải danh sách nhân viên", error: e, stackTrace: s);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
      if (widget.employee == null) {
        // add
        await EmployeeService().addEmployee(employeeData: newEmployee.toJson());

        if (!mounted) return; // check context
        showSnackBarSuccess(context, "Thêm thành công");
      } else {
        // update
        AppLogger.i("Cập nhật khách hàng: ${widget.employee!.employeeId}");
        await EmployeeService().updateEmployee(
          employeeId: widget.employee!.employeeId,
          updateEmployeeData: newEmployee.toJson(),
        );
        if (!mounted) return;
        showSnackBarSuccess(context, "Cập nhật thành công");
      }

      if (!mounted) return;
      widget.onEmployeeAddOrUpdate();
      Navigator.of(context).pop();
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
    _birthdayController.dispose();
    _citizenIssuedDateController.dispose();
    _joinDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.employee != null;

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
        width: ResponsiveSize.getWidth(context, ResponsiveType.medium),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        //basic info
                        const SizedBox(height: 10),
                        buildingCard(
                          title: "Thông Tin Cơ Bản",
                          children: [
                            buildFieldRow([
                              ValidationEmployee.validateInput(
                                label: "Tên Nhân Viên",
                                controller: _fullNameController,
                                icon: Symbols.person,
                              ),
                            ]),
                            buildFieldRow([
                              ValidationEmployee.validateInput(
                                label: "Số Điện Thoại",
                                controller: _phoneNumberController,
                                icon: Symbols.phone,
                              ),
                              ValidationOrder.dropdownForTypes(itemGender, typeGender, (value) {
                                setState(() {
                                  typeGender = value!;
                                });
                              }),
                            ]),
                            buildFieldRow([
                              ValidationOrder.validateInput(
                                "Ngày Sinh",
                                _birthdayController,
                                Symbols.calendar_month,
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
                                          dialogTheme: DialogThemeData(
                                            backgroundColor: Colors.white12,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      birthday = pickedDate;
                                      _birthdayController.text = DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(pickedDate);
                                    });
                                  }
                                },
                              ),

                              ValidationEmployee.validateInput(
                                label: "Nơi Sinh",
                                controller: _birthPlaceController,
                                icon: Symbols.place,
                              ),
                              ValidationEmployee.validateInput(
                                label: "Nguyên Quán",
                                controller: _homeTownController,
                                icon: Symbols.home_pin,
                              ),
                            ]),
                            buildFieldRow([
                              ValidationEmployee.validateInput(
                                label: "Trình Độ Văn Hóa",
                                controller: _educationLevelController,
                                icon: Symbols.book_ribbon,
                              ),
                              ValidationEmployee.validateInput(
                                label: "Hệ Đào Tạo",
                                controller: _educationSystemController,
                                icon: Symbols.book_5,
                              ),
                              ValidationEmployee.validateInput(
                                label: "Chuyên Ngành",
                                controller: _majorController,
                                icon: Symbols.menu_book,
                              ),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 10),

                        //CCCD info
                        buildingCard(
                          title: "Thông Tin CCCD",
                          children: [
                            buildFieldRow([
                              ValidationEmployee.validateInput(
                                label: "Số CCCD",
                                controller: _citizenIdController,
                                icon: Symbols.numbers,
                              ),
                              ValidationEmployee.validateInput(
                                label: "Dân Tộc",
                                controller: _ethnicityController,
                                icon: Symbols.accessibility,
                              ),
                            ]),
                            buildFieldRow([
                              ValidationOrder.validateInput(
                                "Ngày Cấp",
                                _citizenIssuedDateController,
                                Symbols.calendar_month,
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
                                          dialogTheme: DialogThemeData(
                                            backgroundColor: Colors.white12,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      citizenIssuedDate = pickedDate;
                                      _citizenIssuedDateController.text = DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(pickedDate);
                                    });
                                  }
                                },
                              ),

                              ValidationEmployee.validateInput(
                                label: "Nơi Cấp",
                                controller: _citizenIssuedPlaceController,
                                icon: Symbols.location_on,
                              ),
                            ]),
                            buildFieldRow([
                              ValidationEmployee.validateInput(
                                label: "ĐC Thường Trú",
                                controller: _permanentAddressController,
                                icon: Symbols.add_location,
                              ),
                            ]),
                            buildFieldRow([
                              ValidationEmployee.validateInput(
                                label: "ĐC Tạm Trú",
                                controller: _temporaryAddressController,
                                icon: Symbols.edit_location,
                              ),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 10),

                        //company info
                        buildingCard(
                          title: "Thông Tin Trong CTY",
                          children: [
                            buildFieldRow([
                              ValidationEmployee.validateInput(
                                label: "Mã Nhân Viên",
                                controller: _employeeCodeController,
                                icon: Symbols.person_pin,
                                readOnly: isEdit,
                                allEmployees: allEmployees,
                                currentEmployeeId: widget.employee?.employeeId,
                              ),
                              ValidationOrder.validateInput(
                                "Ngày Tham Gia",
                                _joinDateController,
                                Symbols.calendar_month,
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
                                          dialogTheme: DialogThemeData(
                                            backgroundColor: Colors.white12,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      joinDate = pickedDate;
                                      _joinDateController.text = DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(pickedDate);
                                    });
                                  }
                                },
                              ),
                            ]),
                            buildFieldRow([
                              ValidationEmployee.validateInput(
                                label: "Bộ Phận",
                                controller: _departmentController,
                                icon: Symbols.business,
                              ),
                              ValidationEmployee.validateInput(
                                label: "Chức Vụ",
                                controller: _positionController,
                                icon: Symbols.home_repair_service,
                              ),
                            ]),
                            buildFieldRow([
                              ValidationEmployee.validateInput(
                                label: "Số Liên Hệ Khẩn Cấp",
                                controller: _emergencyPhoneController,
                                icon: Symbols.emergency,
                              ),
                              ValidationOrder.dropdownForTypes(
                                itemStatusWorking,
                                typeStatusWorking,
                                (value) {
                                  setState(() {
                                    typeStatusWorking = value!;
                                  });
                                },
                              ),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
