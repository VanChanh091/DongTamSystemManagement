import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/presentation/components/dialog/dialog_add_product.dart';
import 'package:dongtam/service/product_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:get/get.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<List<Product>> futureProducts;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  TextEditingController searchController = TextEditingController();
  List<String> isSelected = [];
  bool selectedAll = false;
  bool isTextFieldEnabled = false;
  String searchType = "Tất cả";

  @override
  void initState() {
    super.initState();
    loadProduct(false);
  }

  void loadProduct(bool refresh) {
    setState(() {
      futureProducts = ensureMinLoading(
        ProductService().getAllProducts(refresh),
      );
    });
  }

  void searchProduct() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchProduct => searchType=$searchType | keyword=$keyword");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchProduct => searchType=$searchType nhưng keyword rỗng");
      return;
    }

    if (searchType == "Tất cả") {
      setState(() {
        futureProducts = ProductService().getAllProducts(false);
      });
    } else if (searchType == "Theo Mã") {
      setState(() {
        futureProducts = ProductService().getProductById(keyword);
      });
    } else if (searchType == "Theo Tên SP") {
      setState(() {
        futureProducts = ProductService().getProductByName(keyword);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            //button
            SizedBox(
              height: 105,
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    height: 35,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "DANH SÁCH SẢN PHẨM",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: themeController.currentColor.value,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //left button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          child: Row(
                            children: [
                              //dropdown
                              SizedBox(
                                width: 170,
                                child: DropdownButtonFormField<String>(
                                  value: searchType,
                                  items:
                                      const [
                                        'Tất cả',
                                        "Theo Mã",
                                        "Theo Tên SP",
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      searchType = value!;
                                      isTextFieldEnabled =
                                          searchType != 'Tất cả';

                                      searchController.clear();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // input
                              SizedBox(
                                width: 250,
                                height: 50,
                                child: TextField(
                                  controller: searchController,
                                  enabled: isTextFieldEnabled,
                                  onSubmitted: (_) => searchProduct(),
                                  decoration: InputDecoration(
                                    hintText: 'Tìm kiếm...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // find
                              AnimatedButton(
                                onPressed: () {
                                  searchProduct();
                                },
                                label: "Tìm kiếm",
                                icon: Icons.search,
                                backgroundColor: themeController.buttonColor,
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          child:
                              userController.hasPermission("sale")
                                  ? Row(
                                    children: [
                                      //add
                                      AnimatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (_) => ProductDialog(
                                                  product: null,
                                                  onProductAddOrUpdate:
                                                      () => loadProduct(false),
                                                ),
                                          );
                                        },
                                        label: "Thêm mới",
                                        icon: Icons.add,
                                        backgroundColor:
                                            themeController.buttonColor,
                                      ),
                                      const SizedBox(width: 10),

                                      // update
                                      AnimatedButton(
                                        onPressed: () {
                                          if (isSelected.isEmpty) {
                                            showSnackBarError(
                                              context,
                                              'Vui lòng chọn sản phẩm cần sửa',
                                            );
                                            return;
                                          }

                                          String productId = isSelected.first;
                                          ProductService()
                                              .getProductById(productId)
                                              .then((product) {
                                                if (!context.mounted) return;
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (_) => ProductDialog(
                                                        product: product.first,
                                                        onProductAddOrUpdate:
                                                            () => loadProduct(
                                                              false,
                                                            ),
                                                      ),
                                                );
                                              });
                                        },
                                        label: "Sửa",
                                        icon: Symbols.construction,
                                        backgroundColor:
                                            themeController.buttonColor,
                                      ),
                                      const SizedBox(width: 10),

                                      //delete customers
                                      AnimatedButton(
                                        onPressed:
                                            isSelected.isNotEmpty
                                                ? () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      bool isDeleting = false;

                                                      return StatefulBuilder(
                                                        builder: (
                                                          context,
                                                          setStateDialog,
                                                        ) {
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                            title: Row(
                                                              children: const [
                                                                Icon(
                                                                  Icons
                                                                      .warning_amber_rounded,
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                  size: 30,
                                                                ),
                                                                SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Text(
                                                                  "Xác nhận xoá",
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            content:
                                                                isDeleting
                                                                    ? Row(
                                                                      children: const [
                                                                        CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              12,
                                                                        ),
                                                                        Text(
                                                                          "Đang xoá...",
                                                                        ),
                                                                      ],
                                                                    )
                                                                    : Text(
                                                                      'Bạn có chắc chắn muốn xoá ${isSelected.length} sản phẩm?',
                                                                      style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                            actions:
                                                                isDeleting
                                                                    ? []
                                                                    : [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () => Navigator.pop(
                                                                              context,
                                                                            ),
                                                                        child: const Text(
                                                                          "Huỷ",
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                Colors.black54,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                          backgroundColor: const Color(
                                                                            0xffEA4346,
                                                                          ),
                                                                          foregroundColor:
                                                                              Colors.white,
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              8,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        onPressed: () async {
                                                                          setStateDialog(() {
                                                                            isDeleting =
                                                                                true;
                                                                          });

                                                                          for (String
                                                                              id
                                                                              in isSelected) {
                                                                            await ProductService().deleteProduct(
                                                                              id,
                                                                            );
                                                                          }

                                                                          await Future.delayed(
                                                                            const Duration(
                                                                              seconds:
                                                                                  1,
                                                                            ),
                                                                          );

                                                                          if (!context
                                                                              .mounted) {
                                                                            return;
                                                                          }

                                                                          setState(() {
                                                                            isSelected.clear();
                                                                            futureProducts = ProductService().getAllProducts(
                                                                              false,
                                                                            );
                                                                          });

                                                                          Navigator.pop(
                                                                            context,
                                                                          );

                                                                          // Optional: Show success toast
                                                                          showSnackBarSuccess(
                                                                            context,
                                                                            'Xoá thành công',
                                                                          );
                                                                        },
                                                                        child: const Text(
                                                                          "Xoá",
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                }
                                                : null,
                                        label: "Xoá",
                                        icon: Icons.delete,
                                        backgroundColor: const Color(
                                          0xffEA4346,
                                        ),
                                      ),
                                    ],
                                  )
                                  : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // table
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: FutureBuilder<List<Product>>(
                  future: futureProducts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: SizedBox(
                          height: 400,
                          child: buildShimmerSkeletonTable(
                            context: context,
                            rowCount: 10,
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "Không có đơn hàng nào",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      );
                    }

                    final data = snapshot.data!;

                    // Sort the data by the numeric part of productId in ascending order
                    data.sort((a, b) {
                      final aNumeric =
                          int.tryParse(
                            a.productId.replaceAll(RegExp(r'[^0-9]'), ''),
                          ) ??
                          0;
                      final bNumeric =
                          int.tryParse(
                            b.productId.replaceAll(RegExp(r'[^0-9]'), ''),
                          ) ??
                          0;
                      return aNumeric.compareTo(bNumeric);
                    });

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        // columnSpacing: 25,
                        headingRowHeight: 50,
                        headingRowColor: WidgetStatePropertyAll(
                          themeController.currentColor.value,
                        ),
                        columns: [
                          DataColumn(
                            label: Theme(
                              data: Theme.of(context).copyWith(
                                checkboxTheme: CheckboxThemeData(
                                  fillColor: WidgetStateProperty.resolveWith<
                                    Color
                                  >((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return Colors.red;
                                    }
                                    return Colors.white;
                                  }),
                                  checkColor: WidgetStateProperty.all<Color>(
                                    Colors.white,
                                  ),
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Checkbox(
                                value: selectedAll,
                                onChanged: (value) {
                                  setState(() {
                                    selectedAll = value!;
                                    if (selectedAll) {
                                      isSelected =
                                          data.map((e) => e.productId).toList();
                                    } else {
                                      isSelected.clear();
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          DataColumn(label: styleText("Mã Sản Phẩm")),
                          DataColumn(label: styleText("Loại Sản Phẩm")),
                          DataColumn(label: styleText("Tên Sản Phẩm")),
                          DataColumn(label: styleText("Mã Khuôn")),
                          DataColumn(label: styleText("Hình ảnh")),
                        ],
                        rows: List<DataRow>.generate(data.length, (index) {
                          final product = data[index];
                          return DataRow(
                            cells: [
                              DataCell(
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    checkboxTheme: CheckboxThemeData(
                                      fillColor:
                                          WidgetStateProperty.resolveWith<
                                            Color
                                          >((states) {
                                            if (states.contains(
                                              WidgetState.selected,
                                            )) {
                                              return Colors.red;
                                            }
                                            return Colors.white;
                                          }),
                                      checkColor:
                                          WidgetStateProperty.all<Color>(
                                            Colors.white,
                                          ),
                                      side: const BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Checkbox(
                                    value: isSelected.contains(
                                      product.productId,
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          isSelected.add(product.productId);
                                        } else {
                                          isSelected.remove(product.productId);
                                        }
                                        selectedAll =
                                            isSelected.length == data.length;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              DataCell(styleCell(product.productId)),
                              DataCell(styleCell(product.typeProduct)),
                              DataCell(styleCell(product.productName ?? "")),
                              DataCell(styleCell(product.maKhuon ?? "")),
                              DataCell(
                                product.productImage != null &&
                                        product.productImage!.isNotEmpty
                                    ? TextButton(
                                      onPressed: () {
                                        // print(
                                        //   'Attempting to show image from URL: ${product.productImage}',
                                        // );
                                        showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (_) {
                                            return GestureDetector(
                                              onTap:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                              child: Scaffold(
                                                backgroundColor: Colors.black54,
                                                body: Center(
                                                  child: GestureDetector(
                                                    onTap:
                                                        () {}, // Ngăn không cho nhấn vào ảnh đóng dialog
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      child: SizedBox(
                                                        width: 800,
                                                        height: 800,
                                                        child: Image.network(
                                                          product.productImage!,
                                                          fit: BoxFit.contain,
                                                          errorBuilder: (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              width: 300,
                                                              height: 300,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade300,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: const Text(
                                                                "Lỗi ảnh",
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: const Text(
                                        'Xem ảnh',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    )
                                    : const Text('Không có ảnh'),
                              ),
                            ],
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadProduct(true),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
