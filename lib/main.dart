import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/presentation/splashScreen/splash_screen_dongtam.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
// import 'package:auto_updater/auto_updater.dart';

// void setupAutoUpdater() async {
//   String feedURL = 'http://your-server-ip:3000/updates/appcast.xml'; // Link đến file XML
//   await autoUpdater.setFeedURL(feedURL);
//   await autoUpdater.setScheduledCheckInterval(10800); // Check mỗi 3 tiếng 1 lần
//   await autoUpdater.checkForUpdates(silent: true); // Tự động check khi mở app
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await setupAutoUpdater();

  // Khởi tạo window_manager
  await windowManager.ensureInitialized();

  //khởi tạo theme
  Get.put(ThemeController());

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
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: themeController.currentColor.value),
          useMaterial3: true,
        ),
        home: SplashScreenDT(),
      ),
    );
  }
}
