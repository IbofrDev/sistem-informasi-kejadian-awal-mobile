import 'package:flutter/material.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/info_card.dart';

class Step3Muatan extends StatelessWidget {
  final TextEditingController jenisMuatanController;
  final TextEditingController jumlahMuatanController;
  final TextEditingController jumlahPenumpangController;

  const Step3Muatan({
    super.key,
    required this.jenisMuatanController,
    required this.jumlahMuatanController,
    required this.jumlahPenumpangController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InfoCard(
            title: 'Detail Muatan & Penumpang',
            children: [
              CustomTextField(
                label: 'Jenis Muatan *',
                controller: jenisMuatanController,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Jenis muatan wajib diisi' : null,
              ),
              CustomTextField(
                label: 'Jumlah Muatan *',
                controller: jumlahMuatanController,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Jumlah muatan wajib diisi' : null,
              ),
              CustomTextField(
                label: 'Jumlah Kru & Penumpang  *',
                controller: jumlahPenumpangController,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Jumlah Kru & Penumpang wajib diisi'
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}