import 'package:flutter/material.dart';
import 'package:mobileapp2/models/response_data_list.dart';
import 'package:mobileapp2/models/toko_model.dart';
import 'package:mobileapp2/services/tokoService.dart';

class TokoProvider extends ChangeNotifier {
  final TokoService _tokoService = TokoService();
  
  List<TokoModel> _tokoList = [];
  List<TokoModel> get tokoList => _tokoList;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Fetch data
  Future<void> fetchTokoData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      ResponseDataList response = await _tokoService.getToko();
      
      if (response.status == true) {
        // Cast dengan aman
        if (response.data is List<TokoModel>) {
          _tokoList = response.data as List<TokoModel>;
        } else if (response.data is List) {
          _tokoList = (response.data as List)
              .where((item) => item is TokoModel)
              .cast<TokoModel>()
              .toList();
        } else {
          _tokoList = [];
        }
        
        print("Successfully loaded ${_tokoList.length} items");
      } else {
        _errorMessage = response.message ?? 'Gagal memuat data';
        print("Error from service: $_errorMessage");
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      print("Exception in fetchTokoData: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Simple methods untuk sekarang
  Future<void> addProduct(TokoModel product) async {
    _tokoList.add(product);
    notifyListeners();
  }
  
  Future<void> updateProduct(TokoModel product) async {
    final index = _tokoList.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _tokoList[index] = product;
      notifyListeners();
    }
  }
  
  Future<void> deleteProduct(int id) async {
    _tokoList.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}