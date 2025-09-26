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
    _socket!.onConnectError(
      (err) => AppLogger.e("❌ Connect error", error: err),
    );
    _socket!.onError((err) => AppLogger.e("❌ Socket error", error: err));
    _socket!.onDisconnect((reason) {
      _isConnected = false;
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
    });
  }

  /// Join machine room (use when open machine screen)
  Future<void> joinMachineRoom(String machineName) async {
    final room = 'machine_${machineName.toLowerCase().replaceAll(' ', '_')}';
    if (_socket == null || !_socket!.connected) await connectSocket();
    _socket!.emit('join-machine', room);
    AppLogger.i("➡️ join-machine $room");
  }

  /// Leave a room (server must implement socket.on("leave-room", ...))
  Future<void> leaveRoom(String roomName) async {
    if (_socket == null || !_socket!.connected) return;
    _socket!.emit('leave-room', roomName);
    AppLogger.i("❌ leave-room $roomName");
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
    AppLogger.i("❌ Disconnecting global socket");
    _socket!.clearListeners();
    _socket!.disconnect();
    _socket = null;
    _isConnected = false;
  }
}
