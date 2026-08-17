import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/upload_process_controller.dart';
import 'package:dongtam/presentation/splashScreen/splash_screen_animation.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/progressOverlay/progress_upload_orverlay.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo window_manager
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1366, 768),
    minimumSize: Size(1024, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();

    // Cho Flutter 1 tick nhỏ để sync DPI trước khi maximize
    Future.microtask(() async {
      await windowManager.maximize();
    });
  });

  //khởi tạo theme
  Get.put(ThemeController());
  Get.put(UploadProcessController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: themeController.currentColor.value),
          useMaterial3: true,
        ),
        builder: (context, child) {
          return ProgressUploadOrverlay(child: child!);
        },
        home: SplashScreenAnimation(),
      ),
    );
  }
}
