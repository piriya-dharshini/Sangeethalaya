import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'services/user_service.dart';
import 'screens/add_song_screen.dart';
import 'screens/song_library_screen.dart';
import 'services/song_service.dart';
import 'screens/view_song_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SangeethalayaApp());
}

// ============================================================
// COLORS
// ============================================================

class AppColors {
  static const maroon = Color(0xFF7B0F1A);
  static const darkMaroon = Color(0xFF520912);
  static const deepMaroon = Color(0xFF43070E);

  static const gold = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFE8C866);

  static const ivory = Color(0xFFFFF8EA);
  static const cream = Color(0xFFF8EEDB);

  static const darkBrown = Color(0xFF3A2A21);
  static const mutedBrown = Color(0xFF765C4A);

  static const olive = Color(0xFF556B2F);
}

// ============================================================
// APP
// ============================================================

class SangeethalayaApp extends StatelessWidget {
  const SangeethalayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sangeethalaya',

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: AppColors.ivory,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.maroon,
          primary: AppColors.maroon,
          secondary: AppColors.gold,
          surface: AppColors.ivory,
        ),

        fontFamily: 'serif',

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.maroon,
          foregroundColor: AppColors.ivory,
          elevation: 0,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.ivory,

          labelStyle: const TextStyle(
            color: AppColors.mutedBrown,
          ),

          hintStyle: const TextStyle(
            color: AppColors.mutedBrown,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFD9C29A),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.gold,
              width: 1.5,
            ),
          ),
        ),
      ),

      home: const AuthGate(),
    );
  }
}

// ============================================================
// AUTH GATE
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // ----------------------------------------------------------
        // Firebase is checking authentication status
        // ----------------------------------------------------------
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // ----------------------------------------------------------
        // User is NOT logged in
        // ----------------------------------------------------------
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // ----------------------------------------------------------
        // User IS logged in
        // ----------------------------------------------------------
        final firebaseUser = snapshot.data!;

        return FutureBuilder(
          future: UserService().getUser(firebaseUser.uid),

          builder: (context, userSnapshot) {
            // Database is loading
            if (userSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const SplashScreen();
            }

            // Something went wrong / user profile doesn't exist
            if (userSnapshot.hasError || !userSnapshot.hasData) {
              return const Scaffold(
                backgroundColor: AppColors.ivory,
                body: Center(
                  child: Text(
                    'Unable to load your profile.',
                    style: TextStyle(
                      color: AppColors.darkBrown,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }

            final user = userSnapshot.data!;

            // ------------------------------------------------------
            // ADMIN
            // ------------------------------------------------------
            if (user.isAdmin) {
              return HomeScreen(
                userName: user.name,
                isAdmin: true,
              );
            }

            // ------------------------------------------------------
            // NORMAL USER
            // ------------------------------------------------------
            return HomeScreen(
              userName: user.name,
              isAdmin: false,
            );
          },
        );
      },
    );
  }
}

// ============================================================
// SPLASH SCREEN
// ============================================================

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.maroon,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              color: AppColors.gold,
              size: 60,
            ),

            SizedBox(height: 20),

            Text(
              'SANGEETHALAYA',
              style: TextStyle(
                color: AppColors.ivory,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Carnatic Music Library',
              style: TextStyle(
                color: AppColors.lightGold,
                fontSize: 15,
                letterSpacing: 1,
              ),
            ),

            SizedBox(height: 40),

            CircularProgressIndicator(
              color: AppColors.gold,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  final String userName;
  final bool isAdmin;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.isAdmin,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  final TextEditingController _searchController =
      TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];

  bool _isSearching = false;
  bool _searchLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchSongs(String query) async {
  query = query.trim();

  if (query.isEmpty) {
    setState(() {
      _isSearching = false;
      _searchResults = [];
      _searchLoading = false;
    });
    return;
  }

  setState(() {
    _isSearching = true;
    _searchLoading = true;
  });

  try {
    final results = await SongService().searchSongs(query);

    if (!mounted) return;

    setState(() {
      _searchResults = results;
      _searchLoading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _searchResults = [];
      _searchLoading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,

      appBar: AppBar(
        backgroundColor: AppColors.maroon,

        title: const Text(
          'SANGEETHALAYA',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),

        actions: [

          PopupMenuButton<String>(
            icon: const Icon(
              Icons.account_circle_outlined,
              color: AppColors.ivory,
            ),

            onSelected: (value) {
              if (value == 'logout') {
                logout();
              }
            },

            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),

      body: _buildHome(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,

        onTap: (index) {
          // Add Song
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddSongScreen(),
              ),
            );
            return;
          }

          // Library
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SongLibraryScreen(),
              ),
            );
            return;
          }

            setState(() {
              selectedIndex = index;
            });
          },

        selectedItemColor: AppColors.maroon,
        unselectedItemColor: AppColors.mutedBrown,

        backgroundColor: AppColors.ivory,

        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_outlined),
            activeIcon: Icon(Icons.library_music),
            label: 'Library',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),

        ],
      ),
    );
  }

  Widget _buildSearchResults() {
  if (_searchLoading) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(
          color: AppColors.gold,
        ),
      ),
    );
  }

  if (_searchResults.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        'No songs found.',
        style: TextStyle(
          color: AppColors.mutedBrown,
        ),
      ),
    );
  }

  return Column(
    children: _searchResults.map((song) {
      return SongCard(
        title: song['title']?.toString() ?? 'Untitled',

        subtitle:
            '${song['raga']?.toString() ?? 'Unknown Raga'} • '
            '${song['tala']?.toString() ?? 'Unknown Tala'}',

        author:
            song['author']?.toString() ?? 'Unknown Author',

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewSongScreen(
                song: song,
              ),
            ),
          );
        },
      );
    }).toList(),
  );
}
  // ==========================================================
  // HOME CONTENT
  // ==========================================================

  Widget _buildRecentlyAdded() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: SongService().getSongs(),

    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              color: AppColors.gold,
            ),
          ),
        );
      }

      if (snapshot.hasError) {
        return const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Unable to load recently added songs.',
            style: TextStyle(
              color: AppColors.mutedBrown,
            ),
          ),
        );
      }

      final songs = snapshot.data ?? [];

      if (songs.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'No songs have been added yet.',
            style: TextStyle(
              color: AppColors.mutedBrown,
            ),
          ),
        );
      }

      return Column(
        children: songs.take(5).map((song) {
          return SongCard(
            title: song['title']?.toString() ?? 'Untitled',

            subtitle:
                '${song['raga']?.toString() ?? 'Unknown Raga'} • '
                '${song['tala']?.toString() ?? 'Unknown Tala'}',

            author:
                song['author']?.toString() ?? 'Unknown Author',

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewSongScreen(
                    song: song,
                  ),
                ),
              );
            },
          );
        }).toList(),
      );
    },
  );
}
  Widget _buildHome() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          18,
          20,
          18,
          100,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // --------------------------------------------------
            // WELCOME
            // --------------------------------------------------

            const Text(
              'Namaskaram 🙏',
              style: TextStyle(
                color: AppColors.mutedBrown,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Discover. Learn. Preserve.',
              style: TextStyle(
                color: AppColors.maroon,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'The richness of Carnatic Music',
              style: TextStyle(
                color: AppColors.darkBrown,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // SEARCH
            // --------------------------------------------------

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE1CFA7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: TextField(
                controller: _searchController,

                onChanged: (value) {
                  setState(() {});
                  _searchSongs(value);
                },

                decoration: InputDecoration(
                  hintText: 'Search songs, ragas, talas...',

                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.maroon,
                  ),

                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.mutedBrown,
                          ),
                          onPressed: () {
                            _searchController.clear();

                            setState(() {
                              _isSearching = false;
                              _searchResults = [];
                            });
                          },
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.tune,
                            color: AppColors.gold,
                          ),
                          onPressed: () {},
                        ),

                  border: InputBorder.none,

                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // --------------------------------------------------
            // DECORATIVE DIVIDER
            // --------------------------------------------------

            const RoyalDivider(),

            const SizedBox(height: 22),
            // --------------------------------------------------
            // RECENTLY ADDED
            // --------------------------------------------------

            SectionTitle(
              title: _isSearching ? 'Search Results' : 'Recently Added',
              action: _isSearching ? '' : 'View All',
            ),


          const SizedBox(height: 12),

          if (_isSearching)
            _buildSearchResults()
          else
            _buildRecentlyAdded(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ROYAL DIVIDER
// ============================================================

class RoyalDivider extends StatelessWidget {
  const RoyalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.gold,
            thickness: 0.7,
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: const Text(
            '✦',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 20,
            ),
          ),
        ),

        const Expanded(
          child: Divider(
            color: AppColors.gold,
            thickness: 0.7,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class SectionTitle extends StatelessWidget {
  final String title;
  final String action;

  const SectionTitle({
    super.key,
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.darkBrown,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        TextButton(
          onPressed: () {},
          child: Text(
            action,
            style: const TextStyle(
              color: AppColors.maroon,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SONG CARD
// ============================================================

class SongCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String author;
  final VoidCallback? onTap;

  const SongCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.author,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(14),

        child: Container(
          margin: const EdgeInsets.only(bottom: 10),

          padding: const EdgeInsets.all(13),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(14),

            border: Border.all(
              color: const Color(0xFFE3D2AD),
            ),
          ),

          child: Row(
            children: [
              // ------------------------------------------------
              // MUSIC ICON
              // ------------------------------------------------

              Container(
                height: 48,
                width: 48,

                decoration: BoxDecoration(
                  color: AppColors.maroon,
                  borderRadius: BorderRadius.circular(10),
                ),

                child: const Icon(
                  Icons.music_note,
                  color: AppColors.gold,
                  size: 25,
                ),
              ),

              const SizedBox(width: 13),

              // ------------------------------------------------
              // SONG DETAILS
              // ------------------------------------------------

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: const TextStyle(
                        color: AppColors.darkBrown,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,

                      style: const TextStyle(
                        color: AppColors.mutedBrown,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      author,

                      style: const TextStyle(
                        color: AppColors.maroon,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------
              // ARROW
              // ------------------------------------------------

              const Icon(
                Icons.chevron_right,
                color: AppColors.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}