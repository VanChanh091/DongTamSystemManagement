import 'package:dongtam/presentation/splashScreen/splash_screen_dongtam.dart';
import 'package:window_manager/window_manager.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo window_manager
  await windowManager.ensureInitialized();

  runApp(const MyApp());

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await windowManager.maximize();
    await Future.delayed(const Duration(milliseconds: 200));
    await windowManager.show(); // hiển thị cửa sổ
    await windowManager.focus(); // focus vào cửa sổ
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreenDT(),
    );
  }
}
