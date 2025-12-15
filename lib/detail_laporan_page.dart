import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/laporan.dart';
import '../services/api_service.dart';
import '../services/pdf_generator.dart';
import 'image_preview_page.dart';
import 'video_preview_page.dart';

class DetailLaporanPage extends StatefulWidget {
  final int laporanId;
  final bool isAdmin;

  const DetailLaporanPage({
    super.key,
    required this.laporanId,
    this.isAdmin = false,
  });

  @override
  State<DetailLaporanPage> createState() => _DetailLaporanPageState();
}

class _DetailLaporanPageState extends State<DetailLaporanPage> {
  late Future<Laporan> _laporanFuture;
  final ApiService _apiService = ApiService();

  String? _selectedStatus;
  bool _isUpdatingStatus = false;
  bool _isPrintingPdf = false;

  static const Color primaryColor = Color(0xFF005A9C);
  static const Color pageBackgroundColor = Color(0xFFF5F5F5);
  static const List<String> _statusOptions = [
    'Dikirim',
    'Diverifikasi',
    'Selesai'
  ];

  @override
  void initState() {
    super.initState();
    _laporanFuture = widget.isAdmin
        ? _apiService.getLaporanDetailForAdmin(widget.laporanId)
        : _apiService.getLaporanDetail(widget.laporanId);

    _laporanFuture.then((laporan) {
      if (mounted && laporan.statusLaporan != null) {
        setState(() {
          _selectedStatus = laporan.statusLaporan!.toLowerCase();
        });
      }
    });
  }

  Future<void> _handleStatusUpdate(String newStatus, int id) async {
    setState(() => _isUpdatingStatus = true);
    try {
      await _apiService.updateLaporanStatus(id, newStatus);
      if (!mounted) return;
      setState(() => _selectedStatus = newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diubah menjadi: $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal mengubah status: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _cetakLaporanKePdf(Laporan laporan) async {
    setState(() => _isPrintingPdf = true);
    try {
      final pdfData = await PdfGenerator.generateLaporanPdf(laporan);
      if (!mounted) return;
      await Printing.layoutPdf(onLayout: (PdfPageFormat fmt) async => pdfData);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPrintingPdf = false);
    }
  }

  // 🔹 Format tanggal menjadi bentuk "27 Okt 2025, 14:25"
  String _formatTanggalWaktu(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final dateTime =
          DateTime.parse(isoString).toUtc().add(const Duration(hours: 8));
      const bulan = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      final namaBulan = bulan[dateTime.month - 1];
      final jam = dateTime.hour.toString().padLeft(2, '0');
      final menit = dateTime.minute.toString().padLeft(2, '0');
      return '${dateTime.day} $namaBulan ${dateTime.year}, $jam:$menit WITA';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isUpdatingStatus || _isPrintingPdf;
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Detail LK-${widget.laporanId.toString().padLeft(4, '0')}',
          style:
              const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        actions: [
          FutureBuilder<Laporan>(
            future: _laporanFuture,
            builder: (context, snap) {
              if (snap.hasData) {
                return IconButton(
                  icon: const Icon(Icons.print_outlined, color: primaryColor),
                  tooltip: 'Cetak Laporan',
                  onPressed:
                      isLoading ? null : () => _cetakLaporanKePdf(snap.data!),
                );
              }
              return const SizedBox.shrink();
            },
          )
        ],
      ),
      body: FutureBuilder<Laporan>(
        future: _laporanFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: primaryColor));
          }
          if (snap.hasError) {
            return Center(child: Text('Gagal memuat data: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: Text('Tidak ada data.'));
          }

          final laporan = snap.data!;

          // Cetak debug ke console untuk memastikan nilai ada
          debugPrint('[DETAIL] '
              'jenisMuatan=${laporan.jenisMuatan}, '
              'jumlahMuatan=${laporan.jumlahMuatan}, '
              'jumlahPenumpang=${laporan.jumlahPenumpang}, '
              'namaPandu=${laporan.namaPandu}, '
              'nomorRegisterPandu=${laporan.noRegisterPandu}');

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (widget.isAdmin) _buildAdminActionsCard(laporan),

                    // === 🕒 Status & Waktu Laporan ===
                    _buildDetailCard('Status Laporan', [
                      _buildDetailRow(
                          'Status', laporan.statusLaporan?.toUpperCase()),

                      // tampil selalu, gunakan "-" kalau kosong
                      _buildDetailRow(
                        'Dikirim pada',
                        (laporan.dikirimPada == null ||
                                laporan.dikirimPada!.isEmpty)
                            ? '-'
                            : _formatTanggalWaktu(laporan.dikirimPada),
                      ),
                      _buildDetailRow(
                        'Diverifikasi pada',
                        (laporan.diverifikasiPada == null ||
                                laporan.diverifikasiPada!.isEmpty)
                            ? '-'
                            : _formatTanggalWaktu(laporan.diverifikasiPada),
                      ),
                      _buildDetailRow(
                        'Laporan selesai diproses pada',
                        (laporan.selesaiPada == null ||
                                laporan.selesaiPada!.isEmpty)
                            ? '-'
                            : _formatTanggalWaktu(laporan.selesaiPada),
                      ),
                    ]),

                    // === Informasi Umum + Kapal ===
                    _buildDetailCard('Informasi Kapal', [
                      _buildDetailRow('Jenis Kapal', laporan.jenisKapal),
                      _buildDetailRow('Nama Kapal', laporan.namaKapal),
                      _buildDetailRow(
                          'Nama Kapal ke-2', laporan.namaKapalKedua),
                      _buildDetailRow('Bendera Kapal', laporan.benderaKapal),
                      _buildDetailRow(
                          'Gross Tonnage (GT)', laporan.grtKapal?.toString()),
                      _buildDetailRow('IMO Number', laporan.imoNumber),
                    ]),

                    // === Rute Perjalanan ===
                    // === Rute Perjalanan ===
                    _buildDetailCard('Rute Perjalanan', [
                      _buildDetailRow('Pelabuhan Asal', laporan.pelabuhanAsal),
                      _buildDetailRow('Waktu Berangkat',
                          _formatTanggalWaktu(laporan.waktuBerangkat)),
                      _buildDetailRow(
                          'Pelabuhan Tujuan', laporan.pelabuhanTujuan),
                      _buildDetailRow('Estimasi Tiba',
                          _formatTanggalWaktu(laporan.estimasiTiba)),
                    ]),

                    // === Pemilik & Agen ===
                    _buildDetailCard('Pemilik & Agen', [
                      _buildDetailRow('Pemilik Kapal', laporan.pemilikKapal),
                      _buildDetailRow('Kontak Pemilik', laporan.kontakPemilik),
                      _buildDetailRow('Agen Lokal', laporan.agenLokal),
                      _buildDetailRow('Kontak Agen', laporan.kontakAgen),
                      _buildDetailRow('Nama Pandu', laporan.namaPandu),
                      _buildDetailRow(
                          'Nomor Register Pandu', laporan.noRegisterPandu),
                    ]),

                    // === Muatan & Penumpang ===
                    _buildDetailCard('Muatan & Penumpang', [
                      _buildDetailRow('Jenis Muatan', laporan.jenisMuatan),
                      _buildDetailRow(
                          'Jumlah Muatan', laporan.jumlahMuatan?.toString()),
                      _buildDetailRow('Jumlah Penumpang',
                          laporan.jumlahPenumpang?.toString()),
                    ]),

                    // === Lokasi Kejadian ===
                    // === Lokasi Kejadian ===
                    _buildDetailCard('Lokasi Kejadian', [
                      _buildDetailRow('Posisi Lintang', laporan.posisiLintang),
                      _buildDetailRow('Posisi Bujur', laporan.posisiBujur),
                      _buildDetailRow('Tanggal Laporan',
                          _formatTanggalWaktu(laporan.tanggalLaporan)),
                    ]),

                    // === 🔹 Jenis Kecelakaan ===
                    if (laporan.jenisKecelakaan != null &&
                        laporan.jenisKecelakaan!.isNotEmpty)
                      _buildDetailCard('Detail Kecelakaan', [
                        _buildDetailRow(
                            'Jenis Kecelakaan', laporan.jenisKecelakaan),
                        _buildDetailRow(
                          'Pihak Terkait',
                          (laporan.pihakTerkait == null ||
                                  laporan.pihakTerkait!.isEmpty)
                              ? '-'
                              : laporan.pihakTerkait,
                        ),
                      ]),

                    // === Uraian ===
                    _buildDetailCard('Uraian Kejadian', [
                      _buildDetailRow(
                          'Kronologi / Deskripsi', laporan.isiLaporan,
                          isMultiline: true),
                    ]),

                    // === Informasi Pelapor ===
                    _buildDetailCard('Informasi Pelapor', [
                      _buildDetailRow(
                          'Nama', laporan.user?.nama ?? laporan.namaPelapor),
                      _buildDetailRow('Jabatan',
                          laporan.user?.jabatan ?? laporan.jabatanPelapor),
                      _buildDetailRow('Telepon',
                          laporan.user?.phoneNumber ?? laporan.teleponPelapor),
                    ]),

                    // === Lampiran ===
                    _buildLampiranCard(laporan),
                  ],
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text('Memproses...',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ---- Komponen pembantu ----
  Widget _buildAdminActionsCard(Laporan laporan) {
    return Card(
      color: primaryColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'Tindakan Admin',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Divider(height: 20, color: Colors.white54),
          const Text('Ubah Status Laporan',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          AbsorbPointer(
            absorbing: _isUpdatingStatus,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(canvasColor: const Color(0xFF004a80)),
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  underline: const SizedBox(),
                  iconEnabledColor: Colors.white,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  items: _statusOptions
                      .map((s) => DropdownMenuItem(
                          value: s.toLowerCase(), child: Text(s)))
                      .toList(),
                  onChanged: (newVal) {
                    if (newVal != null && newVal != _selectedStatus) {
                      _handleStatusUpdate(newVal, laporan.id);
                    }
                  },
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 0.5)),
            const Divider(height: 24, color: Colors.black12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String? value,
      {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value == null || value.isEmpty ? '-' : value,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: isMultiline ? 1.5 : 1.2,
            ),
          ),
        ],
      ),
    );
  }

// Helper untuk cek apakah file adalah video
  bool _isVideo(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.3gp'];
    final lowerUrl = url.toLowerCase();
    return videoExtensions.any((ext) => lowerUrl.contains(ext));
  }

  Widget _buildLampiranCard(Laporan laporan) {
    return _buildDetailCard('Lampiran', [
      if (laporan.lampiran.isEmpty)
        const Text('Tidak ada lampiran.',
            style: TextStyle(color: Colors.black54))
      else
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: laporan.lampiran.length,
          itemBuilder: (context, index) {
            final l = laporan.lampiran[index];
            final isVideo = _isVideo(l.url);

            return InkWell(
              onTap: () {
                if (isVideo) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPreviewPage(
                        videoUrl: l.url,
                        title: 'Video ${index + 1}',
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImagePreviewPage(
                        imageUrl: l.url,
                        title: 'Lampiran ${index + 1}',
                      ),
                    ),
                  );
                }
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isVideo
                        ? Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.videocam,
                              color: Colors.white54,
                              size: 32,
                            ),
                          )
                        : Image.network(
                            l.url,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, progress) =>
                                progress == null
                                    ? child
                                    : const Center(
                                        child: CircularProgressIndicator()),
                            errorBuilder: (ctx, err, st) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isVideo ? Icons.play_arrow : Icons.zoom_in,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
    ]);
  }
}
