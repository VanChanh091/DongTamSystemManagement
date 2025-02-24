import 'package:dongtam/presentation/screens/auth/Verification.dart';
import 'package:dongtam/presentation/screens/auth/change_to_login.dart';
import 'package:dongtam/presentation/screens/auth/forgot_password.dart';
import 'package:dongtam/presentation/screens/auth/login.dart';
import 'package:dongtam/presentation/screens/auth/reset_password.dart';
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
      home: LoginScreen(),
      // home: LoginScreen(),
      // home: SignUp(),
      // home: ForgotPassword(),
      // home: Verification(),
      // home: ResetPassword(),
      // home: ChangeToLogin(),
      // routes: {'/login': (context) => },
    );
  }
}
