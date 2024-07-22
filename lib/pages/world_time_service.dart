import 'dart:convert';
import 'package:http/http.dart' as http;

class WorldTimeService {
  Future<Map<String, dynamic>> getWorldTime(String location) async {
    final url = 'http://worldtimeapi.org/api/timezone/$location';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load time data');
    }
  }
}
