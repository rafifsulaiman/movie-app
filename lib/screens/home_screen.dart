import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/services/api_service.dart';
import 'package:movie_app/providers/movie_provider.dart';
import 'package:movie_app/screens/movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<dynamic> movies = [];
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();
  bool isSearching = false; 
  String searchQuery = ""; 
  String currentCategory = "popular"; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        currentCategory = "popular";
      } else if (_tabController.index == 1) {
        currentCategory = "now_playing";
      } else {
        currentCategory = "trending";
      }

      if (isSearching) {
        searchMovies(searchQuery);
      } else {
        fetchMovies();
      }
    });

    fetchMovies();
  }

  void fetchMovies() async {
    final data = await ApiService.fetchMovies(currentCategory);
    setState(() {
      movies = data;
    });
  }

  void searchMovies(String query) async {
    searchQuery = query;

    if (query.isEmpty) {
      setState(() {
        isSearching = false;
      });
      fetchMovies();
    } else {
      final data = await ApiService.searchMovies(query, currentCategory);
      setState(() {
        movies = data;
        isSearching = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.indigo[900], // ✅ Background navy
      appBar: AppBar(
        backgroundColor: Colors.indigo[800], // ✅ AppBar navy gelap
        title: Text("Movies", style: TextStyle(color: Colors.white)), // ✅ Teks putih
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search movies...",
                    hintStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.indigo[700], // ✅ Warna lebih gelap untuk input
                    filled: true,
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: Colors.white), // ✅ Teks putih
                  onChanged: searchMovies,
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: Colors.white, // ✅ Teks putih
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: "Popular"),
                  Tab(text: "Newest"),
                  Tab(text: "Trending"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: movies.isEmpty
          ? Center(child: CircularProgressIndicator(color: Colors.white)) // ✅ Warna loading
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
                  color: Colors.indigo[800], // ✅ Card lebih gelap
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
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), // ✅ Teks putih
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
                            icon: Icon(Icons.more_horiz, color: Colors.white), // ✅ Icon putih
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
    _searchController.dispose();
    super.dispose();
  }
}
