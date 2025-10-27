import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/laporan.dart';
import '../providers/admin_provider.dart';
import 'detail_laporan_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // Palet Warna
  static const Color primaryColor = Color(0xFF005A9C);
  static const Color pageBackgroundColor = Color(0xFFF5F5F5);

  // Filter status laporan di UI
  String _activeFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false)
          .fetchDashboardData(status: null); // awal: semua laporan
    });
  }

  // Warna indikator status laporan
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 1,
        automaticallyImplyLeading: false,
        centerTitle: false,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          final laporanList = adminProvider.laporanList;
          final isLoading = adminProvider.isDashboardLoading;
          final error = adminProvider.errorMessage;

          return RefreshIndicator(
            onRefresh: () => adminProvider.fetchDashboardData(
              status: _activeFilter == 'Semua'
                  ? null
                  : _activeFilter.toLowerCase(),
              refresh: true,
            ),
            child: Column(
              children: [
                _buildSummarySection(adminProvider),
                _buildFilterSection(adminProvider),
                if (isLoading)
                  const Expanded(
                    child: Center(
                      child:
                          CircularProgressIndicator(color: primaryColor),
                    ),
                  )
                else if (error != null)
                  Expanded(
                    child: Center(
                      child: Text(
                        error,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (laporanList.isEmpty)
                  const Expanded(
                    child: Center(
                      child:
                          Text('Tidak ada laporan dengan filter ini.'),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      itemCount: laporanList.length,
                      itemBuilder: (context, index) {
                        final laporan = laporanList[index];
                        return _buildLaporanCard(context, laporan);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ======================= Ringkasan Dashboard =======================
  Widget _buildSummarySection(AdminProvider adminProvider) {
    final totalReports = adminProvider.laporanList.length;
    final newReports = adminProvider.newReportsCount;
    final verifiedReports = adminProvider.laporanList
        .where((l) => l.statusLaporan?.toLowerCase() == 'diverifikasi')
        .length;

    return Container(
      padding: const EdgeInsets.all(12.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Laporan Baru',
              newReports.toString(),
              const Color(0xFF3E8AFF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Perlu Verifikasi',
              verifiedReports.toString(),
              const Color(0xFFFFB946),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Total Laporan',
              totalReports.toString(),
              Colors.grey,
            ),
          ),
        ],
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

  // ======================= Filter Chips =======================
  Widget _buildFilterSection(AdminProvider adminProvider) {
    final filters = ['Semua', 'Dikirim', 'Diverifikasi', 'Selesai'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: filters.map((status) {
            bool isSelected = _activeFilter == status;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _activeFilter = status);
                    final filter =
                        status == 'Semua' ? null : status.toLowerCase();
                    adminProvider.fetchDashboardData(status: filter);
                  }
                },
                selectedColor: primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.white,
                shape: StadiumBorder(
                  side: BorderSide(color: primaryColor),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ======================= Card Daftar Laporan =======================
  Widget _buildLaporanCard(BuildContext context, Laporan laporan) {
    final statusColor = _getStatusColor(laporan.statusLaporan);
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetailLaporanPage(
                laporanId: laporan.id,
                isAdmin: true,
              ),
            ),
          );

          if (result == true && mounted) {
            Provider.of<AdminProvider>(context, listen: false)
                .fetchDashboardData(
              status: _activeFilter == 'Semua'
                  ? null
                  : _activeFilter.toLowerCase(),
              refresh: true,
            );
          }
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
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                        Icon(Icons.person,
                            size: 14, color: Colors.grey[700]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            laporan.user?.nama ?? 'Pelapor Anonim',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[700]),
                        const SizedBox(width: 6),
                        Text(
                          laporan.tanggalLaporan ?? '-',
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
    );
  }
}