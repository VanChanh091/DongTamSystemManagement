import 'package:dongtam/data/controller/sidebar_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/presentation/screens/auth/forgot_password.dart';
import 'package:dongtam/presentation/screens/auth/sign_up.dart';
import 'package:dongtam/presentation/screens/main/home.dart';
import 'package:dongtam/service/auth_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/storage/sharedPreferences/hint_user_name.dart';
import 'package:dongtam/utils/validation/validators.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final SidebarController sidebarController = Get.put(SidebarController());
  final themeController = Get.find<ThemeController>();
  List<String> emailSuggestions = [];
  bool isObscureText = true;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();

    _loadEmailSuggestions();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = "Phiên bản: ${packageInfo.version}";
    });
  }

  Future<void> _loadEmailSuggestions() async {
    final emails = await HintUserName.instance.loadEmail();
    setState(() {
      emailSuggestions = emails;
    });
  }

  void login() async {
    bool success = await authService.login(
      email: emailController.text,
      password: passwordController.text,
    );

    if (success) {
      await HintUserName.instance.saveUsername(emailController.text);

      if (!mounted) return;
      showSnackBarSuccess(context, 'Đăng nhập thành công');

      sidebarController.reset();

      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: Duration(milliseconds: 500),
          child: HomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //UI
          Center(
            child: Container(
              decoration: BoxDecoration(color: themeController.currentColor.value),
              child: Row(
                children: [
                  //logo
                  Expanded(child: Image.asset('assets/images/logoDT.png', height: 250, width: 250)),

                  //form login
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 700,
                        height: 600,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(35),
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                const Text(
                                  "Đăng nhập",
                                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 70),

                                // Email
                                Autocomplete<String>(
                                  optionsBuilder: (textEditingValue) {
                                    if (textEditingValue.text.isEmpty) {
                                      return emailSuggestions;
                                    }
                                    return emailSuggestions.where(
                                      (email) => email.toLowerCase().contains(
                                        textEditingValue.text.toLowerCase(),
                                      ),
                                    );
                                  },
                                  onSelected: (selection) {
                                    emailController.text = selection;
                                  },
                                  fieldViewBuilder: (
                                    context,
                                    textEditingController,
                                    focusNode,
                                    onFieldSubmitted,
                                  ) {
                                    textEditingController.text = emailController.text;
                                    textEditingController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: textEditingController.text.length),
                                    );
                                    textEditingController.addListener(() {
                                      emailController.value = textEditingController.value;
                                    });

                                    return TextFormField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: const Icon(Icons.email),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  },
                                  optionsViewBuilder: (context, onSelected, options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        elevation: 4.0,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.9,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: options.length,
                                            itemBuilder: (context, index) {
                                              final option = options.elementAt(index);
                                              final hover = ValueNotifier(false);

                                              return ValueListenableBuilder<bool>(
                                                valueListenable: hover,
                                                builder: (context, isHovering, child) {
                                                  return MouseRegion(
                                                    onEnter: (_) => hover.value = true,
                                                    onExit: (_) => hover.value = false,
                                                    child: Container(
                                                      color:
                                                          isHovering ? Colors.blue.shade100 : null,
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: InkWell(
                                                              onTap: () => onSelected(option),
                                                              child: Text(
                                                                option,
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  color:
                                                                      isHovering
                                                                          ? Colors.blue.shade500
                                                                          : Colors.black,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () async {
                                                              await HintUserName.instance
                                                                  .removeOneUsername(option);

                                                              setState(() {
                                                                emailSuggestions.remove(option);
                                                              });
                                                            },
                                                            child: const Icon(
                                                              Icons.close,
                                                              size: 18,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 25),

                                // Password
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: isObscureText,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (value) {
                                    if (_formKey.currentState!.validate()) {
                                      login();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Nhập mật khẩu',
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isObscureText = !isObscureText;
                                        });
                                      },
                                      icon: Icon(
                                        isObscureText ? Icons.visibility_off : Icons.visibility,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) => ValidationAuth.validatePassword(value),
                                ),
                                const SizedBox(height: 5),

                                // Quên mật khẩu
                                Align(
                                  alignment: Alignment.centerRight,
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
                                const SizedBox(height: 35),

                                // Nút đăng nhập
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        login();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Đăng nhập",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),

                                // Đăng ký
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Bạn chưa có tài khoản?"),
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
                  ),
                ],
              ),
            ),
          ),

          //version
          Positioned(
            bottom: 20,
            left: 25,
            child: Text(
              _appVersion,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                shadows: [Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black26)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
