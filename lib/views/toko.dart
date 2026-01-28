import 'package:flutter/material.dart';
import 'package:mobileapp2/models/response_data_list.dart';
import 'package:mobileapp2/models/toko_model.dart'; // Pastikan import model
import 'package:mobileapp2/services/tokoService.dart';

class Toko extends StatefulWidget {
  const Toko({super.key});

  @override
  State<Toko> createState() => _TokoState();
}

class _TokoState extends State<Toko> {
  TokoService toko = TokoService();
  List<TokoModel>? barang; // Specify type untuk lebih aman
  bool isLoading = true;
  String? errorMessage;

  getToko() async {
    try {
      ResponseDataList getToko = await toko.getToko();
      if (getToko.status == true) {
        setState(() {
          barang = List<TokoModel>.from(getToko.data ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = getToko.message;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getToko();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Daftar barang'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }
    
    if (barang == null || barang!.isEmpty) {
      return Center(child: Text('Tidak ada data barang'));
    }
    
    return ListView.builder(
      itemCount: barang!.length,
      itemBuilder: (context, index) {
        final item = barang![index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            // Leading dengan gambar atau placeholder
            leading: _buildProductImage(item.image),
            title: Text(
              item.nama_barang ?? 'No Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.deskripsi ?? 'No Description'),
                SizedBox(height: 4),
                Text(
                  'Rp ${item.harga?.toString() ?? '0'}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Stok: ${item.stok?.toString() ?? '0'}'),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigasi ke detail jika diperlukan
            },
          ),
        );
      }
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    // Null check dan validasi URL
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.rectangle,
        ),
        child: Icon(Icons.image, color: Colors.grey[600]),
      );
    }
    
    // Cek apakah URL valid (harus dimulai dengan http)
    if (!imageUrl.startsWith('http')) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.orange[100],
          shape: BoxShape.rectangle,
        ),
        child: Icon(Icons.warning, color: Colors.orange),
      );
    }
    
    // Tampilkan gambar dengan error handling
    return Container(
      width: 50,
      height: 50,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Icon(Icons.broken_image),
          );
        },
      ),
    );
  }
}