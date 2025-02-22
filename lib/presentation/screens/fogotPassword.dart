import 'package:flutter/material.dart';

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
          // padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Color(0xffcfa381)),
          child: Row(
            children: [
              //logo & 4 steps change password
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 500,
                    height: 600,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //logo
                          Image.asset(
                            "assets/images/logoDT.png",
                            height: 100,
                            width: 100,
                          ),
                          SizedBox(height: 20),

                          ..._buildSteps(
                            "1. Thiết lập lại mật khẩu của bạn",
                            "Chúng tôi sẽ gửi mã xác nhận đến email của bạn",
                          ),
                          ..._buildSteps(
                            "2. Nhập mã xác nhận",
                            "Nhập mã xác nhận mà chúng tôi đã gửi đến email của bạn",
                          ),
                          ..._buildSteps(
                            "3. Đặt lại mật khẩu",
                            "Yêu cầu tối thiểu 8 ký tự, bao gồm số và chữ",
                          ),
                          ..._buildSteps(
                            "4. Đăng nhập",
                            "Đăng nhập bằng mật khẩu mới của bạn",
                          ),

                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: TextButton(
                              onPressed: () {},
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back, color: Colors.blue),
                                  SizedBox(width: 5),
                                  Text(
                                    "Quay lại",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              //change password
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 500,
                    height: 600,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
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
                              width: 400,
                              height: 50,
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: "Nhập email",
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
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
                                onPressed: () {},
                                child: Text(
                                  "Gửi mã",
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

List<Widget> _buildSteps(String title, String description) {
  return [
    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    Text(
      description,
      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
    ),
    SizedBox(height: 20),
  ];
}
