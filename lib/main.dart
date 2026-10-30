import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GCGKopegmarApp());
}

class GCGKopegmarApp extends StatelessWidget {
  const GCGKopegmarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // DESIGN_MUDAH Color Palette
    const Color primaryBlue = Color(0xFF2563EB);
    const Color successGreen = Color(0xFF10B981);
    const Color warningOrange = Color(0xFFF59E0B);
    const Color errorRed = Color(0xFFEF4444);
    const Color bgGray = Color(0xFFF3F4F6);

    return MaterialApp(
      title: 'GCG Akor - Kopegmar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.light,
        ),
        // Roboto Typography
        textTheme: GoogleFonts.robotoTextTheme(
          ThemeData.light().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          bodyMedium: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          labelSmall: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        // Button Styling (48px height)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Input Field Styling
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgGray,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
          hintStyle: GoogleFonts.roboto(
            fontSize: 14,
            color: Colors.black45,
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
