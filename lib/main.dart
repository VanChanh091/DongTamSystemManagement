import 'package:dongtam/presentation/screens/auth/login.dart';
import 'package:dongtam/presentation/screens/home/dashboard.dart';
import 'package:dongtam/utils/secure_storage_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SecureStorageService secureStorage = SecureStorageService();
  String? token = await secureStorage.getToken();

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? Dashboard() : LoginScreen(),
    );
  }
}
