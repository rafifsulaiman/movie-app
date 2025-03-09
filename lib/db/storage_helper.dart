import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  // ✅ Ambil semua user dari SharedPreferences
  Future<List<Map<String, dynamic>>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString('users');
    return usersJson != null ? List<Map<String, dynamic>>.from(json.decode(usersJson)) : [];
  }

  // ✅ Cek apakah user sudah ada
  Future<bool> isUserExist(String username) async {
    List<Map<String, dynamic>> users = await getUsers();
    return users.any((user) => user['username'] == username);
  }

  // ✅ Register user baru
  Future<void> registerUser(String username, String password, String fullName, String nickName, String hobbies, String instagram) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> users = await getUsers();

    users.add({
      'id': users.length + 1, // ID otomatis bertambah
      'username': username,
      'password': password,
      'full_name': fullName,
      'nick_name': nickName,
      'hobbies': hobbies,
      'instagram': instagram
    });

    await prefs.setString('users', json.encode(users));
  }

  // ✅ Login user
  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    List<Map<String, dynamic>> users = await getUsers();
    for (var user in users) {
      if (user['username'] == username && user['password'] == password) {
        return user; // Return user data jika login berhasil
      }
    }
    return null;
  }

  // ✅ Logout user (hapus sesi)
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('username');
  }

  // ✅ Simpan daftar favorit per user
  Future<void> toggleFavorite(int userId, int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites_$userId') ?? [];

    if (favorites.contains(movieId.toString())) {
      favorites.remove(movieId.toString()); // Hapus dari favorit
    } else {
      favorites.add(movieId.toString()); // Tambahkan ke favorit
    }

    await prefs.setStringList('favorites_$userId', favorites);
  }

  // ✅ Ambil daftar favorit
  Future<List<int>> getFavorites(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites_$userId') ?? [];
    return favorites.map(int.parse).toList();
  }

  // ✅ Simpan daftar watchlist per user
  Future<void> toggleWatchlist(int userId, int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> watchlist = prefs.getStringList('watchlist_$userId') ?? [];

    if (watchlist.contains(movieId.toString())) {
      watchlist.remove(movieId.toString()); // Hapus dari watchlist
    } else {
      watchlist.add(movieId.toString()); // Tambahkan ke watchlist
    }

    await prefs.setStringList('watchlist_$userId', watchlist);
  }

  // ✅ Ambil daftar watchlist
  Future<List<int>> getWatchlist(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> watchlist = prefs.getStringList('watchlist_$userId') ?? [];
    return watchlist.map(int.parse).toList();
  }

  // ✅ Simpan ulasan film per user
  Future<void> saveReview(int userId, int movieId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> reviews = prefs.getStringList('reviews') ?? [];

    reviews.add(jsonEncode({'user_id': userId, 'movie_id': movieId, 'content': content}));
    await prefs.setStringList('reviews', reviews);
  }
}
