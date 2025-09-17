import 'dart:async';

import 'package:dongtam/presentation/components/step_Items.dart';
import 'package:dongtam/presentation/screens/auth/reset_password.dart';
import 'package:dongtam/service/auth_service.dart';
import 'package:dongtam/utils/helper/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validators.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool isButtonEnabled = true;
  int secondsRemaining = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchAllUser() async {
    try {
      // authService.getal
    } catch (e) {
      print("Lỗi lấy danh sách user: $e");
    }
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

    bool success = await authService.sendOTP(emailController.text);

    if (success) {
      showSnackBarSuccess(context, 'Đã gửi OTP');
      startTimer();
    } else {
      showSnackBarError(context, 'Gửi OTP thất bại');
    }
  }

  void verifyOTP() async {
    bool success = await authService.verifyOTPChangePassword(
      emailController.text,
      otpController.text,
    );
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
          decoration: BoxDecoration(color: Color(0xffcfa381)),
          child: Row(
            children: [
              //logo & 4 steps change password
              StepItems(),

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
                            SizedBox(height: 50),
                            Center(
                              child: Icon(
                                Icons.lock,
                                size: 50,
                                color: Colors.yellow,
                              ),
                            ),
                            SizedBox(height: 15),

                            Center(
                              child: Text(
                                "Thiết lập lại mật khẩu",
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            Center(
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
                            SizedBox(height: 30),

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
                                      prefixIcon: Icon(Icons.mail),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator:
                                        (value) =>
                                            ValidationAuth.validateEmail(value),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  height: 47,
                                  decoration: BoxDecoration(
                                    color:
                                        isButtonEnabled
                                            ? Colors.red.shade400
                                            : Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextButton(
                                    onPressed: isButtonEnabled ? sendOTP : null,
                                    child: Text(
                                      isButtonEnabled
                                          ? "Gửi mã"
                                          : "Đợi $secondsRemaining s",
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

                            SizedBox(height: 20),

                            //enter code otp
                            Center(
                              child: TextFormField(
                                controller: otpController,
                                decoration: InputDecoration(
                                  labelText: "Mã xác nhận",
                                  prefixIcon: Icon(Icons.code),
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
                            SizedBox(height: 25),

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
                                  child: Text(
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
