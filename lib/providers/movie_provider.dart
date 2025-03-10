import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:movie_app/services/auth_service.dart';
import 'package:http/http.dart' as http;

class MovieProvider with ChangeNotifier {
  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> _watchlist = [];

  List<Map<String, dynamic>> get favorites => List.unmodifiable(_favorites);
  List<Map<String, dynamic>> get watchlist => List.unmodifiable(_watchlist);

  MovieProvider() {
    init();
  }

  Future<void> init() async {
    await _loadData();
  }

  Future<Map<String, dynamic>?> fetchMovieDetails(int movieId) async {
    final apiKey = "fe8867a1b16497806297d997a54901c3"; // Ganti dengan API key TMDB kamu
    final url = "https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  Future<void> _loadData() async {
    final userData = await AuthService().getUserData();
    if (userData != null) {
      _favorites = [];
      _watchlist = [];

      // Ambil data film berdasarkan ID
      for (int id in List<int>.from(userData['favorites'] ?? [])) {
        final movie = await fetchMovieDetails(id);
        if (movie != null) _favorites.add(movie);
      }
      for (int id in List<int>.from(userData['watchlist'] ?? [])) {
        final movie = await fetchMovieDetails(id);
        if (movie != null) _watchlist.add(movie);
      }

      print("Favorites Loaded: $_favorites");
      print("Watchlist Loaded: $_watchlist");
      notifyListeners();
    }
  }


  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorites', json.encode(_favorites));
    await prefs.setString('watchlist', json.encode(_watchlist));
  }

  void toggleFavorite(Map<String, dynamic> movieData) {
    if (_favorites.any((m) => m['id'] == movieData['id'])) {
      _favorites.removeWhere((m) => m['id'] == movieData['id']);
      AuthService().removeFromFavorites(movieData['id']);
    } else {
      _favorites.add(movieData);
      AuthService().addToFavorites(movieData['id']);
    }
    _saveData();
    notifyListeners();
  }

  void toggleWatchlist(Map<String, dynamic> movieData) {
    if (_watchlist.any((m) => m['id'] == movieData['id'])) {
      _watchlist.removeWhere((m) => m['id'] == movieData['id']);
      AuthService().removeFromWatchlist(movieData['id']);
    } else {
      _watchlist.add(movieData);
      AuthService().addToWatchlist(movieData['id']);
    }
    _saveData();
    notifyListeners();
  }

  bool isFavorite(int id) {
    return _favorites.any((m) => m['id'] == id);
  }

  bool isInWatchlist(int id) {
    return _watchlist.any((m) => m['id'] == id);
  }
}
