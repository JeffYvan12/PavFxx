import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = 'User Name'; // Default username
  String _email = 'user@example.com'; // Default email
  String? _profileImage; // Profile image path

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Load saved profile data
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? _username;
      _email = prefs.getString('email') ?? _email;
      _profileImage = prefs.getString('profileImage'); // Load profile image path
    });
  }

  Future<void> _saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _username);
    await prefs.setString('email', _email);
    if (_profileImage != null) {
      await prefs.setString('profileImage', _profileImage!);
    }
  }

  Future<void> _editProfile() async {
    String? newUsername;
    String? newEmail;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newUsername = value; // Update username as user types
                },
                decoration: InputDecoration(hintText: "Enter new username"),
              ),
              TextField(
                onChanged: (value) {
                  newEmail = value; // Update email as user types
                },
                decoration: InputDecoration(hintText: "Enter new email"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );

    // Update state if new values are provided
    if (newUsername != null && newUsername!.isNotEmpty) {
      setState(() {
        _username = newUsername!; // Update the username state
      });
    }
    if (newEmail != null && newEmail!.isNotEmpty) {
      setState(() {
        _email = newEmail!; // Update the email state
      });
    }

    // Save the updated profile data
    await _saveProfileData();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile.path; // Update the profile image path
      });
      await _saveProfileData(); // Save the new profile image
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Your Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white), // Edit icon
            onPressed: _editProfile, // Open edit dialog
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _pickImage, // Pick image when tapped
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[800], // Fallback color
                backgroundImage: _profileImage != null // Check if an image is picked
                    ? AssetImage('assets/images/profile.png') as ImageProvider
                    : Image.asset(
                        'assets/images/profile.png',
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ).image, // Placeholder profile image
              ),
            ),
            SizedBox(height: 20),
            Text(
              _username, // Display current username
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Email: $_email', // Display current email
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Log out or other action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Similar to Netflix red
              ),
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}