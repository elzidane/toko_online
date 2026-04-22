import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
  Database? _database;

  CartProvider() {
    init();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cart.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cart_items(
        id INTEGER PRIMARY KEY,
        nama TEXT,
        harga INTEGER,
        image TEXT,
        kategori TEXT,
        stokMax INTEGER,
        qty INTEGER
      )
    ''');
  }

  Future<void> loadCart() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart_items');
    _items.clear();
    for (var map in maps) {
      _items.add(CartItem(
        id: map['id'],
        nama: map['nama'],
        harga: map['harga'],
        image: map['image'],
        kategori: map['kategori'],
        stokMax: map['stokMax'],
        qty: map['qty'],
      ));
    }
    notifyListeners();
  }

  Future<void> _saveCart() async {
    final db = await database;
    await db.delete('cart_items');
    for (var item in _items) {
      await db.insert('cart_items', {
        'id': item.id,
        'nama': item.nama,
        'harga': item.harga,
        'image': item.image,
        'kategori': item.kategori,
        'stokMax': item.stokMax,
        'qty': item.qty,
      });
    }
  }

  Future<void> init() async {
    await loadCart();
  }

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
    _saveCart();
  }

  void removeItem(int id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
    _saveCart();
  }

  void increaseQty(int id) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1 && _items[idx].qty < _items[idx].stokMax) {
      _items[idx].qty++;
      notifyListeners();
      _saveCart();
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
      _saveCart();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _saveCart();
  }

  List<Map<String, dynamic>> toPesanList() =>
      _items.map((i) => i.toPesan()).toList();
}