import 'package:dongtam/presentation/components/StepItems.dart';
import 'package:dongtam/presentation/screens/auth/change_to_login.dart';
import 'package:dongtam/presentation/screens/auth/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
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
                      // decoration: BoxDecoration(
                      //   color: Colors.white,
                      //   borderRadius: BorderRadius.circular(10),
                      // ),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(25),
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

                          Center(
                            child: SizedBox(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: "Email",
                                        prefixIcon: Icon(Icons.mail),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 5),

                                  SizedBox(
                                    height: 45,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade400,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          "Gửi mã",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          //enter code otp
                          Center(
                            child: TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Mã xác nhận",
                                prefixIcon: Icon(Icons.code),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
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
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.fade,
                                      duration: Duration(milliseconds: 500),
                                      child: ResetPassword(),
                                    ),
                                  );
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
            ],
          ),
        ),
      ),
    );
  }
}
