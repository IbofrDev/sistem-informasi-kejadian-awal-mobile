class Lampiran {
  final int id;
  final String tipeFile;
  final String pathFile;
  final String url; // URL lengkap untuk menampilkan gambar

  Lampiran({
    required this.id,
    required this.tipeFile,
    required this.pathFile,
    required this.url,
  });

  factory Lampiran.fromJson(Map<String, dynamic> json, String baseUrl) {
    // Hapus '/api' dari baseUrl supaya URL storage bisa diakses
    final String cleanBaseUrl = baseUrl.replaceAll('/api', '');
    final String fullUrl = '$cleanBaseUrl/storage/${json['path_file']}';
    
    return Lampiran(
      id: json['id'],
      tipeFile: json['tipe_file'],
      pathFile: json['path_file'],
      url: fullUrl,
    );
  }
}
