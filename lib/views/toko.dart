import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Toko extends StatefulWidget {
  const Toko({super.key});

  @override
  State<Toko> createState() => _TokoState();
}

class _TokoState extends State<Toko> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'MacBook Pro M3',
      'category': 'Elektronik',
      'price': 28500000,
      'stock': 8,
      'rating': 4.9,
      'sales': 156,
      'image': '💻',
      'status': 'active',
      'discount': 15,
      'color': Color(0xFF6366F1),
    },
    {
      'id': '2',
      'name': 'iPhone 15 Pro',
      'category': 'Elektronik',
      'price': 18999000,
      'stock': 22,
      'rating': 4.8,
      'sales': 324,
      'image': '📱',
      'status': 'active',
      'discount': 10,
      'color': Color(0xFF10B981),
    },
    {
      'id': '3',
      'name': 'Nike Air Max',
      'category': 'Fashion',
      'price': 2399000,
      'stock': 45,
      'rating': 4.7,
      'sales': 89,
      'image': '👟',
      'status': 'active',
      'discount': 20,
      'color': Color(0xFFF59E0B),
    },
    {
      'id': '4',
      'name': 'Sony Alpha 7 IV',
      'category': 'Fotografi',
      'price': 42500000,
      'stock': 3,
      'rating': 4.9,
      'sales': 42,
      'image': '📷',
      'status': 'low_stock',
      'discount': 12,
      'color': Color(0xFF8B5CF6),
    },
    {
      'id': '5',
      'name': 'AirPods Pro 2',
      'category': 'Elektronik',
      'price': 4499000,
      'stock': 0,
      'rating': 4.8,
      'sales': 218,
      'image': '🎧',
      'status': 'out_of_stock',
      'discount': 0,
      'color': Color(0xFFEC4899),
    },
    {
      'id': '6',
      'name': 'Gucci Tote Bag',
      'category': 'Fashion',
      'price': 35900000,
      'stock': 12,
      'rating': 4.6,
      'sales': 67,
      'image': '👜',
      'status': 'active',
      'discount': 25,
      'color': Color(0xFF0EA5E9),
    },
    {
      'id': '7',
      'name': 'Samsung QLED TV',
      'category': 'Elektronik',
      'price': 32999000,
      'stock': 7,
      'rating': 4.7,
      'sales': 51,
      'image': '📺',
      'status': 'active',
      'discount': 18,
      'color': Color(0xFFEF4444),
    },
    {
      'id': '8',
      'name': 'Coffee Maker Premium',
      'category': 'Rumah Tangga',
      'price': 5499000,
      'stock': 18,
      'rating': 4.5,
      'sales': 92,
      'image': '☕',
      'status': 'active',
      'discount': 30,
      'color': Color(0xFF14B8A6),
    },
  ];

  final List<String> _categories = [
    'Semua',
    'Elektronik',
    'Fashion',
    'Fotografi',
    'Rumah Tangga',
  ];
  String _selectedCategory = 'Semua';
  String _sortBy = 'terbaru';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> filtered = List.from(_products);

    if (_selectedCategory != 'Semua') {
      filtered = filtered
          .where((product) => product['category'] == _selectedCategory)
          .toList();
    }

    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (product) => product['name'].toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    switch (_sortBy) {
      case 'terbaru':
        filtered.sort((a, b) => b['id'].compareTo(a['id']));
        break;
      case 'harga_tinggi':
        filtered.sort((a, b) => b['price'].compareTo(a['price']));
        break;
      case 'harga_rendah':
        filtered.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'terlaris':
        filtered.sort((a, b) => b['sales'].compareTo(a['sales']));
        break;
      case 'rating':
        filtered.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
    }

    return filtered;
  }

  Map<String, dynamic> get _stats {
    int totalProducts = _products.length;
    int activeProducts = _products.where((p) => p['status'] == 'active').length;
    int lowStockProducts = _products
        .where((p) => p['status'] == 'low_stock')
        .length;
    int outOfStockProducts = _products
        .where((p) => p['status'] == 'out_of_stock')
        .length;
    double totalRevenue = _products.fold(
      0,
      (sum, product) => sum + (product['price'] * product['sales']),
    );

    return {
      'total_products': totalProducts,
      'active_products': activeProducts,
      'low_stock_products': lowStockProducts,
      'out_of_stock_products': outOfStockProducts,
      'total_revenue': totalRevenue,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header dengan Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text(
                        //       'Selamat Datang,',
                        //       style: GoogleFonts.poppins(
                        //         color: Colors.white.withOpacity(0.9),
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //     ),
                        //     SizedBox(height: 4),
                        //     Text(
                        //       'Admin Store',
                        //       style: GoogleFonts.poppins(
                        //         color: Colors.white,
                        //         fontSize: 24,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: Colors.white.withOpacity(0.2),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   padding: EdgeInsets.all(10),
                        //   child: Icon(
                        //     Icons.notifications_outlined,
                        //     color: Colors.white,
                        //   ),
                        // ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Search Bar Modern
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          hintStyle: GoogleFonts.poppins(),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF6366F1),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.filter_list,
                              color: Color(0xFF6366F1),
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => _buildFilterSheet(),
                              );
                            },
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Stats Cards dengan Neumorphism Effect
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCard(
                      'Total Produk',
                      _stats['total_products'].toString(),
                      Icons.inventory_2_outlined,
                      LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                    ),
                    _buildStatCard(
                      'Aktif',
                      _stats['active_products'].toString(),
                      Icons.check_circle_outline,
                      LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      ),
                    ),
                    _buildStatCard(
                      'Stok Sedikit',
                      _stats['low_stock_products'].toString(),
                      Icons.warning_amber_outlined,
                      LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                      ),
                    ),
                    _buildStatCard(
                      'Pendapatan',
                      'Rp${(_stats['total_revenue'] / 1000000).toStringAsFixed(1)}M',
                      Icons.attach_money_outlined,
                      LinearGradient(
                        colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Quick Actions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kategori Produk',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.add, color: Color(0xFF8B5CF6), size: 18),
                      label: Text(
                        'Tambah',
                        style: GoogleFonts.poppins(
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Category Chips
              Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    Color(0xFF6366F1),
                                    Color(0xFF8B5CF6),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(25),
                          border: isSelected
                              ? null
                              : Border.all(color: Color(0xFF334155), width: 1),
                        ),
                        child: Text(
                          category,
                          style: GoogleFonts.poppins(
                            color: isSelected
                                ? Colors.white
                                : Color(0xFF94A3B8),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 32),

              // Products List Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Produk Terbaru',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_alt_outlined,
                            size: 16,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '${_filteredProducts.length} items',
                            style: GoogleFonts.poppins(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Products List
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: _buildProductCard(product, index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Floating Action Button dengan Gradient
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6366F1).withOpacity(0.5),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            _showAddProductModal();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add, size: 30),
        ),
      ),

      // Bottom Navigation Bar Modern
      // bottomNavigationBar: Container(
      //   decoration: BoxDecoration(
      //     color: Color(0xFF1E293B),
      //     border: Border(top: BorderSide(color: Color(0xFF334155), width: 1)),
      //   ),
      //   padding: EdgeInsets.symmetric(vertical: 12),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //     children: [
      //       _buildNavItem(Icons.dashboard_outlined, 'Dashboard', 0),
      //       _buildNavItem(Icons.inventory_2_outlined, 'Produk', 1),
      //       _buildNavItem(Icons.analytics_outlined, 'Analytics', 2),
      //       _buildNavItem(Icons.person_outline, 'Profile', 3),
      //     ],
      //   ),
      // ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Gradient gradient,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, color: Colors.white, size: 22)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    return GestureDetector(
      onTap: () => _showProductDetail(index),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Decoration
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      product['color'].withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(60),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Product Image/Icon Container
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          product['color'],
                          product['color'].withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        product['image'],
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ),

                  SizedBox(width: 16),

                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product['name'],
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (product['discount'] > 0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF10B981).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${product['discount']}% OFF',
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFF10B981),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: 4),

                        Text(
                          product['category'],
                          style: GoogleFonts.poppins(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),

                        SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(
                              Icons.attach_money_outlined,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Rp ${(product['price']).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),

                        Row(
                          children: [
                            _buildInfoChip(
                              '${product['stock']} Stok',
                              product['status'] == 'out_of_stock'
                                  ? Colors.red
                                  : product['status'] == 'low_stock'
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            SizedBox(width: 8),
                            _buildInfoChip(
                              '${product['rating']} ⭐',
                              Colors.amber,
                            ),
                            SizedBox(width: 8),
                            _buildInfoChip(
                              '${product['sales']} Terjual',
                              Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Status Indicator
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusColor(product['status']),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    )
                  : null,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Color(0xFF64748B),
              size: 22,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Color(0xFF8B5CF6) : Color(0xFF64748B),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSheet() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFF475569),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Filter & Urutkan',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          ...[
            'terbaru',
            'harga_tinggi',
            'harga_rendah',
            'terlaris',
            'rating',
          ].map((sort) {
            return ListTile(
              onTap: () {
                setState(() {
                  _sortBy = sort;
                });
                Navigator.pop(context);
              },
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _sortBy == sort
                        ? Color(0xFF8B5CF6)
                        : Color(0xFF475569),
                    width: 2,
                  ),
                  color: _sortBy == sort
                      ? Color(0xFF8B5CF6)
                      : Colors.transparent,
                ),
                child: _sortBy == sort
                    ? Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              title: Text(
                sort == 'terbaru'
                    ? 'Terbaru'
                    : sort == 'harga_tinggi'
                    ? 'Harga Tertinggi'
                    : sort == 'harga_rendah'
                    ? 'Harga Terendah'
                    : sort == 'terlaris'
                    ? 'Terlaris'
                    : 'Rating Tertinggi',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showProductDetail(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Color(0xFF475569),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Product Header
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _filteredProducts[index]['color'],
                            _filteredProducts[index]['color'].withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          _filteredProducts[index]['image'],
                          style: TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _filteredProducts[index]['name'],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _filteredProducts[index]['category'],
                            style: GoogleFonts.poppins(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, size: 18, color: Colors.amber),
                              SizedBox(width: 4),
                              Text(
                                '${_filteredProducts[index]['rating']}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // Price Section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Harga',
                            style: GoogleFonts.poppins(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Rp ${(_filteredProducts[index]['price']).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF34D399)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_filteredProducts[index]['sales']} Terjual',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildDetailStat(
                      'Stok Tersedia',
                      '${_filteredProducts[index]['stock']}',
                      Icons.inventory,
                    ),
                    _buildDetailStat(
                      'Status',
                      _getStatusText(_filteredProducts[index]['status']),
                      Icons.circle,
                      color: _getStatusColor(
                        _filteredProducts[index]['status'],
                      ),
                    ),
                    _buildDetailStat(
                      'Diskon',
                      '${_filteredProducts[index]['discount']}%',
                      Icons.local_offer,
                    ),
                    _buildDetailStat(
                      'ID Produk',
                      _filteredProducts[index]['id'],
                      Icons.tag,
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.edit_outlined),
                        label: Text('Edit Produk'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8B5CF6),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.delete_outline),
                        label: Text('Hapus'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFFEF4444)),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStat(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? Color(0xFF8B5CF6), size: 24),
          SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showAddProductModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color(0xFF475569),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Tambah Produk Baru',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    _buildFormField('Nama Produk', 'Masukkan nama produk'),
                    SizedBox(height: 16),
                    _buildFormField('Kategori', 'Pilih kategori'),
                    SizedBox(height: 16),
                    _buildFormField('Harga', 'Rp 0'),
                    SizedBox(height: 16),
                    _buildFormField('Stok', '0'),
                    SizedBox(height: 16),
                    _buildFormField('Deskripsi', 'Masukkan deskripsi produk'),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Produk berhasil ditambahkan'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Simpan Produk',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF334155), width: 1),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Color(0xFF64748B)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Color(0xFF10B981);
      case 'low_stock':
        return Color(0xFFF59E0B);
      case 'out_of_stock':
        return Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'low_stock':
        return 'Stok Sedikit';
      case 'out_of_stock':
        return 'Habis';
      default:
        return 'Tidak Diketahui';
    }
  }
}
