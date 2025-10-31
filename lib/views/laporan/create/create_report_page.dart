import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/laporan_provider.dart';
import '../../../services/draft_service.dart';
import 'step1_info_kapal.dart';
import 'step2_perjalanan.dart';
import 'step3_muatan.dart';
import 'step4_detail.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;
  bool _isSending = false;

  // --- CONTROLLER ---
  final _namaKapalController = TextEditingController();
  final _namaKapalKeduaController = TextEditingController();
  final _benderaKapalController = TextEditingController();
  final _grtKapalController = TextEditingController();
  final _imoNumberController = TextEditingController();
  final _pelabuhanAsalController = TextEditingController();
  final _waktuBerangkatController = TextEditingController();
  final _pelabuhanTujuanController = TextEditingController();
  final _estimasiTibaController = TextEditingController();
  final _pemilikKapalController = TextEditingController();
  final _kontakPemilikController = TextEditingController();
  final _agenLokalController = TextEditingController();
  final _kontakAgenController = TextEditingController();
  final _namaPanduController = TextEditingController();
  final _noRegisterPanduController = TextEditingController();
  final _jenisMuatanController = TextEditingController();
  final _jumlahMuatanController = TextEditingController();
  final _jumlahPenumpangController = TextEditingController();
  final _posisiLintangController = TextEditingController();
  final _posisiBujurController = TextEditingController();
  final _tanggalLaporanController = TextEditingController();
  final _uraianKejadianController = TextEditingController();

  // 🆕 Tambahan controller baru untuk field baru di Step4Detail
  final _jenisKecelakaanController = TextEditingController();
  final _pihakTerkaitController = TextEditingController();

  // --- STATE ---
  String? _selectedJenisKapal;
  final List<String> _listJenisKapal = [
    'KM (Kapal Motor)',
    'MV (Motor Vessel)',
    'MT (Motor Tanker)',
    'SPOB (Self Propeller Oil Barge)',
    'LCT (Landing Craft Tanker)',
    'TB (TUG Boat)',
    'BG (Barge)',
    'FC (Floating Crane)',
    'KLM (Kapal Layar Motor / Yacth)',
  ];

  final ImagePicker _picker = ImagePicker();
  List<XFile> _lampiranFiles = [];

  final MapController _mapController = MapController();
  final LatLng _initialPosition = LatLng(-3.317222, 114.590000);
  Marker? _currentMarker;
  Timer? _debounce;

  static const Color primaryColor = Color(0xFF005A9C);
  static const Color pageBackgroundColor = Color(0xFFF5F5F5);
  static const Color cardBackgroundColor = Colors.white;

  final List<String> _pageTitles = [
    'Langkah 1 dari 4: Info Kapal',
    'Langkah 2 dari 4: Info Perjalanan',
    'Langkah 3 dari 4: Info Muatan',
    'Langkah 4 dari 4: Detail Kejadian',
  ];

  @override
  void initState() {
    super.initState();
    _posisiLintangController.addListener(_onCoordinateChanged);
    _posisiBujurController.addListener(_onCoordinateChanged);
    _checkForDraft();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _posisiLintangController.removeListener(_onCoordinateChanged);
    _posisiBujurController.removeListener(_onCoordinateChanged);
    _pageController.dispose();

    _namaKapalController.dispose();
    _namaKapalKeduaController.dispose();
    _benderaKapalController.dispose();
    _grtKapalController.dispose();
    _imoNumberController.dispose();
    _pelabuhanAsalController.dispose();
    _waktuBerangkatController.dispose();
    _pelabuhanTujuanController.dispose();
    _estimasiTibaController.dispose();
    _pemilikKapalController.dispose();
    _kontakPemilikController.dispose();
    _agenLokalController.dispose();
    _kontakAgenController.dispose();
    _namaPanduController.dispose();
    _noRegisterPanduController.dispose();
    _jenisMuatanController.dispose();
    _jumlahMuatanController.dispose();
    _jumlahPenumpangController.dispose();
    _posisiLintangController.dispose();
    _posisiBujurController.dispose();
    _tanggalLaporanController.dispose();
    _uraianKejadianController.dispose();

    // 🆕 Jangan lupa dispose controller tambahan
    _jenisKecelakaanController.dispose();
    _pihakTerkaitController.dispose();

    super.dispose();
  }

  Future<void> _checkForDraft() async {
    final draft = await DraftService().loadDraft();
    if (draft != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Lanjutkan draft?"),
            content:
                const Text("Kami menemukan draft laporan yang belum dikirim."),
            actions: [
              TextButton(
                onPressed: () async {
                  await DraftService().clearDraft();
                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Buang"),
              ),
              TextButton(
                onPressed: () {
                  _namaKapalController.text = draft['nama_kapal'] ?? '';
                  _namaKapalKeduaController.text =
                      draft['nama_kapal_kedua'] ?? '';
                  _benderaKapalController.text = draft['bendera_kapal'] ?? '';
                  _grtKapalController.text = draft['grt_kapal'] ?? '';
                  _imoNumberController.text = draft['imo_number'] ?? '';
                  _pelabuhanAsalController.text = draft['pelabuhan_asal'] ?? '';
                  _waktuBerangkatController.text =
                      draft['waktu_berangkat'] ?? '';
                  _pelabuhanTujuanController.text =
                      draft['pelabuhan_tujuan'] ?? '';
                  _estimasiTibaController.text = draft['estimasi_tiba'] ?? '';
                  _pemilikKapalController.text = draft['pemilik_kapal'] ?? '';
                  _kontakPemilikController.text = draft['kontak_pemilik'] ?? '';
                  _agenLokalController.text = draft['agen_lokal'] ?? '';
                  _kontakAgenController.text = draft['kontak_agen'] ?? '';
                  _namaPanduController.text = draft['nama_pandu'] ?? '';
                  _noRegisterPanduController.text =
                      draft['nomor_register_pandu'] ?? '';
                  _jenisMuatanController.text = draft['jenis_muatan'] ?? '';
                  _jumlahMuatanController.text = draft['jumlah_muatan'] ?? '';
                  _jumlahPenumpangController.text =
                      draft['jumlah_penumpang'] ?? '';
                  _posisiLintangController.text = draft['posisi_lintang'] ?? '';
                  _posisiBujurController.text = draft['posisi_bujur'] ?? '';
                  _tanggalLaporanController.text =
                      draft['tanggal_laporan'] ?? '';
                  _uraianKejadianController.text = draft['isi_laporan'] ?? '';

                  // 🆕 Restore data tambahan jika ada
                  _jenisKecelakaanController.text =
                      draft['jenis_kecelakaan'] ?? '';
                  _pihakTerkaitController.text = draft['pihak_terkait'] ?? '';

                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Lanjutkan"),
              ),
            ],
          ),
        );
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onCoordinateChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1500), () {});
  }

  Future<void> _submitReport(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Tambahkan pengecekan lampiran wajib
    if (_lampiranFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lampiran wajib diunggah minimal 1 file."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    final provider = Provider.of<LaporanProvider>(context, listen: false);
    final data = _collectFormData();

    final success = await provider.submitReport(data, _lampiranFiles);
    if (!mounted) return;
    setState(() => _isSending = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Laporan berhasil dikirim")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(provider.errorMessage ?? "Gagal mengirim laporan.")),
      );
    }
  }

  Future<void> _saveDraft(BuildContext context) async {
    final data = _collectFormData();
    await Provider.of<LaporanProvider>(context, listen: false).saveDraft(data);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("💾 Draft berhasil disimpan")));
  }

  Map<String, String> _collectFormData() {
    return {
      'jenis_kapal': _selectedJenisKapal ?? '',
      'nama_kapal': _namaKapalController.text.trim(),
      'nama_kapal_kedua': _namaKapalKeduaController.text.trim(),
      'bendera_kapal': _benderaKapalController.text.trim(),
      'grt_kapal': _grtKapalController.text.trim(),
      'imo_number': _imoNumberController.text.trim(),
      'pelabuhan_asal': _pelabuhanAsalController.text.trim(),
      'waktu_berangkat': _waktuBerangkatController.text.trim(),
      'pelabuhan_tujuan': _pelabuhanTujuanController.text.trim(),
      'estimasi_tiba': _estimasiTibaController.text.trim(),
      'pemilik_kapal': _pemilikKapalController.text.trim(),
      'kontak_pemilik': _kontakPemilikController.text.trim(),
      'agen_lokal': _agenLokalController.text.trim(),
      'kontak_agen': _kontakAgenController.text.trim(),
      'nama_pandu': _namaPanduController.text.trim(),
      'nomor_register_pandu': _noRegisterPanduController.text.trim(),
      'jenis_muatan': _jenisMuatanController.text.trim(),
      'jumlah_muatan': _jumlahMuatanController.text.trim(),
      'jumlah_penumpang': _jumlahPenumpangController.text.trim(),
      'posisi_lintang': _posisiLintangController.text.trim(),
      'posisi_bujur': _posisiBujurController.text.trim(),
      'tanggal_laporan': _tanggalLaporanController.text.trim(),
      'isi_laporan': _uraianKejadianController.text.trim(),
      // 🆕 Sertakan field baru
      'jenis_kecelakaan': _jenisKecelakaanController.text.trim(),
      'pihak_terkait': _pihakTerkaitController.text.trim(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardBackgroundColor,
        foregroundColor: primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _pageTitles[_currentPage],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            Step1InfoKapal(
              currentUser: context.watch<AuthProvider>().user,
              selectedJenisKapal: _selectedJenisKapal,
              onJenisKapalChanged: (val) =>
                  setState(() => _selectedJenisKapal = val),
              namaKapalController: _namaKapalController,
              namaKapalKeduaController: _namaKapalKeduaController,
              benderaKapalController: _benderaKapalController,
              grtKapalController: _grtKapalController,
              imoNumberController: _imoNumberController,
              listJenisKapal: _listJenisKapal,
            ),
            Step2Perjalanan(
              pelabuhanAsalController: _pelabuhanAsalController,
              waktuBerangkatController: _waktuBerangkatController,
              pelabuhanTujuanController: _pelabuhanTujuanController,
              estimasiTibaController: _estimasiTibaController,
              pemilikKapalController: _pemilikKapalController,
              kontakPemilikController: _kontakPemilikController,
              agenLokalController: _agenLokalController,
              kontakAgenController: _kontakAgenController,
              namaPanduController: _namaPanduController,
              noRegisterPanduController: _noRegisterPanduController,
            ),
            Step3Muatan(
              jenisMuatanController: _jenisMuatanController,
              jumlahMuatanController: _jumlahMuatanController,
              jumlahPenumpangController: _jumlahPenumpangController,
            ),
            Step4Detail(
              posisiLintangController: _posisiLintangController,
              posisiBujurController: _posisiBujurController,
              tanggalLaporanController: _tanggalLaporanController,
              uraianKejadianController: _uraianKejadianController,

              // 🆕 wajib ditambahkan agar tidak error
              jenisKecelakaanController: _jenisKecelakaanController,
              pihakTerkaitController: _pihakTerkaitController,

              lampiranFiles: _lampiranFiles,
              picker: _picker,
              mapController: _mapController,
              initialPosition: _initialPosition,
              currentMarker: _currentMarker,
              isSending: _isSending,
              onLampiranChanged: (files) =>
                  setState(() => _lampiranFiles = files),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final isLastPage = _currentPage == _totalPages - 1;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          spacing: 8,
          children: [
            if (_currentPage > 0)
              OutlinedButton.icon(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
                icon: const Icon(Icons.arrow_back, color: primaryColor),
                label: const Text('Kembali',
                    style: TextStyle(color: primaryColor)),
              ),
            ElevatedButton(
              onPressed: _isSending
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        if (isLastPage) {
                          _submitReport(context);
                        } else {
                          _nextPage();
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      isLastPage ? 'Kirim Laporan' : 'Selanjutnya',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
            if (isLastPage)
              OutlinedButton.icon(
                onPressed: _isSending ? null : () => _saveDraft(context),
                icon: const Icon(Icons.save, color: primaryColor),
                label: const Text(
                  "Simpan Draft",
                  style: TextStyle(color: primaryColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
