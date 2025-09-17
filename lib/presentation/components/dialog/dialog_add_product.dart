import 'dart:typed_data';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/service/product_service.dart';
import 'package:dongtam/utils/helper/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';

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
  final nameProductController = TextEditingController();
  final maKhuonController = TextEditingController();
  final typeProductController = TextEditingController();
  String typeProduct = "Thùng/hộp";
  final List<String> itemsTypeProduct = [
    'Thùng/hộp',
    "Giấy tấm",
    "Giấy quấn cuồn",
    "Giấy cuộn",
    "Giấy kg",
  ];
  Uint8List? pickedProductImage;
  String? productImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      idController.text = widget.product!.productId;
      typeProduct = widget.product!.typeProduct;
      nameProductController.text = widget.product?.productName ?? "";
      maKhuonController.text = widget.product?.maKhuon ?? "";
      productImageUrl = widget.product!.productImage;
    }
  }

  @override
  void dispose() {
    super.dispose();
    idController.dispose();
    nameProductController.dispose();
    maKhuonController.dispose();
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        pickedProductImage = result.files.single.bytes;
      });
    }
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
        await ProductService().addProduct(
          newProduct.productId,
          newProduct.toJson(),
          imageBytes: pickedProductImage,
        );
        showSnackBarSuccess(context, 'Thêm thành công');
      } else {
        // Update existing product
        await ProductService().updateProductById(
          newProduct.productId,
          newProduct.toJson(),
          imageBytes: pickedProductImage,
        );
        showSnackBarSuccess(context, 'Cập nhật thành công');
      }

      widget.onProductAddOrUpdate();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error: $e");
      showSnackBarError(context, 'Lỗi: không thể lưu dữ liệu');
    }

    widget.onProductAddOrUpdate();
  }

  Widget validateInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
    bool checkId = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        fillColor: readOnly ? Colors.grey.shade300 : Colors.white,
        filled: true,
      ),
      validator: (value) {
        if ((label == "Mã Sản Phẩm") && (value == null || value.isEmpty)) {
          return "Không được để trống";
        }
        if (label == "Mã Sản Phẩm") {
          // Kiểm tra nếu có dấu tiếng Việt
          final withoutDiacritics = removeDiacritics(value!);
          if (value != withoutDiacritics) {
            return "Mã sản phẩm không được có dấu tiếng Việt";
          }

          // Regex kiểm tra ký tự đặc biệt nếu muốn
          final pattern = RegExp(r"^[a-zA-Z0-9]+$");
          if (!pattern.hasMatch(value)) {
            return "Mã sản phẩm không được chứa ký tự đặc biệt";
          }
        }
        if (checkId && label == "Mã Sản Phẩm") {
          if (value!.length > 10) {
            return "Mã sản phẩm chỉ được tối đa 10 ký tự";
          }
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
      content: SizedBox(
        width: 550,
        height: 450,
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
                  checkId: !isEdit,
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
                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: Icon(Icons.upload),
                  label: Text(
                    "Chọn ảnh sản phẩm",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (pickedProductImage != null) ...[
                  SizedBox(height: 15),
                  Image.memory(
                    pickedProductImage!,
                    width: 350,
                    height: 350,
                    fit: BoxFit.contain,
                  ),
                ] else if (productImageUrl != null) ...[
                  SizedBox(height: 15),
                  Image.network(
                    productImageUrl!,
                    width: 350,
                    height: 350,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Lỗi tải ảnh');
                    },
                  ),
                ],
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
