import 'package:dongtam/data/models/customer_model.dart';
import 'package:dongtam/service/customer_Service.dart';
import 'package:flutter/material.dart';

class CustomerDialog extends StatefulWidget {
  final Customer? customer;
  final VoidCallback onCustomerAddOrUpdate;

  const CustomerDialog({
    Key? key,
    this.customer,
    required this.onCustomerAddOrUpdate,
  }) : super(key: key);

  @override
  State<CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<CustomerDialog> {
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
    if (!formKey.currentState!.validate()) return;

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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(
          isEdit ? "Cập nhật khách hàng" : "Thêm khách hàng",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      content: Container(
        width: 700,
        height: 550,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 15),
                validateInput("Mã Khách hàng", _idController, Icons.badge),
                const SizedBox(height: 15),
                validateInput("Tên khách hàng", _nameController, Icons.person),
                const SizedBox(height: 15),
                validateInput(
                  "Tên công ty",
                  _companyNameController,
                  Icons.business,
                ),
                const SizedBox(height: 15),
                validateInput(
                  "Địa chỉ công ty",
                  _companyAddressController,
                  Icons.location_city,
                ),
                const SizedBox(height: 15),
                validateInput(
                  "Địa chỉ giao hàng",
                  _shippingAddressController,
                  Icons.local_shipping,
                ),
                const SizedBox(height: 15),
                validateInput("MST", _mstController, Icons.numbers),
                const SizedBox(height: 15),
                validateInput("SDT", _phoneController, Icons.phone),
                const SizedBox(height: 15),
                validateInput("CSKH", _cskhController, Icons.support_agent),
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

Widget validateInput(
  String label,
  TextEditingController controller,
  IconData icon,
) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    validator:
        (value) =>
            value == null || value.isEmpty ? 'Vui lòng nhập $label' : null,
  );
}
