import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ======================= LOGIN =======================
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      _user = User.fromJson(response['user']);
      _isAuthenticated = true;
// 🔔 Kirim FCM token ke server setelah login berhasil
      try {
        final notificationService = NotificationService();
        final fcmToken = await notificationService.getToken();
        if (fcmToken != null) {
          await _apiService.updateFCMToken(fcmToken);
        }
      } catch (e) {
        print('⚠️ Gagal mengirim FCM token: $e');
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString(); // <-- tampilkan pesan dari exception
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================= REGISTER =======================
  Future<bool> register({
    required String nama,
    required String pt,
    required String jabatan,
    required String jenisKapal,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register({
        'nama': nama,
        'pt': pt,
        'jabatan': jabatan,
        'jenis_kapal': jenisKapal,
        'phone_number': phoneNumber,
        'email': email,
        'password': password,
      });

      // ✅ VALIDASI RESPONSE
      if (response['user'] == null) {
        throw Exception('Data user tidak valid');
      }

      _user = User.fromJson(response['user']);

      // ✅ CEK APAKAH USER BERHASIL DIBUAT
      if (_user == null || _user!.id == 0) {
        throw Exception('Gagal membuat user');
      }

      _isAuthenticated = true;
      _errorMessage = null;
      print('✅ Registrasi berhasil: ${_user!.nama}');
      return true;
    } catch (e) {
      print('❌ Error registrasi: ${e.toString()}');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isAuthenticated = false;
      _user = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================= UPDATE PROFIL =======================
  Future<bool> updateProfile({
    required String nama,
    String? pt,
    String? jabatan,
    required String jenisKapal,
    required String phoneNumber,
    required String email,
    String? oldPassword,
    String? newPassword,
    String? confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _apiService.updateUserProfile({
        'nama': nama,
        if (pt != null) 'pt': pt,
        'jabatan': jabatan,
        'jenis_kapal': jenisKapal,
        'phone_number': phoneNumber,
        'email': email,
        if (oldPassword != null && oldPassword.isNotEmpty)
          'current_password': oldPassword,
        if (newPassword != null && newPassword.isNotEmpty)
          'new_password': newPassword,
        if (confirmPassword != null && confirmPassword.isNotEmpty)
          'new_password_confirmation': confirmPassword,
      });

      _user = updatedUser;
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui profil: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================= LOGOUT =======================
  Future<void> logout() async {
// 🔔 Hapus FCM token dari server sebelum logout
    try {
      await _apiService.removeFCMToken();
    } catch (e) {
      print('⚠️ Gagal menghapus FCM token: $e');
    }

    await _apiService.clearToken();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // ======================= AUTO LOGIN =======================
  Future<bool> tryAutoLogin() async {
    final token = await _apiService.getToken();
    if (token == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userResponse = await _apiService.getUser();
      _user = userResponse;
      _isAuthenticated = true;
      return true;
    } catch (e) {
      await logout();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================= RESET ERROR =======================
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}
