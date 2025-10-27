import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/admin_provider.dart';

class EditUserPage extends StatefulWidget {
  final User user;

  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  String? _selectedJabatan;
  String? _selectedJenisKapal;

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
    'KLM (Kapal Layar Motor / Yacth)'
  ];

  static const Color primaryColor = Color(0xFF005A9C);
  static const Color pageBackgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.user.nama);
    _phoneController =
        TextEditingController(text: widget.user.phoneNumber ?? '');

    if (widget.user.jabatan != null &&
        _jabatanOptions.contains(widget.user.jabatan)) {
      _selectedJabatan = widget.user.jabatan;
    } else {
      _selectedJabatan = null;
    }

    if (widget.user.jenisKapal != null &&
        _jenisKapalOptions.contains(widget.user.jenisKapal)) {
      _selectedJenisKapal = widget.user.jenisKapal;
    } else {
      _selectedJenisKapal = null;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      await provider.updateUser(
        widget.user.id,
        {
          'nama': _namaController.text,
          'jabatan': _selectedJabatan,
          'jenis_kapal': _selectedJenisKapal,
          'phone_number': _phoneController.text,
        },
      );

      if (mounted) {
        // --- PERUBAHAN: HAPUS SNACKBAR DARI SINI ---
        // ScaffoldMessenger.of(context).showSnackBar(...); // <-- DIHAPUS

        // Hanya pop dengan nilai 'true' untuk memberi sinyal sukses
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // ... sisa kode build dan widget lainnya tetap sama ...
  // (kode sengaja dipersingkat untuk fokus pada perubahan)

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: Colors.white,
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
      labelStyle: const TextStyle(color: Colors.black54),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Edit Informasi User',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _namaController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildDropdownFormField(
                value: _selectedJabatan,
                labelText: 'Jabatan',
                icon: Icons.work_outline,
                items: _jabatanOptions,
                onChanged: (newValue) {
                  setState(() => _selectedJabatan = newValue);
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownFormField(
                value: _selectedJenisKapal,
                labelText: 'Jenis Kapal',
                icon: Icons.directions_boat_outlined,
                items: _jenisKapalOptions,
                onChanged: (newValue) {
                  setState(() => _selectedJenisKapal = newValue);
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Nomor Telepon',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32), // Jarak sebelum tombol
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3))
                      : const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
          color: Colors.black87, fontWeight: FontWeight.w500),
      decoration: _buildInputDecoration(labelText: label, icon: icon),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownFormField({
    required String? value,
    required String labelText,
    required IconData icon,
    required List<String> items,
    void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      style: const TextStyle(
          color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 16),
      iconEnabledColor: Colors.grey[700],
      dropdownColor: Colors.white,
      decoration: _buildInputDecoration(labelText: labelText, icon: icon),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? '$labelText harus dipilih' : null,
    );
  }
}

