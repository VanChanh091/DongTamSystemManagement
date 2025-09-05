import 'package:dongtam/presentation/splashScreen/myAppLauncher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class SplashScreenDT extends StatefulWidget {
  const SplashScreenDT({super.key});

  @override
  State<SplashScreenDT> createState() => _SplashScreenDTState();
}

class _SplashScreenDTState extends State<SplashScreenDT>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _logoController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _positionAnimation;

  late AnimationController _textController;
  String displayedText = "";
  final String fullText = "Dong Tam Packaging";

  @override
  void initState() {
    super.initState();

    // Fade in logo
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    _fadeController.forward();

    // Sau khi fade in xong + giữ 1s → mới zoom out
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {
          _logoController.forward();
        });
      }
    });

    // Logo scale + position
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(begin: 1.5, end: 1.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.2),
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Khi logo xong thì chạy text
    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startTypingEffect();
      }
    });

    // Controller cho text
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  void _startTypingEffect() {
    _textController.addListener(() {
      setState(() {
        int currentLength = (_textController.value * fullText.length).toInt();
        displayedText = fullText.substring(0, currentLength);
      });
    });
    _textController.forward();

    _textController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 800),
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const MyAppLauncher(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  );

                  return FadeTransition(
                    opacity: curvedAnimation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.9,
                        end: 1.0,
                      ).animate(curvedAnimation),
                      child: child,
                    ),
                  );
                },
              ),
            );
          }
        });
      }
    });
  }

  TextStyle textColor({
    double fontSize = 55,
    Color color = const Color(0xFFFFD700),
    // Color color = const Color.fromARGB(255, 248, 192, 149),
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.w900,
      shadows: [
        Shadow(blurRadius: 3, color: Colors.black87, offset: Offset(2, 2)),
      ],
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/background_DT.png", fit: BoxFit.cover),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // logo
                SlideTransition(
                  position: _positionAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Image.asset(
                            "assets/images/logoSplashScreen.png",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // text
                SizedBox(
                  height: 70,
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: displayedText.substring(
                              0,
                              displayedText.length.clamp(0, 4),
                            ),
                            style: textColor(),
                          ),
                          if (displayedText.length > 4)
                            TextSpan(
                              text: displayedText.substring(
                                4,
                                displayedText.length.clamp(0, 7),
                              ),
                              style: textColor(),
                            ),
                          if (displayedText.length > 7)
                            TextSpan(
                              text: displayedText.substring(7),
                              style: textColor(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NeonText extends StatelessWidget {
  final String text;
  const NeonText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final Shader linearGradient = const LinearGradient(
      colors: [Colors.blue, Colors.cyanAccent],
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0));

    return Text(
      text,
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        foreground: Paint()..shader = linearGradient,
        shadows: const [
          Shadow(
            blurRadius: 20,
            color: Colors.cyanAccent,
            offset: Offset(0, 0),
          ),
          Shadow(
            blurRadius: 40,
            color: Colors.blueAccent,
            offset: Offset(0, 0),
          ),
        ],
      ),
    );
  }
}
