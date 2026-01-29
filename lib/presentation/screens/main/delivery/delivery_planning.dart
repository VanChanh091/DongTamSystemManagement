import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/models/admin/admin_vehicle_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/service/admin/admin_service.dart';
import 'package:dongtam/service/delivery_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
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
  final themeController = Get.find<ThemeController>();
  final Map<int, TextEditingController> _noteControllers = {};
  final Map<int, bool> _showNoteMap = {};

  Map<String, List<PlanningPaper>> vehicleOrders = {}; //final
  Map<String, List<PlanningPaper>> originalVehicleOrders = {};

  List<AdminVehicleModel> vehicles = [];
  List<PlanningPaper> pendingPapers = [];
  List<DeliveryTrip> trips = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String selectedTripFilter = "Tài 1";

  TextEditingController dayStartController = TextEditingController();

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

    await Future.wait([loadPlanningWaiting(), loadVehicles(), loadPlannedOrders()]);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> loadPlanningWaiting() async {
    final data = await DeliveryService().getPlanningPending();
    setState(() {
      pendingPapers = data;
    });
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
      final plans = await DeliveryService().getDeliveryPlanDetail(deliveryDate: date);

      setState(() {
        vehicleOrders.clear();
        originalVehicleOrders.clear();

        if (plans.isNotEmpty) {
          final plan = plans.first;

          if (plan.deliveryItems != null) {
            for (var item in plan.deliveryItems!) {
              if (item.planning != null) {
                item.planning!.itemStatus = item.status; //item status for order has been cancelled

                //input for note
                final pId = item.planning!.planningId;
                _noteControllers[pId] = TextEditingController(text: item.note ?? "");

                final String key = buildVehicleKey(item.sequence, item.vehicleId);

                // Thêm vào cả 2 map
                vehicleOrders.putIfAbsent(key, () => []);
                vehicleOrders[key]!.add(item.planning!);

                originalVehicleOrders.putIfAbsent(key, () => []);
                originalVehicleOrders[key]!.add(item.planning!);
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
    return orders.fold(0.0, (sum, paper) => sum + (paper.order?.volume ?? 0.0));
  }

  void _removePaperFromEverywhere(PlanningPaper paper) {
    // remove bên trái
    pendingPapers.removeWhere((p) => p.planningId == paper.planningId);

    // remove khỏi tất cả xe (phòng trường hợp kéo lại)
    for (final entry in vehicleOrders.entries) {
      entry.value.removeWhere((p) => p.planningId == paper.planningId);
    }
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

  @override
  void dispose() {
    for (var controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 20),
            //button
            SizedBox(
              height: 60,
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //left button
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: SizedBox(
                            height: 45,
                            width: double.infinity,
                            child: Text(
                              "HÀNG CHỜ SẮP XẾP GIAO",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: themeController.currentColor.value,
                              ),
                            ),
                          ),
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

                                    await loadPlannedOrders();
                                  }
                                },
                              ),
                              const SizedBox(width: 15),

                              //save
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
                                          List<String> overloadedList = [];

                                          for (var vehicle in vehicles) {
                                            for (String seq in ["1", "2", "3", "Xe Ngoài"]) {
                                              final key = buildVehicleKey(seq, vehicle.vehicleId!);
                                              final ordersInVehicle = vehicleOrders[key] ?? [];

                                              if (ordersInVehicle.isNotEmpty) {
                                                double currentVol = _calculateTotalVolume(key);
                                                double maxVol = vehicle.volumeCapacity;

                                                if (currentVol > maxVol) {
                                                  overloadedList.add(
                                                    "${vehicle.vehicleName} (Tài: $seq)",
                                                  );
                                                }
                                              }
                                            }
                                          }

                                          if (overloadedList.isNotEmpty) {
                                            String errorMsg = overloadedList.join(", ");

                                            showSnackBarError(
                                              context,
                                              "Các xe sau đang quá tải: $errorMsg",
                                            );
                                            return;
                                          }

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

                                            vehicleOrders.forEach((key, papers) {
                                              // Key có định dạng: "tripSeq_vehicleId" (ví dụ: "1_3")
                                              final parts = key.split('_');
                                              final seq = parts[0];
                                              final int vehicleId = int.parse(parts[1]);

                                              for (var paper in papers) {
                                                String targetType;
                                                int targetId;

                                                if (paper.hasBox == true) {
                                                  targetType = "box";
                                                  targetId = paper.planningBox!.planningBoxId;
                                                } else {
                                                  targetType = "paper";
                                                  targetId = paper.planningId;
                                                }

                                                items.add({
                                                  "targetType": targetType,
                                                  "targetId": targetId,
                                                  "vehicleId": vehicleId,
                                                  "sequence": seq,
                                                  'note':
                                                      _noteControllers[paper.planningId]?.text ??
                                                      "",
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
                                                loadPlanningWaiting(),
                                                loadPlannedOrders(),
                                              ]);
                                            }

                                            await Future.delayed(const Duration(seconds: 1));
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            showSnackBarError(context, "Có lỗi xảy ra");
                                          } finally {
                                            setState(() => _isSaving = false);
                                          }
                                        },
                              ),
                              const SizedBox(width: 10),

                              //confirm delivery
                              AnimatedButton(
                                onPressed:
                                    !_isEditable
                                        ? null
                                        : () async {
                                          try {
                                            bool confirm = await showConfirmDialog(
                                              context: context,
                                              title: "Xác Nhận Giao Hàng",
                                              content: 'Bạn có muốn chốt lịch giao hàng này không?',
                                              confirmText: "Xác nhận",
                                            );

                                            if (confirm) {
                                              await DeliveryService().confirmForDeliveryPlanning(
                                                deliveryDate: DateFormat(
                                                  'dd/MM/yyyy',
                                                ).parse(dayStartController.text),
                                              );

                                              if (!context.mounted) return;
                                              showSnackBarSuccess(
                                                context,
                                                "Chốt lịch giao hàng thành công",
                                              );
                                            }
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            showSnackBarError(context, "Lỗi không xác định");
                                          }
                                        },
                                label: 'Chốt Lịch',
                                icon: Symbols.confirmation_number,
                                backgroundColor: themeController.buttonColor,
                              ),
                              const SizedBox(width: 10),
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
          setState(() {
            vehicleOrders.clear();
            originalVehicleOrders.forEach((key, list) {
              vehicleOrders[key] = List.from(list);
            });
          });

          await _initializeData();
        },
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  //left UI
  Widget _buildPendingOrders() {
    return DragTarget<PlanningPaper>(
      onAcceptWithDetails: (details) {
        final paper = details.data;

        setState(() {
          _removePaperFromEverywhere(paper);
          pendingPapers.add(paper);
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
                  "📦 Đơn chờ giao",
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
                    _isLoading
                        ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: buildShimmerSkeletonTable(context: context, rowCount: 10),
                        )
                        : pendingPapers.isEmpty
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
                              itemCount: pendingPapers.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final paper = pendingPapers[index];
                                return _buildDraggablePaper(
                                  paper,
                                  constraints.maxWidth - 24,
                                  allowNote: false,
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

  Widget _planningPaperCard({
    required PlanningPaper paper,
    String? status,
    bool isDragging = false,
    bool allowNote = true,
  }) {
    final currentStatus = status ?? paper.itemStatus;
    final bool isCancelled = currentStatus == 'cancelled';
    final pId = paper.planningId;
    final bool isOpen = _showNoteMap[pId] ?? false;
    final controller = _noteControllers.putIfAbsent(pId, () => TextEditingController());

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mã Đơn: ${paper.orderId} ${paper.order?.flute != null ? '- ${paper.order!.flute}' : ''}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Thông tin: ${paper.order?.product?.productName ?? ""} ${paper.lengthPaperPlanning}*${paper.sizePaperPLaning} ${paper.order?.QC_box ?? ""}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Khách Hàng: ${paper.order?.customer?.customerName ?? ''}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (allowNote) ...[
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showNoteMap[pId] = !isOpen;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            isOpen ? Icons.remove_circle : Icons.add_circle,
                            color: isOpen ? Colors.red : Colors.green,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 5),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        "${paper.order?.volume ?? 0} m³",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // input
          if (isOpen)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: controller,
                maxLines: 2,
                minLines: 1,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: "Thêm ghi chú cho đơn này...",
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: Icon(
                    Icons.sticky_note_2_outlined,
                    size: 20,
                    color: Colors.blueGrey.shade400,
                  ),

                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),

                  // Viền khi bình thường
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),

                  // Viền khi nhấn vào (Focus)
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                  ),
                ),
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

      // Khi ở tab Xe Ngoài, mặc định gán tạm vào sequence 1 (hoặc tùy logic của bạn)
      return externalVehicles.map((v) => _buildVehicleCard(v, "Xe Ngoài")).toList();
    } else {
      // Xử lý cho Tài 1, 2, 3
      final targetSeq = selectedTripFilter.split(" ").last;

      // Tìm đúng chuyến (trip) cần hiển thị
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

    return DragTarget<PlanningPaper>(
      onWillAcceptWithDetails: (details) {
        if (!_isEditable) return false;

        final paper = details.data;
        return !orders.any((p) => p.planningId == paper.planningId);
      },

      onAcceptWithDetails: (details) {
        final paper = details.data;

        setState(() {
          _removePaperFromEverywhere(paper);

          vehicleOrders.putIfAbsent(key, () => []);
          vehicleOrders[key]!.add(paper);
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
                constraints: const BoxConstraints(maxHeight: 250),
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
                        });
                      },
                      itemBuilder: (context, index) {
                        final paper = orders[index];
                        return Container(
                          key: ValueKey("${paper.planningId}_$index"),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _buildDraggablePaper(paper, constraints.maxWidth),
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
  Widget _buildDraggablePaper(PlanningPaper paper, double width, {bool allowNote = true}) {
    return Draggable<PlanningPaper>(
      data: paper,
      maxSimultaneousDrags: _isEditable ? 1 : 0,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: width,
          child: _planningPaperCard(paper: paper, isDragging: true, allowNote: allowNote),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _planningPaperCard(paper: paper, allowNote: allowNote),
      ),
      child: _planningPaperCard(paper: paper, allowNote: allowNote),
    );
  }
}
