import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileapp2/models/user_login.dart';
import 'package:mobileapp2/providers/user_provider.dart';
import 'package:mobileapp2/views/dashboard.dart';
import 'package:mobileapp2/views/pesan.dart';
import 'package:mobileapp2/views/toko.dart';

class Bottomnav extends StatefulWidget {
  int activePage = 0;
  Bottomnav(this.activePage);

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  UserLogin userLogin = UserLogin();
  String? role;

  int currentIndex = 0;
  List<Widget> navbar = [];
  List<BottomNavigationBarItem> navbarItems = [];

  getDataLogin() async {
    var user = await userLogin!.getUserLogin();
    if (user!.status != false) {
      setState(() {
        role = user.role;
        _buildNavbarItems();
      });
    } else {
      Navigator.popAndPushNamed(context, '/login');
    }
  }

  void _buildNavbarItems() {
    if (role == 'admin') {
      navbar = [Dashboard(), Toko()];
      navbarItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.storefront),
          label: 'Toko',
        ),
      ];
    } else if (role == 'user') {
      navbar = [Dashboard(), Pesan()];
      navbarItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Pesan',
        ),
      ];
    }
    // Reset currentIndex jika melebihi panjang navbar baru
    if (currentIndex >= navbar.length) {
      currentIndex = 0;
    }
  }

  @override
  void initState() {
    super.initState();
    getDataLogin();
  }

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (navbar.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: navbar[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        
        selectedItemColor: const Color.fromARGB(255, 123, 97, 255),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'poppins',
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontFamily: 'poppins'),
        currentIndex: currentIndex,
        onTap: onTap,
        
        backgroundColor: Color(0xFF1E293B),
        items: navbarItems,
      ),
    );
  }
}
