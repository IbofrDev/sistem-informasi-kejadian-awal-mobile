import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/info_card.dart';

class Step2Perjalanan extends StatelessWidget {
  final TextEditingController pelabuhanAsalController;
  final TextEditingController waktuBerangkatController;
  final TextEditingController pelabuhanTujuanController;
  final TextEditingController estimasiTibaController;
  final TextEditingController pemilikKapalController;
  final TextEditingController kontakPemilikController;
  final TextEditingController agenLokalController;
  final TextEditingController kontakAgenController;
  final TextEditingController namaPanduController;
  final TextEditingController noRegisterPanduController;

  const Step2Perjalanan({
    super.key,
    required this.pelabuhanAsalController,
    required this.waktuBerangkatController,
    required this.pelabuhanTujuanController,
    required this.estimasiTibaController,
    required this.pemilikKapalController,
    required this.kontakPemilikController,
    required this.agenLokalController,
    required this.kontakAgenController,
    required this.namaPanduController,
    required this.noRegisterPanduController,
  });

  static const Color primaryColor = Color(0xFF005A9C);

  Future<void> _selectDateTime(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        // Tema khusus hanya untuk dialog date picker
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor, // warna header & tombol OK/Cancel
              onSurface: Colors.black87, // warna teks
            ),
            dialogBackgroundColor: Colors.white,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors
                  .white, // sama seperti CustomTextField.cardBackgroundColor
              labelStyle: const TextStyle(color: Colors.black54),
              hintStyle: const TextStyle(color: Colors.black54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor, // warna teks tombol Cancel & OK
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (pickedTime == null) return;

    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    controller.text = DateFormat('MM/dd/yyyy').format(finalDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InfoCard(
            title: 'Rute Perjalanan',
            children: [
              CustomTextField(
                label: 'Pelabuhan Asal *',
                controller: pelabuhanAsalController,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Pelabuhan asal wajib diisi'
                    : null,
              ),
              CustomTextField(
                label: 'Waktu Berangkat *',
                controller: waktuBerangkatController,
                isDateField: true,
                onDateTap: () =>
                    _selectDateTime(context, waktuBerangkatController),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Waktu berangkat wajib diisi'
                    : null,
              ),
              CustomTextField(
                label: 'Pelabuhan Tujuan *',
                controller: pelabuhanTujuanController,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Pelabuhan tujuan wajib diisi'
                    : null,
              ),
              CustomTextField(
                label: 'Estimasi Tiba *',
                controller: estimasiTibaController,
                isDateField: true,
                onDateTap: () =>
                    _selectDateTime(context, estimasiTibaController),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Estimasi tiba wajib diisi'
                    : null,
              ),
            ],
          ),
          InfoCard(
            title: 'Pihak Terkait',
            children: [
              CustomTextField(
                label: 'Pemilik / Operator Kapal *',
                controller: pemilikKapalController,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Pemilik kapal wajib diisi'
                    : null,
              ),
              CustomTextField(
                label: 'Kontak Pemilik / Operator *',
                controller: kontakPemilikController,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Kontak pemilik wajib diisi'
                    : null,
              ),
              CustomTextField(
                label: 'Agen Lokal *',
                controller: agenLokalController,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Agen lokal wajib diisi' : null,
              ),
              CustomTextField(
                label: 'Kontak Agen *',
                controller: kontakAgenController,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Kontak agen wajib diisi' : null,
              ),
              CustomTextField(
                label: 'Nama Pandu (Opsional)',
                controller: namaPanduController,
              ),
              CustomTextField(
                label: 'No. Register Pandu (Opsional)',
                controller: noRegisterPanduController,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
