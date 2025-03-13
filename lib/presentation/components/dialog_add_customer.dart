import 'package:dongtam/data/models/customer_model.dart';
import 'package:dongtam/service/customer_Service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomerDialog extends StatefulWidget {
  final Customer? customer;
  final VoidCallback onCustomerAddOrUpdate;

  const CustomerDialog({
    Key? key,
    this.customer,
    required this.onCustomerAddOrUpdate,
  }) : super(key: key);

  @override
  State<CustomerDialog> createState() => _ShowDialogState();
}

class _ShowDialogState extends State<CustomerDialog> {
  final formKey = GlobalKey<FormState>();

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
      _idController.text = widget.customer!.customerId.toString();
      _nameController.text = widget.customer!.customerName;
      _companyNameController.text = widget.customer!.companyName;
      _companyAddressController.text = widget.customer!.companyAddress;
      _shippingAddressController.text = widget.customer!.shippingAddress;
      _mstController.text = widget.customer!.mst;
      _phoneController.text = widget.customer!.phone;
      _cskhController.text = widget.customer!.cskh;
    }
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

  void submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final newCustomer = Customer(
      customerId: widget.customer?.customerId ?? _idController.text,
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
        await CustomerService().addCustomer(newCustomer.toJson());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Thêm thành công")));
      } else {
        await CustomerService().updateCustomer(
          newCustomer.customerId,
          newCustomer.toJson(),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Cập nhật thành công")));
      }

      widget.onCustomerAddOrUpdate();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: không thể lưu dữ liệu")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;

    return AlertDialog(
      title: Text(isEdit ? "Cập nhật khách hàng" : "Thêm khách hàng"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            validateInput("Mã Khách hàng", _idController),
            validateInput("Tên công ty", _nameController),
            validateInput("Địa chỉ công ty", _companyAddressController),
            validateInput("Địa chỉ giao hàng", _shippingAddressController),
            validateInput("MST", _mstController),
            validateInput("SDT", _phoneController),
            validateInput("CSKH", _cskhController),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Hủy")),
        ElevatedButton(
          onPressed: submit,
          child: Text(isEdit ? "Cập nhật" : "Thêm"),
        ),
      ],
    );
  }
}

Widget validateInput(String label, TextEditingController controller) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "Không được để trống";
      }
      return null;
    },
  );
}
