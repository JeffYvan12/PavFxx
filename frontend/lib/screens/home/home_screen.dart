import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/movie.dart';
import '../../models/notification.dart';
import '../../widgets/netflix_card.dart';
import '../../services/api_service.dart';
import 'add_movie_screen.dart';
import 'add_watchlist_screen.dart';
import 'profile_screen.dart';
import '../../screens/superscreen/downloadscreen.dart';
//import 'download_screen.dart';
import 'movie_details_screen.dart';
import '../../widgets/netflix_app_bar.dart';

// Theme provider to manage dark mode state
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class HomeScreen extends StatefulWidget {
  final String userId;

  HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Stream<List<Movie>> movies;
  List<NotificationModel> notifications = [];
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> downloadedMovies = [];

  @override
  void initState() {
    super.initState();
    movies = apiService.getAllMovies();
    _fetchNotifications();
  }

  void _fetchNotifications() {
    FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      notifications = snapshot.docs.map((doc) {
        return NotificationModel(
          id: doc.id,
          movieTitle: doc['movieTitle'],
          message: doc['message'],
          date: (doc['date'] as Timestamp).toDate(),
        );
      }).toList();
      setState(() {});
    });
  }

  void _deleteNotification(String notificationId) {
    FirebaseFirestore.instance.collection('notifications').doc(notificationId).delete();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddMovieScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddWatchlistScreen(userId: widget.userId)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DownloadScreen(filePath:'',title:'',movie:Movie(id:'', title: '', description: '', genre: '', releaseDate: '', rating: 0, director: '', overview: '', photoUrls: [], videoUrls: []))),
        );
        break;
     
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationsScreen(notifications: notifications)),
        );
        break;
    }
  }

  void _searchMovies() async {
    String? searchQuery = await showSearch(
      context: context,
      delegate: MovieSearchDelegate(apiService),
    );
    if (searchQuery != null) {
      print("Searching for: $searchQuery");
    }
  }

  void _downloadMovie(String title) {
    setState(() {
      downloadedMovies.add(title);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("$title downloaded!"),
    ));
  }



  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color primaryColor = Colors.red;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NetflixAppBar()),
            );
          },
          child: Text(
            'PavFlix',
            style: TextStyle(
              color: isDarkMode ? Colors.red : Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: textColor),
            onPressed: _searchMovies,
          ),
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications, color: textColor),
                if (notifications.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${notifications.length}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen(notifications: notifications)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.menu, color: textColor),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: textColor, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: primaryColor),
              title: Text('Settings', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: primaryColor),
              title: Text('User Profile', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: primaryColor),
              title: Text('Notifications', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsScreen(notifications: notifications)),
                );
              },
            ),
            ListTile(
              leading: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: primaryColor,
              ),
              title: Text('Dark Mode', style: TextStyle(color: textColor)),
              trailing: Switch(
                value: !isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleDarkMode();
                },
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Movie>>(
        stream: movies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: textColor)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No movies found", style: TextStyle(color: textColor)));
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: snapshot.data!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,                // Number of columns
                  childAspectRatio: 0.75,           // Aspect ratio of each item
                  crossAxisSpacing: 10.0,           // Spacing between columns
                  mainAxisSpacing: 10.0,            // Spacing between rows
                ),
                itemBuilder: (context, index) {
                  final movie = snapshot.data![index];
                  return NetflixCard(
                    movie: movie,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailsScreen(
                            movie: movie,
                            onDownload: _downloadMovie,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDarkMode ? const Color.fromARGB(255, 24, 18, 18) : Colors.black54,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: textColor),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie, color: textColor),
            label: 'Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark, color: textColor),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download, color: textColor),
            label: 'Downloads',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, color: textColor),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}

// NotificationsScreen to display notifications
class NotificationsScreen extends StatelessWidget {
  final List<NotificationModel> notifications;

  const NotificationsScreen({Key? key, required this.notifications}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? Center(child: Text('No notifications available.'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  title: Text(notification.message),
                  subtitle: Text('${notification.movieTitle} - ${notification.date.toLocal()}'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Notification Details'),
                        content: Text('Movie: ${notification.movieTitle}\n'
                            'Message: ${notification.message}\n'
                            'Date: ${notification.date.toLocal()}'),
                        actions: [
                          TextButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// Search Delegate for movies
class MovieSearchDelegate extends SearchDelegate<String> {
  final ApiService apiService;

  MovieSearchDelegate(this.apiService);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    return FutureBuilder<List<Movie>>(
      future: apiService.searchMovies(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No results found", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final movie = snapshot.data![index];
              return ListTile(
                title: Text(movie.title, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                onTap: () {
                  close(context, movie.title);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailsScreen(movie: movie, onDownload: (title) {}),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // Suggestions can be implemented if needed
  }
}

// Main function to set up the provider
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MaterialApp(
        home: HomeScreen(userId: 'user123'),
      ),
    ),
  );
}