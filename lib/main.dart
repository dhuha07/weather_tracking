import 'package:flutter/material.dart';
import 'package:tracking_cuaca/pages/homePage.dart'; // Sesuaikan dengan lokasi file homepage Anda
import 'package:tracking_cuaca/pages/loginPage.dart'; // Sesuaikan dengan lokasi file loginpage Anda

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRACU',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Ganti home dengan Loginpage sebagai halaman pertama
      home: Loginpage(),
      // Definisikan rute untuk navigasi di aplikasi Anda
      routes: {
        '/login': (context) => Loginpage(), // Rute untuk Loginpage
        '/home': (context) => Homepage(), // Rute untuk Homepage
        // Tambahkan rute lain sesuai kebutuhan aplikasi Anda
      },
    );
  }
}
