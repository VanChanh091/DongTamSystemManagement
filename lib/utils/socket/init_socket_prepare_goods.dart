import 'package:dongtam/socket/socket_service.dart';
import 'package:flutter/material.dart';

class InitSocketPrepareGoods {
  final BuildContext context;
  final SocketService socketService;
  final Function() onLoadData;

  // Khai báo hằng số cho tên room và event
  static const String roomName = 'prepare-goods';
  static const String eventName = 'prepare-goods-event';

  InitSocketPrepareGoods({
    required this.context,
    required this.socketService,
    required this.onLoadData,
  });

  Future<void> registerSocket() async {
    socketService.joinPrepareGoodsRoom();

    socketService.off(eventName);
    socketService.on(eventName, (data) => _handleNotification(data));
  }

  void _handleNotification(dynamic data) {
    // print("Received socket update: $data");
    final String message = data['message'] ?? "Có đơn hàng mới cần chuẩn bị hàng";
    _showUpdateDialog(message);
  }

  void _showUpdateDialog(String message) {
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
                  Icon(Icons.notifications_active, color: Colors.green, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Yêu Cầu Chuẩn Bị Hàng',
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
                  backgroundColor: Colors.green,
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

  void stop() {
    socketService.leaveRoom(roomName);
    socketService.off(eventName);
  }
}
