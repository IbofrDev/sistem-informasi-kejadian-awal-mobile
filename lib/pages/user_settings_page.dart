import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _ptController;
  late TextEditingController _jabatanController;
  late TextEditingController _jenisKapalController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _namaController = TextEditingController(text: user?.nama ?? '');
    _ptController = TextEditingController(text: user?.pt ?? '-');
    _jabatanController = TextEditingController(text: user?.jabatan ?? '');
    _jenisKapalController =
        TextEditingController(text: user?.jenisKapal ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _ptController.dispose();
    _jabatanController.dispose();
    _jenisKapalController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).updateProfile(
        nama: _namaController.text,
        jabatan: _jabatanController.text,
        jenisKapal: _jenisKapalController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui profil: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _namaController,
                label: 'Nama',
                validator: (v) =>
                    v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),

              // ======== PT hanya baca (read-only) ========
              _buildReadOnlyField(
                label: 'Nama PT / Perusahaan',
                value: _ptController.text,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _jabatanController,
                label: 'Jabatan',
                validator: (v) => null,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _jenisKapalController,
                label: 'Jenis Kapal',
                validator: (v) => null,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _phoneController,
                label: 'Nomor HP',
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v!.isEmpty ? 'Nomor HP tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v!.isEmpty ? 'Email tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================== HELPER FIELD ==================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  // ===== READ-ONLY VARIAN =====
  Widget _buildReadOnlyField({
    required String label,
    required String value,
  }) {
    return TextFormField(
      readOnly: true,
      initialValue: value.isEmpty ? '-' : value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
      ),
    );
  }
}