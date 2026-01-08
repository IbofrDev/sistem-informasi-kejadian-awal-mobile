import 'package:flutter/material.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/info_card.dart';

class Step2Perjalanan extends StatefulWidget {
  final TextEditingController pelabuhanAsalController;
  final TextEditingController
      tanggalBerangkatController; // Gabungan tanggal + jam
  final TextEditingController pelabuhanTujuanController;
  final TextEditingController jadwalTibaController; // GANTI NAMA
  final TextEditingController pemilikKapalController;
  final TextEditingController kontakPemilikController;
  final TextEditingController agenLokalController;
  final TextEditingController kontakAgenController;
  final TextEditingController namaPanduController;
  final TextEditingController noRegisterPanduController;

  const Step2Perjalanan({
    super.key,
    required this.pelabuhanAsalController,
    required this.tanggalBerangkatController, // Gabungan tanggal + jam
    required this.pelabuhanTujuanController,
    required this.jadwalTibaController, // GANTI NAMA
    required this.pemilikKapalController,
    required this.kontakPemilikController,
    required this.agenLokalController,
    required this.kontakAgenController,
    required this.namaPanduController,
    required this.noRegisterPanduController,
  });

  @override
  State<Step2Perjalanan> createState() => _Step2PerjalananState();
}

class _Step2PerjalananState extends State<Step2Perjalanan> {
  static const Color primaryColor = Color(0xFF005A9C);

  // Method-method baru akan ditambahkan di sini

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
                controller: widget.pelabuhanAsalController,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Pelabuhan asal wajib diisi'
                    : null,
              ),
              CustomTextField(
                label: 'Waktu Berangkat *',
                controller: widget.tanggalBerangkatController,
                isDateField: true,
                onDateTap: () =>
                    _selectDateTime(context, widget.tanggalBerangkatController),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Waktu berangkat wajib diisi'
                    : null,
              ),
              CustomTextField(
                label: 'Pelabuhan Tujuan *',
                controller: widget.pelabuhanTujuanController,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Pelabuhan tujuan wajib diisi'
                    : null,
              ),
              CustomTextField(
                label: 'Perkiraan Waktu Tiba Awal (Opsional)',
                controller: widget.jadwalTibaController,
                isDateField: true,
                onDateTap: () =>
                    _selectDateTime(context, widget.jadwalTibaController),
              ),
            ],
          ),
          InfoCard(
            title: 'Pihak Terkait',
            children: [
              CustomTextField(
                label: 'Pemilik / Operator Kapal *',
                controller: widget.pemilikKapalController,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Pemilik kapal wajib diisi'
                    : null,
              ),
              CustomTextField(
                label: 'Kontak Pemilik / Operator *',
                controller: widget.kontakPemilikController,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Kontak pemilik wajib diisi'
                    : null,
              ),
              CustomTextField(
                label: 'Agen Lokal *',
                controller: widget.agenLokalController,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Agen lokal wajib diisi' : null,
              ),
              CustomTextField(
                label: 'Kontak Agen *',
                controller: widget.kontakAgenController,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Kontak agen wajib diisi' : null,
              ),
              CustomTextField(
                label: 'Nama Pandu (Opsional)',
                controller: widget.namaPanduController,
              ),
              CustomTextField(
                label: 'No. Register Pandu (Opsional)',
                controller: widget.noRegisterPanduController,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Pilih Tanggal Keberangkatan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      // ⬇️ BAGIAN PENTING: pakai calendarOnly agar ikon pensil hilang
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            useMaterial3: true, // boleh dihapus jika tidak pakai M3
            datePickerTheme: const DatePickerThemeData(
                // optional: styling lain jika mau
                ),
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Pilih Jam Keberangkatan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: primaryColor,
                onSurface: Colors.black87,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (pickedTime == null) return;

    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Format: "2025-01-15 13:14:00"
    controller.text = '${finalDateTime.year}-'
        '${finalDateTime.month.toString().padLeft(2, '0')}-'
        '${finalDateTime.day.toString().padLeft(2, '0')} '
        '${finalDateTime.hour.toString().padLeft(2, '0')}:'
        '${finalDateTime.minute.toString().padLeft(2, '0')}:00';
  }
}
