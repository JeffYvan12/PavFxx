import 'package:flutter/material.dart';
import '/models/movie.dart';
import '/services/api_service.dart';

class AddMovieScreen extends StatefulWidget {
  @override
  _AddMovieScreenState createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController directorController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController releaseDateController = TextEditingController();
  final TextEditingController overviewController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController photoUrlController = TextEditingController();
  final TextEditingController videoUrlController = TextEditingController();
  
  final ApiService apiService = ApiService();

  void addMovie(BuildContext context) async {
    // Validate fields
    if (_validateFields()) {
      final movie = Movie(
        id: '',
        title: titleController.text,
        description: descriptionController.text,
        genre: genreController.text,
        releaseDate: releaseDateController.text,
        rating: int.tryParse(ratingController.text) ?? 0,
        director: directorController.text,
        overview: overviewController.text,
        photoUrls: [photoUrlController.text], // Collect photo URLs
        videoUrls: [videoUrlController.text], // Collect video URLs
      );

      try {
        await apiService.addMovie(movie);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Movie added successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add movie: $e")),
        );
      }
    }
  }

  bool _validateFields() {
    if (titleController.text.isEmpty ||
        genreController.text.isEmpty ||
        directorController.text.isEmpty ||
        ratingController.text.isEmpty ||
        releaseDateController.text.isEmpty ||
        overviewController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        photoUrlController.text.isEmpty ||
        videoUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Add Movie",
          style: TextStyle(color: Colors.redAccent, fontSize: 28),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(titleController, 'Title', screenSize),
              SizedBox(height: 15),
              buildTextField(genreController, 'Genre', screenSize),
              SizedBox(height: 15),
              buildTextField(directorController, 'Director', screenSize),
              SizedBox(height: 15),
              buildTextField(ratingController, 'Rating', screenSize, keyboardType: TextInputType.number),
              SizedBox(height: 15),
              buildTextField(releaseDateController, 'Release Date', screenSize),
              SizedBox(height: 15),
              buildTextField(overviewController, 'Overview', screenSize, maxLines: 3),
              SizedBox(height: 15),
              buildTextField(descriptionController, 'Description', screenSize, maxLines: 3),
              SizedBox(height: 15),
              buildTextField(photoUrlController, 'Photo URL', screenSize),
              SizedBox(height: 15),
              buildTextField(videoUrlController, 'Video URL', screenSize),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () => addMovie(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: Text("Add Movie", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String labelText, Size screenSize, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
      ),
    );
  }
}