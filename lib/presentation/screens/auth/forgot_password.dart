import 'dart:async';

import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/presentation/components/step_items.dart';
import 'package:dongtam/presentation/screens/auth/reset_password.dart';
import 'package:dongtam/service/auth_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validators.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  final themeController = Get.find<ThemeController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool isButtonEnabled = true;
  int secondsRemaining = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  void startTimer() {
    setState(() {
      isButtonEnabled = false;
      secondsRemaining = 30;
    });

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsRemaining == 0) {
        setState(() {
          isButtonEnabled = true;
          timer.cancel();
        });
      } else {
        setState(() {
          secondsRemaining--;
        });
      }
    });
  }

  void sendOTP() async {
    if (emailController.text.isEmpty) {
      showSnackBarError(context, 'Vui lòng nhập email');
      return;
    }

    bool success = await authService.sendOTP(email: emailController.text);

    if (!mounted) return;

    if (success) {
      showSnackBarSuccess(context, 'Đã gửi OTP');
      startTimer();
    } else {
      showSnackBarError(context, 'Gửi OTP thất bại');
    }
  }

  void verifyOTP() async {
    bool success = await authService.verifyOTPChangePassword(
      email: emailController.text,
      otp: otpController.text,
    );
    if (!mounted) return;
    if (success) {
      showSnackBarSuccess(context, 'Xác thực OTP thành công');
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: Duration(milliseconds: 500),
          child: ResetPassword(email: emailController.text),
        ),
      );
    } else {
      showSnackBarError(context, 'Sai mã OTP');
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(color: themeController.currentColor.value),
          child: Row(
            children: [
              //logo & 4 steps change password
              const StepItems(),

              //change password
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 500,
                    height: 600,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(25),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 50),
                            const Center(child: Icon(Icons.lock, size: 50, color: Colors.yellow)),
                            const SizedBox(height: 15),

                            const Center(
                              child: Text(
                                "Thiết lập lại mật khẩu",
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
                                "Thiết lập lại mật khẩu của bạn\n"
                                "Chúng tôi sẽ gửi mã xác nhận đến email của bạn",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      labelText: "Email",
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: const Icon(Icons.mail),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: (value) => ValidationAuth.validateEmail(value),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  height: 47,
                                  decoration: BoxDecoration(
                                    color: isButtonEnabled ? Colors.red.shade400 : Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextButton(
                                    onPressed: isButtonEnabled ? sendOTP : null,
                                    child: Text(
                                      isButtonEnabled ? "Gửi mã" : "Đợi $secondsRemaining s",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            //enter code otp
                            Center(
                              child: TextFormField(
                                controller: otpController,
                                decoration: InputDecoration(
                                  labelText: "Mã xác nhận",
                                  prefixIcon: const Icon(Icons.code),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "OTP không được để trống";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 25),

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
                                    if (_formKey.currentState!.validate()) {
                                      verifyOTP();
                                    }
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
                          ],
                        ),
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
