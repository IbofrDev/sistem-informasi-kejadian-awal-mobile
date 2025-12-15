import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/laporan.dart';
import '../providers/auth_provider.dart';
import '../providers/laporan_provider.dart';
import 'views/laporan/create/create_report_page.dart';
import '../detail_laporan_page.dart'; // ✅ Jalur impor disesuaikan
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Palet warna aplikasi
  static const Color primaryColor = Color(0xFF005A9C);
  static const Color pageBackgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LaporanProvider>(context, listen: false)
          .fetchLaporanHistory();
    });
  }

  // Memberi warna sesuai status laporan
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'diverifikasi':
        return const Color(0xFFFFB946);
      case 'dikirim':
        return const Color(0xFF3E8AFF);
      default:
        return Colors.grey;
    }
  }

  // Kode BARU - Tambahkan setelah fungsi _getStatusColor
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
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      body: SafeArea(
        child: Consumer<LaporanProvider>(
          builder: (context, laporanProvider, child) {
            if (laporanProvider.errorMessage != null &&
                laporanProvider.laporanList.isEmpty &&
                !laporanProvider.isLoading) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    laporanProvider.errorMessage ?? 'Terjadi kesalahan.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => laporanProvider.fetchLaporanHistory(),
              child: CustomScrollView(
                slivers: [
                  _buildHeader(),
                  _buildSummarySection(laporanProvider.laporanList),
                  if (laporanProvider.isLoading &&
                      laporanProvider.laporanList.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    )
                  else if (laporanProvider.laporanList.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(),
                    )
                  else
                    _buildLaporanList(laporanProvider.laporanList),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateReportPage()),
          );
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Buat Laporan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ================= HEADER SECTION =================
  SliverAppBar _buildHeader() {
    return SliverAppBar(
      backgroundColor: pageBackgroundColor,
      pinned: true,
      elevation: 0,
      expandedHeight: 120.0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16.0),
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final userName = authProvider.user?.nama ?? 'Pelapor';
            return Text(
              'Selamat Datang,\n$userName',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        centerTitle: false,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: primaryColor),
          tooltip: 'Profil Saya',
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: primaryColor),
          tooltip: 'Keluar',
          onPressed: () async {
            await context.read<AuthProvider>().logout();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }

  // ================= SUMMARY SECTION =================
  SliverToBoxAdapter _buildSummarySection(List<Laporan> laporanList) {
    final dikirimCount =
        laporanList.where((l) => l.statusLaporan == 'dikirim').length;
    final diverifikasiCount =
        laporanList.where((l) => l.statusLaporan == 'diverifikasi').length;
    final selesaiCount =
        laporanList.where((l) => l.statusLaporan == 'selesai').length;

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Dikirim',
                dikirimCount.toString(),
                const Color(0xFF3E8AFF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Diverifikasi',
                diverifikasiCount.toString(),
                const Color(0xFFFFB946),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Selesai',
                selesaiCount.toString(),
                Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ================= EMPTY STATE =================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Riwayat Laporan Kosong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol di bawah untuk membuat\nlaporan kejadian pertama Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ================= LIST RIWAYAT LAPORAN =================
  SliverList _buildLaporanList(List<Laporan> laporanList) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final laporan = laporanList[index];
          final statusColor = _getStatusColor(laporan.statusLaporan);

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Card(
              color: Colors.white,
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DetailLaporanPage(laporanId: laporan.id),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 110,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID: LK-${laporan.id.toString().padLeft(4, '0')}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              laporan.namaKapal ?? 'Nama Kapal Tidak Tersedia',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 14, color: Colors.grey[700]),
                                const SizedBox(width: 6),
                                Text(
                                  _formatTanggalWaktu(laporan.tanggalLaporan),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: laporanList.length,
      ),
    );
  }
}
