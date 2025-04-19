import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/service/product_Service.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:flutter/material.dart';

class ProductDialog extends StatefulWidget {
  final Product? product;
  final VoidCallback onProductAddOrUpdate;

  const ProductDialog({
    super.key,
    this.product,
    required this.onProductAddOrUpdate,
  });

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final formKey = GlobalKey<FormState>();

  final idController = TextEditingController();
  final typeProductController = TextEditingController();
  final nameProductController = TextEditingController();
  final maKhuonController = TextEditingController();
  String typeProduct = "Thùng/hộp";
  final List<String> itemsTypeProduct = [
    'Thùng/hộp',
    "Giấy tấm",
    "Giấy quấn cuồn",
    "Giấy cuộn",
    "Giấy kg",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      idController.text = widget.product!.productId;
      typeProduct = widget.product!.typeProduct;
      nameProductController.text = widget.product!.productName;
      maKhuonController.text = widget.product!.maKhuon;
    }
  }

  @override
  void dispose() {
    super.dispose();
    idController.dispose();
    nameProductController.dispose();
    maKhuonController.dispose();
  }

  void submit() async {
    if (!formKey.currentState!.validate()) return;

    final newProduct = Product(
      productId: idController.text.toUpperCase(),
      typeProduct: typeProduct,
      productName: nameProductController.text,
      maKhuon: maKhuonController.text,
    );

    try {
      if (widget.product == null) {
        // Add new product
        await ProductService().addProduct(newProduct.toJson());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Thêm thành công")));
      } else {
        // Update existing product
        await ProductService().updateProductById(
          newProduct.productId,
          newProduct.toJson(),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Cập nhật thành công")));
      }

      widget.onProductAddOrUpdate();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: không thể lưu dữ liệu")));
    }

    widget.onProductAddOrUpdate();
  }

  static validateInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        fillColor: readOnly ? Colors.grey.shade300 : Colors.white,
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Không được để trống";
        }
        if (label == 'Mã Sản Phẩm' && value.length > 10) {
          return 'Mã khách hàng chỉ được nhập tối đa 10 ký tự';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(
          isEdit ? "Cập nhật sản phẩm" : "Thêm sản phẩm",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      content: Container(
        width: 550,
        height: 400,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(height: 15),
                validateInput(
                  "Mã Sản Phẩm",
                  idController,
                  Icons.code,
                  readOnly: isEdit,
                ),
                SizedBox(height: 15),
                ValidationOrder.dropdownForTypes(
                  itemsTypeProduct,
                  typeProduct,
                  (value) {
                    setState(() {
                      typeProduct = value!;
                    });
                  },
                ),
                SizedBox(height: 15),
                validateInput(
                  "Tên sản phẩm",
                  nameProductController,
                  Icons.production_quantity_limits,
                ),
                SizedBox(height: 15),
                validateInput("Mã khuôn", maKhuonController, Icons.code),
                SizedBox(height: 15),
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
