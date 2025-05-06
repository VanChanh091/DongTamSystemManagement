import 'package:dongtam/presentation/components/dialog/dialog_add_product.dart';
import 'package:dongtam/service/product_Service.dart';
import 'package:flutter/material.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<List<Product>> futureProducts;
  TextEditingController searchController = TextEditingController();
  List<String> isSelected = [];
  bool selectedAll = false;
  bool isTextFieldEnabled = false;
  String searchType = "Tất cả";

  @override
  void initState() {
    super.initState();
    futureProducts = ProductService().getAllProducts();
  }

  void searchProduct() {
    String keyword = searchController.text.trim().toLowerCase();

    if (isTextFieldEnabled && keyword.isEmpty) return;

    if (searchType == "Tất cả") {
      setState(() {
        futureProducts = ProductService().getAllProducts();
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          //button
          SizedBox(
            height: 80,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //dropdown
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      //dropdown
                      SizedBox(
                        width: 170,
                        child: DropdownButtonFormField<String>(
                          value: searchType,
                          items:
                              ['Tất cả', "Theo Mã", "Theo Tên SP"].map((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              searchType = value!;
                              isTextFieldEnabled = searchType != 'Tất cả';

                              if (!isTextFieldEnabled) {
                                searchController.clear();
                              }
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),

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
                      ElevatedButton.icon(
                        onPressed: () {
                          searchProduct();
                        },
                        label: Text(
                          "Tìm kiếm",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Icons.search, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff78D761),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      // refresh
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            futureProducts = ProductService().getAllProducts();
                          });
                        },
                        label: Text(
                          "Tải lại",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Icons.refresh, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff78D761),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      //add
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => ProductDialog(
                                  product: null,
                                  onProductAddOrUpdate: () {
                                    setState(() {
                                      futureProducts =
                                          ProductService().getAllProducts();
                                    });
                                  },
                                ),
                          );
                        },
                        label: Text(
                          "Thêm mới",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Icons.add, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff78D761),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // update
                      ElevatedButton.icon(
                        onPressed: () {
                          if (isSelected.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Vui lòng chọn sản phẩm để sửa"),
                              ),
                            );
                            return;
                          }

                          String productId = isSelected.first;
                          ProductService().getProductById(productId).then((
                            product,
                          ) {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => ProductDialog(
                                    product: product.first,
                                    onProductAddOrUpdate: () {
                                      setState(() {
                                        futureProducts =
                                            ProductService().getAllProducts();
                                      });
                                    },
                                  ),
                            );
                          });
                        },
                        label: Text(
                          "Sửa",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Symbols.construction, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff78D761),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      //delete customers
                      ElevatedButton.icon(
                        onPressed:
                            isSelected.isNotEmpty
                                ? () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text("Xác nhận"),
                                          content: Text(
                                            'Bạn có chắc chắn muốn xóa ${isSelected.length} khách hàng?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: Text("Hủy"),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                for (String id in isSelected) {
                                                  await ProductService()
                                                      .deleteProduct(id);
                                                }

                                                setState(() {
                                                  isSelected.clear();
                                                  futureProducts =
                                                      ProductService()
                                                          .getAllProducts();
                                                });

                                                Navigator.pop(context);
                                              },
                                              child: Text("Xoá"),
                                            ),
                                          ],
                                        ),
                                  );
                                }
                                : null,
                        label: Text(
                          "Xóa",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Icons.delete, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffEA4346),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }

                  final data = snapshot.data!;

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 25,
                      headingRowColor: WidgetStatePropertyAll(
                        Color(0xffcfa381),
                      ),
                      columns: [
                        DataColumn(
                          label: Theme(
                            data: Theme.of(context).copyWith(
                              checkboxTheme: CheckboxThemeData(
                                fillColor: MaterialStateProperty.resolveWith<
                                  Color
                                >((states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.red;
                                  }
                                  return Colors.white;
                                }),
                                checkColor: MaterialStateProperty.all<Color>(
                                  Colors.white,
                                ),
                                side: BorderSide(color: Colors.black, width: 1),
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
                          color: WidgetStateProperty.all(
                            index % 2 == 0
                                ? Colors.white
                                : const Color.fromARGB(77, 184, 184, 184),
                          ),
                          cells: [
                            DataCell(
                              Theme(
                                data: Theme.of(context).copyWith(
                                  checkboxTheme: CheckboxThemeData(
                                    fillColor:
                                        MaterialStateProperty.resolveWith<
                                          Color
                                        >((states) {
                                          if (states.contains(
                                            MaterialState.selected,
                                          )) {
                                            return Colors.red;
                                          }
                                          return Colors.white;
                                        }),
                                    checkColor:
                                        MaterialStateProperty.all<Color>(
                                          Colors.white,
                                        ),
                                    side: BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Checkbox(
                                  value: isSelected.contains(product.productId),
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
                            DataCell(styleCell(product.productName)),
                            DataCell(styleCell(product.maKhuon)),
                            DataCell(
                              styleCell(product.productImage ?? 'Không có ảnh'),
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
    );
  }

  Widget styleText(String text) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }

  Widget styleCell(String text) {
    return SizedBox(child: Text(text, maxLines: 2));
  }
}
