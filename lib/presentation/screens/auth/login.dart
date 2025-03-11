import 'package:dongtam/presentation/screens/auth/forgot_password.dart';
import 'package:dongtam/presentation/screens/auth/sign_up.dart';
import 'package:dongtam/presentation/screens/main/home.dart';
import 'package:dongtam/service/auth_Service.dart';
import 'package:dongtam/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isObscureText = true;

  void login() async {
    String? emailError = Validators.validateEmail(emailController.text);
    String? passwordError = Validators.validatePassword(
      passwordController.text,
    );

    if (emailError != null || passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            emailError ?? passwordError ?? "Lỗi không xác định",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return;
    }

    bool susccess = await authService.login(
      emailController.text,
      passwordController.text,
    );
    if (susccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đăng nhập thành công")));
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: Duration(milliseconds: 500),
          child: HomePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sai thông tin đăng nhập")));
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
                    height: 550,
                    child: Container(
                      // constraints: BoxConstraints(maxWidth: 400, maxHeight: 600),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(35),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //title
                          SizedBox(height: 20),
                          Text(
                            "Đăng nhập",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 70),

                          //email
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Nhập email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 25),

                          //password
                          TextField(
                            controller: passwordController,
                            obscureText: isObscureText,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Nhập mật khẩu',
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
                          SizedBox(height: 5),

                          //forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
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
                          ),
                          SizedBox(height: 45),

                          //login button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                login();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Đăng nhập",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),

                          //register
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Chưa có tài khoản?"),
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
            ],
          ),
        ),
      ),
    );
  }
}
