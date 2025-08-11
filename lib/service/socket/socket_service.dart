import 'package:dongtam/constant/appInfo.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  // Singleton pattern
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentRoom;

  IO.Socket get socket {
    if (_socket == null) throw Exception("Socket chưa được khởi tạo");
    return _socket!;
  }

  bool get isConnected => _isConnected;

  // Kết nối socket nếu chưa kết nối
  Future<void> connectToSocket(String machineName) async {
    final room = 'machine_${machineName.toLowerCase().replaceAll(' ', '_')}';

    if (_isConnected && _currentRoom == room) {
      print('⚠️ Socket already connected to $room');
      return;
    }

    // Nếu đã có socket nhưng khác room → disconnect trước
    if (_socket != null) {
      disconnectSocket();
    }

    final token = await SecureStorageService().getToken();

    _socket = IO.io(
      AppInfo.BASE_URL,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      _currentRoom = room;
      print('✅ Socket connected to $room');
      _socket!.emit('join-machine', room);
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
      _isConnected = false;
      _currentRoom = null;
    });
  }

  // Đăng ký lắng nghe 1 event (và đảm bảo không lặp)
  void on(String event, Function(dynamic data) callback) {
    _socket?.off(event); // Gỡ listener cũ nếu có
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void disconnectSocket() {
    if (_socket != null) {
      print('❌ Disconnecting socket $_currentRoom');
      _socket!.clearListeners();
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
      _currentRoom = null;
    }
  }
}
