import 'package:flutter/material.dart';

import '../main.dart';
import '../services/notes_service.dart';
import 'edit_song_screen.dart';

class ViewSongScreen extends StatefulWidget {
  final Map<String, dynamic> song;

  const ViewSongScreen({
    super.key,
    required this.song,
  });

  @override
  State<ViewSongScreen> createState() => _ViewSongScreenState();
}

class _ViewSongScreenState extends State<ViewSongScreen> {
  final NoteService _noteService = NoteService();

  // ============================================================
  // NOTES
  // ============================================================

  Map<String, List<Map<String, dynamic>>> _notes = {};

  bool _notesLoading = true;

  // ============================================================
  // HELPERS
  // ============================================================

  String get songId =>
      widget.song['id']?.toString() ?? '';

  String get title =>
      widget.song['title']?.toString() ?? 'Untitled Song';

  String get type =>
      widget.song['type']?.toString() ?? '';

  String get raga =>
      widget.song['raga']?.toString() ?? '';

  String get tala =>
      widget.song['tala']?.toString() ?? '';

  String get author =>
      widget.song['author']?.toString() ?? '';

  String get deity =>
      widget.song['deity']?.toString() ?? '';

  String get lyricsType =>
      widget.song['lyricsType']?.toString() ?? 'simple';

  Map<String, dynamic> get lyrics {
    final value = widget.song['lyrics'];

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  // ============================================================
  // LOAD NOTES
  // ============================================================

  Future<void> loadNotes() async {
    if (songId.isEmpty) {
      setState(() {
        _notesLoading = false;
      });
      return;
    }

    try {
      final notes = await _noteService.getSongNotes(songId);

      if (!mounted) return;

      setState(() {
        _notes = notes;
        _notesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _notesLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load notes: $e'),
        ),
      );
    }
  }

  // ============================================================
  // ADD NOTE
  // ============================================================

  Future<void> addNote(String sectionId) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.ivory,

          title: const Text(
            'Add Note',
            style: TextStyle(
              color: AppColors.maroon,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: TextField(
            controller: controller,
            maxLines: 5,
            autofocus: true,

            decoration: InputDecoration(
              hintText: 'Write your note...',
              filled: true,
              fillColor: Colors.white,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE0C992),
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

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.mutedBrown,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: AppColors.ivory,
              ),

              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(
                  context,
                  controller.text.trim(),
                );
              },

              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.trim().isEmpty) {
      return;
    }

    try {
      await _noteService.addNote(
        songId: songId,
        sectionId: sectionId,
        text: result,
      );

      await loadNotes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note added successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to add note: $e'),
        ),
      );
    }
  }

  // ============================================================
  // EDIT NOTE
  // ============================================================

  Future<void> editNote({
    required String sectionId,
    required Map<String, dynamic> note,
  }) async {
    final controller = TextEditingController(
      text: note['text']?.toString() ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.ivory,

          title: const Text(
            'Edit Note',
            style: TextStyle(
              color: AppColors.maroon,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: TextField(
            controller: controller,
            maxLines: 5,
            autofocus: true,

            decoration: InputDecoration(
              hintText: 'Edit your note...',
              filled: true,
              fillColor: Colors.white,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.mutedBrown,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: AppColors.ivory,
              ),

              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(
                  context,
                  controller.text.trim(),
                );
              },

              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.trim().isEmpty) {
      return;
    }

    try {
      await _noteService.updateNote(
        songId: songId,
        sectionId: sectionId,
        noteId: note['id'].toString(),
        text: result,
      );

      await loadNotes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note updated successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update note: $e'),
        ),
      );
    }
  }

  // ============================================================
  // DELETE NOTE
  // ============================================================

  Future<void> deleteNote({
    required String sectionId,
    required Map<String, dynamic> note,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.ivory,

          title: const Text(
            'Delete Note?',
            style: TextStyle(
              color: AppColors.maroon,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: const Text(
            'Are you sure you want to delete this note?',
            style: TextStyle(
              color: AppColors.darkBrown,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.mutedBrown,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: AppColors.ivory,
              ),

              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _noteService.deleteNote(
        songId: songId,
        sectionId: sectionId,
        noteId: note['id'].toString(),
      );

      await loadNotes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note deleted.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to delete note: $e'),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,

      appBar: AppBar(
        backgroundColor: AppColors.maroon,
        foregroundColor: AppColors.ivory,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'SONG LYRICS',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Edit Song',

            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.gold,
            ),

            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditSongScreen(
                    song: widget.song,
                  ),
                ),
              );

              // Song was edited.
              if (updated == true && mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            24,
            18,
            40,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              buildSongHeader(),

              const SizedBox(height: 24),

              const RoyalDivider(),

              const SizedBox(height: 28),

              if (_notesLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: AppColors.gold,
                    ),
                  ),
                )
              else
                buildLyrics(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SONG HEADER
  // ============================================================

  Widget buildSongHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        22,
      ),

      decoration: BoxDecoration(
        color: AppColors.cream,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: AppColors.gold,
          width: 1.2,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,

            decoration: const BoxDecoration(
              color: AppColors.maroon,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.music_note,
              color: AppColors.gold,
              size: 29,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: AppColors.maroon,
              fontSize: 27,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          if (type.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),

              decoration: BoxDecoration(
                color: AppColors.maroon,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Text(
                type.toUpperCase(),

                style: const TextStyle(
                  color: AppColors.ivory,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

          const SizedBox(height: 20),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,

            children: [
              if (raga.isNotEmpty)
                buildDetailChip(
                  icon: Icons.auto_awesome,
                  label: 'Raga',
                  value: raga,
                ),

              if (tala.isNotEmpty)
                buildDetailChip(
                  icon: Icons.access_time,
                  label: 'Tala',
                  value: tala,
                ),

              if (author.isNotEmpty)
                buildDetailChip(
                  icon: Icons.person_outline,
                  label: 'Author',
                  value: author,
                ),

              if (deity.isNotEmpty)
                buildDetailChip(
                  icon: Icons.temple_hindu,
                  label: 'Dedicated To',
                  value: deity,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL CHIP
  // ============================================================

  Widget buildDetailChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 130,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),

      decoration: BoxDecoration(
        color: AppColors.ivory,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(
          color: const Color(0xFFE0C992),
        ),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(
            icon,
            size: 17,
            color: AppColors.maroon,
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                label,

                style: const TextStyle(
                  color: AppColors.mutedBrown,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 1),

              Text(
                value,

                style: const TextStyle(
                  color: AppColors.darkBrown,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LYRICS ROUTER
  // ============================================================

  Widget buildLyrics() {
    switch (lyricsType) {
      case 'structured':
        return buildStructuredLyrics();

      case 'stanza':
        return buildStanzaLyrics();

      case 'simple':
      default:
        return buildSimpleLyrics();
    }
  }

  // ============================================================
  // SIMPLE LYRICS
  // ============================================================

  Widget buildSimpleLyrics() {
    final text =
        lyrics['text']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        buildLyricsHeading(
          'Lyrics',
          Icons.menu_book_outlined,
        ),

        const SizedBox(height: 16),

        buildSimpleLyricsCard(
          text,
          sectionId: 'simple',
        ),
      ],
    );
  }

  // ============================================================
  // STRUCTURED LYRICS
  // ============================================================

  Widget buildStructuredLyrics() {
    final pallavi =
        lyrics['pallavi']?.toString() ?? '';

    final anupallavi =
        lyrics['anupallavi']?.toString() ?? '';

    final rawCharanams =
        lyrics['charanams'];

    List<dynamic> charanams = [];

    if (rawCharanams is List) {
      charanams = rawCharanams;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        buildLyricsHeading(
          'Lyrics',
          Icons.menu_book_outlined,
        ),

        const SizedBox(height: 18),

        // ======================================================
        // PALLAVI
        // ======================================================

        if (pallavi.isNotEmpty)
          buildLyricsSection(
            title: 'Pallavi',
            text: pallavi,
            sectionId: 'pallavi',
          ),

        // ======================================================
        // ANUPALLAVI
        // ======================================================

        if (anupallavi.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              top: 18,
            ),

            child: buildLyricsSection(
              title: 'Anupallavi',
              text: anupallavi,
              sectionId: 'anupallavi',
            ),
          ),

        // ======================================================
        // CHARANAMS
        // ======================================================

        ...List.generate(
          charanams.length,
          (index) {
            final charanam =
                charanams[index].toString();

            if (charanam.trim().isEmpty) {
              return const SizedBox();
            }

            return Padding(
              padding: const EdgeInsets.only(
                top: 18,
              ),

              child: buildLyricsSection(
                title: 'Charanam ${index + 1}',
                text: charanam,

                // VERY IMPORTANT
                // This creates:
                // charanam_1
                // charanam_2
                // charanam_3
                sectionId: 'charanam_${index + 1}',
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // STANZA BASED LYRICS
  // ============================================================

  Widget buildStanzaLyrics() {
    final rawStanzas =
        lyrics['stanzas'];

    List<dynamic> stanzas = [];

    if (rawStanzas is List) {
      stanzas = rawStanzas;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        buildLyricsHeading(
          'Lyrics',
          Icons.menu_book_outlined,
        ),

        const SizedBox(height: 18),

        ...List.generate(
          stanzas.length,
          (index) {
            final stanza =
                stanzas[index].toString();

            if (stanza.trim().isEmpty) {
              return const SizedBox();
            }

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 18,
              ),

              child: buildLyricsSection(
                title: 'Stanza ${index + 1}',
                text: stanza,

                // VERY IMPORTANT
                sectionId: 'stanza_${index + 1}',
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // LYRICS HEADING
  // ============================================================

  Widget buildLyricsHeading(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,

          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(10),

            border: Border.all(
              color: AppColors.gold,
            ),
          ),

          child: Icon(
            icon,
            color: AppColors.maroon,
            size: 21,
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,

          style: const TextStyle(
            color: AppColors.darkBrown,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LYRICS SECTION + NOTES
  // ============================================================

  Widget buildLyricsSection({
    required String title,
    required String text,
    required String sectionId,
  }) {
    final sectionNotes =
        _notes[sectionId] ?? [];

    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(15),

        border: Border.all(
          color: const Color(0xFFE0C992),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ====================================================
          // SECTION TITLE
          // ====================================================

          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 11,
            ),

            decoration: const BoxDecoration(
              color: AppColors.cream,

              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),

            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,

                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    title,

                    style: const TextStyle(
                      color: AppColors.maroon,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),

                // ADD NOTE BUTTON
                InkWell(
                  borderRadius: BorderRadius.circular(20),

                  onTap: () {
                    addNote(sectionId);
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: AppColors.maroon,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Icon(
                          Icons.edit_note,
                          color: AppColors.gold,
                          size: 17,
                        ),

                        SizedBox(width: 4),

                        Text(
                          'Add Note',
                          style: TextStyle(
                            color: AppColors.ivory,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // ACTUAL LYRICS
          // ====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              20,
            ),

            child: Text(
              text,

              style: const TextStyle(
                color: AppColors.darkBrown,
                fontSize: 16,
                height: 1.75,
                letterSpacing: 0.2,
              ),
            ),
          ),

          // ====================================================
          // NOTES
          // ====================================================

          if (sectionNotes.isNotEmpty)
            buildNotesArea(
              sectionId: sectionId,
              notes: sectionNotes,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SIMPLE LYRICS CARD
  // ============================================================

  Widget buildSimpleLyricsCard(
    String text, {
    required String sectionId,
  }) {
    final sectionNotes =
        _notes[sectionId] ?? [];

    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(15),

        border: Border.all(
          color: const Color(0xFFE0C992),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              10,
            ),

            child: Text(
              text,

              style: const TextStyle(
                color: AppColors.darkBrown,
                fontSize: 16,
                height: 1.75,
                letterSpacing: 0.2,
              ),
            ),
          ),

          // Add note button for simple lyrics
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              4,
              20,
              15,
            ),

            child: Align(
              alignment: Alignment.centerRight,

              child: TextButton.icon(
                onPressed: () {
                  addNote(sectionId);
                },

                icon: const Icon(
                  Icons.edit_note,
                  color: AppColors.maroon,
                  size: 20,
                ),

                label: const Text(
                  'Add Note',
                  style: TextStyle(
                    color: AppColors.maroon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          if (sectionNotes.isNotEmpty)
            buildNotesArea(
              sectionId: sectionId,
              notes: sectionNotes,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTES AREA
  // ============================================================

  Widget buildNotesArea({
    required String sectionId,
    required List<Map<String, dynamic>> notes,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        14,
      ),

      decoration: const BoxDecoration(
        color: Color(0xFFFFF8EA),

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.sticky_note_2_outlined,
                color: AppColors.gold,
                size: 18,
              ),

              const SizedBox(width: 7),

              const Text(
                'My Notes',
                style: TextStyle(
                  color: AppColors.maroon,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(width: 5),

              Text(
                '(${notes.length})',
                style: const TextStyle(
                  color: AppColors.mutedBrown,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ...notes.map(
            (note) {
              return buildNoteCard(
                sectionId: sectionId,
                note: note,
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTE CARD
  // ============================================================

  Widget buildNoteCard({
    required String sectionId,
    required Map<String, dynamic> note,
  }) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(
        bottom: 8,
      ),

      padding: const EdgeInsets.fromLTRB(
        12,
        10,
        8,
        10,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(10),

        border: Border.all(
          color: const Color(0xFFE5D5B5),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.notes,
              color: AppColors.gold,
              size: 17,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              note['text']?.toString() ?? '',

              style: const TextStyle(
                color: AppColors.darkBrown,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),

          PopupMenuButton<String>(
            padding: EdgeInsets.zero,

            icon: const Icon(
              Icons.more_vert,
              color: AppColors.mutedBrown,
              size: 19,
            ),

            onSelected: (value) {
              if (value == 'edit') {
                editNote(
                  sectionId: sectionId,
                  note: note,
                );
              }

              if (value == 'delete') {
                deleteNote(
                  sectionId: sectionId,
                  note: note,
                );
              }
            },

            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),

              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}