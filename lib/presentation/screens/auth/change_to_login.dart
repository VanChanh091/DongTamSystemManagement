import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/presentation/components/step_items.dart';
import 'package:dongtam/presentation/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';

class ChangeToLogin extends StatefulWidget {
  const ChangeToLogin({super.key});

  @override
  State<ChangeToLogin> createState() => _ChangeToLoginState();
}

class _ChangeToLoginState extends State<ChangeToLogin> {
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(color: themeController.currentColor.value),
          child: Row(
            children: [
              //step items
              const StepItems(),

              //enter code
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 600,
                    width: 500,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const SizedBox(height: 70),
                          const Center(
                            child: Icon(
                              Icons.check_circle,
                              size: 50,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 15),

                          const Center(
                            child: Text(
                              "Đổi mật khẩu thành công",
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Center(
                            child: Text(
                              "Mật khẩu của bạn đã thay đổi thành công\n"
                              "Nhấn vào nút bên dưới để đăng nhập",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          Center(
                            child: SizedBox(
                              width: 400,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.fade,
                                      duration: Duration(milliseconds: 500),
                                      child: LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Xác nhận",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
