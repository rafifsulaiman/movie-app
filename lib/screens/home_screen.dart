import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/services/api_service.dart';
import 'package:movie_app/providers/movie_provider.dart';
import 'package:movie_app/providers/auth_provider.dart';
import 'package:movie_app/screens/movie_detail_screen.dart';
import 'package:movie_app/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<dynamic> movies = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        fetchMovies("popular");
      } else if (_tabController.index == 1) {
        fetchMovies("now_playing");
      } else {
        fetchMovies("trending");
      }
    });
    fetchMovies("popular");
  }

  void fetchMovies(String category) async {
    final data = await ApiService.fetchMovies(category);
    setState(() {
      movies = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Movies"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // await authProvider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Popular"),
            Tab(text: "Newest"),
            Tab(text: "Trending"),
          ],
        ),
      ),
      body: movies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.65,
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                final isFav = movieProvider.isFavorite(movie['id']);
                final isWatchlist = movieProvider.isInWatchlist(movie['id']);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          "https://image.tmdb.org/t/p/w500${movie['poster_path']}",
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          movie['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                            onPressed: () => movieProvider.toggleFavorite(movie),
                          ),
                          IconButton(
                            icon: Icon(isWatchlist ? Icons.bookmark : Icons.bookmark_border, color: Colors.blue),
                            onPressed: () => movieProvider.toggleWatchlist(movie),
                          ),
                          IconButton(
                            icon: Icon(Icons.more_horiz, color: Colors.black),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailScreen(movieId: movie['id']),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
