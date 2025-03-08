import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final favData = prefs.getString('favorites');
    final watchData = prefs.getString('watchlist');

    _favorites = favData != null ? List<Map<String, dynamic>>.from(json.decode(favData)) : [];
    _watchlist = watchData != null ? List<Map<String, dynamic>>.from(json.decode(watchData)) : [];

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorites', json.encode(_favorites));
    await prefs.setString('watchlist', json.encode(_watchlist));
  }

  void toggleFavorite(Map<String, dynamic> movie) {
    final existingIndex = _favorites.indexWhere((m) => m['id'] == movie['id']);
    if (existingIndex != -1) {
      _favorites.removeAt(existingIndex);
    } else {
      _favorites.add(movie);
    }
    _saveData();
    notifyListeners();
  }

  void toggleWatchlist(Map<String, dynamic> movie) {
    final existingIndex = _watchlist.indexWhere((m) => m['id'] == movie['id']);
    if (existingIndex != -1) {
      _watchlist.removeAt(existingIndex);
    } else {
      _watchlist.add(movie);
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
