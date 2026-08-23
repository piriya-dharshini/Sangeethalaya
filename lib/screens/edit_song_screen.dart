import 'package:flutter/material.dart';

import '../main.dart';
import '../services/song_service.dart';

class EditSongScreen extends StatefulWidget {
  final Map<String, dynamic> song;

  const EditSongScreen({
    super.key,
    required this.song,
  });

  @override
  State<EditSongScreen> createState() => _EditSongScreenState();
}

class _EditSongScreenState extends State<EditSongScreen> {
  final SongService _songService = SongService();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _ragaController;
  late TextEditingController _talaController;
  late TextEditingController _authorController;
  late TextEditingController _deityController;

  String _selectedType = '';
  String _selectedLyricsType = 'simple';

  // Simple lyrics
  late TextEditingController _simpleLyricsController;

  // Structured lyrics
  late TextEditingController _pallaviController;
  late TextEditingController _anupallaviController;

  List<TextEditingController> _charanamControllers = [];

  // Stanza lyrics
  List<TextEditingController> _stanzaControllers = [];

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.song['title']?.toString() ?? '',
    );

    _ragaController = TextEditingController(
      text: widget.song['raga']?.toString() ?? '',
    );

    _talaController = TextEditingController(
      text: widget.song['tala']?.toString() ?? '',
    );

    _authorController = TextEditingController(
      text: widget.song['author']?.toString() ?? '',
    );

    _deityController = TextEditingController(
      text: widget.song['deity']?.toString() ?? '',
    );

    _selectedType =
        widget.song['type']?.toString() ?? '';

    _selectedLyricsType =
        widget.song['lyricsType']?.toString() ?? 'simple';

    _initializeLyrics();
  }

  void _initializeLyrics() {
    final rawLyrics = widget.song['lyrics'];

    Map<String, dynamic> lyrics = {};

    if (rawLyrics is Map) {
      lyrics = Map<String, dynamic>.from(rawLyrics);
    }

    // ============================================================
    // SIMPLE
    // ============================================================

    _simpleLyricsController = TextEditingController(
      text: lyrics['text']?.toString() ?? '',
    );

    // ============================================================
    // STRUCTURED
    // ============================================================

    _pallaviController = TextEditingController(
      text: lyrics['pallavi']?.toString() ?? '',
    );

    _anupallaviController = TextEditingController(
      text: lyrics['anupallavi']?.toString() ?? '',
    );

    final rawCharanams = lyrics['charanams'];

    if (rawCharanams is List) {
      for (final charanam in rawCharanams) {
        _charanamControllers.add(
          TextEditingController(
            text: charanam.toString(),
          ),
        );
      }
    }

    // ============================================================
    // STANZAS
    // ============================================================

    final rawStanzas = lyrics['stanzas'];

    if (rawStanzas is List) {
      for (final stanza in rawStanzas) {
        _stanzaControllers.add(
          TextEditingController(
            text: stanza.toString(),
          ),
        );
      }
    }

    // Always provide at least one field
    if (_charanamControllers.isEmpty) {
      _charanamControllers.add(
        TextEditingController(),
      );
    }

    if (_stanzaControllers.isEmpty) {
      _stanzaControllers.add(
        TextEditingController(),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ragaController.dispose();
    _talaController.dispose();
    _authorController.dispose();
    _deityController.dispose();

    _simpleLyricsController.dispose();

    _pallaviController.dispose();
    _anupallaviController.dispose();

    for (final controller in _charanamControllers) {
      controller.dispose();
    }

    for (final controller in _stanzaControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // SAVE SONG
  // ============================================================

  Future<void> _updateSong() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final songId =
        widget.song['id']?.toString() ?? '';

    if (songId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Song ID is missing.'),
        ),
      );
      return;
    }

    Map<String, dynamic> lyrics = {};

    // ============================================================
    // SIMPLE
    // ============================================================

    if (_selectedLyricsType == 'simple') {
      lyrics = {
        'text': _simpleLyricsController.text.trim(),
      };
    }

    // ============================================================
    // STRUCTURED
    // ============================================================

    else if (_selectedLyricsType == 'structured') {
      lyrics = {
        'pallavi': _pallaviController.text.trim(),
        'anupallavi': _anupallaviController.text.trim(),
        'charanams': _charanamControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
      };
    }

    // ============================================================
    // STANZA
    // ============================================================

    else if (_selectedLyricsType == 'stanza') {
      lyrics = {
        'stanzas': _stanzaControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
      };
    }

    setState(() {
      _saving = true;
    });

    try {
      await _songService.updateSong(
        songId: songId,
        title: _titleController.text.trim(),
        type: _selectedType,
        raga: _ragaController.text.trim(),
        tala: _talaController.text.trim(),
        author: _authorController.text.trim(),
        deity: _deityController.text.trim(),
        lyricsType: _selectedLyricsType,
        lyrics: lyrics,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Song updated successfully.',
          ),
        ),
      );

      // Return true so ViewSongScreen knows
      // that the song was edited.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update song: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
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
        centerTitle: true,
        elevation: 0,

        title: const Text(
          'EDIT SONG',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              18,
              24,
              18,
              40,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                _buildBasicDetails(),

                const SizedBox(height: 24),

                const RoyalDivider(),

                const SizedBox(height: 24),

                _buildLyricsEditor(),

                const SizedBox(height: 30),

                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BASIC DETAILS
  // ============================================================

  Widget _buildBasicDetails() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.gold,
          width: 1.2,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Song Details',
            style: TextStyle(
              color: AppColors.maroon,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          _buildTextField(
            controller: _titleController,
            label: 'Song Title',
            icon: Icons.music_note,
            required: true,
          ),

          const SizedBox(height: 14),

          _buildTextField(
            controller: _ragaController,
            label: 'Raga',
            icon: Icons.auto_awesome,
          ),

          const SizedBox(height: 14),

          _buildTextField(
            controller: _talaController,
            label: 'Tala',
            icon: Icons.access_time,
          ),

          const SizedBox(height: 14),

          _buildTextField(
            controller: _authorController,
            label: 'Author',
            icon: Icons.person_outline,
          ),

          const SizedBox(height: 14),

          _buildTextField(
            controller: _deityController,
            label: 'Dedicated To',
            icon: Icons.temple_hindu,
          ),

          const SizedBox(height: 18),

          const Text(
            'Song Type',
            style: TextStyle(
              color: AppColors.darkBrown,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue:
                _selectedType.isEmpty
                    ? null
                    : _selectedType,

            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,

              prefixIcon: const Icon(
                Icons.category_outlined,
                color: AppColors.maroon,
              ),

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),

            items: const [
              DropdownMenuItem(
                value: 'Kriti',
                child: Text('Kriti'),
              ),
              DropdownMenuItem(
                value: 'Bhajan',
                child: Text('Bhajan'),
              ),
              DropdownMenuItem(
                value: 'Varnam',
                child: Text('Varnam'),
              ),
              DropdownMenuItem(
                value: 'Keerthanai',
                child: Text('Keerthanai'),
              ),
              DropdownMenuItem(
                value: 'Sloka',
                child: Text('Sloka'),
              ),
              DropdownMenuItem(
                value: 'Other',
                child: Text('Other'),
              ),
            ],

            onChanged: (value) {
              setState(() {
                _selectedType = value ?? '';
              });
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,

      validator: required
          ? (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return '$label is required';
              }

              return null;
            }
          : null,

      decoration: InputDecoration(
        labelText: label,

        filled: true,
        fillColor: Colors.white,

        prefixIcon: Icon(
          icon,
          color: AppColors.maroon,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.gold,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LYRICS EDITOR
  // ============================================================

  Widget _buildLyricsEditor() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          'Lyrics',
          style: TextStyle(
            color: AppColors.darkBrown,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        DropdownButtonFormField<String>(
          initialValue: _selectedLyricsType,

          decoration: InputDecoration(
            labelText: 'Lyrics Format',
            filled: true,
            fillColor: Colors.white,

            prefixIcon: const Icon(
              Icons.menu_book_outlined,
              color: AppColors.maroon,
            ),

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
          ),

          items: const [
            DropdownMenuItem(
              value: 'simple',
              child: Text('Simple Lyrics'),
            ),
            DropdownMenuItem(
              value: 'structured',
              child: Text('Pallavi / Anupallavi / Charanams'),
            ),
            DropdownMenuItem(
              value: 'stanza',
              child: Text('Stanzas'),
            ),
          ],

          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedLyricsType = value;
            });
          },
        ),

        const SizedBox(height: 20),

        if (_selectedLyricsType == 'simple')
          _buildSimpleEditor(),

        if (_selectedLyricsType == 'structured')
          _buildStructuredEditor(),

        if (_selectedLyricsType == 'stanza')
          _buildStanzaEditor(),
      ],
    );
  }

  // ============================================================
  // SIMPLE EDITOR
  // ============================================================

  Widget _buildSimpleEditor() {
    return _lyricsTextField(
      controller: _simpleLyricsController,
      label: 'Lyrics',
      hint: 'Enter the lyrics...',
    );
  }

  // ============================================================
  // STRUCTURED EDITOR
  // ============================================================

  Widget _buildStructuredEditor() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        _lyricsTextField(
          controller: _pallaviController,
          label: 'Pallavi',
          hint: 'Enter Pallavi...',
        ),

        const SizedBox(height: 16),

        _lyricsTextField(
          controller: _anupallaviController,
          label: 'Anupallavi',
          hint: 'Enter Anupallavi...',
        ),

        const SizedBox(height: 20),

        const Text(
          'Charanams',
          style: TextStyle(
            color: AppColors.maroon,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        ...List.generate(
          _charanamControllers.length,
          (index) {
            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),

              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Expanded(
                    child: _lyricsTextField(
                      controller:
                          _charanamControllers[
                              index],
                      label:
                          'Charanam ${index + 1}',
                      hint:
                          'Enter Charanam ${index + 1}...',
                    ),
                  ),

                  if (_charanamControllers
                          .length >
                      1)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _charanamControllers[
                                  index]
                              .dispose();

                          _charanamControllers
                              .removeAt(index);
                        });
                      },

                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.maroon,
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 5),

        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _charanamControllers.add(
                TextEditingController(),
              );
            });
          },

          icon: const Icon(
            Icons.add,
            color: AppColors.maroon,
          ),

          label: const Text(
            'Add Charanam',
            style: TextStyle(
              color: AppColors.maroon,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STANZA EDITOR
  // ============================================================

  Widget _buildStanzaEditor() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          'Stanzas',
          style: TextStyle(
            color: AppColors.maroon,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        ...List.generate(
          _stanzaControllers.length,
          (index) {
            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),

              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Expanded(
                    child: _lyricsTextField(
                      controller:
                          _stanzaControllers[
                              index],
                      label:
                          'Stanza ${index + 1}',
                      hint:
                          'Enter Stanza ${index + 1}...',
                    ),
                  ),

                  if (_stanzaControllers.length >
                      1)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _stanzaControllers[
                                  index]
                              .dispose();

                          _stanzaControllers
                              .removeAt(index);
                        });
                      },

                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.maroon,
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 5),

        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _stanzaControllers.add(
                TextEditingController(),
              );
            });
          },

          icon: const Icon(
            Icons.add,
            color: AppColors.maroon,
          ),

          label: const Text(
            'Add Stanza',
            style: TextStyle(
              color: AppColors.maroon,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LYRICS TEXT FIELD
  // ============================================================

  Widget _lyricsTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,

      maxLines: 8,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        alignLabelWithHint: true,

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),

          borderSide: const BorderSide(
            color: AppColors.gold,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,

      child: ElevatedButton.icon(
        onPressed:
            _saving ? null : _updateSong,

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.maroon,
          foregroundColor: AppColors.ivory,

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),

        icon: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.gold,
                ),
              )
            : const Icon(
                Icons.save_outlined,
                color: AppColors.gold,
              ),

        label: Text(
          _saving
              ? 'Saving...'
              : 'Save Changes',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}