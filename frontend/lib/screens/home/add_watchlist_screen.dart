import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/watchlist.dart';
import '/models/movie.dart';

class AddWatchlistScreen extends StatefulWidget {
  final String userId;

  const AddWatchlistScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddWatchlistScreenState createState() => _AddWatchlistScreenState();
}

class _AddWatchlistScreenState extends State<AddWatchlistScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  List<Movie> _availableMovies = [];
  List<String> _selectedMovieIds = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableMovies();
  }

  Future<void> _fetchAvailableMovies() async {
    try {
      final moviesSnapshot = await _firestore.collection('movies').get();
      setState(() {
        _availableMovies = moviesSnapshot.docs
            .map((doc) => Movie.fromSnapshot(doc))
            .toList();
      });
    } catch (e) {
      _showErrorSnackBar("Failed to load movies: $e");
    }
  }

  Future<void> _addWatchlist() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar("Watchlist name cannot be empty");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create watchlist document in Firestore
      final watchlistRef = _firestore.collection('watchlists').doc();
      
      final watchlist = Watchlist(
        userId: widget.userId,
        name: _nameController.text.trim(),
        movieIds: _selectedMovieIds,
      );

      await watchlistRef.set(watchlist.toMap());

      if (mounted) {
        Navigator.pop(context, watchlist);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Watchlist created successfully")),
        );
      }
    } catch (e) {
      _showErrorSnackBar("Failed to create watchlist: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Add Watchlist",
          style: TextStyle(color: Colors.redAccent, fontSize: 28),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField(_nameController, 'Watchlist Name'),
            const SizedBox(height: 20),
            _buildMovieSelection(),
            const SizedBox(height: 20),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0), 
          borderSide: BorderSide.none
        ),
      ),
    );
  }

  Widget _buildMovieSelection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: _availableMovies.isEmpty
        ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
        : ListView.builder(
            itemCount: _availableMovies.length,
            itemBuilder: (context, index) {
              final movie = _availableMovies[index];
              final isSelected = _selectedMovieIds.contains(movie.id);
              
              return CheckboxListTile(
                title: Text(
                  movie.title,
                  style: const TextStyle(color: Colors.white),
                ),
                value: isSelected,
                activeColor: Colors.redAccent,
                checkColor: Colors.white,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedMovieIds.add(movie.id);
                    } else {
                      _selectedMovieIds.remove(movie.id);
                    }
                  });
                },
              );
            },
          ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _addWatchlist,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      child: _isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: Colors.white)
          )
        : const Text("Create Watchlist"),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}