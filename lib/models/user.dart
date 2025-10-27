import 'laporan.dart';

class User {
  final int id;
  final String nama;
  final String email;
  final String role;
  final String? pt; // 🆕 tambahan field PT / Perusahaan
  final String? jabatan;
  final String? jenisKapal;
  final String? phoneNumber;
  final int laporanKejadianCount;
  final Laporan? latestReport;

  User({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.pt,
    this.jabatan,
    this.jenisKapal,
    this.phoneNumber,
    required this.laporanKejadianCount,
    this.latestReport,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'pelapor',
      pt: json['pt'], // 🆕 ambil nilai PT dari respons API
      jabatan: json['jabatan'],
      jenisKapal: json['jenis_kapal'],
      phoneNumber: json['phone_number'],
      laporanKejadianCount: json['laporan_kejadian_count'] ?? 0,
      latestReport: json['latest_report'] != null
          ? Laporan.fromJson(json['latest_report'])
          : null,
    );
  }
}