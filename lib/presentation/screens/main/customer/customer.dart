import 'package:dongtam/data/controller/userController.dart';
import 'package:dongtam/presentation/components/dialog/dialog_add_customer.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_customer.dart';
import 'package:dongtam/presentation/sources/customer_dataSource.dart';
import 'package:dongtam/service/customer_Service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  late Future<List<Customer>> futureCustomer;
  late CustomerDatasource customerDatasource;
  late List<GridColumn> columns;
  final userController = Get.find<UserController>();
  TextEditingController searchController = TextEditingController();
  bool selectedAll = false;
  bool isTextFieldEnabled = false;
  String searchType = "Tất cả";
  String? selectedCustomerId;

  @override
  void initState() {
    super.initState();
    loadCustomer(true);

    columns = buildCustomerColumn();
  }

  void loadCustomer(bool refresh) {
    setState(() {
      futureCustomer = CustomerService().getAllCustomers(refresh);
    });
  }

  void searchCustomer() {
    String keyword = searchController.text.trim().toLowerCase();

    if (isTextFieldEnabled && keyword.isEmpty) return;

    if (searchType == "Tất cả") {
      setState(() {
        futureCustomer = CustomerService().getAllCustomers(false);
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
    final bool isSale = userController.hasPermission("sale");

    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            //button
            SizedBox(
              height: 70,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //left button
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

                        //input
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

                        //find
                        AnimatedButton(
                          onPressed: () {
                            searchCustomer();
                          },
                          label: "Tìm kiếm",
                          icon: Icons.search,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),

                  //right button
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child:
                        isSale
                            ? Row(
                              children: [
                                //add
                                AnimatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => CustomerDialog(
                                            customer: null,
                                            onCustomerAddOrUpdate:
                                                () => loadCustomer(false),
                                          ),
                                    );
                                  },
                                  label: "Thêm mới",
                                  icon: Icons.add,
                                ),
                                const SizedBox(width: 10),

                                // update
                                AnimatedButton(
                                  onPressed:
                                      isSale
                                          ? () {
                                            if (selectedCustomerId == null ||
                                                selectedCustomerId!.isEmpty) {
                                              showSnackBarError(
                                                context,
                                                'Vui lòng chọn sản phẩm cần sửa',
                                              );
                                              return;
                                            }

                                            CustomerService()
                                                .getCustomerById(
                                                  selectedCustomerId!,
                                                )
                                                .then((product) {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (_) => CustomerDialog(
                                                          customer:
                                                              product.first,
                                                          onCustomerAddOrUpdate:
                                                              () =>
                                                                  loadCustomer(
                                                                    false,
                                                                  ),
                                                        ),
                                                  );
                                                });
                                          }
                                          : null,
                                  label: "Sửa",
                                  icon: Symbols.construction,
                                ),

                                const SizedBox(width: 10),

                                //delete customers
                                AnimatedButton(
                                  onPressed:
                                      isSale &&
                                              selectedCustomerId != null &&
                                              selectedCustomerId!.isNotEmpty
                                          ? () => _confirmDelete(context)
                                          : null,
                                  label: "Xóa",
                                  icon: Icons.delete,
                                  backgroundColor: Color(0xffEA4346),
                                ),
                              ],
                            )
                            : SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // table
            Expanded(
              child: FutureBuilder(
                future: futureCustomer,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có khách hàng nào",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    );
                  }

                  final List<Customer> data = snapshot.data!;

                  customerDatasource = CustomerDatasource(
                    customer: data,
                    selectedCustomerId: selectedCustomerId,
                  );

                  return SfDataGrid(
                    source: customerDatasource,
                    columns: columns,
                    isScrollbarAlwaysShown: true,
                    columnWidthMode: ColumnWidthMode.auto,
                    selectionMode: SelectionMode.single,
                    onSelectionChanged: (addedRows, removedRows) {
                      if (addedRows.isNotEmpty) {
                        final selectedRow = addedRows.first;
                        final customerId =
                            selectedRow
                                .getCells()
                                .firstWhere(
                                  (cell) => cell.columnName == 'customerId',
                                )
                                .value
                                .toString();

                        final selectedCustomer = data.firstWhere(
                          (customer) => customer.customerId == customerId,
                        );

                        setState(() {
                          selectedCustomerId = selectedCustomer.customerId;
                        });
                      } else {
                        setState(() {
                          selectedCustomerId = null;
                        });
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            futureCustomer = CustomerService().getAllCustomers(true);
          });
        },
        backgroundColor: Color(0xff78D761),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    bool isDeleting = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: const [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 30,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Xác nhận xoá",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content:
                  isDeleting
                      ? Row(
                        children: const [
                          CircularProgressIndicator(strokeWidth: 2),
                          SizedBox(width: 12),
                          Text("Đang xoá..."),
                        ],
                      )
                      : const Text(
                        'Bạn có chắc chắn muốn xoá khách hàng này?',
                        style: TextStyle(fontSize: 16),
                      ),
              actions:
                  isDeleting
                      ? []
                      : [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Huỷ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffEA4346),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            setStateDialog(() {
                              isDeleting = true;
                            });

                            await CustomerService().deleteCustomer(
                              selectedCustomerId!,
                            );
                            await Future.delayed(const Duration(seconds: 1));

                            setState(() {
                              selectedCustomerId = null;
                              futureCustomer = CustomerService()
                                  .getAllCustomers(false);
                            });

                            Navigator.pop(context);
                            showSnackBarSuccess(context, 'Xoá thành công');
                          },
                          child: const Text(
                            "Xoá",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
}
