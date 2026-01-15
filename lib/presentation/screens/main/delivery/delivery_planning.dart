import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/models/admin/admin_vehicle_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/service/admin/admin_service.dart';
import 'package:dongtam/service/delivery_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryTrip {
  final int sequence;
  final List<AdminVehicleModel> vehicles;

  DeliveryTrip({required this.sequence, required this.vehicles});
}

class DeliveryPlanning extends StatefulWidget {
  const DeliveryPlanning({super.key});

  @override
  State<DeliveryPlanning> createState() => _DeliveryPlanningState();
}

class _DeliveryPlanningState extends State<DeliveryPlanning> {
  List<PlanningPaper> pendingPapers = [];
  List<DeliveryTrip> trips = [];
  final themeController = Get.find<ThemeController>();
  final Map<String, List<PlanningPaper>> vehicleOrders = {};

  @override
  void initState() {
    super.initState();

    loadPlanningWaiting();
    loadVehicles();
  }

  Future<void> loadPlanningWaiting() async {
    final data = await DeliveryService().getPlanningWaitingDelivery();
    setState(() {
      pendingPapers = data;
    });
  }

  Future<void> loadVehicles() async {
    final vehicles = await AdminService().getAllVehicle();

    setState(() {
      trips = [];
    });

    setState(() {
      trips = [
        DeliveryTrip(sequence: 1, vehicles: vehicles),
        DeliveryTrip(sequence: 2, vehicles: vehicles),
        DeliveryTrip(sequence: 3, vehicles: vehicles),
      ];
    });
  }

  String buildVehicleKey(int tripSeq, int vehicleId) {
    return '${tripSeq}_$vehicleId';
  }

  double _calculateTotalVolume(String vehicleKey) {
    final orders = vehicleOrders[vehicleKey] ?? [];
    return orders.fold(0.0, (sum, paper) => sum + (paper.volume ?? 0.0));
  }

  void _removePaperFromEverywhere(PlanningPaper paper) {
    // remove bên trái
    pendingPapers.removeWhere((p) => p.planningId == paper.planningId);

    // remove khỏi tất cả xe (phòng trường hợp kéo lại)
    for (final entry in vehicleOrders.entries) {
      entry.value.removeWhere((p) => p.planningId == paper.planningId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await loadPlanningWaiting();
          await loadVehicles();
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
        // LUÔN TRẢ VỀ CONTAINER để giữ Border và cấu trúc UI
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER - Phần này luôn hiển thị
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

              // PHẦN NỘI DUNG - Kiểm tra rỗng ở đây
              Expanded(
                child:
                    pendingPapers.isEmpty
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

  Widget _planningPaperCard({required PlanningPaper paper, bool isDragging = false}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 120),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDragging ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow:
            isDragging
                ? [
                  BoxShadow(
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 3),
                    color: Colors.black12,
                  ),
                ]
                : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mã đơn
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mã Đơn: ${paper.orderId} ${paper.order?.flute ?? ""} ${paper.order?.QC_box ?? ""}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Khách Hàng: ${paper.order?.customer?.customerName ?? ''}",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              "${paper.volume} m³",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
            ),
          ),
        ],
      ),
    );
  }

  //right UI
  Widget _buildTrips() {
    return ListView(
      children:
          trips.map((trip) {
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🚚 TÀI ${trip.sequence}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      Column(
                        children:
                            trip.vehicles.map((v) {
                              return _buildVehicleCard(v, trip.sequence);
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildVehicleCard(AdminVehicleModel vehicle, int tripSeq) {
    final key = buildVehicleKey(tripSeq, vehicle.vehicleId!);
    final orders = vehicleOrders[key] ?? [];

    // Tính toán volume hiện tại
    final currentVolume = _calculateTotalVolume(key);
    final maxVolume = vehicle.volumeCapacity;
    final isOverloaded = currentVolume > maxVolume;

    return DragTarget<PlanningPaper>(
      onWillAcceptWithDetails: (details) {
        final paper = details.data;
        return !orders.any((p) => p.planningId == paper.planningId);
      },

      // Thay cho onAccept
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
                        'Biển số: ${vehicle.licensePlate}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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

              // Tìm đến phần này trong hàm _buildVehicleCard của bạn:
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (orders.isEmpty) return const SizedBox.shrink();

                    return Theme(
                      // Làm thanh cuộn nhỏ gọn hơn (tùy chọn)
                      data: Theme.of(context).copyWith(
                        scrollbarTheme: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(Colors.grey.withValues(alpha: 0.5)),
                        ),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(right: 8), // Chừa chỗ cho thanh cuộn
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final paper = orders[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            // Sử dụng hàm dùng chung đã tạo hoặc code Draggable của bạn
                            child: _buildDraggablePaper(paper, constraints.maxWidth),
                          );
                        },
                      ),
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
  Widget _buildDraggablePaper(PlanningPaper paper, double width) {
    return Draggable<PlanningPaper>(
      data: paper,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(width: width, child: _planningPaperCard(paper: paper, isDragging: true)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _planningPaperCard(paper: paper)),
      child: _planningPaperCard(paper: paper),
    );
  }
}
