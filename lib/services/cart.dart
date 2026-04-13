class Cart {
  late final int? id_transaksi;
  late final String? nama_user;
  late final String? tgl_transaksi;
  late final List<CartDetail>? detail;

  Cart({this.id_transaksi, this.nama_user, this.tgl_transaksi, this.detail});

  factory Cart.fromMap(Map<String, dynamic> json) {
    return Cart(
      id_transaksi: json['id_transaksi'],
      nama_user: json['nama_user'],
      tgl_transaksi: json['tgl_transaksi'],
      detail: json['detail'] != null
          ? List<CartDetail>.from(
              json['detail'].map((x) => CartDetail.fromMap(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_transaksi': id_transaksi,
      'nama_user': nama_user,
      'tgl_transaksi': tgl_transaksi,
      'detail': detail != null
          ? List<dynamic>.from(detail!.map((x) => x.toMap()))
          : null,
    };
  }
}

class CartDetail {
  late final int? id_detail_transaksi;
  late final int? barang_id;
  late final String? nama_barang;
  late final int? quantity;
  late final int? harga_beli;

  CartDetail({
    this.id_detail_transaksi,
    this.barang_id,
    this.nama_barang,
    this.quantity,
    this.harga_beli,
  });

  factory CartDetail.fromMap(Map<String, dynamic> json) {
    return CartDetail(
      id_detail_transaksi: json['id_detail_transaksi'],
      barang_id: json['barang_id'],
      nama_barang: json['nama_barang'],
      quantity: json['quantity'],
      harga_beli: json['harga_beli'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_detail_transaksi': id_detail_transaksi,
      'barang_id': barang_id,
      'nama_barang': nama_barang,
      'quantity': quantity,
      'harga_beli': harga_beli,
    };
  }
}
