import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
import 'admin_main_page.dart';

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

  /// ------------------------------------------------------------
  /// 🔐 Fungsi untuk memeriksa status login pengguna
  /// ------------------------------------------------------------
  Future<void> _checkLoginStatus() async {
    // Tambahkan jeda ringan supaya animasi splash terlihat
    await Future.delayed(const Duration(seconds: 3));

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Jalankan auto-login (ambil token + user dari storage)
    final isLoggedIn = await authProvider.tryAutoLogin();

    // Debug log membantu memastikan user berhasil dimuat
    debugPrint("DEBUG AUTOLOGIN RESULT: $isLoggedIn");
    debugPrint("DEBUG USER DATA: ${authProvider.user?.nama ?? 'User null'}");

    // ------------------------------------------------------------
    // ✅ Pastikan login sahih (token valid & user tersedia)
    // ------------------------------------------------------------
    if (!mounted) return;

    if (isLoggedIn && authProvider.user != null) {
      final userRole = authProvider.user?.role ?? 'pelapor';
      if (userRole == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminMainPage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    } else {
      // Jika autoLogin gagal, arahkan ke halaman login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  /// ------------------------------------------------------------
  /// Tampilan UI Splash Screen
  /// ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo SIKAP
                Image(
                  image: const AssetImage('assets/images/icon_SIKAP.png'),
                  width: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
// Spinner loading
                CircularProgressIndicator(
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF0D214F)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Memeriksa Sesi Anda...',
                  style: TextStyle(
                    color: Color(0xFF0D214F),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Branding bawah
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'SIKAP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kantor KSOP Kelas I Banjarmasin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
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
