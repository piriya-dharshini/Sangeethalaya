import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class NoteService {
  final DatabaseReference _notesRef =
      FirebaseDatabase.instanceFor(
    app: Firebase.app(),

    // SAME DATABASE URL THAT IS WORKING
    databaseURL:
        'https://sangeethalaya-default-rtdb.asia-southeast1.firebasedatabase.app/',
  ).ref().child('notes');

  // ============================================================
  // ADD NOTE
  // ============================================================

  Future<String> addNote({
    required String songId,
    required String sectionId,
    required String text,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    if (text.trim().isEmpty) {
      throw Exception('Note cannot be empty.');
    }

    final noteRef = _notesRef
        .child(user.uid)
        .child(songId)
        .child(sectionId)
        .push();

    await noteRef.set({
      'text': text.trim(),

      'createdAt': ServerValue.timestamp,

      'updatedAt': ServerValue.timestamp,
    });

    return noteRef.key!;
  }

  // ============================================================
  // GET NOTES FOR ONE SECTION
  // ============================================================

  Future<List<Map<String, dynamic>>> getNotes({
    required String songId,
    required String sectionId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final snapshot = await _notesRef
        .child(user.uid)
        .child(songId)
        .child(sectionId)
        .get();

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final data = Map<dynamic, dynamic>.from(
      snapshot.value as Map,
    );

    final notes = data.entries.map((entry) {
      final note = Map<String, dynamic>.from(
        entry.value as Map,
      );

      note['id'] = entry.key.toString();

      return note;
    }).toList();

    // Newest notes first
    notes.sort((a, b) {
      final aTime = a['createdAt'] ?? 0;
      final bTime = b['createdAt'] ?? 0;

      return (bTime as num).compareTo(aTime as num);
    });

    return notes;
  }

  // ============================================================
  // GET ALL NOTES FOR ONE SONG
  // ============================================================

  Future<Map<String, List<Map<String, dynamic>>>> getSongNotes(
    String songId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final snapshot = await _notesRef
        .child(user.uid)
        .child(songId)
        .get();

    if (!snapshot.exists || snapshot.value == null) {
      return {};
    }

    final data = Map<dynamic, dynamic>.from(
      snapshot.value as Map,
    );

    final Map<String, List<Map<String, dynamic>>> result = {};

    for (final sectionEntry in data.entries) {
      final sectionId = sectionEntry.key.toString();

      final sectionData = Map<dynamic, dynamic>.from(
        sectionEntry.value as Map,
      );

      final notes = sectionData.entries.map((noteEntry) {
        final note = Map<String, dynamic>.from(
          noteEntry.value as Map,
        );

        note['id'] = noteEntry.key.toString();

        return note;
      }).toList();

      notes.sort((a, b) {
        final aTime = a['createdAt'] ?? 0;
        final bTime = b['createdAt'] ?? 0;

        return (bTime as num).compareTo(aTime as num);
      });

      result[sectionId] = notes;
    }

    return result;
  }

  // ============================================================
  // UPDATE NOTE
  // ============================================================

  Future<void> updateNote({
    required String songId,
    required String sectionId,
    required String noteId,
    required String text,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    if (text.trim().isEmpty) {
      throw Exception('Note cannot be empty.');
    }

    await _notesRef
        .child(user.uid)
        .child(songId)
        .child(sectionId)
        .child(noteId)
        .update({
      'text': text.trim(),
      'updatedAt': ServerValue.timestamp,
    });
  }

  // ============================================================
  // DELETE NOTE
  // ============================================================

  Future<void> deleteNote({
    required String songId,
    required String sectionId,
    required String noteId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await _notesRef
        .child(user.uid)
        .child(songId)
        .child(sectionId)
        .child(noteId)
        .remove();
  }
}