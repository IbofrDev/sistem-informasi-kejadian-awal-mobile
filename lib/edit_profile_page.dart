import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

const Color primaryColor = Color(0xFF005A9C);
const Color pageBackgroundColor = Color(0xFFF5F5F5);
const Color cardBackgroundColor = Colors.white;
const double padding = 16.0;
const double spacing = 12.0;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _namaController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  // Controller untuk password
  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  String? _selectedJenisKapal;

  final List<String> _jenisKapalOptions = [
    'KM (Kapal Motor)',
    'MV (Motor Vessel)',
    'MT (Motor Tanker)',
    'SPOB (Self Propeller Oil Barge)',
    'LCT (Landing Craft Tanker)',
    'TB (TUG Boat)',
    'BG (Barge)',
    'FC (Floating Crane)',
    'KLM (Kapal Layar Motor / Yacht)',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;

    _namaController = TextEditingController(text: user?.nama ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _selectedJenisKapal = user?.jenisKapal;

    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().updateProfile(
            nama: _namaController.text,
            jenisKapal: _selectedJenisKapal ?? '',
            phoneNumber: _phoneController.text,
            email: _emailController.text,
            oldPassword: _oldPasswordController.text.isNotEmpty
                ? _oldPasswordController.text
                : null,
            newPassword: _newPasswordController.text.isNotEmpty
                ? _newPasswordController.text
                : null,
            confirmPassword: _confirmPasswordController.text.isNotEmpty
                ? _confirmPasswordController.text
                : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui profil: $e'),
              backgroundColor: Colors.red,
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: cardBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      labelStyle:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nama
              TextFormField(
                controller: _namaController,
                decoration: _buildInputDecoration('Nama'),
                style: const TextStyle(color: Colors.black87),
                validator: (value) =>
                    value!.isEmpty ? 'Nama wajib diisi' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: spacing),

              // Jenis Kapal (Dropdown)
              DropdownButtonFormField<String>(
                value: _selectedJenisKapal,
                decoration: _buildInputDecoration('Jenis Kapal'),
                isExpanded: true,
                items: _jenisKapalOptions.map((jenis) {
                  return DropdownMenuItem(
                    value: jenis,
                    child: Text(
                      jenis,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedJenisKapal = value),
                validator: (value) =>
                    value == null ? 'Jenis kapal harus dipilih' : null,
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: spacing),

              // No. HP
              TextFormField(
                controller: _phoneController,
                decoration: _buildInputDecoration('No. HP'),
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: spacing),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: _buildInputDecoration('Email'),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: const TextStyle(color: Colors.black87),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email wajib diisi';
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Masukkan format email yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: spacing * 2),

              // Password Lama
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: _buildInputDecoration('Password Lama'),
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: spacing),

              // Password Baru
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: _buildInputDecoration('Password Baru'),
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: spacing),

              // Konfirmasi Password Baru
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: _buildInputDecoration('Konfirmasi Password Baru'),
                style: const TextStyle(color: Colors.black87),
                validator: (value) {
                  if (_newPasswordController.text.isNotEmpty &&
                      value != _newPasswordController.text) {
                    return 'Konfirmasi password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: spacing * 2),

              // Tombol Simpan
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor))
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}