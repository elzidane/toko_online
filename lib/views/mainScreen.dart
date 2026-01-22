import 'package:flutter/material.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/atas.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),

            const SizedBox(height: 40),

            Text(
              'Selamat Datang!!',
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 22, 98, 165),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Ini adalah aplikasi toko online',
              style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
            ),

            const SizedBox(height: 70),

            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/animasi.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: 70),

            MaterialButton(
              minWidth: 300,
              height: 50,
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.blue[800],
              child: Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            
            SizedBox(height: 20),

            MaterialButton(
              minWidth: 300,
              height: 50,
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: Colors.blue.shade800,
                ),
              ),
              child: Text(
                "Registrasi",
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
