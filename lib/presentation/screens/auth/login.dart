import 'package:dongtam/presentation/screens/auth/forgot_password.dart';
import 'package:dongtam/presentation/screens/auth/sign_up.dart';
import 'package:dongtam/presentation/screens/home/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isObscureText = true;
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
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    duration: Duration(milliseconds: 500),
                                    type: PageTransitionType.fade,
                                    child: Dashboard(),
                                  ),
                                );
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
