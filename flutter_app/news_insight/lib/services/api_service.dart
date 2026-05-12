import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://YOUR_EC2_IP:8000';

  Future<Map<String, dynamic>> analyzeText(String text) async {
    final url = Uri.parse('$baseUrl/analyze');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'text': text}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}