import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/service/customer_Service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_customer.dart';
import 'package:flutter/material.dart';

class CustomerDialog extends StatefulWidget {
  final Customer? customer;
  final VoidCallback onCustomerAddOrUpdate;

  const CustomerDialog({
    super.key,
    this.customer,
    required this.onCustomerAddOrUpdate,
  });

  @override
  State<CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<CustomerDialog> {
  final formKey = GlobalKey<FormState>();
  List<Customer> allCustomers = [];

  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _mstController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cskhController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _idController.text = widget.customer!.customerId;
      _nameController.text = widget.customer!.customerName;
      _companyNameController.text = widget.customer!.companyName;
      _companyAddressController.text = widget.customer!.companyAddress;
      _shippingAddressController.text = widget.customer!.shippingAddress;
      _mstController.text = widget.customer!.mst;
      _phoneController.text = widget.customer!.phone;
      _cskhController.text = widget.customer!.cskh;
    }
    fetchAllCustomer();
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _shippingAddressController.dispose();
    _mstController.dispose();
    _phoneController.dispose();
    _cskhController.dispose();
    super.dispose();
  }

  Future<void> fetchAllCustomer() async {
    try {
      allCustomers = await CustomerService().getAllCustomers();
    } catch (e) {
      print("Lỗi lấy danh sách khách hàng: $e");
    }
  }

  void submit() async {
    if (!formKey.currentState!.validate()) return;

    if (widget.customer == null) {
      final isPhoneExist = allCustomers.any(
        (customer) => customer.phone == _phoneController.text,
      );

      if (isPhoneExist) {
        final shouldContinue = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      'Cảnh báo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: const Text(
                  'Số điện thoại này đã tồn tại trong hệ thống.\nBạn có chắc chắn muốn tiếp tục lưu không?',
                  style: TextStyle(fontSize: 16),
                ),
                actionsPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
      mst: _mstController.text,
      phone: _phoneController.text,
      cskh: _cskhController.text,
    );

    try {
      if (widget.customer == null) {
        // add
        await CustomerService().addCustomer(newCustomer.toJson());
        showSnackBarSuccess(context, "Thêm thành công");
      } else {
        // update
        await CustomerService().updateCustomer(
          newCustomer.customerId,
          newCustomer.toJson(),
        );
        showSnackBarSuccess(context, "Cập nhật thành công");
      }

      widget.onCustomerAddOrUpdate();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error: $e");
      showSnackBarError(context, "Lỗi: Không thể lưu dữ liệu");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(
          isEdit ? "Cập nhật khách hàng" : "Thêm khách hàng",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      content: SizedBox(
        width: 700,
        height: 550,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 15),
                ValidationCustomer.validateInput(
                  "Mã Khách hàng",
                  _idController,
                  Icons.badge,
                  readOnly: isEdit,
                ),
                const SizedBox(height: 15),
                ValidationCustomer.validateInput(
                  "Tên khách hàng",
                  _nameController,
                  Icons.person,
                ),
                const SizedBox(height: 15),
                ValidationCustomer.validateInput(
                  "Tên công ty",
                  _companyNameController,
                  Icons.business,
                ),
                const SizedBox(height: 15),
                ValidationCustomer.validateInput(
                  "Địa chỉ công ty",
                  _companyAddressController,
                  Icons.location_city,
                ),
                const SizedBox(height: 15),
                ValidationCustomer.validateInput(
                  "Địa chỉ giao hàng",
                  _shippingAddressController,
                  Icons.local_shipping,
                ),
                const SizedBox(height: 15),
                ValidationCustomer.validateInput(
                  "MST",
                  _mstController,
                  Icons.numbers,
                ),
                const SizedBox(height: 15),
                ValidationCustomer.validateInput(
                  "SDT",
                  _phoneController,
                  Icons.phone,
                ),
                const SizedBox(height: 15),
                ValidationCustomer.validateInput(
                  "CSKH",
                  _cskhController,
                  Icons.support_agent,
                ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Hủy",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.red,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            isEdit ? "Cập nhật" : "Thêm",
            style: TextStyle(
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
