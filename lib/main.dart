import 'package:flutter/material.dart';
import 'package:mobileapp2/views/dashboard.dart';
import 'package:mobileapp2/views/mainScreen.dart';
import 'package:mobileapp2/views/pesan.dart';
import 'package:mobileapp2/views/register.dart';
import 'package:mobileapp2/views/login.dart';
import 'package:mobileapp2/views/toko.dart';
import 'package:mobileapp2/widget/bottomnav.dart';
import 'package:provider/provider.dart';
import 'package:mobileapp2/providers/user_provider.dart';

//multi`provider
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider()..loadUserFromStorage(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: '/mainScreen',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/': (context) => const Register(),
        '/mainScreen': (context) => const Mainscreen(),
        '/login': (context) => const Login(),
        '/dashboard': (context) => const Dashboard(),
        '/bottomnav': (context) => Bottomnav(0),
        '/pesan': (context) => const Pesan(),
        '/toko': (context) => const Toko(),
      },
    );
  }
}