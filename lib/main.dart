import 'package:dongtam/presentation/screens/auth/login.dart';
import 'package:dongtam/presentation/screens/main/home.dart';
import 'package:dongtam/presentation/splashScreen/splashScreenDT.dart';
import 'package:window_manager/window_manager.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo window_manager
  await windowManager.ensureInitialized();

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreenDT(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await windowManager.maximize(); // mở cửa sổ maximize
    await Future.delayed(const Duration(milliseconds: 200)); // cho chắc
    await windowManager.show(); // hiển thị cửa sổ
    await windowManager.focus(); // focus vào cửa sổ
  });
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? HomePage() : LoginScreen(),
    );
  }
}
