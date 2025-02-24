import 'package:dongtam/presentation/screens/auth/forgot_password.dart';
import 'package:dongtam/presentation/screens/auth/verification.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

//root
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      // home: LoginScreen(),
      // home: SignUpPage(),
      // home: ForgotPassword(),
      home: Verification(),
    );
  }
}
