import 'package:dongtam/constant/app_info.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  // Singleton pattern
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;

  // Lưu trữ các dynamic room đang tham gia để tự động join lại khi Reconnect
  final Set<String> _activeRooms = {};

  bool get isConnected => _isConnected;

  io.Socket get socket {
    if (_socket == null) throw Exception("Socket chưa được khởi tạo");
    return _socket!;
  }

  /// Connect 1 lần (global). Safe to call multiple lần.
  Future<void> connectSocket() async {
    if (_socket != null && _socket!.connected) {
      AppLogger.i("⚠️ Socket already connected");
      return;
    }

    if (_isConnecting) {
      AppLogger.i("⏳ Socket is connecting, please wait...");
      return;
    }

    _isConnecting = true;

    try {
      final token = await SecureStorageService().getToken();

      _socket = io.io(
        AppInfo.BASE_URL,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .enableReconnection()
            .enableForceNew() //Ép buộc xóa bỏ Manager cũ trong cache của thư viện
            .disableMultiplex() //Không dùng chung kết nối cũ để tránh lẫn lộn token
            .build(),
      );

      // errors
      _socket!.onConnectError((err) {
        _isConnected = false;
        _isConnecting = false;
        AppLogger.e("❌ Connect error", error: err);
      });

      _socket!.onError((err) => AppLogger.e("❌ Socket error", error: err));

      _socket!.onDisconnect((reason) {
        _isConnected = false;
        _isConnecting = false;
        AppLogger.w("⚠️ Socket disconnected: $reason");
      });

      _socket!.onConnect((_) {
        _isConnected = true;
        _isConnecting = false;
        AppLogger.i("🟢 Kết nối thành công! Socket ID: ${_socket?.id}");

        // tự động join lại các room đang active khi reconnect
        _rejoinActiveRooms();
      });

      _socket!.connect();
    } catch (e) {
      _isConnecting = false;
      AppLogger.e("❌ Lỗi khi khởi tạo Socket", error: e);
    }
  }

  /// Tự động join lại các phòng đang lắng nghe
  void _rejoinActiveRooms() {
    if (_activeRooms.isEmpty || _socket == null || !_socket!.connected) return;

    AppLogger.i("🔄 Đang khôi phục lại các room: $_activeRooms");
    for (final room in _activeRooms) {
      if (room.startsWith("machine_")) {
        _socket!.emit('join-machine', room);
      } else if (room == "prepare-goods") {
        _socket!.emit('request-prepare');
      } else if (room.startsWith("delivery-")) {
        final dateStr = room.replaceFirst("delivery-", "");
        _socket!.emit('delivery-schedule', dateStr);
      }
    }
  }

  /// Register event listener (ensure not duplicated)
  void on(String event, Function(dynamic) callback) {
    _socket?.off(event);
    _socket?.on(event, callback);
  }

  /// Remove event listener
  void off(String event) {
    _socket?.off(event);
  }

  /// Đăng ký nghe tất cả sự kiện để debug an toàn (Không lo crash)
  void listenAny(Function(String event, dynamic data) callback) {
    _socket?.onAny((event, data) => callback(event.toString(), data));
  }

  /// Disconnect socket fully
  void disconnect() {
    if (_socket == null) return;

    // 1. Gỡ bỏ mọi listener để tránh sự kiện dư thừa
    _socket!.clearListeners();
    _socket!.offAny();

    // 2. Chấm dứt kết nối
    _socket!.disconnect();

    // 3. Giải phóng instance để tránh rò rỉ bộ nhớ
    _socket!.dispose();

    // 4. Reset các flag để trạng thái luônnhất quán
    _socket = null;
    _isConnected = false;

    AppLogger.i("❌ Disconnecting global socket");
  }

  //============================== START JOIN ROOOM =================================

  // Join machine room (use when open machine screen)
  Future<void> joinMachineRoom(String machineName) async {
    final room = 'machine_${machineName.toLowerCase().replaceAll(' ', '_')}';
    _activeRooms.add(room);

    if (_socket == null || !_socket!.connected) {
      await connectSocket();
    } else {
      _socket!.emit('join-machine', room);
      AppLogger.i("➡️ socket join-machine: $room");
    }
  }

  //join prepare goods room
  Future<void> joinPrepareGoodsRoom() async {
    const room = 'prepare-goods';
    _activeRooms.add(room);

    if (_socket == null || !_socket!.connected) {
      await connectSocket();
    } else {
      _socket!.emit('request-prepare');
      AppLogger.i("➡️ socket join: prepare-goods");
    }
  }

  //join delivery schedule room
  Future<void> joinDeliveryScheduleRoom(DateTime deliverDate) async {
    final dateStr = deliverDate.toIso8601String().split('T').first;
    final room = 'delivery-$dateStr';
    _activeRooms.add(room);

    if (_socket == null || !_socket!.connected) {
      await connectSocket();
    } else {
      _socket!.emit('delivery-schedule', dateStr);
      AppLogger.i("➡️ socket join: $room");
    }
  }

  // Leave a room (server must implement socket.on("leave-room", ...))
  Future<void> leaveRoom(String roomName) async {
    _activeRooms.remove(roomName);

    if (_socket == null || !_socket!.connected) return;
    _socket!.emit('leave-room', roomName);
    AppLogger.i("❌ socket leave-room: $roomName");
  }
}
