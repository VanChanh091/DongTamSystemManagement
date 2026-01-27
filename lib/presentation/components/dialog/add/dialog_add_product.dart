import 'dart:typed_data';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/service/product_service.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/helper/cardForm/format_key_value_card.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/helper/reponsive/reponsive_dialog.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';

class ProductDialog extends StatefulWidget {
  final Product? product;
  final VoidCallback onProductAddOrUpdate;

  const ProductDialog({super.key, this.product, required this.onProductAddOrUpdate});

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final formKey = GlobalKey<FormState>();

  final idController = TextEditingController();
  final nameProductController = TextEditingController();
  final maKhuonController = TextEditingController();
  final typeProductController = TextEditingController();
  String typeProduct = "Giấy Tấm";
  final List<String> itemsTypeProduct = [
    "Giấy Tấm",
    'Thùng/hộp',
    "Giấy Quấn Cuồn",
    "Giấy Cuộn",
    "Giấy Kg",
    "Phí Khác",
  ];
  Uint8List? pickedProductImage;
  String? productImageUrl;
  String? serverIdError;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      AppLogger.i("Khởi tạo form với customerId=${widget.product!.productId}");
      idController.text = widget.product!.productId;
      typeProduct = widget.product!.typeProduct;
      nameProductController.text = widget.product?.productName ?? "";
      maKhuonController.text = widget.product?.maKhuon ?? "";
      productImageUrl = widget.product!.productImage;
    }
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        pickedProductImage = result.files.single.bytes;
      });
      AppLogger.d(
        "Đã chọn ảnh sản phẩm (${result.files.single.name}, ${result.files.single.size} bytes)",
      );
    } else {
      AppLogger.d("Không chọn ảnh nào");
    }
  }

  void submit() async {
    if (!formKey.currentState!.validate()) {
      AppLogger.w("Form không hợp lệ, dừng submit");
      return;
    }

    final newProduct = Product(
      productId: idController.text.toUpperCase(),
      typeProduct: typeProduct,
      productName: nameProductController.text,
      maKhuon: maKhuonController.text,
    );

    try {
      final bool isAdd = widget.product == null;

      AppLogger.i(
        isAdd
            ? "Thêm sản phẩm mới: ${newProduct.productId}"
            : "Cập nhật sản phẩm: ${newProduct.productId}",
      );

      isAdd
          ? await ProductService().addProduct(
            prefix: newProduct.productId,
            product: newProduct.toJson(),
            imageBytes: pickedProductImage,
          )
          : await ProductService().updateProductById(
            productId: newProduct.productId,
            productUpdated: newProduct.toJson(),
            imageBytes: pickedProductImage,
          );

      // Show loadingonProductAddOrUpdate
      if (!mounted) return;
      showLoadingDialog(context);
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.pop(context); // đóng dialog loading

      // Thông báo thành công
      showSnackBarSuccess(context, isAdd ? "Thêm thành công" : "Cập nhật thành công");

      widget.onProductAddOrUpdate();

      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (e.errorCode == 'PREFIX_ALREADY_EXISTS') {
        setState(() {
          serverIdError = 'Tiền mã sản phẩm đã tồn tại';
        });

        // Gọi validate lại để nó hiển thị lỗi đỏ dưới chân ô input ngay lập tức
        formKey.currentState!.validate();
      } else {
        if (mounted) {
          showSnackBarError(context, 'Có lỗi xảy ra, vui lòng thử lại');
        }
      }
    } catch (e, s) {
      if (widget.product == null) {
        AppLogger.e("Lỗi khi thêm sản phẩm", error: e, stackTrace: s);
      } else {
        AppLogger.e("Lỗi khi sửa sản phẩm", error: e, stackTrace: s);
      }

      if (!mounted) return;
      return showSnackBarError(context, 'Lỗi: không thể lưu dữ liệu');
    }
  }

  Widget validateInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
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
        errorText: (label == "Mã Sản Phẩm") ? serverIdError : null,
        fillColor: readOnly ? Colors.grey.shade300 : Colors.white,
        filled: true,
      ),
      onChanged: (value) {
        //xóa lỗi cũ khi user nhập lại
        if (label == "Mã Sản Phẩm" && serverIdError != null) {
          setState(() {
            serverIdError = null;
          });
        }
      },
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

          if (checkId) {
            if (value.length < 10) {
              return 'Mã sản phẩm phải nhập 10 ký tự';
            } else if (value.length > 10) {
              return 'Mã sản phẩm vượt quá 10 ký tự';
            }
          }
        }

        if (label == "Mã Sản Phẩm" && serverIdError != null) {
          return serverIdError;
        }

        return null;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    idController.dispose();
    nameProductController.dispose();
    maKhuonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    final List<Map<String, dynamic>> productInfoRows = [
      {
        "leftKey": "Mã Sản Phẩm",
        "leftValue": validateInput(
          label: "Mã Sản Phẩm",
          controller: idController,
          icon: Icons.code,
          readOnly: isEdit,
          checkId: !isEdit,
        ),
      },
      {
        "leftKey": "Loại Sản Phẩm",
        "leftValue": ValidationOrder.dropdownForTypes(
          items: itemsTypeProduct,
          type: typeProduct,
          onChanged: (value) {
            setState(() {
              typeProduct = value!;
            });
          },
        ),
      },
      {
        "leftKey": "Tên sản phẩm",
        "leftValue": validateInput(
          label: "Tên sản phẩm",
          controller: nameProductController,
          icon: Icons.production_quantity_limits,
        ),
      },
      {
        "leftKey": "Mã khuôn",
        "leftValue": validateInput(
          label: "Mã khuôn",
          controller: maKhuonController,
          icon: Icons.code,
        ),
      },
    ];

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(
          isEdit ? "Cập nhật sản phẩm" : "Thêm sản phẩm",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      content: SizedBox(
        width: ResponsiveSize.getWidth(context, ResponsiveType.small),
        // height: 450,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                ...formatKeyValueRows(
                  rows: productInfoRows,
                  columnCount: 1,
                  labelWidth: 150,
                  centerAlign: true,
                ),
                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.upload),
                  label: const Text(
                    "Chọn ảnh sản phẩm",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (pickedProductImage != null) ...[
                  const SizedBox(height: 15),
                  Image.memory(pickedProductImage!, width: 400, height: 400, fit: BoxFit.contain),
                ] else if (productImageUrl != null) ...[
                  const SizedBox(height: 15),
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
