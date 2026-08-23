import 'package:flutter/material.dart';

import '../main.dart';
import '../services/song_service.dart';
import 'view_song_screen.dart';

class SongLibraryScreen extends StatefulWidget {
  const SongLibraryScreen({super.key});

  @override
  State<SongLibraryScreen> createState() => _SongLibraryScreenState();
}

class _SongLibraryScreenState extends State<SongLibraryScreen> {
  final SongService songService = SongService();

  late Future<List<Map<String, dynamic>>> songsFuture;

  @override
  void initState() {
    super.initState();
    songsFuture = songService.getSongs();
  }

  Future<void> refreshSongs() async {
    setState(() {
      songsFuture = songService.getSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,

      appBar: AppBar(
        title: const Text(
          'SONG LIBRARY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: songsFuture,

        builder: (context, snapshot) {
          // =====================================================
          // LOADING
          // =====================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.gold,
              ),
            );
          }

          // =====================================================
          // ERROR
          // =====================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load songs.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
            );
          }

          final songs = snapshot.data ?? [];

          // =====================================================
          // EMPTY LIBRARY
          // =====================================================

          if (songs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_music_outlined,
                    size: 60,
                    color: AppColors.gold,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'No songs added yet',
                    style: TextStyle(
                      color: AppColors.maroon,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Your music library will appear here.',
                    style: TextStyle(
                      color: AppColors.mutedBrown,
                    ),
                  ),
                ],
              ),
            );
          }

          // =====================================================
          // SONG LIST
          // =====================================================

          return RefreshIndicator(
            color: AppColors.maroon,

            onRefresh: refreshSongs,

            child: ListView.builder(
              padding: const EdgeInsets.all(18),

              itemCount: songs.length,

              itemBuilder: (context, index) {
                final song = songs[index];

                final title =
                    song['title']?.toString() ?? 'Untitled';

                final raga =
                    song['raga']?.toString() ?? '';

                final tala =
                    song['tala']?.toString() ?? '';

                final author =
                    song['author']?.toString() ?? '';

                final subtitle = [
                  if (raga.isNotEmpty) raga,
                  if (tala.isNotEmpty) tala,
                ].join(' • ');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),

                  child: _SongCard(
                    title: title,

                    subtitle: subtitle,

                    author: author.isNotEmpty
                        ? author
                        : 'Unknown Author',

                    // =================================================
                    // CLICK SONG
                    // =================================================

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                              ViewSongScreen(
                            song: song,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// SONG CARD
// ============================================================

class _SongCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String author;
  final VoidCallback? onTap;

  const _SongCard({
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
          width: double.infinity,

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
              // ==================================================
              // MUSIC ICON
              // =======================================S===========

              Container(
                height: 48,
                width: 48,

                decoration: BoxDecoration(
                  color: AppColors.maroon,

                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: const Icon(
                  Icons.music_note,

                  color: AppColors.gold,

                  size: 25,
                ),
              ),

              const SizedBox(width: 13),

              // ==================================================
              // SONG DETAILS
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        color:
                            AppColors.darkBrown,

                        fontSize: 15,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,

                        maxLines: 1,

                        overflow:
                            TextOverflow.ellipsis,

                        style: const TextStyle(
                          color:
                              AppColors.mutedBrown,

                          fontSize: 12,
                        ),
                      ),

                    const SizedBox(height: 3),

                    Text(
                      author,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        color:
                            AppColors.maroon,

                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ==================================================
              // ARROW
              // ==================================================

              const Icon(
                Icons.chevron_right,

                color: AppColors.gold,

                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}