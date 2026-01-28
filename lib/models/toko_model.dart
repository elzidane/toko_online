import 'package:mobileapp2/services/url.dart' as url;

class TokoModel {
  int? id;
  String? nama_barang;
  String? deskripsi;
  int? stok;
  int? harga;
  String? image;
  String? kategori; // Tambahkan field kategori
  double? rating; // Tambahkan field rating
  int? terjual; // Tambahkan field terjual
  
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
    id = parsedJson['id'];
    nama_barang = parsedJson['nama_barang'];
    deskripsi = parsedJson['deskripsi'];
    stok = parsedJson['stok'];
    harga = parsedJson['harga'];
    image = parsedJson['image'];
    kategori = parsedJson['kategori'];
    rating = parsedJson['rating'];
    terjual = parsedJson['terjual'];
  }
}