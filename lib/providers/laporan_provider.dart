import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/laporan.dart';
import '../services/api_service.dart';
import '../services/draft_service.dart';
import 'auth_provider.dart';

class LaporanProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DraftService _draftService = DraftService();
  AuthProvider authProvider;

  LaporanProvider({required this.authProvider});
  
  void updateAuthProvider(AuthProvider newAuthProvider) {
    authProvider = newAuthProvider;
  }

  // ===================== STATE =====================
  bool _isLoading = false;
  String? _errorMessage;
  List<Laporan> _laporanList = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Laporan> get laporanList => _laporanList;

  // ===================== FETCH LAPORAN HISTORY =====================
  Future<void> fetchLaporanHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint(
          "📡 [LaporanProvider] Mengambil daftar laporan dari server...");
      _laporanList = await _apiService.getLaporanHistory();
      debugPrint(
          "✅ [LaporanProvider] Berhasil memuat ${_laporanList.length} laporan dari server.");
    } catch (e, s) {
      String cleanMsg = e.toString();
      if (cleanMsg.contains("Unauthenticated")) {
        debugPrint(
            "🚫 [LaporanProvider] Token tidak valid atau belum login ulang.");
        _errorMessage = "Sesi Anda telah berakhir. Silakan login kembali.";
        await authProvider.logout();
      } else {
        debugPrint("❌ [LaporanProvider] Gagal memuat laporan: $e\n$s");
        _errorMessage = "Gagal memuat daftar laporan: ${e.toString()}";
      }
      _laporanList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===================== CREATE LAPORAN =====================
  Future<bool> submitReport(
    Map<String, String> data,
    List<XFile> lampiran,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // === 🆕 Validasi dan lengkapi field baru (jenis kecelakaan, pihak terkait)
      if (!data.containsKey('jenis_kecelakaan')) {
        data['jenis_kecelakaan'] = '';
      }
      if (!data.containsKey('pihak_terkait')) {
        data['pihak_terkait'] = '';
      }

      // Tambahkan data pelapor otomatis dari authProvider
      final currentUser = authProvider.user;
      if (currentUser != null) {
        data.addAll({
          'nama_pelapor': currentUser.nama,
          'jabatan_pelapor': currentUser.jabatan ?? '',
          'telepon_pelapor': currentUser.phoneNumber ?? '',
        });
      }

      debugPrint(
          "🚀 [LaporanProvider] Mengirim laporan dengan data: ${data.keys.join(', ')}");
      debugPrint(
          "📎 Jumlah lampiran: ${lampiran.length}\n🧾 Isi data: ${data.toString()}");

      await _apiService.createReport(data, lampiran);
      debugPrint("✅ [LaporanProvider] Laporan berhasil dikirim ke server!");

      // Bersihkan draft setelah pengiriman sukses
      await _draftService.clearDraft();
      debugPrint("🧹 Draft berhasil dihapus setelah pengiriman.");

      // Refresh daftar laporan agar terbaru
      await fetchLaporanHistory();
      return true;
    } catch (e, s) {
      debugPrint("❌ [LaporanProvider] Error saat mengirim laporan: $e\n$s");

      String cleanMessage =
          e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
      cleanMessage = cleanMessage
          .replaceFirst(RegExp(r'^Gagal mengirim laporan:\s*'), '')
          .trim();

      if (cleanMessage.contains("Unauthenticated")) {
        _errorMessage = "Sesi Anda telah berakhir. Silakan login kembali.";
        await authProvider.logout();
      } else {
        _errorMessage = cleanMessage;
      }

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===================== GET DETAIL LAPORAN =====================
  Future<Laporan> getLaporanDetail(int laporanId) async {
    final role = authProvider.user?.role ?? 'pelapor';
    try {
      debugPrint(
          "📖 [LaporanProvider] Memuat detail laporan ID: $laporanId (role: $role)");
      if (role == 'admin') {
        return await _apiService.getLaporanDetailForAdmin(laporanId);
      } else {
        return await _apiService.getLaporanDetail(laporanId);
      }
    } catch (e, s) {
      debugPrint("❌ [LaporanProvider] Gagal mengambil detail laporan: $e\n$s");
      if (e.toString().contains("Unauthenticated")) {
        await authProvider.logout();
        throw Exception("Sesi Anda sudah berakhir. Silakan login kembali.");
      }
      rethrow;
    }
  }

  // ===================== DRAFT HANDLER =====================
  Future<void> saveDraft(Map<String, String> data) async {
    try {
      await _draftService.saveDraft(data);
      debugPrint("💾 Draft laporan disimpan.");
    } catch (e, s) {
      debugPrint("❌ Gagal menyimpan draft: $e\n$s");
    }
  }

  Future<Map<String, String>?> loadDraft() async {
    try {
      final draft = await _draftService.loadDraft();
      debugPrint(
          "📂 Draft berhasil dimuat: ${draft?.keys.join(', ') ?? 'kosong'}");
      return draft;
    } catch (e, s) {
      debugPrint("❌ Gagal memuat draft: $e\n$s");
      return null;
    }
  }

  Future<void> clearDraft() async {
    try {
      await _draftService.clearDraft();
      debugPrint("🧹 Draft berhasil dihapus.");
    } catch (e, s) {
      debugPrint("❌ Gagal menghapus draft: $e\n$s");
    }
  }

  // ===================== ERROR HANDLER =====================
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}
