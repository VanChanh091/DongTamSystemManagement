import 'package:dongtam/data/controller/userController.dart';
import 'package:dongtam/main.dart';
import 'package:dongtam/service/config_service.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyAppLauncher extends StatefulWidget {
  const MyAppLauncher({super.key});

  @override
  State<MyAppLauncher> createState() => _MyAppLauncherState();
}

class _MyAppLauncherState extends State<MyAppLauncher> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // WidgetsFlutterBinding.ensureInitialized();

    // Load config, token, permissions
    final config = await loadConfig();
    Get.put<Map<String, dynamic>>(config, tag: "AppConfig");

    SecureStorageService secureStorage = SecureStorageService();
    String? token = await secureStorage.getToken();

    final userController = Get.put(UserController());
    await userController.loadUserData();

    setState(() {
      _isLoggedIn = token != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return MyApp(isLoggedIn: _isLoggedIn);
  }
}
