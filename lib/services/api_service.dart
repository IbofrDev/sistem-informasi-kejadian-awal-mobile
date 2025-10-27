import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/laporan.dart';
import '../models/user.dart';

class ApiService {
  final Dio _dio;
  static const String _baseUrl =
      'http://10.234.153.176:9000/api'; // ganti sesuai servermu

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 30),
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) async {
        // Tambahkan Authorization header kecuali saat login/register
        if (!options.path.contains('/login') &&
            !options.path.contains('/register')) {
          final token = await getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('📡 Authorization header ditambahkan: Bearer $token');
          } else {
            print('⚠️ Token tidak ditemukan, permintaan tanpa autentikasi.');
          }
        }
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      }),
    );
  }

  // ===============================================================
  // 🔐 AUTHENTICATION
  // ===============================================================

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      // Periksa kode status dari backend
      if (response.statusCode != 200) {
        throw Exception('Login gagal: ${response.data['message']}');
      }

      // Debug respons
      print('🧾 LOGIN response: ${response.data}');

      // Simpan token hanya jika login sukses
      final token = response.data['access_token'] ??
          response.data['token'] ??
          response.data['plainTextToken'] ??
          '';
      if (token.isEmpty) {
        throw Exception('Token tidak ditemukan.');
      }

      await saveToken(token);
      return response.data;
    } on DioException catch (e) {
      // Tangani error 401 dari backend Laravel
      if (e.response?.statusCode == 401) {
        throw Exception('Email atau password salah.');
      }
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> register(Map<String, String> data) async {
    try {
      final response = await _dio.post('/register', data: data);

      print('🧾 REGISTER response: ${response.data}');
      final token = response.data['access_token'] ??
          response.data['token'] ??
          response.data['plainTextToken'] ??
          '';
      await saveToken(token);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<User> getUser() async {
    try {
      final response = await _dio.get('/user');

      // ✅ Pastikan server merespons sukses
      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Gagal mengambil data pengguna (token tidak valid).');
      }

      final data = response.data;
      if (data is Map && data.containsKey('user')) {
        return User.fromJson(data['user']);
      }
      return User.fromJson(data);
    } on DioException catch (e) {
      // Jika token invalid, hapuskan agar tidak tersangkut
      if (e.response?.statusCode == 401) {
        await clearToken();
        throw Exception('Token tidak valid atau sudah kedaluwarsa.');
      }
      throw Exception(_handleError(e));
    }
  }

  Future<User> updateUserProfile(Map<String, String?> data) async {
    try {
      final response = await _dio.post('/user', data: data);
      if (response.data is Map && response.data.containsKey('user')) {
        return User.fromJson(response.data['user']);
      }
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ===============================================================
  // 🧾 TOKEN STORAGE
  // ===============================================================

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('💾 Token berhasil disimpan: $token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    print('🧹 Token dihapus dari penyimpanan.');
  }

  // ===============================================================
  // 🧠 LAPORAN (USER)
  // ===============================================================

  Future<List<Laporan>> getLaporanHistory() async {
    try {
      final response = await _dio.get('/laporan');
      final data = response.data;

      if (data is List) {
        return data.map((item) => Laporan.fromJson(item)).toList();
      }

      if (data is Map<String, dynamic>) {
        final List<dynamic>? list = data['data'];
        if (list != null) {
          return list.map((item) => Laporan.fromJson(item)).toList();
        }
      }

      throw Exception('Format respons laporan tidak dikenali.');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> createReport(
      Map<String, String> data, List<XFile> lampiran) async {
    try {
      final formData = FormData.fromMap(data);

      for (var file in lampiran) {
        formData.files.add(MapEntry(
          'lampiran[]',
          await MultipartFile.fromFile(file.path, filename: file.name),
        ));
      }

      final response = await _dio.post('/laporan', data: formData);
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Laporan dan lampiran dikirim (${lampiran.length} file)!");
      } else {
        print("⚠️ Respons tidak terduga: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Laporan> getLaporanDetail(int laporanId) async {
    try {
      final response = await _dio.get('/laporan/$laporanId');
      return Laporan.fromJson(response.data, baseUrl: _dio.options.baseUrl);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ===============================================================
  // 👑 ADMIN SECTION (LENGKAP)
  // ===============================================================

  Future<Laporan> getLaporanDetailForAdmin(int laporanId) async {
    try {
      final response = await _dio.get('/admin/laporan/$laporanId');
      return Laporan.fromJson(response.data, baseUrl: _dio.options.baseUrl);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> updateLaporanStatus(int laporanId, String status) async {
    try {
      await _dio.patch(
        '/admin/laporan/$laporanId/status',
        data: {'status_laporan': status},
      );
      print("📝 Status laporan $laporanId diperbarui ke $status");
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<Laporan>> getLaporanByUserForAdmin(int userId) async {
    try {
      final response = await _dio.get('/admin/pelapor/$userId/laporan');
      final List<dynamic> body = response.data;
      return body.map((item) => Laporan.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<User>> getReporters() async {
    try {
      final response = await _dio.get('/admin/pelapor');
      final List<dynamic> body = response.data;
      return body.map((item) => User.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> getAdminDashboardData({String? status}) async {
    try {
      final queryParams = {
        if (status != null) 'status': status,
      };
      final response =
          await _dio.get('/admin/laporan', queryParameters: queryParams);
      final List<dynamic> reports = response.data;
      return {
        'new_reports_count':
            reports.where((r) => r['status_laporan'] == 'dikirim').length,
        'reports': {'data': reports},
      };
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<User> getUserById(int userId) async {
    try {
      final response = await _dio.get('/admin/users/$userId');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> resetUserPassword(int userId, String newPassword) async {
    try {
      await _dio.post(
        '/admin/users/$userId/reset-password',
        data: {'password': newPassword},
      );
      print("🔑 Password user $userId telah direset.");
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> updateUserData(int userId, Map<String, String?> data) async {
    try {
      await _dio.put('/admin/users/$userId', data: data);
      print("⚙️ Data user $userId diperbarui.");
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ===============================================================
  // ⚠️ ERROR HANDLER
  // ===============================================================

  String _handleError(DioException e) {
    String message = 'Terjadi kesalahan tidak diketahui.';

    if (e.response != null && e.response?.data is Map) {
      final data = e.response?.data;
      message = data['message'] ?? message;

      if (data['errors'] != null && data['errors'] is Map) {
        final Map errors = data['errors'];
        if (errors.isNotEmpty) {
          final firstKey = errors.keys.first.toString();
          final firstError =
              (errors[firstKey] as List?)?.first?.toString() ?? '';
          message = _translateLaravelMessage(firstKey, firstError);
        }
      }
    } else if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      message = 'Koneksi ke server gagal. Periksa koneksi internet Anda.';
    }

    print('❌ API Error: $message');
    return message;
  }

  String _translateLaravelMessage(String field, String original) {
    String readableField = field.replaceAll('_', ' ');
    readableField = readableField[0].toUpperCase() + readableField.substring(1);
    final lower = original.toLowerCase();

    if (lower.contains('required')) {
      return '$readableField tidak boleh kosong';
    } else if (lower.contains('must be a file')) {
      return '$readableField harus berupa file';
    } else if (lower.contains('must be an integer')) {
      return '$readableField harus berupa angka';
    } else if (lower.contains('must be a string')) {
      return '$readableField harus berupa teks';
    } else if (lower.contains('may not be greater')) {
      return '$readableField melebihi batas yang diizinkan';
    } else if (lower.contains('invalid')) {
      return '$readableField tidak valid';
    } else if (lower.contains('unique')) {
      return '$readableField sudah terdaftar';
    } else if (lower.contains('email')) {
      return '$readableField harus berupa alamat e‑mail yang valid';
    } else {
      return original;
    }
  }
}
