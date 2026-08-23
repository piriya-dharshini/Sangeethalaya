import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class SongService {
  final DatabaseReference _songsRef =
      FirebaseDatabase.instanceFor(
    app: Firebase.app(),

    // SAME DATABASE URL THAT IS WORKING
    databaseURL:
        'https://sangeethalaya-default-rtdb.asia-southeast1.firebasedatabase.app/',
  ).ref().child('songs');

  // ============================================================
  // ADD SONG
  // ============================================================

  Future<String> addSong({
    required String title,
    required String type,
    required String raga,
    required String tala,
    required String author,
    required String deity,
    required String lyricsType,
    required Map<String, dynamic> lyrics,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final songRef = _songsRef.push();

    await songRef.set({
      'title': title,
      'type': type,
      'raga': raga,
      'tala': tala,
      'author': author,
      'deity': deity,

      // simple / structured / stanza
      'lyricsType': lyricsType,

      'lyrics': lyrics,

      'createdBy': user.uid,

      'createdAt': ServerValue.timestamp,

      'updatedAt': ServerValue.timestamp,

      'updatedBy': user.uid,
    });

    return songRef.key!;
  }
    // ============================================================
    // EDIT / UPDATE SONG
    // ============================================================

    Future<void> updateSong({
      required String songId,
      required String title,
      required String type,
      required String raga,
      required String tala,
      required String author,
      required String deity,
      required String lyricsType,
      required Map<String, dynamic> lyrics,
    }) async {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User is not logged in.');
      }

      final songRef = _songsRef.child(songId);

      // Get existing song so we can preserve createdBy and createdAt
      final snapshot = await songRef.get();

      if (!snapshot.exists || snapshot.value == null) {
        throw Exception('Song not found.');
      }

      final existingSong = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      // Only the person who created the song can edit it
      if (existingSong['createdBy'] != user.uid) {
        throw Exception('You are not allowed to edit this song.');
      }

      await songRef.update({
        'title': title,
        'type': type,
        'raga': raga,
        'tala': tala,
        'author': author,
        'deity': deity,
        'lyricsType': lyricsType,
        'lyrics': lyrics,

        // Keep track of the edit
        'updatedAt': ServerValue.timestamp,
        'updatedBy': user.uid,
      });
    }

      // ============================================================
      // GET ALL SONGS
      // ============================================================

      Future<List<Map<String, dynamic>>> getSongs() async {
        final snapshot = await _songsRef.get();

        if (!snapshot.exists || snapshot.value == null) {
          return [];
        }

        final data = Map<dynamic, dynamic>.from(
          snapshot.value as Map,
        );

        final songs = data.entries.map((entry) {
          final song = Map<String, dynamic>.from(
            entry.value as Map,
          );

          song['id'] = entry.key.toString();

          return song;
        }).toList();

        // Newest songs first
        songs.sort((a, b) {
          final aTime = a['createdAt'] ?? 0;
          final bTime = b['createdAt'] ?? 0;

          return (bTime as num).compareTo(aTime as num);
        });

        return songs;
      }

      // ============================================================
      // GET ONE SONG
      // ============================================================

      Future<Map<String, dynamic>?> getSong(String songId) async {
        final snapshot = await _songsRef.child(songId).get();

        if (!snapshot.exists || snapshot.value == null) {
          return null;
        }

        final song = Map<String, dynamic>.from(
          snapshot.value as Map,
        );

        // Keep Firebase key
        song['id'] = songId;

        return song;
      }

  // ============================================================
// GET SONG COUNT BY TYPE
// ============================================================

Future<Map<String, int>> getSongCountsByType() async {
  final snapshot = await _songsRef.get();

  if (!snapshot.exists || snapshot.value == null) {
    return {};
  }

  final data = Map<dynamic, dynamic>.from(
    snapshot.value as Map,
  );

  final Map<String, int> counts = {};

  for (final entry in data.entries) {
    final song = Map<dynamic, dynamic>.from(
      entry.value as Map,
    );

    final type = song['type']?.toString();

    if (type != null && type.isNotEmpty) {
      counts[type] = (counts[type] ?? 0) + 1;
    }
  }

  return counts;
}

// ============================================================
// SEARCH SONGS
// ============================================================

Future<List<Map<String, dynamic>>> searchSongs(String query) async {
  final songs = await getSongs();

  // If search box is empty, return all songs
  if (query.trim().isEmpty) {
    return songs;
  }

  final searchQuery = query.trim().toLowerCase();

  return songs.where((song) {
    final title = song['title']?.toString().toLowerCase() ?? '';
    final type = song['type']?.toString().toLowerCase() ?? '';
    final raga = song['raga']?.toString().toLowerCase() ?? '';
    final tala = song['tala']?.toString().toLowerCase() ?? '';
    final author = song['author']?.toString().toLowerCase() ?? '';
    final deity = song['deity']?.toString().toLowerCase() ?? '';

    return title.contains(searchQuery) ||
        type.contains(searchQuery) ||
        raga.contains(searchQuery) ||
        tala.contains(searchQuery) ||
        author.contains(searchQuery) ||
        deity.contains(searchQuery);
  }).toList();
}
}