import 'package:mobileapp2/services/url.dart' as url;

class TokoModel {
  int? id;
  String? nama_barang;
  String? deskripsi;
  int? stok;
  int? harga;
  String? image;
  String? kategori; 
  double? rating;
  int? terjual;
  
  TokoModel({
    this.id,
    this.nama_barang,
    this.deskripsi,
    this.stok,
    this.harga,
    this.image,
    this.kategori,
    this.rating,
    this.terjual,
  });
  
  TokoModel.fromJson(Map<String, dynamic> parsedJson){
    id = _parseInt(parsedJson['id']);
    nama_barang = parsedJson['nama_barang'];
    deskripsi = parsedJson['deskripsi'];
    stok = _parseInt(parsedJson['stok']);
    harga = _parseInt(parsedJson['harga']);
    image = parsedJson['image'];
    kategori = parsedJson['kategori'];
    rating = _parseDouble(parsedJson['rating']);
    terjual = _parseInt(parsedJson['terjual']);
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  operator [](String other) {}
}