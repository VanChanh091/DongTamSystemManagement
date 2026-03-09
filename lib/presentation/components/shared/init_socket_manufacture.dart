import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InitSocketManufacture {
  final BuildContext context;
  final dynamic socketService;
  final String eventName;
  final Function() onLoadData;
  final Function(String) onMachineChanged;

  InitSocketManufacture({
    required this.context,
    required this.socketService,
    required this.eventName,
    required this.onLoadData,
    required this.onMachineChanged,
  });

  Future<void> registerSocket(String machine) async {
    socketService.joinMachineRoom(machine);

    socketService.off(eventName);
    socketService.on(eventName, (data) => _onSocketUpdated(data));
  }

  String machineRoomName(String machineName) =>
      'machine_${machineName.toLowerCase().replaceAll(' ', '_')}';

  Future<void> changeMachine({required String oldMachine, required String newMachine}) async {
    final oldRoom = machineRoomName(oldMachine);
    AppLogger.i("changeMachine: from=$oldRoom to=$newMachine");

    // rời room cũ
    await socketService.leaveRoom(oldRoom);

    // cập nhật state trước (UI)
    onMachineChanged(newMachine);

    // gỡ listener cũ
    socketService.off(eventName);

    // join room mới và đăng ký listener
    await socketService.joinMachineRoom(newMachine);
    AppLogger.i("changeMachine: joined newRoom=$newMachine");

    socketService.on(eventName, (data) => _onSocketUpdated(data));

    // load data cho máy mới
    onLoadData();
  }

  void _onSocketUpdated(dynamic data) {
    print("Received socket update: $data");

    bool isPlan = data['isPlan'] ?? false;
    int? senderId = data['senderId'];
    String message = data['message'] ?? "";
    
    final userController = Get.find<UserController>();
    if (!isPlan && senderId != null && senderId == userController.userId.value) {
      // Bỏ qua hiển thị dialog nếu là chính user đang đăng nhập gửi request
      onLoadData();
      showSnackBarSuccess(context, message);
      return;
    }

    _showUpdateDialog(data, isPlan: isPlan);
  }

  void _showUpdateDialog(dynamic data, {required bool isPlan}) {
    final from = data['from'] ?? "";
    final machine = data['machine'] ?? "";
    final message = data['message'] ?? "";

    AppLogger.i("_showUpdateDialog: machine=$machine, message=$message, isPlan=$isPlan");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.all(20),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            actionsPadding: const EdgeInsets.only(right: 20, bottom: 16),

            title: Center(
              child: Row(
                children: [
                  Icon(
                    isPlan ? Icons.notifications_active : Icons.info_outline,
                    color: isPlan ? Colors.green : Colors.blue,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPlan
                        ? 'Thông báo từ: ${from.isNotEmpty ? from : 'Kế hoạch'}'
                        : 'Thông báo từ: Sản xuất',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$message\nNhấn OK để cập nhật dữ liệu.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),

            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onLoadData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPlan ? Colors.green : Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text('OK', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
    );
  }

  void stop(String lastMachineName) {
    final room = machineRoomName(lastMachineName);
    socketService.leaveRoom(room);
    socketService.off(eventName);
  }
}
