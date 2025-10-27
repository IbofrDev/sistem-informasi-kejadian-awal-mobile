import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart'; // Pastikan import ini benar

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  // 1. Menambahkan konstanta warna agar konsisten
  static const Color primaryColor = Color(0xFF005A9C);
  static const Color pageBackgroundColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Menambahkan penanganan jika user null, sama seperti halaman profil sebelumnya
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profil Admin")),
        body: const Center(child: Text("Tidak dapat memuat data admin.")),
      );
    }

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      // 2. Menyesuaikan gaya AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Profil Admin",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        automaticallyImplyLeading: false, // Admin page mungkin tidak butuh tombol kembali
      ),
      // 3. Mengubah layout dari ListView ke Column dengan Padding
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 4. Menggunakan _buildInfoCard untuk menampilkan data
            _buildInfoCard("Nama", user.nama),
            _buildInfoCard("Email", user.email),
            _buildInfoCard("Role", user.role),
            const Spacer(), // Mendorong tombol logout ke bawah
            // 5. Mengubah ListTile logout menjadi ElevatedButton
            ElevatedButton(
              onPressed: () async {
                // Logika logout tetap sama, sudah bagus
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Logout",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget yang sama dari halaman profil sebelumnya untuk konsistensi
  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}