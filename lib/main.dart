import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'routes/app_routes.dart';
import 'core/constants/colors.dart';
import 'core/localization/app_localizations.dart';
import 'core/language_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // notification initialization removed per user request
  // Enable Firestore offline persistence so data stays available when app is offline
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const KormoBD());
}

class KormoBD extends StatelessWidget {
  const KormoBD({super.key});

  @override
  Widget build(BuildContext context) {
    return LanguageController(
      initialLocale: const Locale('en'),
      child: Builder(
        builder: (context) {
          final locale = LanguageController.of(context).locale;

          return MaterialApp(
            title: 'KormoBD',
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: const [Locale('en'), Locale('bn')],
            localizationsDelegates: [
              AppLocalizations.delegate,
              // fallback Flutter delegates
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              // Dark teal primary theme
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF00796B),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF064E40),
              fontFamily: 'Roboto',
              textTheme: const TextTheme(
                titleLarge: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.15,
                ),
                bodyLarge: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.white,
                ),
                bodyMedium: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.white70,
                ),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFFFFFFFF).withOpacity(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 6,
                margin: EdgeInsets.zero,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0x14FFFFFF),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            // Show a short splash screen first, then navigate to the login route.
            initialRoute: AppRoutes.splash,
            routes: {
              ...AppRoutes.routes,
              AppRoutes.splash: (context) => const SplashScreen(),
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait 1.5 seconds then navigate to login screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF064E40),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [AppLogo(size: 120)],
        ),
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 100});

  final double size;

  @override
  Widget build(BuildContext context) {
    final double emblemSize = size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: emblemSize,
          height: emblemSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00BFA5), Color(0xFF00796B)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: emblemSize * 0.62,
              height: emblemSize * 0.62,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work_outline,
                color: Colors.white,
                size: emblemSize * 0.36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'KormoBD',
          style: TextStyle(
            fontSize: size * 0.22 + 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}
