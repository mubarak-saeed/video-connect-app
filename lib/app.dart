import 'package:flutter/material.dart';
import 'core/app_constants.dart';
import 'features/home/home_screen.dart';

class VideoConnectApp extends StatelessWidget {
  const VideoConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      locale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        fontFamilyFallback: const [
          'Noto Sans Arabic',
          'Segoe UI',
          'Tahoma',
          'Arial',
        ],
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF31D0AA),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF07131F),
        textTheme: ThemeData.dark().textTheme
            .apply(bodyColor: Colors.white, displayColor: Colors.white)
            .copyWith(
              displaySmall: ThemeData.dark().textTheme.displaySmall?.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.4,
              ),
              headlineSmall: ThemeData.dark().textTheme.headlineSmall?.copyWith(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                height: 1.25,
                letterSpacing: -0.2,
              ),
              titleLarge: ThemeData.dark().textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
              bodyLarge: ThemeData.dark().textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                height: 1.55,
              ),
              bodyMedium: ThemeData.dark().textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                height: 1.5,
              ),
              labelLarge: ThemeData.dark().textTheme.labelLarge?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              labelMedium: ThemeData.dark().textTheme.labelMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
        iconTheme: const IconThemeData(size: 20),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF31D0AA)),
          ),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),
    );
  }
}
