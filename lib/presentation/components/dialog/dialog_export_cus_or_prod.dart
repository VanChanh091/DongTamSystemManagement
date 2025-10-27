import 'package:dongtam/service/customer_service.dart';
import 'package:dongtam/service/product_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:flutter/material.dart';

class DialogExportCusOrProd extends StatefulWidget {
  final VoidCallback onCusOrProd;
  final bool isProduct;

  const DialogExportCusOrProd({super.key, required this.onCusOrProd, this.isProduct = false});

  @override
  State<DialogExportCusOrProd> createState() => _DialogExportCusOrProdState();
}

class _DialogExportCusOrProdState extends State<DialogExportCusOrProd> {
  ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);
  DateTimeRange? selectedRange;
  String typeProduct = "Giấy Tấm";
  final List<String> itemsTypeProduct = [
    "Giấy Tấm",
    'Thùng/hộp',
    "Giấy Quấn Cuồn",
    "Giấy Cuộn",
    "Giấy Kg",
    "Phí Khác",
  ];

  Future<void> pickDateRange(BuildContext context) async {
    final size = MediaQuery.of(context).size;

    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: selectedRange,
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: size.width * 0.3, maxHeight: size.height * 0.8),
            child: Material(
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: child!,
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedRange = result;
      });
    }
  }

  void submit() async {
    try {
      if (selectedOption.value == 'termPayment') {
        if (selectedRange == null) {
          showSnackBarError(context, 'Vui lòng chọn khoảng thời gian');
          return;
        }
      }

      if (widget.isProduct) {
        AppLogger.i("Export báo cáo product");

        //export product
        await ProductService().exportExcelProduct(
          typeProduct: selectedOption.value == 'typeProduct' ? typeProduct : null,
          all: selectedOption.value == 'all' ? true : false,
        );
      } else {
        AppLogger.i(
          "Export báo cáo customer | "
          "from=${selectedRange?.start}, to=${selectedRange?.end}",
        );

        await CustomerService().exportExcelCustomer(
          fromDate: selectedRange?.start,
          toDate: selectedRange?.end,
          all: selectedOption.value == 'all' ? true : false,
        );
      }
      if (!mounted) return;
      showSnackBarSuccess(context, "Xuất thành công");

      widget.onCusOrProd();

      if (!mounted) return; // check context
      Navigator.of(context).pop();
    } catch (e, s) {
      if (!mounted) return; // check context
      AppLogger.e("Lỗi khi xuất báo cáo", error: e, stackTrace: s);
      showSnackBarError(context, 'Lỗi: Không thể xuất dữ liệu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Xuất File Excel"),
      content: ValueListenableBuilder<String?>(
        valueListenable: selectedOption,
        builder: (context, value, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Option 1: Tất cả báo cáo
              RadioListTile<String>(
                title: const Text("Tất cả", style: TextStyle(fontSize: 16)),
                value: 'all',
                groupValue: value,
                onChanged: (val) => selectedOption.value = val,
              ),

              // Option 2: Theo thời gian
              !widget.isProduct
                  ? RadioListTile<String>(
                    title: const Text("Hạn Thanh Toán", style: TextStyle(fontSize: 16)),
                    value: 'termPayment',
                    groupValue: value,
                    onChanged: (val) => selectedOption.value = val,
                  )
                  : const SizedBox.shrink(),

              // Option 3: Theo loại sp
              widget.isProduct
                  ? RadioListTile<String>(
                    title: const Text("Loại Sản Phẩm", style: TextStyle(fontSize: 16)),
                    value: 'typeProduct',
                    groupValue: value,
                    onChanged: (val) => selectedOption.value = val,
                  )
                  : const SizedBox.shrink(),

              const SizedBox(height: 10),
              if (value == 'termPayment') ...[
                Column(
                  children: [
                    SizedBox(
                      width: 250,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          side: BorderSide(color: Colors.blue.shade400, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => pickDateRange(context),
                        icon: Icon(Icons.date_range, color: Colors.blue.shade400),
                        label: Text(
                          selectedRange == null
                              ? "Chọn khoảng thời gian"
                              : "${selectedRange!.start.day}/${selectedRange!.start.month}/${selectedRange!.start.year} - "
                                  "${selectedRange!.end.day}/${selectedRange!.end.month}/${selectedRange!.end.year}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    if (selectedRange == null)
                      const Text(
                        "Chưa chọn khoảng thời gian",
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                  ],
                ),
              ] else if (value == 'typeProduct') ...[
                ValidationOrder.dropdownForTypes(itemsTypeProduct, typeProduct, (value) {
                  setState(() {
                    typeProduct = value!;
                  });
                }),
              ],
            ],
          );
        },
      ),

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
          child: const Text(
            "Xác nhận",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
