import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Result extends StatefulWidget {
  final String place;
  const Result({Key? key, required this.place}) : super(key: key);

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> _weatherData;
  late AnimationController _controller;
  bool _isLoading = true;
  bool _cityNotFound = false;
  String _countryName = "";
  String _recommendation = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _weatherData = getDataFromAPI();
  }

  Future<Map<String, dynamic>> getDataFromAPI() async {
    final response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=${widget.place}&appid=210f7d44aa9f8ec2fb0feac1133e3766&units=metric"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final countryCode = data["sys"]["country"];
      final countryName = await getCountryNameFromCode(countryCode);

      setState(() {
        _isLoading = false;
        _cityNotFound = false;
        _countryName = countryName;

        if (data["weather"][0]["main"].toString().toLowerCase().contains("clear") ||
            data["weather"][0]["main"].toString().toLowerCase().contains("sun")) {
          _controller.repeat();
        } else {
          _controller.reset();
        }

        // Tentukan rekomendasi berdasarkan cuaca
        final weatherDescription = data["weather"][0]["description"].toString().toLowerCase();
        final windSpeed = data["wind"]["speed"];
        final temperature = data["main"]["temp"];

        _recommendation = "";

        // Recommendation based on weather description
        if (weatherDescription.contains("rain")) {
          _recommendation += "• Bawa payung karena kemungkinan hujan.\n• Pastikan pakaian Anda tahan air.\n";
        } 
        if (weatherDescription.contains("clear") || weatherDescription.contains("sun")) {
          _recommendation += "• Gunakan sunscreen.\n• Perhatikan bahaya sinar UV karena cuaca panas.\n";
        }
        if (weatherDescription.contains("cold") || weatherDescription.contains("chilly")) {
          _recommendation += "• Bawa jaket atau pakaian tebal.\n• Pertimbangkan untuk menggunakan payung jika hujan.\n";
        } 
        if (windSpeed > 15) { // Contoh batas kecepatan angin kencang
          _recommendation += "• Kecepatan angin tinggi, harap berhati-hati saat beraktivitas di luar ruangan.\n";
        }

        // Recommendation based on temperature
        if (temperature < 16) {
          _recommendation += "• Pakai pakaian hangat.\n• Hindari aktivitas di luar rumah jika tidak berkepentingan.\n";
        } 
        if (temperature > 28) {
          _recommendation += "• Gunakan sunscreen.\n• Bawa payung.";
        }

        if (_recommendation.isEmpty) {
          _recommendation = "• Periksa cuaca sebelum berangkat.\n• Persiapkan diri dengan tepat.";
        }
      });
      return data;
    } else if (response.statusCode == 404) {
      setState(() {
        _isLoading = false;
        _cityNotFound = true;
      });
      return {};
    } else {
      throw Exception("Failed to load weather data. Status code: ${response.statusCode}");
    }
  }

  Future<String> getCountryNameFromCode(String code) async {
    final response = await http.get(Uri.parse("https://restcountries.com/v3.1/alpha/$code"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data[0]["name"]["common"];
    } else {
      return "Negara tidak dikenal";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hasil Tracking", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.lightBlueAccent.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _cityNotFound
                ? Center(child: Text("Tempat tidak ditemukan", style: TextStyle(fontSize: 24, color: Colors.white)))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: _weatherData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        } else if (snapshot.hasData) {
                          final data = snapshot.data!;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RotationTransition(
                                turns: _controller,
                                child: Icon(
                                  _getWeatherIcon(data["weather"][0]["main"]),
                                  size: 100,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "${data["weather"][0]["main"]}",
                                style: TextStyle(fontSize: 36, color: Colors.white),
                              ),
                              Text(
                                "${data["weather"][0]["description"]}",
                                style: TextStyle(fontSize: 24, color: Colors.white70),
                              ),
                              const SizedBox(height: 20),
                              Divider(color: Colors.white, thickness: 1.0),
                              const SizedBox(height: 10),
                              _buildWeatherInfoRow(Icons.thermostat, "Suhu", "${data["main"]["temp"]}°C"),
                              const SizedBox(height: 10),
                              _buildWeatherInfoRow(Icons.wind_power, "Kecepatan Angin", "${data["wind"]["speed"]} m/s"),
                              const SizedBox(height: 10),
                              _buildWeatherInfoRow(Icons.location_city, "Kota", widget.place),
                              const SizedBox(height: 10),
                              _buildWeatherInfoRow(Icons.flag, "Negara", _countryName),
                              const SizedBox(height: 20),
                              Divider(color: Colors.white, thickness: 1.0),
                              const SizedBox(height: 10),
                              Text(
                                "Rekomendasi",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _recommendation,
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
      ),
    );
  }

  IconData _getWeatherIcon(String weatherDescription) {
    if (weatherDescription.toLowerCase().contains("rain")) {
      return Icons.beach_access;
    } else {
      return Icons.wb_sunny;
    }
  }

  Widget _buildWeatherInfoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

