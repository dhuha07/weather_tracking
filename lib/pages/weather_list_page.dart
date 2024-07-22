import 'package:flutter/material.dart';
import 'weather_service.dart';

class WeatherListPage extends StatefulWidget {
  @override
  _WeatherListPageState createState() => _WeatherListPageState();
}

class _WeatherListPageState extends State<WeatherListPage> {
  final WeatherService _weatherService = WeatherService();
  List<String> _indonesianCities = [
    'Jakarta',
    'Surabaya',
    'Bandung',
    'Medan',
    'Yogyakarta',
    'Denpasar'
  ]; // Add more cities as needed

  List<String> _foreignCities = [
    'New York',
    'London',
    'Tokyo',
    'Paris',
    'Sydney',
    'Moscow'
  ]; // Initial foreign cities list

  late Future<List<Map<String, dynamic>>> _indonesianWeatherData;
  late Future<List<Map<String, dynamic>>> _foreignWeatherData;

  @override
  void initState() {
    super.initState();
    _indonesianWeatherData = _fetchWeatherData(_indonesianCities);
    _foreignWeatherData = _fetchWeatherData(_foreignCities);
  }

  Future<List<Map<String, dynamic>>> _fetchWeatherData(
      List<String> cities) async {
    List<Map<String, dynamic>> weatherData = [];
    for (String city in cities) {
      try {
        final data = await _weatherService.getWeatherData(city);
        weatherData.add(data);
      } catch (e) {
        print('Error fetching weather data for $city: $e');
      }
    }
    return weatherData;
  }

  void _addCity(String city) {
    setState(() {
      _indonesianCities.add(city);
      _indonesianWeatherData =
          _fetchWeatherData(_indonesianCities); // Refresh weather data
    });
  }

  void _removeCity(int index) {
    setState(() {
      _indonesianCities.removeAt(index);
      _indonesianWeatherData =
          _fetchWeatherData(_indonesianCities); // Refresh weather data
    });
  }

  void _addForeignCity(String city) {
    setState(() {
      _foreignCities.add(city);
      _foreignWeatherData =
          _fetchWeatherData(_foreignCities); // Refresh foreign weather data
    });
  }

  void _removeForeignCity(int index) {
    setState(() {
      _foreignCities.removeAt(index);
      _foreignWeatherData =
          _fetchWeatherData(_foreignCities); // Refresh foreign weather data
    });
  }

  void _showAddCityDialog() {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New City'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter city name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _addCity(_controller.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAddForeignCityDialog() {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Foreign City'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter foreign city name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _addForeignCity(_controller.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Information'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Indonesian Cities Section
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _indonesianWeatherData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 20, color: Colors.grey.shade400),
                  itemBuilder: (context, index) {
                    final data = snapshot.data![index];
                    final city = _indonesianCities[index];
                    final temperature = data['main']['temp'];
                    final weatherDescription =
                        data['weather'][0]['description'];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: Icon(Icons.cloud,
                            size: 50, color: Colors.blueAccent),
                        title: Text(
                          city,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '$weatherDescription, $temperature°C',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _removeCity(index);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Foreign Cities Section
          Divider(height: 40, color: Colors.grey.shade400),
          Text(
            'Foreign Cities',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _foreignWeatherData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 20, color: Colors.grey.shade400),
                  itemBuilder: (context, index) {
                    final data = snapshot.data![index];
                    final city = _foreignCities[index];
                    final temperature = data['main']['temp'];
                    final weatherDescription =
                        data['weather'][0]['description'];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: Icon(Icons.cloud,
                            size: 50, color: Colors.blueAccent),
                        title: Text(
                          city,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '$weatherDescription, $temperature°C',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _removeForeignCity(index);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _showAddCityDialog,
                  child: Text('Add Indonesian City'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent, // Text color
                    minimumSize: Size(double.infinity, 50), // Button size
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _showAddForeignCityDialog,
                  child: Text('Add Foreign City'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent, // Text color
                    minimumSize: Size(double.infinity, 50), // Button size
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
