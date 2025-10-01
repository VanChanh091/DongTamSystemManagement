import 'package:dongtam/data/controller/sidebar_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/presentation/screens/auth/forgot_password.dart';
import 'package:dongtam/presentation/screens/auth/sign_up.dart';
import 'package:dongtam/presentation/screens/main/home.dart';
import 'package:dongtam/service/auth_service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validators.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final SidebarController sidebarController = Get.put(SidebarController());
  final themeController = Get.find<ThemeController>();
  bool isObscureText = true;

  void login() async {
    bool success = await authService.login(
      emailController.text,
      passwordController.text,
    );
    if (!mounted) return;

    if (success) {
      showSnackBarSuccess(context, 'Đăng nhập thành công');

      sidebarController.reset();

      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: Duration(milliseconds: 500),
          child: HomePage(),
        ),
      );
    } else {
      showSnackBarError(context, 'Sai thông tin đăng nhập');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(color: themeController.currentColor.value),
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
                    height: 600,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(35),
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            const Text(
                              "Đăng nhập",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 70),

                            // Email
                            TextFormField(
                              controller: emailController,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).nextFocus();
                              },
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator:
                                  (value) =>
                                      ValidationAuth.validateEmail(value),
                            ),
                            const SizedBox(height: 25),

                            // Password
                            TextFormField(
                              controller: passwordController,
                              obscureText: isObscureText,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (value) {
                                if (_formKey.currentState!.validate()) {
                                  login();
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Nhập mật khẩu',
                                prefixIcon: const Icon(Icons.lock),
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
                            const SizedBox(height: 5),

                            // Quên mật khẩu
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.fade,
                                      duration: Duration(milliseconds: 500),
                                      child: ForgotPassword(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Quên mật khẩu",
                                  style: TextStyle(
                                    color: Colors.blue.shade400,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 35),

                            // Nút đăng nhập
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    login();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Đăng nhập",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),

                            // Đăng ký
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Bạn chưa có tài khoản?"),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        duration: Duration(milliseconds: 500),
                                        type: PageTransitionType.fade,
                                        child: SignUp(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Đăng ký",
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
            ],
          ),
        ),
      ),
    );
  }
}
