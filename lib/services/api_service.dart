import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiKey = "fe8867a1b16497806297d997a54901c3";
  static const String baseUrl = "https://api.themoviedb.org/3";

  static Future<List<dynamic>> fetchMovies(String category) async {
    final url = Uri.parse("$baseUrl/movie/$category?api_key=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception("Failed to load movies");
    }
  }
}
