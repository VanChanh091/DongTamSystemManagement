import 'package:dongtam/presentation/screens/auth/login.dart';
import 'package:dongtam/presentation/screens/home/dashboard.dart';
import 'package:dongtam/service/auth_Service.dart';
import 'package:dongtam/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService authService = AuthService();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPWController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool isObscureText = true;

  void register() async {
    String? fullNameErr = Validators.validateFullName(fullNameController.text);
    String? emailErr = Validators.validateEmail(emailController.text);
    String? passwordErr = Validators.validatePassword(passwordController.text);
    String? confirmPwErr = Validators.validateConfirmPassword(
      passwordController.text,
      confirmPWController.text,
    );

    bool success = await authService.register(
      fullNameController.text,
      emailController.text,
      passwordController.text,
      confirmPWController.text,
      otpController.text,
    );

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đăng ký thành công")));
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: Duration(milliseconds: 500),
          child: LoginScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đăng ký thất bại")));
    }
  }

  void sendOTP() async {
    bool success = await authService.sendOTP(emailController.text);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã gửi OTP")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gửi OTP thất bại")));
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
                    width: 600,
                    height: 700,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //title
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
                          TextField(
                            controller: fullNameController,
                            decoration: InputDecoration(
                              labelText: "Họ và tên",
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 22),

                          //email
                          SizedBox(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      labelText: "Email",
                                      prefixIcon: Icon(Icons.mail),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    sendOTP();
                                  },
                                  child: Text(
                                    "Gửi mã",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red.shade400,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 22),

                          //password
                          TextField(
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
                          ),
                          SizedBox(height: 22),

                          //confirm password
                          TextField(
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
                          ),
                          SizedBox(height: 22),

                          //enter code otp
                          TextField(
                            controller: otpController,
                            decoration: InputDecoration(
                              labelText: "Nhập mã xác nhận",
                              prefixIcon: Icon(Icons.verified),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 40),

                          //button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                register();
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

                          //Sign in
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
            ],
          ),
        ),
      ),
    );
  }
}
