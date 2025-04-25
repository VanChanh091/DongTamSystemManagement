import 'dart:async';

import 'package:dongtam/presentation/screens/auth/login.dart';
import 'package:dongtam/service/auth_Service.dart';
import 'package:dongtam/utils/validation/validators.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  bool isButtonEnabled = true;
  int secondsRemaining = 0;
  Timer? timer;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPWController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool isObscureText = true;

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vui lòng nhập email")));
      return;
    }

    bool success = await authService.sendOTP(emailController.text);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã gửi OTP"),
          duration: Duration(milliseconds: 2000),
        ),
      );
      startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gửi OTP thất bại"),
          duration: Duration(milliseconds: 2000),
        ),
      );
    }
  }

  void register() async {
    await authService.verifyOTPChangePassword(
      emailController.text,
      otpController.text,
    );

    bool success = await authService.register(
      fullNameController.text,
      emailController.text,
      passwordController.text,
      confirmPWController.text,
      otpController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng ký thành công"),
          duration: Duration(milliseconds: 2000),
        ),
      );
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: Duration(milliseconds: 500),
          child: LoginScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng ký thất bại"),
          duration: Duration(milliseconds: 2000),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(color: Color(0xffcfa381)),
          child: Row(
            children: [
              //logo
              Expanded(
                child: Image.asset(
                  'assets/images/logoDT.png',
                  height: 250,
                  width: 250,
                ),
              ),

              //form login
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 700,
                    height: 800,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(25),
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 20),
                              Text(
                                "Đăng ký",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 40),

                              // name
                              TextFormField(
                                controller: fullNameController,
                                decoration: InputDecoration(
                                  labelText: "Họ và tên",
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator:
                                    (value) =>
                                        ValidationAuth.validateFullName(value),
                              ),
                              SizedBox(height: 22),

                              // email + OTP
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: emailController,
                                      decoration: InputDecoration(
                                        labelText: "Email",
                                        prefixIcon: Icon(Icons.mail),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      validator:
                                          (value) =>
                                              ValidationAuth.validateEmail(
                                                value,
                                              ),
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
                                      onPressed:
                                          isButtonEnabled ? sendOTP : null,
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

                              SizedBox(height: 22),

                              // password
                              TextFormField(
                                controller: passwordController,
                                obscureText: isObscureText,
                                decoration: InputDecoration(
                                  labelText: "Mật khẩu",
                                  prefixIcon: Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isObscureText = !isObscureText;
                                      });
                                    },
                                    icon: Icon(
                                      isObscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator:
                                    (value) =>
                                        ValidationAuth.validatePassword(value),
                              ),
                              SizedBox(height: 22),

                              // confirm password
                              TextFormField(
                                obscureText: isObscureText,
                                controller: confirmPWController,
                                decoration: InputDecoration(
                                  labelText: "Nhập lại mật khẩu",
                                  prefixIcon: Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isObscureText = !isObscureText;
                                      });
                                    },
                                    icon: Icon(
                                      isObscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator:
                                    (value) =>
                                        ValidationAuth.validateConfirmPassword(
                                          passwordController.text,
                                          value,
                                        ),
                              ),
                              SizedBox(height: 22),

                              // otp
                              TextFormField(
                                controller: otpController,
                                decoration: InputDecoration(
                                  labelText: "Nhập mã xác nhận",
                                  prefixIcon: Icon(Icons.verified),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return "Không được bỏ trống";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 60),

                              // submit
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      register();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    "Đăng ký",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),

                              // Sign in
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Bạn đã có tài khoản?"),
                                  TextButton(
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
                                    child: Text(
                                      "Đăng nhập",
                                      style: TextStyle(
                                        color: Colors.blue.shade400,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
