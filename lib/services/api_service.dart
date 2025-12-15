import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/laporan.dart';
import '../models/user.dart';

class ApiService {
  final Dio _dio;

  // ⚙️ Ganti baseUrl sesuai alamat server Laravel kamu
  static const String _baseUrl = 'https://kecelakaankapal.my.id/api';

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) async {
        // Tambahkan Authorization header otomatis ke semua request kecuali login/register
        if (!options.path.contains('/login') &&
            !options.path.contains('/register')) {
          final token = await getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('📡 Authorization ditambahkan: Bearer $token');
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
      final response = await _dio
          .post('/login', data: {'email': email, 'password': password});

      if (response.statusCode != 200) {
        throw Exception('Login gagal: ${response.data['message']}');
      }

      print('🧾 LOGIN response: ${response.data}');

      final token = response.data['access_token'] ??
          response.data['token'] ??
          response.data['plainTextToken'] ??
          '';

      if (token.isEmpty) throw Exception('Token tidak ditemukan.');

      await saveToken(token);
      return response.data;
    } on DioException catch (e) {
      // 🔒 Handle 403 - Admin tidak boleh login via mobile
      if (e.response?.statusCode == 403) {
        final message = e.response?.data['message'] ??
            'Akun admin tidak dapat mengakses aplikasi mobile.';
        throw Exception(message);
      }
      // Handle 401 - Email/password salah
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
      print('📊 Status Code: ${response.statusCode}');

      // ✅ CEK STATUS CODE
      if (response.statusCode != 201 && response.statusCode != 200) {
        // Jika bukan success, throw error
        final errorMsg = response.data['message'] ?? 'Registrasi gagal';
        throw Exception(errorMsg);
      }

      // ✅ CEK APAKAH ADA TOKEN
      final token = response.data['access_token'] ??
          response.data['token'] ??
          response.data['plainTextToken'] ??
          '';

      if (token.isEmpty) {
        throw Exception('Token tidak ditemukan dalam respons');
      }

      // ✅ CEK APAKAH ADA DATA USER
      if (response.data['user'] == null) {
        throw Exception('Data user tidak ditemukan dalam respons');
      }

      await saveToken(token);
      return response.data;
    } on DioException catch (e) {
      // ✅ HANDLE VALIDATION ERROR (422)
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null && errors is Map) {
          // Ambil error pertama
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError[0]);
          }
        }
        throw Exception(e.response?.data['message'] ?? 'Validasi gagal');
      }
      throw Exception(_handleError(e));
    } catch (e) {
      // ✅ HANDLE ERROR LAINNYA
      if (e is Exception) rethrow;
      throw Exception('Registrasi gagal: ${e.toString()}');
    }
  }

  Future<User> getUser() async {
    try {
      final response = await _dio.get('/user');

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Gagal mengambil data pengguna (token tidak valid).');
      }

      final data = response.data;
      if (data is Map && data.containsKey('user')) {
        return User.fromJson(data['user']);
      }
      return User.fromJson(data);
    } on DioException catch (e) {
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
    print('💾 Token disimpan: $token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    print('🧹 Token dihapus.');
  }

  // ===============================================================
  // 🧠 LAPORAN (USER)
  // ===============================================================

  Future<List<Laporan>> getLaporanHistory() async {
    try {
      final response = await _dio.get('/laporan');
      final data = response.data;

      // Laravel sekarang mengirim array JSON langsung
      if (data is List) {
        return data.map((json) => Laporan.fromJson(json)).toList();
      }

      // Jika API mengirim berbentuk { data: [...] }
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((json) => Laporan.fromJson(json))
            .toList();
      }

      // Jika bukan salah satu di atas
      throw Exception('Format respons laporan tidak dikenali.');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> createReport(
    Map<String, String> data,
    List<XFile> lampiran,
  ) async {
    try {
      final formData = FormData.fromMap({...data});

      // ✅ PERBAIKAN: Gunakan readAsBytes() yang kompatibel Web & Mobile
      for (final file in lampiran) {
        // Baca file sebagai bytes (cross-platform)
        final bytes = await file.readAsBytes();

        // Tentukan MIME type berdasarkan ekstensi file
        String? mimeType;
        final extension = file.name.toLowerCase().split('.').last;
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'png':
            mimeType = 'image/png';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          case 'pdf':
            mimeType = 'application/pdf';
            break;
          default:
            mimeType = 'application/octet-stream';
        }

        formData.files.add(MapEntry(
          'lampiran[]',
          MultipartFile.fromBytes(
            bytes,
            filename: file.name,
            contentType: DioMediaType.parse(mimeType),
          ),
        ));
      }

      final response = await _dio.post('/laporan', data: formData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Laporan berhasil dikirim (${lampiran.length} lampiran)');
      } else {
        print('⚠️ Respons tidak terduga (${response.statusCode})');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ===============================================================
  // 🔹 Diperbarui bagian ini
  // ===============================================================
  Future<Laporan> getLaporanDetail(int laporanId) async {
    try {
      final response = await _dio.get('/laporan/$laporanId');
      print('🧾 RESPONSE DETAIL LAPORAN: ${response.data}');
      final raw = response.data;

      // Perbaikan: tangani kemungkinan data dikemas dalam key "data"
      final laporanData = (raw is Map && raw.containsKey('laporan'))
          ? raw['laporan']
          : (raw is Map && raw.containsKey('data'))
              ? raw['data']
              : raw;

      print('🧾 PARSED LAPORAN DATA: $laporanData');
      return Laporan.fromJson(laporanData, baseUrl: _dio.options.baseUrl);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ===============================================================
  // 👑 ADMIN SECTION
  // ===============================================================
  Future<Laporan> getLaporanDetailForAdmin(int laporanId) async {
    try {
      final response = await _dio.get('/admin/laporan/$laporanId');

      // Perbaikan: tangani kemungkinan data dikemas dalam key "data"
      final raw = response.data;
      final laporanData = (raw is Map && raw.containsKey('laporan'))
          ? raw['laporan']
          : (raw is Map && raw.containsKey('data'))
              ? raw['data']
              : raw;

      return Laporan.fromJson(laporanData, baseUrl: _dio.options.baseUrl);
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
      print('📝 Status laporan $laporanId diperbarui ke $status');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<Laporan>> getLaporanByUserForAdmin(int userId) async {
    try {
      final response = await _dio.get('/admin/pelapor/$userId/laporan');
      final List<dynamic> body = response.data;
      return body.map((json) => Laporan.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<User>> getReporters() async {
    try {
      final response = await _dio.get('/admin/pelapor');
      final List<dynamic> body = response.data;
      return body.map((json) => User.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> getAdminDashboardData({String? status}) async {
    try {
      final queryParams = {if (status != null) 'status': status};
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
      print('🔑 Password user $userId berhasil direset.');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> updateUserData(int userId, Map<String, String?> data) async {
    try {
      await _dio.put('/admin/users/$userId', data: data);
      print('⚙️ Data user $userId diperbarui.');
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
      final data = e.response?.data as Map;
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
