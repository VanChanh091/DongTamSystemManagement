import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/presentation/screens/auth/login.dart';
import 'package:dongtam/presentation/screens/main/home.dart';
import 'package:dongtam/service/config_service.dart';
import 'package:dongtam/updates/update_services.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
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
    WidgetsFlutterBinding.ensureInitialized();

    // Load config, token, permissions
    final config = await loadConfig();
    Get.put<Map<String, dynamic>>(config, tag: "AppConfig");

    // Check for updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        UpdateService.checkUpdate(context);
      }
    });

    //init dio to check token
    await DioClient().init();

    //get token from secure storage
    SecureStorageService secureStorage = SecureStorageService();
    await secureStorage.deleteToken();
    await secureStorage.deleteUserId();
    await secureStorage.deleteRole();
    await secureStorage.deletePermission();

    String? token = await secureStorage.getToken();

    //get role and permissions
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
    return _isLoggedIn ? HomePage() : LoginScreen();
  }
}
