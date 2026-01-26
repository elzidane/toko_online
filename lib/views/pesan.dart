import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Pesan extends StatefulWidget {
  const Pesan({super.key});

  @override
  State<Pesan> createState() => _PesanState();
}

class _PesanState extends State<Pesan> {
  int _selectedFilter = 0;
  final List<String> _filterOptions = ['Semua', 'Pending', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'];
  
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-2024-001',
      'customer': 'Budi Santoso',
      'email': 'budi@gmail.com',
      'phone': '081234567890',
      'date': '2024-01-15 14:30',
      'status': 'pending',
      'total': 28500000,
      'items': [
        {'name': 'MacBook Pro M3', 'qty': 1, 'price': 25000000},
        {'name': 'Mouse Wireless', 'qty': 1, 'price': 3500000},
      ],
      'payment': 'Bank Transfer',
      'shipping': 'JNE Express',
      'address': 'Jl. Merdeka No. 123, Jakarta',
    },
    {
      'id': 'ORD-2024-002',
      'customer': 'Siti Rahayu',
      'email': 'siti@gmail.com',
      'phone': '081298765432',
      'date': '2024-01-14 10:15',
      'status': 'processed',
      'total': 18999000,
      'items': [
        {'name': 'iPhone 15 Pro', 'qty': 1, 'price': 18999000},
      ],
      'payment': 'Credit Card',
      'shipping': 'GoSend',
      'address': 'Jl. Sudirman No. 456, Bandung',
    },
    {
      'id': 'ORD-2024-003',
      'customer': 'Agus Wijaya',
      'email': 'agus@gmail.com',
      'phone': '081312345678',
      'date': '2024-01-13 16:45',
      'status': 'shipped',
      'total': 2399000,
      'items': [
        {'name': 'Nike Air Max', 'qty': 1, 'price': 2399000},
      ],
      'payment': 'E-Wallet',
      'shipping': 'J&T Express',
      'address': 'Jl. Asia Afrika No. 789, Surabaya',
    },
    {
      'id': 'ORD-2024-004',
      'customer': 'Rina Melati',
      'email': 'rina@gmail.com',
      'phone': '081323456789',
      'date': '2024-01-12 09:20',
      'status': 'completed',
      'total': 42500000,
      'items': [
        {'name': 'Sony Alpha 7 IV', 'qty': 1, 'price': 42500000},
      ],
      'payment': 'Bank Transfer',
      'shipping': 'SiCepat',
      'address': 'Jl. Gatot Subroto No. 101, Medan',
    },
    {
      'id': 'ORD-2024-005',
      'customer': 'Dian Permata',
      'email': 'dian@gmail.com',
      'phone': '081334567890',
      'date': '2024-01-11 13:10',
      'status': 'cancelled',
      'total': 4499000,
      'items': [
        {'name': 'AirPods Pro 2', 'qty': 1, 'price': 4499000},
      ],
      'payment': 'Credit Card',
      'shipping': 'JNE Express',
      'address': 'Jl. Diponegoro No. 202, Semarang',
    },
    {
      'id': 'ORD-2024-006',
      'customer': 'Hendra Kurniawan',
      'email': 'hendra@gmail.com',
      'phone': '081345678901',
      'date': '2024-01-10 11:30',
      'status': 'processed',
      'total': 35900000,
      'items': [
        {'name': 'Gucci Tote Bag', 'qty': 1, 'price': 35900000},
      ],
      'payment': 'Bank Transfer',
      'shipping': 'GoSend',
      'address': 'Jl. Thamrin No. 303, Makassar',
    },
    {
      'id': 'ORD-2024-007',
      'customer': 'Maya Sari',
      'email': 'maya@gmail.com',
      'phone': '081356789012',
      'date': '2024-01-09 15:45',
      'status': 'pending',
      'total': 32999000,
      'items': [
        {'name': 'Samsung QLED TV', 'qty': 1, 'price': 32999000},
      ],
      'payment': 'E-Wallet',
      'shipping': 'J&T Express',
      'address': 'Jl. Pahlawan No. 404, Bali',
    },
    {
      'id': 'ORD-2024-008',
      'customer': 'Fajar Setiawan',
      'email': 'fajar@gmail.com',
      'phone': '081367890123',
      'date': '2024-01-08 08:55',
      'status': 'shipped',
      'total': 5499000,
      'items': [
        {'name': 'Coffee Maker Premium', 'qty': 1, 'price': 5499000},
      ],
      'payment': 'Credit Card',
      'shipping': 'SiCepat',
      'address': 'Jl. Juanda No. 505, Yogyakarta',
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == 0) return _orders;
    final status = _filterOptions[_selectedFilter].toLowerCase();
    return _orders.where((order) => order['status'] == status).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Color(0xFFF59E0B);
      case 'processed':
        return Color(0xFF3B82F6);
      case 'shipped':
        return Color(0xFF8B5CF6);
      case 'completed':
        return Color(0xFF10B981);
      case 'cancelled':
        return Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'processed':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Tidak Diketahui';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_actions;
      case 'processed':
        return Icons.autorenew;
      case 'shipped':
        return Icons.local_shipping;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _showOrderDetails(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: _buildOrderDetailSheet(index),
      ),
    );
  }

  void _updateOrderStatus(String orderId, String newStatus) {
    setState(() {
      final orderIndex = _orders.indexWhere((order) => order['id'] == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex]['status'] = newStatus;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status pesanan berhasil diperbarui'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan Gradient
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manajemen Pesanan',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${_filteredOrders.length} pesanan ditemukan',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.shopping_bag_outlined, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  // Quick Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('Pending', 
                        _orders.where((o) => o['status'] == 'pending').length.toString(),
                        Color(0xFFF59E0B)
                      ),
                      _buildMiniStat('Diproses', 
                        _orders.where((o) => o['status'] == 'processed').length.toString(),
                        Color(0xFF3B82F6)
                      ),
                      _buildMiniStat('Dikirim', 
                        _orders.where((o) => o['status'] == 'shipped').length.toString(),
                        Color(0xFF8B5CF6)
                      ),
                      _buildMiniStat('Selesai', 
                        _orders.where((o) => o['status'] == 'completed').length.toString(),
                        Color(0xFF10B981)
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Filter Chips
            Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = index;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10, top: 15),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: _selectedFilter == index
                            ? LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              )
                            : null,
                        color: _selectedFilter == index ? null : Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(25),
                        border: _selectedFilter == index
                            ? null
                            : Border.all(color: Color(0xFF334155), width: 1),
                      ),
                      child: Text(
                        _filterOptions[index],
                        style: GoogleFonts.poppins(
                          color: _selectedFilter == index ? Colors.white : Color(0xFF94A3B8),
                          fontWeight: _selectedFilter == index ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: 10),
            
            // Orders List
            Expanded(
              child: _filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 80, color: Color(0xFF475569)),
                          SizedBox(height: 20),
                          Text(
                            'Tidak ada pesanan',
                            style: GoogleFonts.poppins(
                              color: Color(0xFF94A3B8),
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tidak ada pesanan dengan status ini',
                            style: GoogleFonts.poppins(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.9),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(int index) {
    final order = _filteredOrders[index];
    final statusColor = _getStatusColor(order['status']);
    
    return GestureDetector(
      onTap: () => _showOrderDetails(index),
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['id'],
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(order['status']),
                          size: 14,
                          color: statusColor,
                        ),
                        SizedBox(width: 6),
                        Text(
                          _getStatusText(order['status']),
                          style: GoogleFonts.poppins(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Customer Info
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        order['customer'][0],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['customer'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          order['email'],
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
              
              SizedBox(height: 16),
              
              // Order Details
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tanggal:',
                          style: GoogleFonts.poppins(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          order['date'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: GoogleFonts.poppins(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Rp ${NumberFormat('#,###').format(order['total'])}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Items:',
                          style: GoogleFonts.poppins(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${order['items'].length} produk',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showOrderDetails(index),
                      icon: Icon(Icons.remove_red_eye_outlined, size: 16),
                      label: Text('Detail'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF475569)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showUpdateStatusDialog(order['id']),
                      icon: Icon(Icons.edit_outlined, size: 16),
                      label: Text('Update'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B5CF6),
                        padding: EdgeInsets.symmetric(vertical: 12),
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
    );
  }

  void _showUpdateStatusDialog(String orderId) {
    final currentOrder = _orders.firstWhere((order) => order['id'] == orderId);
    final currentStatus = currentOrder['status'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              'Update Status Pesanan',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              orderId,
              style: GoogleFonts.poppins(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            
            ...['pending', 'processed', 'shipped', 'completed', 'cancelled'].map((status) {
              return ListTile(
                onTap: () {
                  if (status != currentStatus) {
                    _updateOrderStatus(orderId, status);
                  }
                  Navigator.pop(context);
                },
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: status == currentStatus ? _getStatusColor(status) : Color(0xFF475569),
                      width: 2,
                    ),
                    color: status == currentStatus ? _getStatusColor(status) : Colors.transparent,
                  ),
                  child: status == currentStatus
                      ? Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                title: Text(
                  _getStatusText(status),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
                trailing: Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailSheet(int index) {
    final order = _filteredOrders[index];
    final statusColor = _getStatusColor(order['status']);
    final currencyFormat = NumberFormat('#,###');
    
    return SingleChildScrollView(
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
            
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['id'],
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      order['date'],
                      style: GoogleFonts.poppins(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(_getStatusIcon(order['status']), color: statusColor, size: 18),
                      SizedBox(width: 8),
                      Text(
                        _getStatusText(order['status']),
                        style: GoogleFonts.poppins(
                          color: statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 32),
            
            // Customer Info Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Pelanggan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  _buildDetailRow('Nama', order['customer']),
                  _buildDetailRow('Email', order['email']),
                  _buildDetailRow('Telepon', order['phone']),
                  _buildDetailRow('Alamat Pengiriman', order['address']),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Order Items Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Pesanan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  ...order['items'].map<Widget>((item) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF6366F1).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '📦',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${item['qty']} x Rp ${currencyFormat.format(item['price'])}',
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Rp ${currencyFormat.format(item['price'] * item['qty'])}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  
                  SizedBox(height: 16),
                  
                  Divider(color: Color(0xFF334155)),
                  
                  SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Rp ${currencyFormat.format(order['total'])}',
                        style: GoogleFonts.poppins(
                          color: Color(0xFF10B981),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Payment & Shipping Info
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF3B82F6).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.payment, color: Color(0xFF3B82F6), size: 20),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Pembayaran',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          order['payment'],
                          style: GoogleFonts.poppins(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF8B5CF6).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.local_shipping, color: Color(0xFF8B5CF6), size: 20),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Pengiriman',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          order['shipping'],
                          style: GoogleFonts.poppins(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showUpdateStatusDialog(order['id']),
                    icon: Icon(Icons.edit_outlined),
                    label: Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8B5CF6),
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Implement print invoice
                    },
                    icon: Icon(Icons.print_outlined),
                    label: Text('Cetak Invoice'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF475569)),
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}