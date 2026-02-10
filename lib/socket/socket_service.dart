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

    final token = await SecureStorageService().getToken();

    _socket = io.io(
      AppInfo.BASE_URL,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .enableReconnection()
          .build(),
    );

    // errors
    _socket!.onConnectError((err) => AppLogger.e("❌ Connect error", error: err));
    _socket!.onError((err) => AppLogger.e("❌ Socket error", error: err));
    _socket!.onDisconnect((reason) {
      _isConnected = false;
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
    });
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

  //============================== START JOIN ROOOM=================================
  /// Join machine room (use when open machine screen)
  Future<void> joinMachineRoom(String machineName) async {
    final room = 'machine_${machineName.toLowerCase().replaceAll(' ', '_')}';
    if (_socket == null || !_socket!.connected) await connectSocket();
    _socket!.emit('join-machine', room);
    AppLogger.i("➡️ socket join-machine: $room");
  }

  //join user room
  Future<void> joinUserRoom(int ownerId) async {
    if (_socket == null || !_socket!.connected) await connectSocket();
    _socket!.emit('join-user', ownerId);
    AppLogger.i("➡️ socket join-user: $ownerId");
  }

  /// Leave a room (server must implement socket.on("leave-room", ...))
  Future<void> leaveRoom(String roomName) async {
    if (_socket == null || !_socket!.connected) return;
    _socket!.emit('leave-room', roomName);
    AppLogger.i("❌ socket leave-room: $roomName");
  }
}
