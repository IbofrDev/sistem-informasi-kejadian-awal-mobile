import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/info_card.dart';
import '../../../widgets/common/read_only_field.dart';

class Step1InfoKapal extends StatelessWidget {
  final User? currentUser;
  final String? selectedJenisKapal;
  final Function(String?) onJenisKapalChanged;

  final TextEditingController namaKapalController;
  final TextEditingController namaKapalKeduaController;
  final TextEditingController benderaKapalController;
  final TextEditingController grtKapalController;
  final TextEditingController imoNumberController;
  final List<String> listJenisKapal;

  const Step1InfoKapal({
    super.key,
    required this.currentUser,
    required this.selectedJenisKapal,
    required this.onJenisKapalChanged,
    required this.namaKapalController,
    required this.namaKapalKeduaController,
    required this.benderaKapalController,
    required this.grtKapalController,
    required this.imoNumberController,
    required this.listJenisKapal,
  });

  static const Color primaryColor = Color(0xFF005A9C);
  static const Color cardBackgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InfoCard(
            title: 'Informasi Pelapor',
            children: [
              ReadOnlyField(
                label: 'Nama Pelapor',
                value: currentUser?.nama ?? 'Tidak Ditemukan',
              ),
              ReadOnlyField(
                label: 'Jabatan',
                value: currentUser?.jabatan ?? 'Tidak Ditemukan',
              ),
              ReadOnlyField(
                label: 'No. Telepon',
                value: currentUser?.phoneNumber ?? 'Tidak Ditemukan',
              ),
            ],
          ),
          InfoCard(
            title: 'Data Kapal',
            children: [
              CustomTextField(
                label: 'Nama Kapal *',
                controller: namaKapalController,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nama kapal wajib diisi' : null,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Jenis Kapal *',
                    filled: true,
                    fillColor: cardBackgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide:
                          BorderSide(color: primaryColor, width: 1.5),
                    ),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  isExpanded: true,
                  value: selectedJenisKapal,
                  dropdownColor: cardBackgroundColor,
                  items: listJenisKapal.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: const TextStyle(color: Colors.black87)),
                    );
                  }).toList(),
                  onChanged: onJenisKapalChanged,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Jenis kapal tidak boleh kosong'
                      : null,
                ),
              ),
              if (selectedJenisKapal == 'TB (TUG Boat)')
                CustomTextField(
                  label: 'Nama Kapal ke-2 (Gandengan)',
                  controller: namaKapalKeduaController,
                ),
              CustomTextField(
                label: 'Bendera Kapal *',
                controller: benderaKapalController,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Bendera kapal wajib diisi'
                    : null,
              ),
              CustomTextField(
                label: 'Gross Tonnage (GT) *',
                controller: grtKapalController,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Gross tonnage wajib diisi'
                    : null,
              ),
              CustomTextField(
                label: 'IMO Number (Opsional)',
                controller: imoNumberController,
              ),
            ],
          ),
        ],
      ),
    );
  }
}