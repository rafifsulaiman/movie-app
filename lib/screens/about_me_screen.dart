import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/providers/movie_provider.dart';
import 'package:movie_app/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:movie_app/screens/movie_detail_screen.dart';

class AboutMeScreen extends StatefulWidget {
  @override
  _AboutMeScreenState createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  bool isEditing = false;

  void _editProfileDialog(Map<String, dynamic> userData) {
    final TextEditingController nameController =
        TextEditingController(text: userData['fullname']);
    final TextEditingController nicknameController =
        TextEditingController(text: userData['nickname']);
    final TextEditingController hobbyController =
        TextEditingController(text: userData['hobby']);
    final TextEditingController imageController =
        TextEditingController(text: userData['profile_picture'] ?? "");
    final TextEditingController instagramController =
        TextEditingController(text: userData['instagram'] ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: imageController,
                  decoration: InputDecoration(labelText: "Profile Picture URL"),
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Full Name"),
                ),
                TextField(
                  controller: nicknameController,
                  decoration: InputDecoration(labelText: "Nickname"),
                ),
                TextField(
                  controller: hobbyController,
                  decoration: InputDecoration(labelText: "Hobby"),
                ),
                TextField(
                  controller: instagramController,
                  decoration: InputDecoration(labelText: "Instagram URL"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService().updateUserData({
                  'fullname': nameController.text.trim(),
                  'nickname': nicknameController.text.trim(),
                  'hobby': hobbyController.text.trim(),
                  'profile_picture': imageController.text.trim(),
                  'instagram': instagramController.text.trim(),
                });

                if (!mounted) return;
                Navigator.pop(context);
                setState(() {}); // Refresh UI setelah update
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final favorites = movieProvider.favorites;
    final watchlist = movieProvider.watchlist;

    return Scaffold(
      appBar: AppBar(
        title: Text("About Me", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[800],
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: AuthService().getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Failed to load user data"));
          }

          final userData = snapshot.data!;
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                  key: ValueKey(userData['profile_picture']), // ✅ Paksa rebuild jika gambar berubah
                  radius: 50,
                  backgroundImage: NetworkImage(
                    userData['profile_picture']?.isNotEmpty == true
                        ? userData['profile_picture']
                        : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                  ),
                ),
                  SizedBox(height: 10),
                  Text(userData['fullname'] ?? "No Name",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Text("Nickname: ${userData['nickname'] ?? '-'}", style: TextStyle(color: Colors.grey)),
                  Text("Hobbies: ${userData['hobby'] ?? '-'}", style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () async {
                      final String username = userData['instagram'] ?? "";
                      if (username.isNotEmpty) {
                        final Uri url = Uri.parse("https://www.instagram.com/$username");
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          debugPrint("Could not launch $url");
                        }
                      }
                    },
                    child: Text("Instagram Profile", style: TextStyle(color: Colors.blue)),
                  ),
                  if (isEditing)
                    ElevatedButton(
                      onPressed: () => _editProfileDialog(userData),
                      child: Text("Edit Profile"),
                    ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.grey, size: 28),
                      SizedBox(width: 8),
                      Text(
                        "Favorite Movies",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
                  favorites.isEmpty
                      ? Center(child: Text("No favorites yet!"))
                      : _buildMovieList(favorites),
                  SizedBox(height: 20),
                  Text("🎬 Watchlist", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                  watchlist.isEmpty
                      ? Center(child: Text("No movies in watchlist!"))
                      : _buildMovieList(watchlist),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieList(List<Map<String, dynamic>> movies) {
    return SizedBox(
      height: 190, // ✅ Tambah tinggi agar teks tidak overflow
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(movieId: movie['id']),
                      ),
                    );
                  },
                  child: Image.network(
                    movie['poster_path'] != null
                        ? "https://image.tmdb.org/t/p/w200${movie['poster_path']}"
                        : "https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png",
                    width: 100,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image, size: 50, color: Colors.grey);
                    },
                  ),
                ),
                SizedBox(height: 5),
                SizedBox(
                  width: 100,
                  child: Text(
                    movie['title'],
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
