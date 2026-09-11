import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/customer/customer_model.dart";
import "package:dongtam/data/models/customer/customer_payment_model.dart";
import "package:dongtam/data/models/user/user_user_model.dart";
import "package:dongtam/service/customer_service.dart";
import "package:dongtam/utils/extension/extension_helper.dart";
import "package:dongtam/utils/handleError/api_exception.dart";
import "package:dongtam/presentation/components/shared/cardForm/building_card_form.dart";
import "package:dongtam/presentation/components/shared/cardForm/format_key_value_card.dart";
import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/presentation/components/shared/resizable_dialog.dart";
import "package:dongtam/utils/helper/reponsive/reponsive_dialog.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/validation/validation_helper.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

class CustomerDialog extends StatefulWidget {
  final CustomerModel? customer;
  final VoidCallback onCustomerAddOrUpdate;

  const CustomerDialog({super.key, this.customer, required this.onCustomerAddOrUpdate});

  @override
  State<CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<CustomerDialog> {
  late Future<List<UserUserModel>> futureUserSales;
  final formKey = GlobalKey<FormState>();
  final userController = Get.find<UserController>();

  List<CustomerModel> allCustomers = [];
  bool isLoading = true;
  String? idServerError;
  String? mstServerError;

  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _distanceController = TextEditingController();
  final _mstController = TextEditingController();
  final _phoneController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _customerSourceController = TextEditingController();

  int? selectedUserId;
  String? cskhSelected;

  late String typeRating = "Bình Thường";
  final List<String> itemRating = ["Xấu", "Bình Thường", "Tốt", "VIP"];

  //payment
  String paymentType = "Theo ngày";
  final List<String> itemsPaymentType = ["Theo ngày", "Theo tuần", "Theo tháng", "Tùy chỉnh"];
  final Map<String, String> paymentMapping = {
    "daily": "Theo ngày",
    "weekly": "Theo tuần",
    "monthly": "Theo tháng",
    "custom_days": "Tùy chỉnh",
  };

  String closingDay = "Thứ 2";
  final List<String> itemClosingDay = [
    "Thứ 2",
    "Thứ 3",
    "Thứ 4",
    "Thứ 5",
    "Thứ 6",
    "Thứ 7",
    "Chủ nhật",
  ];
  final Map<int, String> closingDaysMapping = {
    1: "Thứ 2",
    2: "Thứ 3",
    3: "Thứ 4",
    4: "Thứ 5",
    5: "Thứ 6",
    6: "Thứ 7",
    0: "Chủ nhật",
  };

  final _debtLimitController = TextEditingController();
  final _closingDaysController = TextEditingController();
  final _paymentTermDaysController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.customer != null) {
      customerInitState();
    }

    futureUserSales = CustomerService().getUserSales();
    getPhoneCustomer();
  }

  //create value of customer to update
  void customerInitState() {
    final customer = widget.customer!;
    final payment = customer.payment;

    _idController.text = customer.customerId;
    _nameController.text = customer.customerName;
    _companyNameController.text = customer.companyName;
    _companyAddressController.text = customer.companyAddress;
    _shippingAddressController.text = customer.shippingAddress;
    _distanceController.text = customer.distance?.toString() ?? "0";
    _mstController.text = customer.mst;
    _phoneController.text = customer.phone;
    _contactPersonController.text = customer.contactPerson ?? "";
    _customerSourceController.text = customer.customerSource;
    cskhSelected = customer.cskh;
    selectedUserId = customer.userId;

    //=====================PAYMENT=======================
    _debtLimitController.text = payment?.debtLimit?.toString() ?? "0";
    _closingDaysController.text =
        (payment?.closingDays != null && payment!.closingDays!.isNotEmpty)
            ? payment.closingDays!.join(", ")
            : "";
    _paymentTermDaysController.text = payment?.paymentTermDays.toString() ?? "0";

    //dropdown
    typeRating = customer.rateCustomer ?? "";
    paymentType = paymentMapping[payment?.paymentType] ?? "Theo ngày";

    closingDay =
        (payment?.closingDays != null && payment!.closingDays!.isNotEmpty)
            ? closingDaysMapping[payment.closingDays!.first] ?? "Thứ 2"
            : "Thứ 2";
  }

  //get all customer to check sdt
  Future<void> getPhoneCustomer() async {
    try {
      final result = await CustomerService().getCustomers(noPaging: true);
      allCustomers = result["customers"] as List<CustomerModel>;
    } catch (e, s) {
      AppLogger.e("Lỗi khi tải danh sách khách hàng", error: e, stackTrace: s);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    //check sdt is existed
    if (mounted) {
      if (widget.customer == null && _phoneController.text.isNotEmpty) {
        final isPhoneExist = allCustomers.any(
          (customer) => customer.phone == _phoneController.text,
        );

        if (isPhoneExist) {
          AppLogger.w("Số điện thoại đã tồn tại: ${_phoneController.text}");
          final shouldContinue = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text("Cảnh báo", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: const Text(
                    "Số điện thoại này đã tồn tại trong hệ thống.\nBạn có chắc chắn muốn tiếp tục lưu không?",
                    style: TextStyle(fontSize: 16),
                  ),
                  actionsPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  actionsAlignment: MainAxisAlignment.end,
                  actions: [
                    TextButton.icon(
                      label: const Text(
                        "Huỷ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    ElevatedButton.icon(
                      label: const Text(
                        "Tiếp tục",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
          );

          if (shouldContinue != true) return;
        }
      }
    }

    // Show loading
    if (!mounted) return;
    showLoadingDialog(context);
    await Future.delayed(const Duration(seconds: 1));

    try {
      final paymentTypeConvert = paymentMapping.keys.firstWhere(
        (k) => paymentMapping[k] == paymentType,
        orElse: () => "daily",
      );

      List<int> closingDays = [];

      if (paymentTypeConvert == 'weekly') {
        final selectedInt =
            closingDaysMapping.entries
                .firstWhere((e) => e.value == closingDay, orElse: () => const MapEntry(1, 'Thứ 2'))
                .key;
        closingDays = [selectedInt];
      } else if (paymentTypeConvert == 'monthly' || paymentTypeConvert == 'custom_days') {
        closingDays =
            _closingDaysController.trimmed
                .split(",")
                .map((e) => int.tryParse(e.trim()) ?? 0)
                .where((e) => e > 0)
                .toList();
      } else {
        closingDays = [];
      }

      if (selectedUserId == null || selectedUserId == 0) {
        if (!mounted) return;
        showSnackBarError(context, "Vui lòng chọn nhân viên CSKH hợp lệ");
        Navigator.pop(context);
        return;
      }

      // Chuẩn hóa dữ liệu đầu vào
      final payment = CustomerPaymentModel(
        cusPaymentId: widget.customer?.payment?.cusPaymentId ?? 0,
        customerId: widget.customer?.customerId ?? "",
        debtLimit: double.tryParse(_debtLimitController.trimmed) ?? 0,
        paymentType: paymentTypeConvert,
        closingDays: closingDays,
        paymentTermDays: int.tryParse(_paymentTermDaysController.trimmed) ?? 0,
      );

      final newCustomer = CustomerModel(
        customerId: _idController.trimmed.toUpperCase(), //prefix
        customerName: _nameController.superClean,
        companyName: _companyNameController.superClean,
        companyAddress: _companyAddressController.superClean,
        shippingAddress: _shippingAddressController.superClean,
        distance: double.tryParse(_distanceController.trimmed) ?? 0,
        mst: _mstController.trimmed,
        phone: _phoneController.trimmed,
        rateCustomer: typeRating,
        contactPerson: _contactPersonController.superClean,
        customerSource: _customerSourceController.trimmed,
        cskh: cskhSelected ?? "",
        userId: selectedUserId,
        payment: payment,
      );

      final bool isAdd = widget.customer == null;
      AppLogger.i(
        isAdd
            ? "Thêm khách hàng mới: ${newCustomer.customerId}"
            : "Cập nhật khách hàng: ${newCustomer.customerId}",
      );

      final bool success;
      if (isAdd) {
        success = await CustomerService().addCustomer(customerData: newCustomer.toJson());
      } else {
        success = await CustomerService().updateCustomer(
          customerId: newCustomer.customerId,
          updateCustomer: newCustomer.toJson(),
        );
      }

      if (success) {
        if (!mounted) return;
        Navigator.pop(context); // đóng dialog loading

        // Thông báo thành công
        showSnackBarSuccess(context, isAdd ? "Thêm thành công" : "Cập nhật thành công");

        widget.onCustomerAddOrUpdate();
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      setState(() {
        switch (e.errorCode) {
          case "PREFIX_ALREADY_EXISTS":
            idServerError = "Mã khách hàng này đã tồn tại";
            break;
          case "MST_ALREADY_EXISTS":
            mstServerError = "Mã số thuế này đã tồn tại";
            break;
          default:
            showSnackBarError(context, "Có lỗi xảy ra, vui lòng thử lại");
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState!.validate();
      });

      if (!mounted) return;
      Navigator.pop(context); // đóng dialog loading
    } catch (e, s) {
      if (widget.customer == null) {
        AppLogger.e("Lỗi khi thêm khách hàng", error: e, stackTrace: s);
      } else {
        AppLogger.e("Lỗi khi sửa khách hàng", error: e, stackTrace: s);
      }

      if (!mounted) return;
      showSnackBarError(context, "Lỗi: Không thể lưu dữ liệu");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _idController.dispose();
    _nameController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _shippingAddressController.dispose();
    _distanceController.dispose();
    _mstController.dispose();
    _phoneController.dispose();
    _contactPersonController.dispose();
    _debtLimitController.dispose();
    _customerSourceController.dispose();
    _closingDaysController.dispose();
    _paymentTermDaysController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;
    final bool canEditDebtLimit =
        widget.customer == null ? true : userController.hasAnyRole(roles: ["admin", "manager"]);

    final List<Map<String, dynamic>> basicInfoRows = [
      {
        "leftKey": "Mã khách hàng",
        "leftValue": ValidationHelper.customerInput(
          label: "Mã khách hàng",
          controller: _idController,
          icon: Icons.badge,
          readOnly: isEdit,
          checkId: !isEdit,
          externalError: idServerError,
          onChanged: (val) {
            if (idServerError != null) setState(() => idServerError = null);
          },
        ),
        "rightKey": "Tên khách hàng",
        "rightValue": ValidationHelper.customerInput(
          label: "Tên khách hàng",
          controller: _nameController,
          icon: Icons.person,
        ),
      },

      {
        "leftKey": "Tên công ty",
        "leftValue": ValidationHelper.customerInput(
          label: "Tên công ty",
          controller: _companyNameController,
          icon: Icons.business,
        ),
        "rightKey": "Mã Số Thuế",
        "rightValue": ValidationHelper.customerInput(
          label: "MST",
          controller: _mstController,
          icon: Icons.numbers,
          externalError: mstServerError,
          onChanged: (val) {
            if (mstServerError != null) setState(() => mstServerError = null);
          },
        ),
      },

      {
        "leftKey": "Địa chỉ công ty",
        "leftValue": ValidationHelper.customerInput(
          label: "Địa chỉ công ty",
          controller: _companyAddressController,
          icon: Icons.location_city,
        ),
        "rightKey": "Địa chỉ giao hàng",
        "rightValue": ValidationHelper.customerInput(
          label: "Địa chỉ giao hàng",
          controller: _shippingAddressController,
          icon: Icons.local_shipping,
        ),
      },

      {
        "leftKey": "Số Điện Thoại",
        "leftValue": ValidationHelper.customerInput(
          label: "SDT",
          controller: _phoneController,
          icon: Icons.phone,
        ),
        "rightKey": "Người Liên Hệ",
        "rightValue": ValidationHelper.customerInput(
          label: "Người Liên Hệ",
          controller: _contactPersonController,
          icon: Icons.person,
        ),
      },

      {
        "leftKey": "CSKH",
        "leftValue": FormField<String>(
          validator: (_) {
            if ((cskhSelected ?? "").trim().isEmpty) {
              return "Vui lòng chọn nhân viên CSKH";
            }
            return null;
          },
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<UserUserModel>>(
                  future: futureUserSales,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Text("Lỗi tải nhân viên CSKH");
                    }

                    final users = snapshot.data ?? [];
                    // final items = users.map((u) => u.fullName).whereType<String>().toList();

                    if (users.isEmpty) {
                      return const Text("Không có dữ liệu nhân viên CSKH");
                    }

                    if (cskhSelected == null || !users.any((u) => u.fullName == cskhSelected)) {
                      cskhSelected = users.first.fullName;
                      selectedUserId = users.first.userId;
                    } else {
                      final matchedUser = users.firstWhere(
                        (u) => u.fullName == cskhSelected,
                        orElse: () => users.first,
                      );
                      selectedUserId = matchedUser.userId;
                    }

                    final items = users.map((u) => u.fullName).whereType<String>().toList();

                    return ValidationHelper.dropdownForTypes(
                      items: items,
                      type: cskhSelected!,
                      onChanged: (selectedName) {
                        final matchedUser = users.firstWhere(
                          (u) => u.fullName == selectedName,
                          orElse: () => users.first,
                        );

                        setState(() {
                          cskhSelected = selectedName;
                          selectedUserId = matchedUser.userId;
                        });

                        state.didChange(selectedName);
                      },
                    );
                  },
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 12),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),

        "rightKey": "Nguồn Khách Hàng",
        "rightValue": ValidationHelper.customerInput(
          label: "Nguồn Khách Hàng",
          controller: _customerSourceController,
          icon: Icons.source,
        ),
      },
    ];

    final List<Map<String, dynamic>> otherInfoRows = [
      {
        "leftKey": "Hạn Mức Công Nợ",
        "leftValue": ValidationHelper.customerInput(
          label: "Hạn Mức Công Nợ",
          controller: _debtLimitController,
          icon: Icons.money,
          readOnly: !canEditDebtLimit,
        ),

        "rightKey": "Ngày Chốt Công Nợ",
        "rightValue": () {
          if (paymentType == "Theo tuần" || paymentType == "weekly") {
            return ValidationHelper.dropdownForTypes(
              items: itemClosingDay,
              type: closingDay,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    closingDay = value;
                  });
                }
              },
            );
          }

          final isDaily = paymentType == "Theo ngày" || paymentType == "daily";
          return ValidationHelper.customerInput(
            label: "Ngày Chốt Công Nợ",
            controller: _closingDaysController,
            icon: Icons.calendar_today,
            isRequired: !isDaily,
            readOnly: isDaily,
          );
        }(),
      },
      {
        "leftKey": "Kiểu Thanh Toán",
        "leftValue": ValidationHelper.dropdownForTypes(
          items: itemsPaymentType,
          type: paymentType,
          onChanged: (value) {
            setState(() {
              paymentType = value!;
              if (paymentType == "Theo ngày" || paymentType == "daily") {
                _closingDaysController.clear();
              }
            });
          },
        ),
        "rightKey": "Số Ngày Công Nợ",
        "rightValue": ValidationHelper.customerInput(
          label: "Số Ngày Công Nợ",
          controller: _paymentTermDaysController,
          icon: Icons.calendar_today,
        ),
      },
      {
        "leftKey": "Khoảng Cách Giao Hàng",
        "leftValue": ValidationHelper.customerInput(
          label: "Khoảng Cách Giao Hàng (km)",
          controller: _distanceController,
          icon: Icons.social_distance,
        ),
        "rightKey": "Đánh Giá",
        "rightValue": ValidationHelper.dropdownForTypes(
          items: itemRating,
          type: typeRating,
          onChanged: (value) {
            setState(() {
              typeRating = value!;
            });
          },
        ),
      },
    ];

    return ResizableDialog(
      initialWidth: ResponsiveSize.getWidth(context, ResponsiveType.large),
      minWidth: 1100,
      maxWidth: 1500,
      minHeight: 600,
      title: Center(
        child: Text(
          isEdit ? "Cập nhật khách hàng" : "Thêm khách hàng",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      actions: isLoading ? [] : buildDialogActions(context: context, onConfirm: submit),
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
                        title: "Thông Tin Khách Hàng",
                        children: formatKeyValueRows(
                          rows: basicInfoRows,
                          columnCount: 2,
                          labelWidth: 150,
                          centerAlign: true,
                        ),
                      ),
                      const SizedBox(height: 10),

                      //other info
                      buildingCard(
                        title: "Thông Tin Thanh Toán",
                        children: formatKeyValueRows(
                          rows: otherInfoRows,
                          columnCount: 2,
                          labelWidth: 150,
                          centerAlign: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
