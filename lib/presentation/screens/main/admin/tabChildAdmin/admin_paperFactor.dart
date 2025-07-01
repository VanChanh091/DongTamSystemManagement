import 'package:dongtam/data/models/admin/admin_paperFactor_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_update_adminPF.dart';
import 'package:dongtam/service/admin_Service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminPaperFactor extends StatefulWidget {
  const AdminPaperFactor({super.key});

  @override
  State<AdminPaperFactor> createState() => _AdminPaperFactorState();
}

class _AdminPaperFactorState extends State<AdminPaperFactor> {
  late Future<List<AdminPaperFactorModel>> futurePaperFactor;
  Map<String, Map<String, AdminPaperFactorModel>> matrix = {};
  List<String> layerTypes = [];
  List<String> paperTypes = [];
  String? selectedLayer;
  String? selectedPaper;

  final Map<String, String> paperTypeTranslations = {
    'BOTTOM': 'Đáy',
    'SONG_E': 'Sóng E',
    'SONG_B': 'Sóng B',
    'SONG_C': 'Sóng C',
    'DAO': 'Dao',
  };

  final Map<String, String> layerTypeTranslations = {
    '3_LAYER': '3 lớp',
    '4_5_LAYER': '4-5 lớp',
    'MORE_5_LAYER': 'Trên 5 lớp',
  };

  @override
  void initState() {
    super.initState();
    loadPaperFactor();
  }

  void loadPaperFactor() {
    setState(() {
      futurePaperFactor = AdminService().getPaperFactor();
    });
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
                  child: Row(children: [SizedBox(width: 170)]),
                ),

                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      // refresh
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            futurePaperFactor = AdminService().getPaperFactor();
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

                      // //add
                      // ElevatedButton.icon(
                      //   onPressed: () {
                      //     // showDialog(
                      //     //   context: context,
                      //     //   builder:
                      //     //       (_) => CustomerDialog(
                      //     //         customer: null,
                      //     //         onCustomerAddOrUpdate: () {
                      //     //           setState(() {
                      //     //             futureCustomer =
                      //     //                 CustomerService().getAllCustomers();
                      //     //           });
                      //     //         },
                      //     //       ),
                      //     // );
                      //   },
                      //   label: Text(
                      //     "Thêm mới",
                      //     style: TextStyle(
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      //   icon: Icon(Icons.add, color: Colors.white),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Color(0xff78D761),
                      //     foregroundColor: Colors.white,
                      //     padding: EdgeInsets.symmetric(
                      //       horizontal: 15,
                      //       vertical: 15,
                      //     ),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(width: 10),

                      // update
                      ElevatedButton.icon(
                        onPressed: () {
                          if (selectedLayer != null && selectedPaper != null) {
                            final item =
                                matrix[selectedLayer!]![selectedPaper!];
                            if (item != null) {
                              showDialog(
                                context: context,
                                builder:
                                    (_) => UpdateAdminPFDialog(
                                      adminPaperFactorModel: item,
                                      onPaperFactorUpdate: loadPaperFactor,
                                    ),
                              );
                            } else {
                              showSnackBarError(
                                context,
                                "Không tìm thấy dữ liệu cần sửa",
                              );
                            }
                          } else {
                            showSnackBarError(
                              context,
                              "Vui lòng chọn ô cần sửa",
                            );
                          }
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
                    ],
                  ),
                ),
              ],
            ),
          ),

          //table
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: FutureBuilder(
                future: futurePaperFactor,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu'));
                  }

                  final data = snapshot.data!;

                  layerTypes = data.map((e) => e.layerType).toSet().toList();
                  paperTypes = data.map((e) => e.paperType).toSet().toList();

                  // Lưu vào biến toàn cục
                  matrix.clear();
                  for (var item in data) {
                    matrix[item.layerType] ??= {};
                    matrix[item.layerType]![item.paperType] = item;
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                      ),
                      child: Table(
                        border: TableBorder.all(color: Colors.grey),
                        children: [
                          // Header
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade100,
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Layer \\ Paper',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ...paperTypes.map(
                                (p) => Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    paperTypeTranslations[p] ?? p,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Data rows
                          ...layerTypes.map((layer) {
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    layerTypeTranslations[layer] ?? layer,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                ...paperTypes.map((paper) {
                                  final item = matrix[layer]?[paper];
                                  if (item == null) {
                                    return const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text('-'),
                                    );
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedLayer = layer;
                                        selectedPaper = paper;
                                      });
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      color:
                                          (selectedLayer == layer &&
                                                  selectedPaper == paper)
                                              ? Colors.yellow.shade100
                                              : Colors.transparent,
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Hệ số giấy: ${item.coefficient}',
                                          ),
                                          Text(
                                            '% Chạy quấn cuồn: ${item.rollLossPercent}%',
                                          ),
                                          Text(
                                            '% Quá trình chạy: ${item.processLossPercent}%',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
