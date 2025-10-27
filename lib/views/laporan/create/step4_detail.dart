import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/info_card.dart';

class Step4Detail extends StatefulWidget {
  final TextEditingController posisiLintangController;
  final TextEditingController posisiBujurController;
  final TextEditingController tanggalLaporanController;
  final TextEditingController uraianKejadianController;
  final TextEditingController jenisKecelakaanController;
  final TextEditingController pihakTerkaitController;

  final List<XFile> lampiranFiles;
  final ImagePicker picker;
  final MapController mapController;
  final LatLng initialPosition;
  final Marker? currentMarker;
  final bool isSending;

  final Function(List<XFile>) onLampiranChanged;

  const Step4Detail({
    super.key,
    required this.posisiLintangController,
    required this.posisiBujurController,
    required this.tanggalLaporanController,
    required this.uraianKejadianController,
    required this.jenisKecelakaanController,
    required this.pihakTerkaitController,
    required this.lampiranFiles,
    required this.picker,
    required this.mapController,
    required this.initialPosition,
    required this.currentMarker,
    required this.isSending,
    required this.onLampiranChanged,
  });

  @override
  State<Step4Detail> createState() => _Step4DetailState();
}

class _Step4DetailState extends State<Step4Detail> {
  static const Color primaryColor = Color(0xFF005A9C);
  static const Color cardBackgroundColor = Colors.white;

  Marker? _currentMarker;

  final List<String> _jenisKecelakaanOptions = const [
    'Kecelakaan Tunggal',
    'Kecelakaan Antar Kapal (Tabrakan)',
    'Kecelakaan di Pelabuhan / Saat Sandar',
    'Kecelakaan karena Cuaca Ekstrem / Alam',
    'Kapal Terbalik / Tenggelam',
    'Kehilangan Kendali (Mesin / Kemudi Rusak)',
    'Kecelakaan dengan Fasilitas / Masyarakat',
    'Insiden Muatan / Tumpahan Bahan Berbahaya',
  ];

  String? _selectedJenisKecelakaan;

  @override
  void initState() {
    super.initState();
    _currentMarker = widget.currentMarker;
    widget.posisiLintangController.addListener(_onCoordinateFieldsChanged);
    widget.posisiBujurController.addListener(_onCoordinateFieldsChanged);

    _selectedJenisKecelakaan = widget.jenisKecelakaanController.text.isNotEmpty
        ? widget.jenisKecelakaanController.text
        : null;
  }

  @override
  void dispose() {
    widget.posisiLintangController.removeListener(_onCoordinateFieldsChanged);
    widget.posisiBujurController.removeListener(_onCoordinateFieldsChanged);
    super.dispose();
  }

  void _onCoordinateFieldsChanged() {
    try {
      final latText = widget.posisiLintangController.text.trim();
      final lngText = widget.posisiBujurController.text.trim();
      if (latText.isEmpty || lngText.isEmpty) return;

      final lat = _dmsToDd(latText);
      final lng = _dmsToDd(lngText);
      if (lat == null || lng == null) return;

      final newPoint = LatLng(lat, lng);
      setState(() {
        _currentMarker = Marker(
          point: newPoint,
          width: 80,
          height: 80,
          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
        );
      });
      widget.mapController.move(newPoint, widget.mapController.camera.zoom);
    } catch (_) {}
  }

  double? _dmsToDd(String dms) {
    final regex = RegExp(r'''(\d+)[°\s]+(\d+)['\s]+([\d.]+)"?\s*([UTSBNSEW])''',
        caseSensitive: false);
    final match = regex.firstMatch(dms);
    if (match == null) return null;
    final deg = double.parse(match.group(1)!);
    final min = double.parse(match.group(2)!);
    final sec = double.parse(match.group(3)!);
    final dir = match.group(4)!.toUpperCase();
    double dd = deg + (min / 60) + (sec / 3600);
    if (dir == 'S' || dir == 'B' || dir == 'W') dd *= -1;
    return dd;
  }

  Future<void> _pickMedia(ImageSource source, {required bool isVideo}) async {
    try {
      if (isVideo) {
        final XFile? file = await widget.picker.pickVideo(source: source);
        if (file != null) {
          final updated = [...widget.lampiranFiles, file];
          widget.onLampiranChanged(updated);
        }
      } else {
        if (source == ImageSource.gallery) {
          final List<XFile> files = await widget.picker.pickMultiImage();
          if (files.isNotEmpty) {
            final updated = [...widget.lampiranFiles, ...files];
            widget.onLampiranChanged(updated);
          }
        } else {
          final XFile? file = await widget.picker.pickImage(source: source);
          if (file != null) {
            final updated = [...widget.lampiranFiles, file];
            widget.onLampiranChanged(updated);
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal mengambil media: $e")));
    }
  }

  void _removeAttachment(int index) {
    final updated = [...widget.lampiranFiles]..removeAt(index);
    widget.onLampiranChanged(updated);
  }

  String _ddToDms(double dd, bool isLat) {
    var positive = dd >= 0;
    dd = dd.abs();
    var deg = dd.floor();
    var frac = (dd - deg) * 60;
    var min = frac.floor();
    var sec = (frac - min) * 60;
    String direction = isLat ? (positive ? 'U' : 'S') : (positive ? 'T' : 'B');
    return '$deg° $min\' ${sec.toStringAsFixed(2)}" $direction';
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Layanan lokasi tidak aktif. Mohon aktifkan GPS.')));
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin lokasi ditolak.')));
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Izin lokasi ditolak permanen, tidak dapat meminta izin.')));
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _updateMapAndFields(LatLng(position.latitude, position.longitude));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal mengambil lokasi: $e")));
    }
  }

  void _updateMapAndFields(LatLng point) {
    setState(() {
      _currentMarker = Marker(
        point: point,
        width: 80,
        height: 80,
        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
      );
    });
    widget.posisiLintangController.text = _ddToDms(point.latitude, true);
    widget.posisiBujurController.text = _ddToDms(point.longitude, false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        widget.mapController.move(point, 15.0);
      } catch (_) {}
    });
  }

  Future<void> _selectDateTime(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate == null) return;
    final TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime == null) return;
    final DateTime finalDateTime = DateTime(pickedDate.year, pickedDate.month,
        pickedDate.day, pickedTime.hour, pickedTime.minute);
    controller.text = DateFormat('yyyy-MM-dd HH:mm').format(finalDateTime);
  }

  Future<void> _showAttachmentPicker() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih Foto dari Galeri'),
              onTap: () {
                _pickMedia(ImageSource.gallery, isVideo: false);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Ambil Foto Baru'),
              onTap: () {
                _pickMedia(ImageSource.camera, isVideo: false);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Pilih Video dari Galeri'),
              onTap: () {
                _pickMedia(ImageSource.gallery, isVideo: true);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Rekam Video Baru'),
              onTap: () {
                _pickMedia(ImageSource.camera, isVideo: true);
                Navigator.of(context).pop();
              },
            ),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // ------------------- Lokasi Kejadian -------------------
        InfoCard(
          title: 'Lokasi Kejadian',
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  mapController: widget.mapController,
                  options: MapOptions(
                    initialCenter: widget.initialPosition,
                    initialZoom: 12,
                    onTap: (tapPosition, point) => _updateMapAndFields(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'sistem_kejadian_awal_mobile',
                    ),
                    if (_currentMarker != null)
                      MarkerLayer(markers: [_currentMarker!]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.my_location),
                label: const Text('Gunakan Lokasi Saat Ini'),
                onPressed: _getCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Posisi Lintang *',
              controller: widget.posisiLintangController,
              hintText: 'Contoh: 3° 28\' 12.34" S',
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Posisi lintang wajib diisi' : null,
            ),
            CustomTextField(
              label: 'Posisi Bujur *',
              controller: widget.posisiBujurController,
              hintText: 'Contoh: 114° 35\' 24.00" T',
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Posisi bujur wajib diisi' : null,
            ),
          ],
        ),

        // ------------------- Rincian Laporan -------------------
        InfoCard(
          title: 'Rincian Laporan',
          children: [
            CustomTextField(
              label: 'Tanggal Laporan *',
              controller: widget.tanggalLaporanController,
              isDateField: true,
              onDateTap: () =>
                  _selectDateTime(context, widget.tanggalLaporanController),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Tanggal laporan wajib diisi' : null,
            ),
            CustomTextField(
              label: 'Uraian Kejadian *',
              controller: widget.uraianKejadianController,
              maxLines: 5,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Uraian wajib diisi' : null,
            ),

            // === Dropdown desain seperti Step1 ===
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Jenis Kecelakaan Kapal *',
                  filled: true,
                  fillColor: cardBackgroundColor,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                value: _selectedJenisKecelakaan,
                dropdownColor: cardBackgroundColor,
                items: _jenisKecelakaanOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: const TextStyle(color: Colors.black87)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedJenisKecelakaan = value;
                    widget.jenisKecelakaanController.text = value ?? '';
                    if (value != 'Kecelakaan Antar Kapal (Tabrakan)') {
                      widget.pihakTerkaitController.clear();
                    }
                  });
                },
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Jenis kecelakaan tidak boleh kosong'
                    : null,
              ),
            ),

            // === Kolom tambahan bila tabrakan ===
            if (_selectedJenisKecelakaan ==
                'Kecelakaan Antar Kapal (Tabrakan)')
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: CustomTextField(
                  label: 'Pihak Terkait *',
                  controller: widget.pihakTerkaitController,
                  hintText:
                      'Misal: Kapal Nelayan, Kapal Cargo, Kapal Penumpang, dsb.',
                  validator: (v) {
                    if (_selectedJenisKecelakaan ==
                            'Kecelakaan Antar Kapal (Tabrakan)' &&
                        (v == null || v.isEmpty)) {
                      return 'Pihak terkait wajib diisi untuk tabrakan antar kapal';
                    }
                    return null;
                  },
                ),
              ),
          ],
        ),

        // ------------------- Lampiran -------------------
        InfoCard(
          title: 'Lampiran',
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.lampiranFiles.length + 1,
              itemBuilder: (context, index) {
                if (index == widget.lampiranFiles.length) {
                  return InkWell(
                    onTap: _showAttachmentPicker,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: Colors.grey),
                          SizedBox(height: 4),
                          Text('Tambah',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }
                final file = widget.lampiranFiles[index];
                final isVideo =
                    file.path.endsWith('.mp4') || file.path.endsWith('.mov');
                return Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: isVideo
                          ? null
                          : DecorationImage(
                              image: FileImage(File(file.path)),
                              fit: BoxFit.cover,
                            ),
                      color: isVideo ? Colors.black : Colors.transparent,
                    ),
                    child: isVideo
                        ? const Center(
                            child: Icon(Icons.play_circle_fill,
                                color: Colors.white, size: 40))
                        : null,
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => _removeAttachment(index),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  )
                ]);
              },
            ),
          ],
        ),
      ]),
    );
  }
}