import 'package:flutter/material.dart';
import 'world_time_service.dart';

class WorldClockPage extends StatefulWidget {
  @override
  _WorldClockPageState createState() => _WorldClockPageState();
}

class _WorldClockPageState extends State<WorldClockPage> {
  final WorldTimeService _worldTimeService = WorldTimeService();
  final List<String> _locations = [
    'Europe/London',
    'America/New_York',
    'Asia/Tokyo',
    'Australia/Sydney',
    'Asia/Kolkata',        // India
    'America/Los_Angeles', // Los Angeles
    'Europe/Berlin',       // Berlin
    'Asia/Singapore',      // Singapore
    'Africa/Johannesburg', // Johannesburg
    'Pacific/Auckland',
    'Asia/Jakarta',   // Auckland
    // Add more locations as needed
  ];

  late Future<Map<String, dynamic>> _timeData;

  @override
  void initState() {
    super.initState();
    _timeData = _worldTimeService.getWorldTime(_locations[0]);
  }

  void _updateTime(String location) {
    setState(() {
      _timeData = _worldTimeService.getWorldTime(location);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('World Clock'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: _locations[0],
                  onChanged: (value) {
                    if (value != null) {
                      _updateTime(value);
                    }
                  },
                  items: _locations.map<DropdownMenuItem<String>>((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location, style: TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  isExpanded: true,
                  underline: SizedBox(),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _timeData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return Center(child: Text('No data available'));
                    }

                    final data = snapshot.data!;
                    final datetime = data['datetime'];
                    final timezone = data['timezone'];

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Current time in',
                            style: TextStyle(fontSize: 20, color: Colors.white70),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '$timezone',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '$datetime',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
