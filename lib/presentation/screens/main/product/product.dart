import 'package:dongtam/presentation/components/dialog/dialog_add_product.dart';
import 'package:dongtam/service/product_Service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dongtam/data/models/product/product_model.dart';

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
          SizedBox(
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
                      // Color.fromARGB(255, 142, 241, 117),
                      Colors.grey.shade400,
                    ),
                    columns: [
                      DataColumn(
                        label: Checkbox(
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
                      DataColumn(label: styleText("Mã SP")),
                      DataColumn(label: styleText("Loại SP")),
                      DataColumn(label: styleText("Tên SP")),
                      DataColumn(label: styleText("Mã Khuôn")),
                      DataColumn(label: Text("")),
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
                            Checkbox(
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
                          DataCell(styleCell(null, product.productId)),
                          DataCell(styleCell(null, product.typeProduct)),
                          DataCell(styleCell(null, product.productName)),
                          DataCell(styleCell(null, product.maKhuon)),
                          DataCell(
                            SizedBox(
                              width: 30,
                              child: PopupMenuButton(
                                icon: Icon(Icons.more_vert),
                                color: Colors.white,
                                onSelected: (String choice) {
                                  if (choice == 'edit') {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => ProductDialog(
                                            product: product,
                                            onProductAddOrUpdate: () {
                                              setState(() {
                                                futureProducts =
                                                    ProductService()
                                                        .getAllProducts();
                                              });
                                            },
                                          ),
                                    );
                                  } else if (choice == 'delete') {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: Text("Xác nhận"),
                                            content: Text(
                                              'Bạn có chắc chắn muốn xóa không?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: Text("Hủy"),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  await ProductService()
                                                      .deleteProduct(
                                                        product.productId,
                                                      )
                                                      .then((_) {
                                                        setState(() {
                                                          futureProducts =
                                                              ProductService()
                                                                  .getAllProducts();
                                                        });
                                                      });

                                                  Navigator.pop(context);
                                                },
                                                child: Text("Xoá"),
                                              ),
                                            ],
                                          ),
                                    );
                                  }
                                },
                                itemBuilder:
                                    (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                          const PopupMenuItem<String>(
                                            value: 'edit',
                                            child: ListTile(
                                              leading: Icon(Icons.edit),
                                              title: Text('Sửa'),
                                            ),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'delete',
                                            child: ListTile(
                                              leading: Icon(Icons.delete),
                                              title: Text('Xóa'),
                                            ),
                                          ),
                                        ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                );
              },
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

  Widget styleCell(double? width, String text) {
    return Container(width: width, child: Text(text, maxLines: 2));
  }
}
