// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'GCG',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // App Name
            Text(
              'Kopegmar',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.black87,
                  ),
            ),
            Text(
              'Koperasi Pegawai Garuda Mas',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.black45,
                  ),
            ),
            const SizedBox(height: 48),
            // Loading Spinner
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
