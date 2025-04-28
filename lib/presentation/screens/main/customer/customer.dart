import 'package:dongtam/presentation/components/dialog/dialog_add_customer.dart';
import 'package:dongtam/service/customer_Service.dart';
import 'package:flutter/material.dart';
import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  late Future<List<Customer>> futureCustomer;
  TextEditingController searchController = TextEditingController();
  List<String> isSelected = [];
  bool selectedAll = false;
  bool isTextFieldEnabled = false;
  String searchType = "Tất cả";

  @override
  void initState() {
    super.initState();
    futureCustomer = CustomerService().getAllCustomers();
    print(CustomerService().getAllCustomers());
  }

  void searchCustomer() {
    String keyword = searchController.text.trim().toLowerCase();

    if (isTextFieldEnabled && keyword.isEmpty) return;

    if (searchType == "Tất cả") {
      setState(() {
        futureCustomer = CustomerService().getAllCustomers();
      });
    } else if (searchType == "Theo Mã") {
      setState(() {
        futureCustomer = CustomerService().getCustomerById(keyword);
      });
    } else if (searchType == "Theo Tên KH") {
      setState(() {
        futureCustomer = CustomerService().getCustomerByName(keyword);
      });
    } else if (searchType == "Theo CSKH") {
      setState(() {
        futureCustomer = CustomerService().getCustomerByCSKH(keyword);
      });
    } else if (searchType == "Theo SDT") {
      setState(() {
        futureCustomer = CustomerService().getCustomerByPhone(keyword);
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
                              [
                                'Tất cả',
                                "Theo Mã",
                                "Theo Tên KH",
                                "Theo CSKH",
                                "Theo SDT",
                              ].map((String value) {
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
                          onSubmitted: (_) => searchCustomer(),
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
                          searchCustomer();
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
                            futureCustomer =
                                CustomerService().getAllCustomers();
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
                                (_) => CustomerDialog(
                                  customer: null,
                                  onCustomerAddOrUpdate: () {
                                    setState(() {
                                      futureCustomer =
                                          CustomerService().getAllCustomers();
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
                          CustomerService().getCustomerById(productId).then((
                            product,
                          ) {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => CustomerDialog(
                                    customer: product.first,
                                    onCustomerAddOrUpdate: () {
                                      setState(() {
                                        futureCustomer =
                                            CustomerService().getAllCustomers();
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
                                                  await CustomerService()
                                                      .deleteCustomer(id);
                                                }

                                                setState(() {
                                                  isSelected.clear();
                                                  futureCustomer =
                                                      CustomerService()
                                                          .getAllCustomers();
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
              child: FutureBuilder<List<Customer>>(
                future: futureCustomer,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }

                  final data = snapshot.data!;

                  // Sort the data by the numeric part of customerId in ascending order
                  data.sort((a, b) {
                    final aNumeric =
                        int.tryParse(
                          a.customerId.replaceAll(RegExp(r'[^0-9]'), ''),
                        ) ??
                        0;
                    final bNumeric =
                        int.tryParse(
                          b.customerId.replaceAll(RegExp(r'[^0-9]'), ''),
                        ) ??
                        0;
                    return aNumeric.compareTo(bNumeric);
                  });

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 25,
                      headingRowColor: WidgetStatePropertyAll(
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
                                      data.map((e) => e.customerId).toList();
                                } else {
                                  isSelected.clear();
                                }
                              });
                            },
                          ),
                        ),
                        DataColumn(label: styleText("Mã KH")),
                        DataColumn(label: styleText("Tên KH")),
                        DataColumn(label: styleText('Tên Công Ty')),
                        DataColumn(label: styleText("Địa chỉ công ty")),
                        DataColumn(label: styleText("Địa chỉ Giao Hàng")),
                        DataColumn(label: styleText('MST')),
                        DataColumn(label: styleText("SDT")),
                        DataColumn(label: styleText("CSKH")),
                      ],
                      rows: List<DataRow>.generate(data.length, (index) {
                        final customer = data[index];
                        return DataRow(
                          color: WidgetStateProperty.all(
                            index % 2 == 0
                                ? Colors.white
                                : const Color.fromARGB(77, 184, 184, 184),
                          ),
                          cells: [
                            DataCell(
                              Checkbox(
                                value: isSelected.contains(customer.customerId),
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      isSelected.add(customer.customerId);
                                    } else {
                                      isSelected.remove(customer.customerId);
                                    }

                                    selectedAll =
                                        isSelected.length == data.length;
                                  });
                                },
                              ),
                            ),
                            DataCell(styleCell(null, customer.customerId)),
                            DataCell(styleCell(120, customer.customerName)),
                            DataCell(styleCell(200, customer.companyName)),
                            DataCell(styleCell(null, customer.companyAddress)),
                            DataCell(styleCell(null, customer.shippingAddress)),
                            DataCell(styleCell(null, customer.mst)),
                            DataCell(styleCell(null, customer.phone)),
                            DataCell(styleCell(55, customer.cskh)),
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
