import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/admin_provider.dart';
import 'user_detail_page.dart';

class PelaporListPage extends StatefulWidget {
  const PelaporListPage({super.key});

  @override
  State<PelaporListPage> createState() => _PelaporListPageState();
}

class _PelaporListPageState extends State<PelaporListPage> {
  static const Color primaryColor = Color(0xFF005A9C);
  static const Color pageBackgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF1A1A1A);

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchReporters();
    });

    _searchController.addListener(() {
      final keyword = _searchController.text.trim();
      final provider = Provider.of<AdminProvider>(context, listen: false);
      if (keyword.isEmpty) {
        // jika kosong, muat ulang semua reporter
        provider.fetchReporters();
      } else {
        provider.searchReporters(keyword);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Kelola Pelapor',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<AdminProvider>(context, listen: false)
                              .fetchReporters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // Daftar pelapor
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, _) {
                if (adminProvider.isReportersLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }
                if (adminProvider.errorMessage != null &&
                    adminProvider.reporters.isEmpty) {
                  return Center(
                    child: Text(
                      adminProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (adminProvider.reporters.isEmpty) {
                  return const Center(
                    child: Text(
                      'Pelapor tidak ditemukan.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => adminProvider.fetchReporters(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: adminProvider.reporters.length,
                    itemBuilder: (context, index) {
                      final pelapor = adminProvider.reporters[index];
                      return _buildPelaporCard(context, pelapor);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPelaporCard(BuildContext context, User pelapor) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserDetailPage(userId: pelapor.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Text(
                  pelapor.nama.isNotEmpty
                      ? pelapor.nama[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pelapor.nama,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pelapor.jabatan ?? 'Jabatan tidak diketahui',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      backgroundColor: Colors.grey[200],
                      avatar: const Icon(Icons.article_outlined,
                          size: 16, color: Colors.black87),
                      label: Text(
                        '${pelapor.laporanKejadianCount} Laporan',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 28),
            ],
          ),
        ),
      ),
    );
  }
}