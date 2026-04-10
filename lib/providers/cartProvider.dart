import 'package:flutter/material.dart';

class CartItem {
  final int    id;
  final String nama;
  final int    harga;
  final String? image;
  final String? kategori;
  final int    stokMax;
  int          qty;

  CartItem({
    required this.id,
    required this.nama,
    required this.harga,
    this.image,
    this.kategori,
    required this.stokMax,
    this.qty = 1,
  });

  Map<String, dynamic> toPesan() => {'barang_id': id, 'qty': qty};

  int get subtotal => harga * qty;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (s, i) => s + i.qty);

  int get totalHarga => _items.fold(0, (s, i) => s + i.subtotal);

  bool isInCart(int id) => _items.any((i) => i.id == id);

  int qtyOf(int id) {
    final idx = _items.indexWhere((i) => i.id == id);
    return idx == -1 ? 0 : _items[idx].qty;
  }

  void addItem(CartItem item) {
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      if (_items[idx].qty < _items[idx].stokMax) {
        _items[idx].qty++;
      }
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(int id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void increaseQty(int id) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1 && _items[idx].qty < _items[idx].stokMax) {
      _items[idx].qty++;
      notifyListeners();
    }
  }

  void decreaseQty(int id) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      if (_items[idx].qty <= 1) {
        _items.removeAt(idx);
      } else {
        _items[idx].qty--;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> toPesanList() =>
      _items.map((i) => i.toPesan()).toList();
}