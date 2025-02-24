import 'package:dongtam/presentation/components/StepItems.dart';
import 'package:flutter/material.dart';

class ChangeToLogin extends StatefulWidget {
  const ChangeToLogin({super.key});

  @override
  State<ChangeToLogin> createState() => _ChangeToLoginState();
}

class _ChangeToLoginState extends State<ChangeToLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(color: Color(0xffcfa381)),
          child: Row(
            children: [
              //step items
              StepItems(),

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
                          SizedBox(height: 70),
                          Center(
                            child: Icon(
                              Icons.check_circle,
                              size: 50,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 15),

                          Center(
                            child: Text(
                              "Đổi mật khẩu thành công",
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
                          SizedBox(height: 30),

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
                                onPressed: () {},
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
                          SizedBox(height: 5),
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
