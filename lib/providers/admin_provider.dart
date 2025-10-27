import 'package:flutter/material.dart';
import '../models/laporan.dart';
import '../models/user.dart';
import '../services/api_service.dart';

/// Provider untuk seluruh fitur Admin:
/// - Dashboard laporan
/// - Daftar pelapor
/// - Laporan berdasarkan user
/// - Detail user
/// - Update user
/// - Update status laporan
class AdminProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // ================= STATE UTAMA =================
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ================= DATA ADMIN =================
  Map<String, dynamic>? _dashboardData;
  List<Laporan> _laporanList = [];
  List<User> _reporters = [];
  List<Laporan> _laporanByUser = [];

  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<Laporan> get laporanList => _laporanList;
  List<User> get reporters => _reporters;
  List<Laporan> get laporanByUser => _laporanByUser;

  // ================= STATE TAMBAHAN =================
  bool _isDashboardLoading = false;
  bool get isDashboardLoading => _isDashboardLoading;

  bool _isReportersLoading = false;
  bool get isReportersLoading => _isReportersLoading;

  bool _isLaporanByUserLoading = false;
  bool get isLaporanByUserLoading => _isLaporanByUserLoading;

  // ===============================================================
  // DASHBOARD DATA (SEMUA LAPORAN)
  // ===============================================================
  Future<void> fetchDashboardData({
    String? status,
    bool refresh = false,
  }) async {
    _isDashboardLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.getAdminDashboardData(status: status);
      _dashboardData = result;

      if (result.containsKey('reports') &&
          result['reports'] is Map &&
          result['reports']['data'] is List) {
        final List<dynamic> reports = result['reports']['data'];
        _laporanList = reports.map((item) => Laporan.fromJson(item)).toList();
      } else if (result['reports'] is List) {
        _laporanList =
            (result['reports'] as List).map((item) => Laporan.fromJson(item)).toList();
      } else {
        _laporanList = [];
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat data dashboard: $e';
      _laporanList = [];
    } finally {
      _isDashboardLoading = false;
      notifyListeners();
    }
  }

  // ===============================================================
  // GET COUNTS QUICKLY FOR SUMMARY SECTION
  // ===============================================================
  int get newReportsCount {
    if (_dashboardData == null) return 0;
    final data = _dashboardData!['new_reports_count'];
    if (data is int) return data;
    if (data is String) return int.tryParse(data) ?? 0;
    return 0;
  }

  // ===============================================================
  // DAFTAR PELAPOR
  // ===============================================================
  Future<void> fetchReporters() async {
    _isReportersLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reporters = await _apiService.getReporters();
    } catch (e) {
      _errorMessage = 'Gagal memuat daftar pelapor: $e';
      _reporters = [];
    } finally {
      _isReportersLoading = false;
      notifyListeners();
    }
  }

  void searchReporters(String keyword) {
    if (keyword.isEmpty) {
      fetchReporters();
      return;
    }

    final lowerKeyword = keyword.toLowerCase();
    _reporters = _reporters
        .where((u) => u.nama.toLowerCase().contains(lowerKeyword))
        .toList();
    notifyListeners();
  }

  // ===============================================================
  // LAPORAN PER USER
  // ===============================================================
  Future<void> fetchLaporanByUser(int userId) async {
    _isLaporanByUserLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _laporanByUser = await _apiService.getLaporanByUserForAdmin(userId);
    } catch (e) {
      _errorMessage = 'Gagal memuat laporan pengguna: $e';
      _laporanByUser = [];
    } finally {
      _isLaporanByUserLoading = false;
      notifyListeners();
    }
  }

  // ===============================================================
  // DETAIL USER (ADMIN)
  // ===============================================================
  User? _selectedUser;
  bool _isUserDetailLoading = false;

  User? get selectedUser => _selectedUser;
  bool get isUserDetailLoading => _isUserDetailLoading;

  Future<void> fetchUserDetail(int userId) async {
    _isUserDetailLoading = true;
    notifyListeners();
    try {
      _selectedUser = await _apiService.getUserById(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal memuat detail user: $e';
      _selectedUser = null;
    } finally {
      _isUserDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetUserPassword(int userId, String newPassword) async {
    try {
      await _apiService.resetUserPassword(userId, newPassword);
    } catch (e) {
      _errorMessage = 'Gagal memperbarui password: $e';
      rethrow;
    }
  }

  // ===============================================================
  // UPDATE DATA USER (EDIT USER PAGE)
  // ===============================================================
  Future<void> updateUser(int userId, Map<String, String?> data) async {
    try {
      await _apiService.updateUserData(userId, data);
    } catch (e) {
      _errorMessage = 'Gagal memperbarui data user: $e';
      rethrow;
    }
  }

  // ===============================================================
  // UPDATE STATUS LAPORAN
  // ===============================================================
  Future<bool> updateLaporanStatus(int laporanId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.updateLaporanStatus(laporanId, status);

      final indexByUser =
          _laporanByUser.indexWhere((laporan) => laporan.id == laporanId);
      if (indexByUser != -1) {
        final updated =
            _laporanByUser[indexByUser].copyWith(statusLaporan: status);
        _laporanByUser[indexByUser] = updated;
      }

      final indexDashboard =
          _laporanList.indexWhere((laporan) => laporan.id == laporanId);
      if (indexDashboard != -1) {
        final updated =
            _laporanList[indexDashboard].copyWith(statusLaporan: status);
        _laporanList[indexDashboard] = updated;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui status: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===============================================================
  // RESET ERROR
  // ===============================================================
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}