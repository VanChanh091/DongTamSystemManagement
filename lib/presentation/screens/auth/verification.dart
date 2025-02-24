import 'package:dongtam/presentation/components/StepItems.dart';
import 'package:dongtam/presentation/screens/auth/reset_password.dart';
import 'package:flutter/material.dart';

class Verification extends StatelessWidget {
  const Verification({super.key});

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
                              Icons.keyboard,
                              size: 50,
                              color: Colors.yellow,
                            ),
                          ),
                          SizedBox(height: 15),

                          Center(
                            child: Text(
                              "Nhập mã xác nhận",
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
                              "Nhập mã xác nhận mà chúng tôi đã gửi đến email của bạn",
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
                                  hintText: "Nhập mã",
                                  labelText: "Nhập mã",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 25),

                          Center(
                            child: Column(
                              children: [
                                //button
                                SizedBox(
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
                                        MaterialPageRoute(
                                          builder: (context) => ResetPassword(),
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
                                SizedBox(height: 5),

                                //send code again
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Bạn chưa nhận được mã?"),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        "Gửi lại",
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                            255,
                                            27,
                                            131,
                                            216,
                                          ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
