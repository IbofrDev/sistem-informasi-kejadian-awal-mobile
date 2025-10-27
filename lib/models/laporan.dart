import 'lampiran.dart';
import 'user.dart';

class Laporan {
  final int id;

  // ========== Data Kapal ==========
  final String? namaKapal;
  final String? jenisKapal;
  final String? namaKapalKedua;
  final String? benderaKapal;
  final int? grtKapal;
  final String? imoNumber;

  // ========== Perjalanan ==========
  final String? pelabuhanAsal;
  final String? waktuBerangkat;
  final String? pelabuhanTujuan;
  final String? estimasiTiba;

  // ========== Pemilik & Agen ==========
  final String? pemilikKapal;
  final String? kontakPemilik;
  final String? agenLokal;
  final String? kontakAgen;
  final String? namaPandu;
  final String? noRegisterPandu;

  // ========== Muatan ==========
  final String? jenisMuatan;
  final String? jumlahMuatan;
  final String? jumlahPenumpang;

  // ========== Lokasi & Waktu ==========
  final String? posisiLintang;
  final String? posisiBujur;
  final String? tanggalLaporan;

  // ========== Laporan & Status ==========
  final String? statusLaporan;
  final String? isiLaporan;

  // 🕒 Tambahan: Waktu status laporan
  final String? dikirimPada;
  final String? diverifikasiPada;
  final String? selesaiPada;

  // ========== Jenis Kecelakaan ==========
  final String? jenisKecelakaan;
  final String? pihakTerkait;

  // ========== Data Pelapor ==========
  final String? namaPelapor;
  final String? jabatanPelapor;
  final String? teleponPelapor;

  // ========== Relasi ==========
  final List<Lampiran> lampiran;
  final User? user;

  Laporan({
    required this.id,
    this.namaKapal,
    this.jenisKapal,
    this.namaKapalKedua,
    this.benderaKapal,
    this.grtKapal,
    this.imoNumber,
    this.pelabuhanAsal,
    this.waktuBerangkat,
    this.pelabuhanTujuan,
    this.estimasiTiba,
    this.pemilikKapal,
    this.kontakPemilik,
    this.agenLokal,
    this.kontakAgen,
    this.namaPandu,
    this.noRegisterPandu,
    this.jenisMuatan,
    this.jumlahMuatan,
    this.jumlahPenumpang,
    this.posisiLintang,
    this.posisiBujur,
    this.tanggalLaporan,
    this.statusLaporan,
    this.isiLaporan,
    this.dikirimPada,
    this.diverifikasiPada,
    this.selesaiPada,
    this.jenisKecelakaan,
    this.pihakTerkait,
    this.namaPelapor,
    this.jabatanPelapor,
    this.teleponPelapor,
    this.lampiran = const [],
    this.user,
  });

  // ========================== FROM JSON ==========================
  factory Laporan.fromJson(Map<String, dynamic> json, {String? baseUrl}) {
    var lampiranList = <Lampiran>[];
    if (json['lampiran'] != null && baseUrl != null) {
      lampiranList = (json['lampiran'] as List)
          .map((item) => Lampiran.fromJson(item, baseUrl))
          .toList();
    }

    return Laporan(
      id: json['id'] ?? 0,

      // Kapal
      namaKapal: json['nama_kapal'],
      jenisKapal: json['jenis_kapal'],
      namaKapalKedua: json['nama_kapal_kedua'],
      benderaKapal: json['bendera_kapal'],
      grtKapal: int.tryParse(json['grt_kapal']?.toString() ?? ''),
      imoNumber: json['imo_number'],

      // Perjalanan
      pelabuhanAsal: json['pelabuhan_asal'],
      waktuBerangkat: json['waktu_berangkat'],
      pelabuhanTujuan: json['pelabuhan_tujuan'],
      estimasiTiba: json['estimasi_tiba'],

      // Pemilik & Agen
      pemilikKapal: json['pemilik_kapal'],
      kontakPemilik: json['kontak_pemilik'],
      agenLokal: json['agen_lokal'],
      kontakAgen: json['kontak_agen'],
      namaPandu: json['nama_pandu'],
      noRegisterPandu: json['nomor_register_pandu'],

      // Muatan
      jenisMuatan: json['jenis_muatan'],
      jumlahMuatan: json['jumlah_muatan']?.toString(),
      jumlahPenumpang: json['jumlah_penumpang']?.toString(),

      // Lokasi & Waktu
      posisiLintang: json['posisi_lintang'],
      posisiBujur: json['posisi_bujur'],
      tanggalLaporan: json['tanggal_laporan'],

      // Status & Laporan
      statusLaporan: json['status_laporan'],
      isiLaporan: json['isi_laporan'],

      // 🕒 Tambahan waktu status
      dikirimPada: json['sent_at'],
      diverifikasiPada: json['verified_at'],
      selesaiPada: json['completed_at'],

      // Kecelakaan
      jenisKecelakaan: json['jenis_kecelakaan'],
      pihakTerkait: json['pihak_terkait'],

      // Pelapor
      namaPelapor: json['nama_pelapor'],
      jabatanPelapor: json['jabatan_pelapor'],
      teleponPelapor: json['telepon_pelapor'],

      lampiran: lampiranList,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  // ========================== TO MAP (untuk draft) ==========================
  Map<String, String> toMap() {
    return {
      'id': id.toString(),
      'nama_kapal': namaKapal ?? '',
      'jenis_kapal': jenisKapal ?? '',
      'nama_kapal_kedua': namaKapalKedua ?? '',
      'bendera_kapal': benderaKapal ?? '',
      'grt_kapal': grtKapal?.toString() ?? '',
      'imo_number': imoNumber ?? '',
      'pelabuhan_asal': pelabuhanAsal ?? '',
      'waktu_berangkat': waktuBerangkat ?? '',
      'pelabuhan_tujuan': pelabuhanTujuan ?? '',
      'estimasi_tiba': estimasiTiba ?? '',
      'pemilik_kapal': pemilikKapal ?? '',
      'kontak_pemilik': kontakPemilik ?? '',
      'agen_lokal': agenLokal ?? '',
      'kontak_agen': kontakAgen ?? '',
      'nama_pandu': namaPandu ?? '',
      'nomor_register_pandu': noRegisterPandu ?? '',
      'jenis_muatan': jenisMuatan ?? '',
      'jumlah_muatan': jumlahMuatan ?? '',
      'jumlah_penumpang': jumlahPenumpang ?? '',
      'posisi_lintang': posisiLintang ?? '',
      'posisi_bujur': posisiBujur ?? '',
      'tanggal_laporan': tanggalLaporan ?? '',
      'status_laporan': statusLaporan ?? '',
      'isi_laporan': isiLaporan ?? '',
      'jenis_kecelakaan': jenisKecelakaan ?? '',
      'pihak_terkait': pihakTerkait ?? '',
      'nama_pelapor': namaPelapor ?? '',
      'jabatan_pelapor': jabatanPelapor ?? '',
      'telepon_pelapor': teleponPelapor ?? '',
      'user_id': user?.id.toString() ?? '',
    };
  }

  // ========================== FROM MAP (untuk load draft) ==========================
  factory Laporan.fromMap(Map<String, String> map) {
    return Laporan(
      id: int.tryParse(map['id'] ?? '0') ?? 0,
      namaKapal: map['nama_kapal'],
      jenisKapal: map['jenis_kapal'],
      namaKapalKedua: map['nama_kapal_kedua'],
      benderaKapal: map['bendera_kapal'],
      grtKapal: int.tryParse(map['grt_kapal'] ?? ''),
      imoNumber: map['imo_number'],
      pelabuhanAsal: map['pelabuhan_asal'],
      waktuBerangkat: map['waktu_berangkat'],
      pelabuhanTujuan: map['pelabuhan_tujuan'],
      estimasiTiba: map['estimasi_tiba'],
      pemilikKapal: map['pemilik_kapal'],
      kontakPemilik: map['kontak_pemilik'],
      agenLokal: map['agen_lokal'],
      kontakAgen: map['kontak_agen'],
      namaPandu: map['nama_pandu'],
      noRegisterPandu: map['nomor_register_pandu'],
      jenisMuatan: map['jenis_muatan'],
      jumlahMuatan: map['jumlah_muatan'],
      jumlahPenumpang: map['jumlah_penumpang'],
      posisiLintang: map['posisi_lintang'],
      posisiBujur: map['posisi_bujur'],
      tanggalLaporan: map['tanggal_laporan'],
      statusLaporan: map['status_laporan'],
      isiLaporan: map['isi_laporan'],
      jenisKecelakaan: map['jenis_kecelakaan'],
      pihakTerkait: map['pihak_terkait'],
      namaPelapor: map['nama_pelapor'],
      jabatanPelapor: map['jabatan_pelapor'],
      teleponPelapor: map['telepon_pelapor'],
    );
  }

  // ========================== COPY WITH ==========================
  Laporan copyWith({
    int? id,
    String? namaKapal,
    String? jenisKapal,
    String? namaKapalKedua,
    String? benderaKapal,
    int? grtKapal,
    String? imoNumber,
    String? pelabuhanAsal,
    String? waktuBerangkat,
    String? pelabuhanTujuan,
    String? estimasiTiba,
    String? pemilikKapal,
    String? kontakPemilik,
    String? agenLokal,
    String? kontakAgen,
    String? namaPandu,
    String? noRegisterPandu,
    String? jenisMuatan,
    String? jumlahMuatan,
    String? jumlahPenumpang,
    String? posisiLintang,
    String? posisiBujur,
    String? tanggalLaporan,
    String? statusLaporan,
    String? isiLaporan,
    String? dikirimPada,
    String? diverifikasiPada,
    String? selesaiPada,
    String? jenisKecelakaan,
    String? pihakTerkait,
    String? namaPelapor,
    String? jabatanPelapor,
    String? teleponPelapor,
    List<Lampiran>? lampiran,
    User? user,
  }) {
    return Laporan(
      id: id ?? this.id,
      namaKapal: namaKapal ?? this.namaKapal,
      jenisKapal: jenisKapal ?? this.jenisKapal,
      namaKapalKedua: namaKapalKedua ?? this.namaKapalKedua,
      benderaKapal: benderaKapal ?? this.benderaKapal,
      grtKapal: grtKapal ?? this.grtKapal,
      imoNumber: imoNumber ?? this.imoNumber,
      pelabuhanAsal: pelabuhanAsal ?? this.pelabuhanAsal,
      waktuBerangkat: waktuBerangkat ?? this.waktuBerangkat,
      pelabuhanTujuan: pelabuhanTujuan ?? this.pelabuhanTujuan,
      estimasiTiba: estimasiTiba ?? this.estimasiTiba,
      pemilikKapal: pemilikKapal ?? this.pemilikKapal,
      kontakPemilik: kontakPemilik ?? this.kontakPemilik,
      agenLokal: agenLokal ?? this.agenLokal,
      kontakAgen: kontakAgen ?? this.kontakAgen,
      namaPandu: namaPandu ?? this.namaPandu,
      noRegisterPandu: noRegisterPandu ?? this.noRegisterPandu,
      jenisMuatan: jenisMuatan ?? this.jenisMuatan,
      jumlahMuatan: jumlahMuatan ?? this.jumlahMuatan,
      jumlahPenumpang: jumlahPenumpang ?? this.jumlahPenumpang,
      posisiLintang: posisiLintang ?? this.posisiLintang,
      posisiBujur: posisiBujur ?? this.posisiBujur,
      tanggalLaporan: tanggalLaporan ?? this.tanggalLaporan,
      statusLaporan: statusLaporan ?? this.statusLaporan,
      isiLaporan: isiLaporan ?? this.isiLaporan,
      dikirimPada: dikirimPada ?? this.dikirimPada,
      diverifikasiPada: diverifikasiPada ?? this.diverifikasiPada,
      selesaiPada: selesaiPada ?? this.selesaiPada,
      jenisKecelakaan: jenisKecelakaan ?? this.jenisKecelakaan,
      pihakTerkait: pihakTerkait ?? this.pihakTerkait,
      namaPelapor: namaPelapor ?? this.namaPelapor,
      jabatanPelapor: jabatanPelapor ?? this.jabatanPelapor,
      teleponPelapor: teleponPelapor ?? this.teleponPelapor,
      lampiran: lampiran ?? this.lampiran,
      user: user ?? this.user,
    );
  }

  bool get hasLampiran => lampiran.isNotEmpty;
  bool get hasLocation =>
      (posisiLintang != null && posisiLintang!.isNotEmpty) &&
      (posisiBujur != null && posisiBujur!.isNotEmpty);
}