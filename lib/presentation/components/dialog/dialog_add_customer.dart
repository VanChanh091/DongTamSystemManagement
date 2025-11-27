import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/service/customer_service.dart';
import 'package:dongtam/utils/helper/cardForm/building_card_form.dart';
import 'package:dongtam/utils/helper/cardForm/format_key_value_card.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/helper/reponsive_size.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_customer.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class CustomerDialog extends StatefulWidget {
  final Customer? customer;
  final VoidCallback onCustomerAddOrUpdate;

  const CustomerDialog({super.key, this.customer, required this.onCustomerAddOrUpdate});

  @override
  State<CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<CustomerDialog> {
  final formKey = GlobalKey<FormState>();
  List<Customer> allCustomers = [];
  bool isLoading = true;
  final List<String> itemRating = ["Xấu", "Bình Thường", "Tốt", "VIP"];
  late String typeRating = "Bình Thường";

  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _distanceController = TextEditingController();
  final _mstController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cskhController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _dayCreatedController = TextEditingController();
  final _debtLimitController = TextEditingController();
  final _timePaymentController = TextEditingController();
  DateTime? dayCreated;
  DateTime? timePayment;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      customerInitState();
    }
    fetchAllCustomer();
  }

  //create value of customer to update
  void customerInitState() {
    final customer = widget.customer!;
    AppLogger.i("Khởi tạo form với customerId=${customer.customerId}");

    _idController.text = customer.customerId;
    _nameController.text = customer.customerName;
    _companyNameController.text = customer.companyName;
    _companyAddressController.text = customer.companyAddress;
    _shippingAddressController.text = customer.shippingAddress;
    _distanceController.text = customer.distance?.toString() ?? "0";
    _mstController.text = customer.mst;
    _phoneController.text = customer.phone;
    _cskhController.text = customer.cskh;
    _contactPersonController.text = customer.contactPerson ?? "";
    _debtLimitController.text = widget.customer!.debtLimit?.toString() ?? "0";

    //dropdown
    typeRating = customer.rateCustomer ?? "";

    //date
    timePayment = customer.timePayment;
    _timePaymentController.text =
        (timePayment != null) ? DateFormat('dd/MM/yyyy').format(timePayment!) : "";
  }

  //get all customer to check sdt
  Future<void> fetchAllCustomer() async {
    try {
      final result = await CustomerService().getAllCustomers(noPaging: true);

      allCustomers = result['customers'] as List<Customer>;
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
      AppLogger.w("Form không hợp lệ, dừng submit");
      return;
    }

    //check sdt is existed
    if (widget.customer == null && _phoneController.text.isNotEmpty) {
      final isPhoneExist = allCustomers.any((customer) => customer.phone == _phoneController.text);

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
                    const Text('Cảnh báo', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                content: const Text(
                  'Số điện thoại này đã tồn tại trong hệ thống.\nBạn có chắc chắn muốn tiếp tục lưu không?',
                  style: TextStyle(fontSize: 16),
                ),
                actionsPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                actionsAlignment: MainAxisAlignment.spaceBetween,
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

    // Chuẩn hóa dữ liệu đầu vào
    final newCustomer = Customer(
      customerId: _idController.text.toUpperCase(), //prefix
      customerName: _nameController.text,
      companyName: _companyNameController.text,
      companyAddress: _companyAddressController.text,
      shippingAddress: _shippingAddressController.text,
      distance: double.tryParse(_distanceController.text) ?? 0,
      mst: _mstController.text,
      phone: _phoneController.text,
      cskh: _cskhController.text,
      contactPerson: _contactPersonController.text,
      dayCreated: dayCreated ?? DateTime.now(),
      debtLimit: double.tryParse(_debtLimitController.text) ?? 0,
      timePayment: timePayment ?? DateTime.now(),
      rateCustomer: typeRating,
    );

    try {
      final bool isAdd = widget.customer == null;

      AppLogger.i(
        isAdd
            ? "Thêm khách hàng mới: ${newCustomer.customerId}"
            : "Cập nhật khách hàng: ${newCustomer.customerId}",
      );

      isAdd
          ? await CustomerService().addCustomer(customerData: newCustomer.toJson())
          : await CustomerService().updateCustomer(
            customerId: newCustomer.customerId,
            updateCustomer: newCustomer.toJson(),
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

      widget.onCustomerAddOrUpdate();

      if (!mounted) return;
      Navigator.of(context).pop();
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
    _idController.dispose();
    _nameController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _shippingAddressController.dispose();
    _distanceController.dispose();
    _mstController.dispose();
    _phoneController.dispose();
    _cskhController.dispose();
    _contactPersonController.dispose();
    _dayCreatedController.dispose();
    _debtLimitController.dispose();
    _timePaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;

    final List<Map<String, dynamic>> basicInfoRows = [
      {
        "leftKey": "Mã khách hàng",
        "leftValue": ValidationCustomer.validateInput(
          label: "Mã khách hàng",
          controller: _idController,
          icon: Icons.badge,
          readOnly: isEdit,
          checkId: !isEdit,
          allCustomers: allCustomers,
          currentCustomerId: widget.customer?.customerId,
        ),
        "rightKey": "Tên khách hàng",
        "rightValue": ValidationCustomer.validateInput(
          label: "Tên khách hàng",
          controller: _nameController,
          icon: Icons.person,
        ),
      },

      {
        "leftKey": "Tên công ty",
        "leftValue": ValidationCustomer.validateInput(
          label: "Tên công ty",
          controller: _companyNameController,
          icon: Icons.business,
        ),
        "rightKey": "Mã Số Thuế",
        "rightValue": ValidationCustomer.validateInput(
          label: "MST",
          controller: _mstController,
          icon: Icons.numbers,
          allCustomers: allCustomers,
          currentCustomerId: widget.customer?.customerId,
        ),
      },

      {
        "leftKey": "Địa chỉ công ty",
        "leftValue": ValidationCustomer.validateInput(
          label: "Địa chỉ công ty",
          controller: _companyAddressController,
          icon: Icons.location_city,
        ),
        "rightKey": "Địa chỉ giao hàng",
        "rightValue": ValidationCustomer.validateInput(
          label: "Địa chỉ giao hàng",
          controller: _shippingAddressController,
          icon: Icons.local_shipping,
        ),
      },

      {
        "leftKey": "Số Điện Thoại",
        "leftValue": ValidationCustomer.validateInput(
          label: "SDT",
          controller: _phoneController,
          icon: Icons.phone,
        ),
        "rightKey": "Người Liên Hệ",
        "rightValue": ValidationCustomer.validateInput(
          label: "Người Liên Hệ",
          controller: _contactPersonController,
          icon: Icons.person,
        ),
      },

      {
        "leftKey": "CSKH",
        "leftValue": ValidationCustomer.validateInput(
          label: "CSKH",
          controller: _cskhController,
          icon: Icons.support_agent,
        ),
        "rightKey": "",
        "rightValue": const SizedBox(),
      },
    ];

    final List<Map<String, dynamic>> otherInfoRows = [
      {
        "leftKey": "Hạn Mức Công Nợ",
        "leftValue": ValidationCustomer.validateInput(
          label: "Hạn Mức Công Nợ",
          controller: _debtLimitController,
          icon: Icons.money,
        ),
        "rightKey": "Hạn Thanh Toán",
        "rightValue": ValidationOrder.validateInput(
          label: "Hạn Thanh Toán",
          controller: _timePaymentController,
          icon: Symbols.calendar_month,
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: timePayment ?? DateTime.now(),
              firstDate: DateTime.now(),
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
                timePayment = pickedDate;
                _timePaymentController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
              });
            }
          },
        ),
      },
      {
        "leftKey": "Khoảng Cách Giao Hàng",
        "leftValue": ValidationCustomer.validateInput(
          label: "Khoảng Cách Giao Hàng",
          controller: _distanceController,
          icon: Icons.social_distance,
        ),
        "rightKey": "Đánh Giá",
        "rightValue": ValidationOrder.dropdownForTypes(
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

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(
          isEdit ? "Cập nhật khách hàng" : "Thêm khách hàng",
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
                          title: "Thông Tin Khác",
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
