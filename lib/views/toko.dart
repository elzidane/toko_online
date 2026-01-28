import 'package:flutter/material.dart';
import 'package:mobileapp2/models/response_data_list.dart';
import 'package:mobileapp2/models/toko_model.dart';
import 'package:mobileapp2/services/tokoService.dart';

class Toko extends StatefulWidget {
  const Toko({super.key});

  @override
  State<Toko> createState() => _TokoState();
}

class _TokoState extends State<Toko> {
  TokoService toko = TokoService();
  List<TokoModel>? barang;
  bool isLoading = true;
  String? errorMessage;
  final ScrollController _scrollController = ScrollController();

  String fixImageUrl(String? image) {
    if (image == null || image.isEmpty) return '';

    if (image.startsWith('http')) {
      return image;
    }

    return 'https://learn.smktelkom-mlg.sch.id/toko/$image';
  }

  Future<void> getToko() async {
    try {
      ResponseDataList getToko = await toko.getToko();

      if (mounted) {
        setState(() {
          if (getToko.status == true) {
            barang = List<TokoModel>.from(getToko.data ?? []);
            errorMessage = null;
          } else {
            errorMessage = getToko.message;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Terjadi kesalahan: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getToko();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    double? percentChange,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (percentChange != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: percentChange > 0
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          percentChange > 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 14,
                          color: percentChange > 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${percentChange > 0 ? '+' : ''}${percentChange.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: percentChange > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(TokoModel item, int index) {
    final imageUrl = fixImageUrl(item.image);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Produk
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: imageUrl.isEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF6366F1).withOpacity(0.2),
                                    const Color(0xFF8B5CF6).withOpacity(0.2),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.shopping_bag,
                                size: 32,
                                color: Color(0xFF6366F1),
                              ),
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                      color: const Color(0xFF6366F1),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFF6366F1).withOpacity(0.2),
                                        const Color(0xFF8B5CF6).withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 32,
                                    color: Color(0xFF6366F1),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Informasi Produk
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.nama_barang ?? 'Produk Tanpa Nama',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (item.stok ?? 0) > 10
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (item.stok ?? 0) > 10 ? 'Tersedia' : 'Terbatas',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: (item.stok ?? 0) > 10
                                      ? Colors.green
                                      : Colors.orange,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 6),
                        
                        Text(
                          item.deskripsi ?? 'Tidak ada deskripsi',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Harga',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.6),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Rp ${item.harga?.toString() ?? '0'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF10B981),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                            
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stok',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.6),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.stok ?? 0} unit',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6366F1),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                            
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF6366F1).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Nomor Urut
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6366F1),
                  strokeWidth: 2,
                ),
              )
            : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    expandedHeight: 70,
                    collapsedHeight: 70,
                    floating: true,
                    pinned: true,
                    backgroundColor: const Color(0xFF1E293B),
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
                      title: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                            ),
                            child: const Icon(
                              Icons.storefront,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Katalog Produk',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Daftar lengkap produk toko',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: getToko,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            color: Color(0xFF6366F1),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          // Header Stats
                          if (barang != null && barang!.isNotEmpty)
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.9,
                              children: [
                                _buildStatCard(
                                  icon: Icons.shopping_bag,
                                  title: 'Total Produk',
                                  value: barang!.length.toString(),
                                  color: const Color(0xFF6366F1),
                                  percentChange: 12.5,
                                ),
                                _buildStatCard(
                                  icon: Icons.inventory,
                                  title: 'Total Stok',
                                  value: barang!
                                      .fold<int>(0, (sum, item) => sum + (item.stok ?? 0))
                                      .toString(),
                                  color: const Color(0xFF10B981),
                                  percentChange: 8.2,
                                ),
                                _buildStatCard(
                                  icon: Icons.attach_money,
                                  title: 'Harga Tertinggi',
                                  value: barang!.isNotEmpty
                                      ? 'Rp ${barang!.reduce((a, b) => (a.harga ?? 0) > (b.harga ?? 0) ? a : b).harga}'
                                      : 'Rp 0',
                                  color: const Color(0xFFF59E0B),
                                  percentChange: 15.3,
                                ),
                                _buildStatCard(
                                  icon: Icons.analytics,
                                  title: 'Rata-rata Harga',
                                  value: barang!.isNotEmpty
                                      ? 'Rp ${(barang!.fold<int>(0, (sum, item) => sum + (item.harga ?? 0)) / barang!.length).toInt()}'
                                      : 'Rp 0',
                                  color: const Color(0xFF8B5CF6),
                                  percentChange: 5.7,
                                ),
                              ],
                            ),
                          
                          const SizedBox(height: 20),
                          
                          // Status Loading/Error
                          if (errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 48,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    errorMessage!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: getToko,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6366F1),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Coba Lagi',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (barang == null || barang!.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 40,
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Belum Ada Produk',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tidak ada produk yang tersedia di toko saat ini',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.7),
                                      fontFamily: 'Poppins',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Semua Produk',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.filter_list_rounded,
                                          color: Color(0xFF6366F1),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${barang!.length} produk',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Daftar Produk
                                ...barang!.asMap().entries.map((entry) {
                                  return _buildProductCard(entry.value, entry.key);
                                }).toList(),
                                
                                const SizedBox(height: 24),
                                
                                // Footer
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF334155),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Nilai Inventori',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.7),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Rp ${barang!.fold<int>(0, (sum, item) => sum + ((item.harga ?? 0) * (item.stok ?? 0))).toString()}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF10B981),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // TODO: Implement export functionality
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF6366F1),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.download_rounded,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Ekspor Data',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}