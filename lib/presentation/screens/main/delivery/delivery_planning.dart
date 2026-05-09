import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/admin/admin_vehicle_model.dart';
import 'package:dongtam/data/models/delivery/delivery_request_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/service/delivery_service.dart';
import 'package:dongtam/utils/extension/extension_helper.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/presentation/components/shared/confirm_dialog.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class DeliveryTrip {
  final String sequence;
  final List<AdminVehicleModel> vehicles;

  DeliveryTrip({required this.sequence, required this.vehicles});
}

class DeliveryPlanning extends StatefulWidget {
  const DeliveryPlanning({super.key});

  @override
  State<DeliveryPlanning> createState() => _DeliveryPlanningState();
}

class _DeliveryPlanningState extends State<DeliveryPlanning> {
  //controller
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final badgesController = Get.find<BadgesController>();
  final unsavedChangeController = Get.find<UnsavedChangeController>();

  //width column
  Map<String, List<DeliveryRequest>> vehicleOrders = {};
  Map<String, List<DeliveryRequest>> originalVehicleOrders = {};

  List<DeliveryTrip> trips = [];
  List<AdminVehicleModel> vehicles = [];
  List<DeliveryRequest> pendingRequests = [];

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
  };

  //flag
  bool _isLoading = true;
  bool _isPendingLoading = false;
  bool _isSaving = false;
  bool isTextFieldEnabled = false;
  String selectedTripFilter = "Tài 1";

  TextEditingController dayStartController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    dayStartController.text =
        "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";

    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    await Future.wait([getPlanningRequest(), loadVehicles(), loadPlannedOrders()]);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _fetchData() async {
    final String keyword = searchController.text.trim();
    final String? selectedField = searchFieldMap[searchType];

    final bool shouldSearch = searchType != "Tất cả" && keyword.isNotEmpty;

    getPlanningRequest(
      field: shouldSearch ? selectedField : null,
      keyword: shouldSearch ? keyword : null,
    );
  }

  Future<void> getPlanningRequest({String? field, String? keyword}) async {
    setState(() => _isPendingLoading = true);

    try {
      final data = await ensureMinLoading(
        DeliveryService().getPlanningRequest(field: field, keyword: keyword),
      );

      setState(() {
        pendingRequests = data;
      });
    } catch (e) {
      if (mounted) {
        showSnackBarError(context, "Không thể tải đơn hàng chờ xếp xe");
      }
    } finally {
      if (mounted) {
        setState(() => _isPendingLoading = false);
      }
    }
  }

  Future<void> loadVehicles() async {
    final data = await AdminService().getAllVehicle();

    setState(() {
      vehicles = data;
      vehicleOrders.clear();

      trips = [
        DeliveryTrip(sequence: "1", vehicles: vehicles),
        DeliveryTrip(sequence: "2", vehicles: vehicles),
        DeliveryTrip(sequence: "3", vehicles: vehicles),
        DeliveryTrip(sequence: "Xe Ngoài", vehicles: vehicles),
      ];
    });
  }

  Future<void> loadPlannedOrders() async {
    try {
      final date = DateFormat('dd/MM/yyyy').parse(dayStartController.text);
      final plan = await ensureMinLoading(
        DeliveryService().getDeliveryPlanDetail(deliveryDate: date),
      );

      setState(() {
        vehicleOrders.clear();
        originalVehicleOrders.clear();

        if (plan != null) {
          if (plan.deliveryItems != null) {
            for (var item in plan.deliveryItems!) {
              if (item.request != null) {
                final String key = buildVehicleKey(item.sequence, item.vehicleId);

                vehicleOrders.putIfAbsent(key, () => []);
                originalVehicleOrders.putIfAbsent(key, () => []);

                vehicleOrders.putIfAbsent(key, () => []);
                vehicleOrders[key]!.add(item.request!);

                originalVehicleOrders.putIfAbsent(key, () => []);
                originalVehicleOrders[key]!.add(item.request!);
              }
            }
          }
        }
      });
    } catch (e) {
      debugPrint("Error loadPlannedOrders: $e");
      if (mounted) {
        showSnackBarError(context, "Không thể tải kế hoạch giao hàng");
      }
    }
  }

  String buildVehicleKey(String tripSeq, int vehicleId) {
    return '${tripSeq}_$vehicleId';
  }

  double _calculateTotalVolume(String vehicleKey) {
    final orders = vehicleOrders[vehicleKey] ?? [];
    return orders.fold(0.0, (sum, req) => sum + (req.volume));
  }

  bool get _isEditable {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      final selectedDate = DateFormat('dd/MM/yyyy').parse(dayStartController.text);
      // Cho phép sửa nếu selectedDate >= today
      return !selectedDate.isBefore(today);
    } catch (e) {
      return false;
    }
  }

  void _removeRequestFromEverywhere(DeliveryRequest req) {
    // remove bên trái
    pendingRequests.removeWhere((r) => r.requestId == req.requestId);

    // remove khỏi tất cả xe (phòng trường hợp kéo lại)
    for (final entry in vehicleOrders.entries) {
      entry.value.removeWhere((r) => r.requestId == req.requestId);
    }
  }

  @override
  void dispose() {
    super.dispose();
    dayStartController.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlan = userController.hasPermission(permission: "plan");

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 20),
            //button
            SizedBox(
              height: 70,
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //left button
                      Expanded(
                        flex: 1,
                        child: LeftButtonSearch(
                          selectedType: searchType,
                          types: const ['Tất cả', "Mã Đơn Hàng", "Tên Khách Hàng"],
                          onTypeChanged: (value) {
                            setState(() {
                              searchType = value;
                              isTextFieldEnabled = value != 'Tất cả';
                              searchType == 'Tất cả' ? searchController.clear() : null;
                            });
                          },
                          controller: searchController,
                          textFieldEnabled: isTextFieldEnabled,
                          buttonColor: themeController.buttonColor,

                          onSearch: () => _fetchData(),
                        ),
                      ),

                      //right button
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Ngày giao
                              buildLabelAndUnderlineInput(
                                label: "Ngày giao:",
                                controller: dayStartController,
                                width: 120,
                                readOnly: true,
                                onTap: () async {
                                  final selected = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2026),
                                    lastDate: DateTime(2100),
                                    builder: (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.blue,
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black,
                                          ),
                                          dialogTheme: DialogThemeData(
                                            backgroundColor: Colors.white12,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (selected != null) {
                                    setState(() {
                                      dayStartController.text = DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(selected);
                                      vehicleOrders.clear();
                                    });

                                    unsavedChangeController.runSafe(() async {
                                      await loadPlannedOrders();
                                    });
                                  }
                                },
                              ),
                              const SizedBox(width: 15),

                              //save
                              isPlan
                                  ? Row(
                                    children: [
                                      AnimatedButton(
                                        label: _isSaving ? 'Đang lưu...' : 'Lưu',
                                        icon: _isSaving ? null : Symbols.save,
                                        backgroundColor:
                                            (!_isEditable || _isSaving)
                                                ? Colors.grey
                                                : themeController.buttonColor,
                                        onPressed:
                                            (!_isEditable || _isSaving)
                                                ? null
                                                : () async {
                                                  //check overload
                                                  // List<String> overloadedList = [];

                                                  // for (var vehicle in vehicles) {
                                                  //   for (String seq in ["1", "2", "3", "Xe Ngoài"]) {
                                                  //     final key = buildVehicleKey(seq, vehicle.vehicleId!);
                                                  //     final ordersInVehicle = vehicleOrders[key] ?? [];

                                                  //     if (ordersInVehicle.isNotEmpty) {
                                                  //       double currentVol = _calculateTotalVolume(key);
                                                  //       double maxVol = vehicle.volumeCapacity;

                                                  //       if (currentVol > maxVol) {
                                                  //         overloadedList.add(
                                                  //           "${vehicle.vehicleName} (Tài: $seq)",
                                                  //         );
                                                  //       }
                                                  //     }
                                                  //   }
                                                  // }

                                                  // if (overloadedList.isNotEmpty) {
                                                  //   String errorMsg = overloadedList.join(", ");

                                                  //   showSnackBarError(
                                                  //     context,
                                                  //     "Các xe sau đang quá tải: $errorMsg",
                                                  //   );
                                                  //   return;
                                                  // }

                                                  setState(() => _isSaving = true);

                                                  try {
                                                    // Kiểm tra xem đã có đơn hàng nào được xếp vào xe chưa
                                                    if (vehicleOrders.values.every(
                                                      (list) => list.isEmpty,
                                                    )) {
                                                      showSnackBarError(
                                                        context,
                                                        "Vui lòng xếp ít nhất một đơn hàng vào xe",
                                                      );
                                                      return;
                                                    }

                                                    List<Map<String, dynamic>> items = [];

                                                    vehicleOrders.forEach((key, requests) {
                                                      // Key có định dạng: "tripSeq_vehicleId" (ví dụ: "1_3")
                                                      final parts = key.split('_');
                                                      final seq = parts[0];
                                                      final int vehicleId = int.parse(parts[1]);

                                                      for (int i = 0; i < requests.length; i++) {
                                                        var req = requests[i];
                                                        items.add({
                                                          "requestId": req.requestId,
                                                          "vehicleId": vehicleId,
                                                          "sequence": seq,
                                                          "idxOrder": i + 1,
                                                        });
                                                      }
                                                    });

                                                    final dayStart = DateFormat(
                                                      'dd/MM/yyyy',
                                                    ).parse(dayStartController.text);

                                                    bool success = await DeliveryService()
                                                        .createDeliveryPlan(
                                                          deliveryDate: dayStart,
                                                          items: items,
                                                        );

                                                    if (success) {
                                                      if (!context.mounted) return;
                                                      showSnackBarSuccess(
                                                        context,
                                                        "Lưu kế hoạch giao hàng thành công",
                                                      );

                                                      await Future.wait([
                                                        getPlanningRequest(),
                                                        loadPlannedOrders(),
                                                      ]);

                                                      // Cập nhật số lượng badge
                                                      badgesController.fetchDeliveryRequest();
                                                    }

                                                    unsavedChangeController.resetUnsavedChanges();
                                                    await Future.delayed(
                                                      const Duration(seconds: 1),
                                                    );
                                                  } catch (e) {
                                                    if (!context.mounted) return;
                                                    showSnackBarError(context, "Có lỗi xảy ra");
                                                  } finally {
                                                    setState(() => _isSaving = false);
                                                  }
                                                },
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  )
                                  : const SizedBox.shrink(),

                              //confirm delivery
                              isPlan
                                  ? Row(
                                    children: [
                                      AnimatedButton(
                                        onPressed:
                                            !_isEditable
                                                ? null
                                                : () async {
                                                  try {
                                                    bool confirm = await showConfirmDialog(
                                                      context: context,
                                                      title: "Xác Nhận Lịch Giao Hàng",
                                                      content:
                                                          'Bạn có muốn triển khai lịch giao hàng này không?',
                                                      confirmText: "Xác nhận",
                                                    );

                                                    if (confirm) {
                                                      await DeliveryService()
                                                          .confirmForDeliveryPlanning(
                                                            deliveryDate: DateFormat(
                                                              'dd/MM/yyyy',
                                                            ).parse(dayStartController.text),
                                                          );
                                                      unsavedChangeController.resetUnsavedChanges();

                                                      if (!context.mounted) return;
                                                      showSnackBarSuccess(
                                                        context,
                                                        "Triển khai lịch giao hàng thành công",
                                                      );
                                                    }
                                                  } catch (e) {
                                                    if (!context.mounted) return;
                                                    showSnackBarError(
                                                      context,
                                                      "Lỗi không xác định",
                                                    );
                                                  }
                                                },
                                        label: 'Triển Khai',
                                        icon: Symbols.confirmation_number,
                                        backgroundColor: themeController.buttonColor,
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //UI
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Row(
                  children: [
                    Expanded(flex: 4, child: _buildPendingOrders()),
                    const SizedBox(width: 12),
                    Expanded(flex: 6, child: _buildTrips()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          unsavedChangeController.runSafe(() async {
            setState(() {
              vehicleOrders.clear();
              originalVehicleOrders.forEach((key, list) {
                vehicleOrders[key] = List.from(list);
              });
            });

            await _initializeData();
          });
        },
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  //left UI
  Widget _buildPendingOrders() {
    return DragTarget<DeliveryRequest>(
      onAcceptWithDetails: (details) {
        final req = details.data;

        bool alreadyInPending = pendingRequests.any((p) => p.requestId == req.requestId);

        if (alreadyInPending) return;

        setState(() {
          _removeRequestFromEverywhere(req);
          pendingRequests.add(req);

          unsavedChangeController.setUnsavedChanges(value: true);
        });
      },

      builder: (context, candidate, rejected) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "📦 Đơn chờ xếp xe",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              Divider(height: 1, color: Colors.grey.shade300),

              // BODY
              Expanded(
                child:
                    _isPendingLoading
                        ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: buildShimmerSkeletonTable(context: context, rowCount: 10),
                        )
                        : pendingRequests.isEmpty
                        ? const Center(
                          child: Text(
                            "Không có đơn hàng nào",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                        )
                        : LayoutBuilder(
                          builder: (context, constraints) {
                            return ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: pendingRequests.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final paper = pendingRequests[index];
                                return _buildDraggablePaper(paper, constraints.maxWidth - 24);
                              },
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _requestedCard({required DeliveryRequest req, String? status, bool isDragging = false}) {
    final formatter = DateFormat('dd/MM/yyyy');

    final currentStatus = status ?? req.status;
    final bool isCancelled = currentStatus == 'cancelled';

    final planning = req.paper;
    final order = planning?.order;
    final qcBox = order?.QC_box;
    final product = order?.product;
    final customer = order?.customer;
    final inventory = order?.Inventory;

    final information =
        "${product!.productName} - ${planning?.lengthPaperPlanning ?? 0}*${planning?.sizePaperPLaning ?? 0} ${qcBox != "" && qcBox != null ? "- $qcBox" : ""}";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDragging ? Colors.blue.shade50 : (isCancelled ? Colors.red.shade50 : Colors.white),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCancelled ? Colors.red.shade300 : Colors.grey.shade300,
          width: isCancelled ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PHẦN BÊN TRÁI: THÔNG TIN CHUNG
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Khách Hàng: ${customer!.customerName}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        "Mã Đơn: ${order!.orderId} - SL Đơn Hàng: ${order.quantityCustomer}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        'Thông tin: $information',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                // PHẦN BÊN PHẢI: VOLUME (TRÊN) & FULLNAME (DƯỚI)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        "${req.volume} m³",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      "SL Đã Giao: ${inventory?.totalQtyOutbound ?? 0} - SL Yêu Cầu: ${req.qtyRegistered}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      ((inventory?.qtyInventory ?? 0) > 0)
                          ? "SL Tồn: ${inventory!.qtyInventory}"
                          : "TG Dự Kiến: ${formatter.format(planning!.dayStart!)} - ${PlanningPaper.formatTimeOfDay(timeOfDay: planning.timeRunning!)}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //right UI
  Widget _buildTrips() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: buildShimmerSkeletonTable(context: context, rowCount: 10),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          // Bộ lọc Tài 1, 2, 3 và Xe Ngoài
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: "Tài 1",
                      label: Text("Tài 1"),
                      icon: Icon(Icons.looks_one),
                    ),
                    ButtonSegment(
                      value: "Tài 2",
                      label: Text("Tài 2"),
                      icon: Icon(Icons.looks_two),
                    ),
                    ButtonSegment(value: "Tài 3", label: Text("Tài 3"), icon: Icon(Icons.looks_3)),
                    ButtonSegment(
                      value: "Xe Ngoài",
                      label: Text("Xe Ngoài"),
                      icon: Icon(Icons.local_shipping),
                    ),
                  ],
                  selected: {selectedTripFilter},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      selectedTripFilter = newSelection.first;
                    });
                  },
                ),
              ),
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade300),

          //body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ListView(children: _buildFilteredTripList()),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredTripList() {
    // Helper kiểm tra xe ngoài
    bool checkIsExternal(AdminVehicleModel v) {
      final house = (v.vehicleHouse).toLowerCase();
      return house.contains("ngoài") || house.contains("ngoai");
    }

    if (selectedTripFilter == "Xe Ngoài") {
      final externalVehicles = vehicles.where((v) => checkIsExternal(v)).toList();

      if (externalVehicles.isEmpty) return [const Center(child: Text("Không có xe ngoài"))];

      // Khi ở tab Xe Ngoài, mặc định gán tạm vào sequence 1
      return externalVehicles.map((v) => _buildVehicleCard(v, "Xe Ngoài")).toList();
    } else {
      // Xử lý cho Tài 1, 2, 3
      final targetSeq = selectedTripFilter.split(" ").last;

      // Tìm đúng chuyến cần hiển thị
      final trip = trips.firstWhere((t) => t.sequence == targetSeq, orElse: () => trips.first);

      // chỉ lấy xe nội bộ
      final internalVehicles = trip.vehicles.where((v) => !checkIsExternal(v)).toList();

      if (internalVehicles.isEmpty) {
        return [const Center(child: Text("Không có xe nội bộ cho Tài này"))];
      }

      return internalVehicles.map((v) => _buildVehicleCard(v, trip.sequence)).toList();
    }
  }

  Widget _buildVehicleCard(AdminVehicleModel vehicle, String tripSeq) {
    final key = buildVehicleKey(tripSeq, vehicle.vehicleId!);
    final orders = vehicleOrders[key] ?? [];

    // Tính toán volume hiện tại
    final currentVolume = _calculateTotalVolume(key);
    final maxVolume = vehicle.volumeCapacity;
    final isOverloaded = currentVolume > maxVolume;

    return DragTarget<DeliveryRequest>(
      onWillAcceptWithDetails: (details) {
        if (!_isEditable) return false;

        final req = details.data;
        return !orders.any((p) => p.requestId == req.requestId);
      },

      onAcceptWithDetails: (details) {
        final req = details.data;

        setState(() {
          _removeRequestFromEverywhere(req);

          vehicleOrders.putIfAbsent(key, () => []);
          vehicleOrders[key]!.add(req);

          unsavedChangeController.setUnsavedChanges(value: true);
        });
      },

      builder: (context, candidate, rejected) {
        final isHover = candidate.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverloaded ? Colors.red : (isHover ? Colors.green : Colors.grey.shade300),
              width: isOverloaded ? 2 : 1,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.vehicleName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vehicle.licensePlate.isNotEmpty ? "Biển số: ${vehicle.licensePlate} - " : ""}Nhà Xe: ${vehicle.vehicleHouse}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOverloaded ? Colors.red.shade100 : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      "${currentVolume.toStringAsFixed(2)} / $maxVolume m³",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOverloaded ? Colors.red.shade900 : Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (orders.isEmpty) return const SizedBox.shrink();

                    return ReorderableListView.builder(
                      shrinkWrap: true,
                      itemCount: orders.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = orders.removeAt(oldIndex);
                          orders.insert(newIndex, item);

                          vehicleOrders[key] = orders;

                          unsavedChangeController.setUnsavedChanges(value: true);
                        });
                      },
                      itemBuilder: (context, index) {
                        final req = orders[index];
                        return Container(
                          key: ValueKey("${req.requestId}_$index"),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _buildDraggablePaper(req, constraints.maxWidth),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //helper
  Widget _buildDraggablePaper(DeliveryRequest req, double width) {
    return Draggable<DeliveryRequest>(
      data: req,
      maxSimultaneousDrags: _isEditable ? 1 : 0,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(width: width, child: _requestedCard(req: req, isDragging: true)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _requestedCard(req: req)),
      child: _requestedCard(req: req),
    );
  }
}
