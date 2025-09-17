import 'package:dongtam/presentation/components/step_Items.dart';
import 'package:dongtam/presentation/screens/auth/change_to_login.dart';
import 'package:dongtam/service/auth_service.dart';
import 'package:dongtam/utils/helper/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ResetPassword extends StatefulWidget {
  final String email;
  const ResetPassword({super.key, required this.email});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool isObscureText = true;

  final AuthService authService = AuthService();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  void changePassword() async {
    bool success = await authService.changePassword(
      widget.email,
      passwordController.text,
      confirmPwController.text,
    );
    if (success) {
      showSnackBarSuccess(context, 'Đổi mật khẩu thành công');
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: Duration(milliseconds: 500),
          child: ChangeToLogin(),
        ),
      );
    } else {
      showSnackBarError(context, 'Thay đổi mật khẩu thất bại');
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
                              "Tạo mật khẩu mới",
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
                              "Vui lòng chọn một mật khẩu mới chưa từng sử dụng trước đó.\n"
                              "Yêu cầu tối thiểu 8 ký tự, bao gồm chữ và số",
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
                                controller: passwordController,
                                obscureText: isObscureText,
                                decoration: InputDecoration(
                                  hintText: "Nhập mật khẩu mới",
                                  filled: true,
                                  fillColor: Colors.white,
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
                            ),
                          ),
                          SizedBox(height: 10),

                          Center(
                            child: SizedBox(
                              width: 400,
                              height: 50,
                              child: TextField(
                                controller: confirmPwController,
                                obscureText: isObscureText,
                                decoration: InputDecoration(
                                  hintText: "Xác nhận lại mật khẩu",
                                  filled: true,
                                  fillColor: Colors.white,
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
                                  changePassword();
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
