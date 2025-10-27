import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'dashboard_page.dart';
import 'login_page.dart';

// --- KONSTANTA DESAIN UNTUK KONSISTENSI ---
const Color primaryColor = Color(0xFF005A9C);
const Color pageBackgroundColor = Color(0xFFF5F5F5);
const Color cardBackgroundColor = Colors.white;
const Color secondaryTextColor = Color(0xFF666666);
const double padding = 24.0;
const double spacing = 16.0;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _ptController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedJabatan;
  String? _selectedJenisKapal;
  bool _isLoading = false;
  bool _passwordVisible = false;

  // Daftar opsi dropdown
  final List<String> _jabatanOptions = [
    'Master/Nakhoda',
    'C/O (Chief Officer)',
    '2nd Officer',
    '3rd Officer'
  ];

  final List<String> _jenisKapalOptions = [
    'KM (Kapal Motor)',
    'MV (Motor Vessel)',
    'MT (Motor Tanker)',
    'SPOB (Self Propeller Oil Barge)',
    'LCT (Landing Craft Tanker)',
    'TB (TUG Boat)',
    'BG (Barge)',
    'FC (Floating Crane)',
    'KLM (Kapal Layar Motor / Yacht)'
  ];

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.register(
        nama: _namaController.text,
        pt: _ptController.text,
        jabatan: _selectedJabatan!,
        jenisKapal: _selectedJenisKapal!,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrasi Gagal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _ptController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: pageBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Buat Akun Baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Isi data di bawah untuk mendaftar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: secondaryTextColor),
                ),
                const SizedBox(height: spacing * 2),

                // ====== Input Nama Lengkap ======
                _buildTextField(
                  controller: _namaController,
                  labelText: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: spacing),

                // ====== Input Nama PT ======
                _buildTextField(
                  controller: _ptController,
                  labelText: 'Nama PT / Perusahaan',
                  icon: Icons.business_outlined,
                  validator: (v) =>
                      v!.isEmpty ? 'Nama PT tidak boleh kosong' : null,
                ),
                const SizedBox(height: spacing),

                // ====== Dropdown Jabatan ======
                _buildDropdownField(
                  value: _selectedJabatan,
                  labelText: 'Jabatan',
                  icon: Icons.work_outline,
                  items: _jabatanOptions,
                  onChanged: (v) => setState(() => _selectedJabatan = v),
                  validator: (v) => v == null ? 'Jabatan harus dipilih' : null,
                ),
                const SizedBox(height: spacing),

                // ====== Dropdown Jenis Kapal ======
                _buildDropdownField(
                  value: _selectedJenisKapal,
                  labelText: 'Jenis Kapal',
                  icon: Icons.directions_boat_outlined,
                  items: _jenisKapalOptions,
                  onChanged: (v) => setState(() => _selectedJenisKapal = v),
                  validator: (v) =>
                      v == null ? 'Jenis kapal harus dipilih' : null,
                ),
                const SizedBox(height: spacing),

                // ====== Input Nomor Telepon ======
                _buildTextField(
                  controller: _phoneController,
                  labelText: 'Nomor Telepon',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v!.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
                ),
                const SizedBox(height: spacing),

                // ====== Input Email ======
                _buildTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Email tidak valid'
                      : null,
                ),
                const SizedBox(height: spacing),

                // ====== Input Password ======
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: !_passwordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: secondaryTextColor,
                    ),
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  ),
                  validator: (v) => v == null || v.length < 8
                      ? 'Password minimal 8 karakter'
                      : null,
                ),
                const SizedBox(height: spacing * 2),

                // ====== Tombol Daftar ======
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('DAFTAR'),
                ),
                const SizedBox(height: spacing * 1.5),

                // ====== Teks Login ======
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Sudah punya akun? ',
                      style: const TextStyle(
                          color: secondaryTextColor,
                          fontSize: 14,
                          fontFamily: 'Poppins'),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: spacing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== HELPER METHODS =====================
  InputDecoration _inputDecoration(String label, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
      prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.7)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: cardBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      decoration: _inputDecoration(labelText, icon, suffixIcon: suffixIcon),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String labelText,
    required IconData icon,
    required List<String> items,
    void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(labelText, icon),
      isExpanded: true,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      selectedItemBuilder: (context) => items
          .map((item) => Text(item,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}