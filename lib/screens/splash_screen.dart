import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk cek status login
import 'package:empedu/pages/login/login.dart'; // Login screen
import 'package:empedu/pages/dashboard/dashboard.dart'; // Dashboard

class SplashScreen extends StatefulWidget {
  final Color backgroundColor;
  final int fadeInDuration;
  final int stayDuration;
  final int fadeOutDuration;

  const SplashScreen({
    super.key,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.fadeInDuration = 2,
    this.stayDuration = 1,
    this.fadeOutDuration = 2,
  });

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    // Animasi untuk splash screen
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: widget.fadeInDuration +
            widget.stayDuration +
            widget.fadeOutDuration,
      ),
    );

    _animation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: widget.fadeInDuration.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: widget.stayDuration.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: widget.fadeOutDuration.toDouble(),
      ),
    ]).animate(_animationController);

    // Mulai animasi
    _animationController.forward();

    // Setelah animasi selesai, periksa login status
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkLoginStatus();
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    String? isLoggedIn = await _secureStorage.read(key: 'isLoggedIn');
    if (isLoggedIn == 'true') {
      // Jika sudah login, arahkan ke dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else {
      // Jika belum login, arahkan ke login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            'assets/Logo.png', // Ganti dengan path logo Anda
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
