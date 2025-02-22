import 'package:dongtam/presentation/screens/fogotPassword.dart';
import 'package:dongtam/presentation/screens/login.dart';
import 'package:dongtam/presentation/screens/signUp.dart';
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
      home: ForgotPassword(),
    );
  }
}
