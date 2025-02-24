import 'package:flutter/material.dart';

class StepItems extends StatelessWidget {
  const StepItems({super.key});

  List<Widget> _buildSteps(String title, String description) {
    return [
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      Text(description, style: TextStyle(fontSize: 16)),
      SizedBox(height: 20),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                  "Yêu cầu tối thiểu 8 ký tự, bao gồm chữ và số",
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
                        Text("Quay lại", style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
