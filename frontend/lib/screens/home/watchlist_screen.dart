import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/api_service.dart';

class WatchlistScreen extends StatefulWidget {
  final String userId;

  WatchlistScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final ApiService apiService = ApiService();
  late Stream<List<Movie>> watchlist;

  @override
  void initState() {
    super.initState();
    watchlist = apiService.getWatchlist(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Watchlist"),
      ),
      body: StreamBuilder<List<Movie>>(
        stream: watchlist,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading watchlist"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Your watchlist is empty"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final movie = snapshot.data![index];
                return ListTile(
                  title: Text(movie.title),
                  subtitle: Text(movie.description),
                  // Additional movie details can be added here
                );
              },
            );
          }
        },
      ),
    );
  }
}