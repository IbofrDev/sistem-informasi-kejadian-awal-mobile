import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/laporan.dart';

class PdfGenerator {
  static Future<Uint8List> generateLaporanPdf(Laporan laporan) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // HEADER
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'LAPORAN KECELAKAAN KAPAL',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Sistem Informasi Kecelakaan Kapal - KSOP Kelas I Banjarmasin',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 15),

            // =========================
            // TABEL IDENTITAS (2 kolom)
            // =========================
            pw.Table(
              border: pw.TableBorder.all(width: 1, color: PdfColors.black),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  children: [
                    _buildSectionPelapor(laporan),
                    _buildSectionKapal(laporan),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 10),

            // =========================
            // DETAIL KEJADIAN (FULL WIDTH)
            // =========================
            pw.Container(
              width: double.infinity,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1, color: PdfColors.black),
              ),
              padding: const pw.EdgeInsets.all(8),
              child: _buildSectionDetailKejadian(laporan),
            ),

            pw.SizedBox(height: 10),

            // =========================
            // ISI LAPORAN (FULL WIDTH)
            // =========================
            pw.Container(
              width: double.infinity,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1, color: PdfColors.black),
              ),
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Isi Laporan',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    laporan.isiLaporan ?? '-',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // === SUB-BUILDER ===

  static pw.Widget _buildSectionPelapor(Laporan laporan) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Identitas Pelapor',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          _buildInnerRow('Nama', laporan.user?.nama ?? '-'),
          _buildInnerRow('Telepon', laporan.user?.phoneNumber ?? '-'),
          _buildInnerRow('Jabatan', laporan.user?.jabatan ?? '-'),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionKapal(Laporan laporan) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Identitas Kapal',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          _buildInnerRow('Nama Kapal', laporan.namaKapal ?? '-'),
          _buildInnerRow('Jenis Kapal', laporan.jenisKapal ?? '-'),
          _buildInnerRow(
              'Bendera', laporan.benderaKapal ?? '-'), // ✅ diperbaiki
          _buildInnerRow(
              'GRT', laporan.grtKapal?.toString() ?? '-'), // ✅ diperbaiki
        ],
      ),
    );
  }

  static pw.Widget _buildSectionDetailKejadian(Laporan laporan) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Detail Kejadian',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        _buildInnerRow(
            'Posisi Lintang', laporan.posisiLintang ?? '-'), // ✅ diperbaiki
        _buildInnerRow(
            'Posisi Bujur', laporan.posisiBujur ?? '-'), // ✅ diperbaiki
        _buildInnerRow('Tanggal Kejadian', laporan.tanggalLaporan ?? '-'),
      ],
    );
  }

  // Helper Row
  static pw.Widget _buildInnerRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 100, child: pw.Text(label)),
          pw.Text(': '),
          pw.Flexible(child: pw.Text(value)),
        ],
      ),
    );
  }
}
