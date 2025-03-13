import 'package:dongtam/presentation/components/dialog_add_customer.dart';
import 'package:dongtam/service/customer_Service.dart';
import 'package:flutter/material.dart';
import 'package:dongtam/data/models/customer_model.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  late Future<List<Customer>> futureCustomer;
  TextEditingController searchController = TextEditingController();
  List<Customer> filteredCustomers = [];
  List<String> isSelected = [];
  bool selectedAll = false;

  @override
  void initState() {
    super.initState();
    futureCustomer = CustomerService().getAllCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          //search
          SizedBox(
            height: 80,
            width: double.infinity,
            child: Row(
              children: [
                DropdownButton<String>(
                  value: "Tất cả",
                  items:
                      ['Tất cả', "Theo Mã", "Theo Tên"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (value) {},
                ),
                SizedBox(width: 10),

                SizedBox(
                  width: 250,
                  child: Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm...',
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // find
                ElevatedButton.icon(
                  onPressed: () {},
                  label: Text("Tìm kiếm"),
                  icon: Icon(Icons.search),
                ),
                const SizedBox(width: 10),

                // refresh
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      futureCustomer = CustomerService().getAllCustomers();
                    });
                  },
                  label: Text("Tải lại"),
                  icon: Icon(Icons.refresh),
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
                  label: Text("Thêm mới"),
                  icon: Icon(Icons.add),
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
                                        onPressed: () => Navigator.pop(context),
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
                  label: Text("Xóa"),
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
          ),

          // table
          Expanded(
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

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    width: double.infinity,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        const Color.fromARGB(255, 185, 182, 182),
                      ),
                      columnSpacing: 25,
                      // dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                      //   (Set<WidgetState> states) => Colors.grey[50],
                      // ),
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
                        DataColumn(label: Text('Mã KH')),
                        DataColumn(label: Text('Tên KH')),
                        DataColumn(label: Text('Tên Công Ty')),
                        DataColumn(label: Text('Địa chỉ công ty')),
                        DataColumn(label: Text('Địa chỉ Giao Hàng')),
                        DataColumn(label: Text('MST')),
                        DataColumn(label: Text('SDT')),
                        DataColumn(label: Text('CSKH')),
                        DataColumn(label: Text("")),
                      ],
                      rows: List<DataRow>.generate(data.length, (index) {
                        final customer = data[index];
                        return DataRow(
                          color: WidgetStateProperty.all(
                            index % 2 == 0
                                ? Colors.white
                                : Colors.grey.shade200,
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
                                  });
                                },
                              ),
                            ),
                            DataCell(Text(customer.customerId)),
                            DataCell(Text(customer.customerName)),
                            DataCell(Text(customer.companyName)),
                            DataCell(Text(customer.companyAddress)),
                            DataCell(Text(customer.shippingAddress)),
                            DataCell(Text(customer.mst.toString())),
                            DataCell(Text(customer.phone.toString())),
                            DataCell(Text(customer.cskh)),
                            DataCell(
                              PopupMenuButton(
                                icon: Icon(Icons.more_vert),
                                onSelected: (String choice) {
                                  if (choice == 'edit') {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => CustomerDialog(
                                            customer: customer,
                                            onCustomerAddOrUpdate: () {
                                              setState(() {
                                                futureCustomer =
                                                    CustomerService()
                                                        .getAllCustomers();
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
                                                onPressed: () {
                                                  CustomerService()
                                                      .deleteCustomer(
                                                        customer.customerId,
                                                      )
                                                      .then((_) {
                                                        setState(() {
                                                          futureCustomer =
                                                              CustomerService()
                                                                  .getAllCustomers();
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
                          ],
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
