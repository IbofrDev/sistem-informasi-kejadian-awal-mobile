import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistem_kejadian_awal_mobile/edit_profile_page.dart';
import 'package:sistem_kejadian_awal_mobile/pages/profile_page.dart';
import 'package:sistem_kejadian_awal_mobile/pages/user_settings_page.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/laporan_provider.dart';
import 'providers/admin_provider.dart';

// Pages
import 'splash_screen.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'dashboard_page.dart';
import 'admin_dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider utama untuk autentikasi
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // ProxyProvider yang menghubungkan AuthProvider dengan LaporanProvider
        ChangeNotifierProxyProvider<AuthProvider, LaporanProvider>(
          create: (context) =>
              LaporanProvider(authProvider: context.read<AuthProvider>()),
          update: (_, authProvider, previous) =>
              LaporanProvider(authProvider: authProvider),
        ),

        // Provider untuk fungsi admin
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Sistem Laporan Awal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF2A3A5E),
          scaffoldBackgroundColor: const Color(0xFF1C2841),
          colorScheme: const ColorScheme.dark(
            primary: Colors.blueAccent,
            secondary: Colors.blueAccent,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2A3A5E),
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2A3A5E),
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/dashboard': (context) => const DashboardPage(),
          '/admin-dashboard': (context) => const AdminDashboardPage(),
          '/profile': (context) => const ProfilePage(),
          '/edit-profile': (context) => const EditProfilePage(),
          '/user-settings': (context) => const UserSettingsPage(),
        },
      ),
    );
  }
}