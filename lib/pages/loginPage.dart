import 'package:flutter/material.dart';
import 'package:tracking_cuaca/pages/homePage.dart'; // Sesuaikan dengan lokasi yang benar
import 'package:tracking_cuaca/pages/registrationPage.dart'; // Sesuaikan dengan lokasi yang benar
import 'package:http/http.dart' as http;
import 'dart:convert';

class Loginpage extends StatelessWidget {
  Loginpage({Key? key}) : super(key: key);

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formkey = GlobalKey<FormState>();

  final String _loginUrl = 'https://reqres.in/api/login'; // Ganti dengan URL yang sesuai

  Future<void> _login(BuildContext context) async {
    final response = await http.post(
      Uri.parse(_loginUrl),
      headers: {
        'Authorization': 'Bearer QpwL5tke4Pnpja7X4', // Token untuk autentikasi
      },
      body: {
        'email': usernameController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      String token = jsonResponse['token'];

      // Navigasi ke halaman beranda jika login berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    } else {
      // Tampilkan pesan kesalahan jika login gagal
      print('Login failed: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: Server error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          textAlign: TextAlign.center, // Tengahkan teks secara horizontal
        ),
        leading: Icon(Icons.arrow_back),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formkey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/logo.png", // Sesuaikan dengan path yang benar
                  height: 150,
                ),
              ),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Kembali',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  print('Klik login');
                  if (formkey.currentState!.validate()) {
                    _login(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisPage(),
                    ),
                  );
                },
                child: Text(
                  'Belum punya akun? Daftar di sini',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
