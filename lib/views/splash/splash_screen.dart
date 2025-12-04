import 'package:flutter/material.dart';
import '../../core/platform_channel/tuya_channel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Add a small delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final isLoggedIn = await TuyaChannel.isLogin();

      if (!mounted) return;

      if (isLoggedIn) {
        // User is logged in → go to Home Screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Not logged in → go to Email Input Screen
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // On error, navigate to email input screen
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_rounded, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'Smart House',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
