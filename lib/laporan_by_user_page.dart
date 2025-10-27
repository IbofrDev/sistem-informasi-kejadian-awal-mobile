import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/laporan.dart';
import '../providers/admin_provider.dart';
import 'detail_laporan_page.dart';

class LaporanByUserPage extends StatefulWidget {
  final int userId;
  final String userName;

  const LaporanByUserPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<LaporanByUserPage> createState() => _LaporanByUserPageState();
}

class _LaporanByUserPageState extends State<LaporanByUserPage> {
  static const Color primaryColor = Color(0xFF005A9C);
  static const Color pageBackgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false)
          .fetchLaporanByUser(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Laporan oleh ${widget.userName}',
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: primaryColor,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLaporanByUserLoading) {
            return const Center(
                child: CircularProgressIndicator(color: primaryColor));
          }

          if (adminProvider.errorMessage != null &&
              adminProvider.laporanByUser.isEmpty) {
            return Center(
              child: Text(
                adminProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (adminProvider.laporanByUser.isEmpty) {
            return const Center(
              child: Text(
                'Pengguna ini belum memiliki laporan.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            );
          }

          final laporanList = adminProvider.laporanByUser;

          return RefreshIndicator(
            onRefresh: () async {
              await adminProvider.fetchLaporanByUser(widget.userId);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: laporanList.length,
              itemBuilder: (context, index) {
                final laporan = laporanList[index];
                return _buildLaporanCard(context, laporan);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLaporanCard(BuildContext context, Laporan laporan) {
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

    final statusColor = _getStatusColor(laporan.statusLaporan);

    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => DetailLaporanPage(
              laporanId: laporan.id,
              isAdmin: true,
            ),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Kapal
              Text(
                laporan.namaKapal ?? 'Nama Kapal Tidak Tersedia',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              // Tanggal
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    laporan.tanggalLaporan ?? '-',
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Status
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    laporan.statusLaporan?.toUpperCase() ?? 'N/A',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}