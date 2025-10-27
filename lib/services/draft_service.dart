import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// DraftService digunakan untuk menyimpan sementara data laporan
/// agar pengguna tidak kehilangan data jika aplikasi ditutup
/// sebelum laporan dikirim.
class DraftService {
  static const String _draftKey = 'laporan_draft';

  /// Simpan draft laporan dalam bentuk Map<String, String>
  /// Misal data hasil dari form atau dari `Laporan.toMap()`
  Future<void> saveDraft(Map<String, String> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_draftKey, jsonEncode(data));
      // Logging untuk debug
      // ignore: avoid_print
      print("✅ Draft laporan berhasil disimpan (${data.length} field).");
    } catch (e) {
      // ignore: avoid_print
      print("❌ Gagal menyimpan draft: $e");
      rethrow;
    }
  }

  /// Ambil kembali draft yg tersimpan.
  /// Mengembalikan `null` bila tidak ada data di storage.
  Future<Map<String, String>?> loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_draftKey);
      if (jsonString == null) return null;

      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      // ignore: avoid_print
      print("❌ Gagal memuat draft: $e");
      return null;
    }
  }

  /// Hapus draft dari penyimpanan lokal.
  Future<void> clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
      // ignore: avoid_print
      print("🧹 Draft laporan berhasil dihapus.");
    } catch (e) {
      // ignore: avoid_print
      print("❌ Gagal menghapus draft: $e");
      rethrow;
    }
  }

  /// Cek apakah ada draft tersimpan
  Future<bool> hasDraft() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_draftKey);
  }
}