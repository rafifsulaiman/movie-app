import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final favorites = movieProvider.favorites;
    final watchlist = movieProvider.watchlist;

    return Scaffold(
      appBar: AppBar(title: Text("About Me")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Konten di tengah layar
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage("https://via.placeholder.com/150"),
              ),
              SizedBox(height: 10),
              Text("Rafif Sulaiman", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("Nickname: Rafif"),
              Text("Hobbies: Coding, Watching Movies"),
              TextButton(
                onPressed: () async {
                  final Uri url = Uri.parse("https://www.instagram.com/rafifsulaimann");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    debugPrint("Could not launch $url");
                  }
                },
                child: Text("Instagram Profile", style: TextStyle(color: Colors.blue)),
              ),
              SizedBox(height: 20),
              Text("⭐ Favorite Movies", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              favorites.isEmpty
                  ? Center(child: Text("No favorites yet!"))
                  : _buildMovieList(favorites),
              SizedBox(height: 20),
              Text("🎬 Watchlist", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              watchlist.isEmpty
                  ? Center(child: Text("No movies in watchlist!"))
                  : _buildMovieList(watchlist),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieList(List<Map<String, dynamic>> movies) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Image.network(
                  "https://image.tmdb.org/t/p/w200${movie['poster_path']}",
                  height: 150,
                ),
                SizedBox(height: 5),
                Text(movie['title'], style: TextStyle(fontSize: 14)),
              ],
            ),
          );
        },
      ),
    );
  }
}
