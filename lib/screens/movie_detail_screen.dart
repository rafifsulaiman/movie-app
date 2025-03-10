import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/movie_provider.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;
  const MovieDetailScreen({required this.movieId});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic>? movie;
  List<dynamic> castList = [];
  List<dynamic> reviews = [];
  List<dynamic> videos = [];
  bool showFullSynopsis = false;
  Map<int, bool> showFullReview = {};

  @override
  void initState() {
    super.initState();
    loadMovieDetail();
    loadCast();
    loadReviews();
    loadVideos();
  }

  void loadMovieDetail() async {
    final url = Uri.parse("https://api.themoviedb.org/3/movie/${widget.movieId}?api_key=fe8867a1b16497806297d997a54901c3");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        movie = json.decode(response.body);
      });
    }
  }

  void loadCast() async {
    final url = Uri.parse("https://api.themoviedb.org/3/movie/${widget.movieId}/credits?api_key=fe8867a1b16497806297d997a54901c3");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        castList = data['cast'].take(10).toList();
      });
    }
  }

  void loadReviews() async {
    final url = Uri.parse("https://api.themoviedb.org/3/movie/${widget.movieId}/reviews?api_key=fe8867a1b16497806297d997a54901c3");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        reviews = data['results'];
        for (var i = 0; i < reviews.length; i++) {
          showFullReview[i] = false;
        }
      });
    }
  }

  void loadVideos() async {
    final url = Uri.parse("https://api.themoviedb.org/3/movie/${widget.movieId}/videos?api_key=fe8867a1b16497806297d997a54901c3");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        videos = data['results'].where((video) => video['site'] == 'YouTube').toList();
      });
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 7.0) {
      return Colors.green;
    } else if (score >= 5.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // final isFav = movieProvider.isFavorite(movie!['id']);
    // final isWatchlist = movieProvider.isInWatchlist(movie!['id']);
    final double userScore = (movie!['vote_average'] ?? 0).toDouble();

    return Scaffold(
      appBar: AppBar(title: Text(movie!['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    "https://image.tmdb.org/t/p/w200${movie!['poster_path']}",
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie!['title'],
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Release Date: ${movie!['release_date']}",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 16),

                      // 🎯 USER SCORE (CIRCULAR PROGRESS INDICATOR)
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  value: userScore / 10,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(userScore)),
                                  strokeWidth: 5,
                                ),
                              ),
                              Text(
                                userScore.toStringAsFixed(1),
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _getScoreColor(userScore)),
                              ),
                            ],
                          ),
                          SizedBox(width: 8),
                          Text("User Score", style: TextStyle(fontSize: 14,  color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Synopsis",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,  color: Colors.white),
            ),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                          Text(
                            showFullSynopsis 
                              ? movie!['overview'] 
                              : (movie!['overview'].length > 150 
                                  ? "${movie!['overview'].substring(0, 150)}..." 
                                  : movie!['overview']
                                ),
                            textAlign: TextAlign.justify,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          if (movie!['overview'].length > 150)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showFullSynopsis = !showFullSynopsis;
                                });
                              },
                              child: Text(
                                showFullSynopsis ? "Read Less" : "Read More",
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ),
                    SizedBox(height: 16),
                    Text(
                      "Cast",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    castList.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: castList.length,
                              itemBuilder: (context, index) {
                                final cast = castList[index];
                                return Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          cast['profile_path'] != null
                                              ? "https://image.tmdb.org/t/p/w200${cast['profile_path']}"
                                              : "https://via.placeholder.com/100",
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        cast['name'],
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                    SizedBox(height: 16),

                    Text("Videos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 8),
                      videos.isEmpty
                          ? Text("No videos available.")
                          : Column(
                              children: videos.map((video) {
                                return ListTile(
                                  leading: Icon(Icons.play_circle_fill, color: Colors.red),
                                  title: Text(video['name'], style: TextStyle(color: Colors.grey)),
                                  onTap: () async {
                                    final url = "https://www.youtube.com/watch?v=${video['key']}";
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                      SizedBox(height: 16),

                      // 📝 REVIEWS SECTION
                      Text("Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 8),
                      reviews.isEmpty
                          ? Text("No reviews available.")
                          : Column(
                              children: reviews.asMap().entries.map((entry) {
                      int index = entry.key;
                      var review = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review['author'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          SizedBox(height: 4),
                          Text(
                            showFullReview[index]! 
                              ? review['content'] 
                              : (review['content'].length > 100 
                                  ? "${review['content'].substring(0, 100)}..." 
                                  : review['content']
                                ),
                            textAlign: TextAlign.justify,
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () => setState(() => showFullReview[index] = !showFullReview[index]!),
                            child: Text(showFullReview[index]! ? "Read Less" : "Read More", style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      );
                    }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    movieProvider.favorites.contains(widget.movieId) ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () => movieProvider.toggleFavorite(movie!),
                ),
                IconButton(
                  icon: Icon(
                    movieProvider.watchlist.contains(widget.movieId) ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.red,
                  ),
                  onPressed: () => movieProvider.toggleWatchlist(movie!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
