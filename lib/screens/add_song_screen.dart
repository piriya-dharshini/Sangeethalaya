import 'package:flutter/material.dart';

import '../services/song_service.dart';
import '../main.dart';

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  // ============================================================
  // SONG DETAILS
  // ============================================================

  final titleController = TextEditingController();
  final ragaController = TextEditingController();
  final talaController = TextEditingController();
  final authorController = TextEditingController();
  final deityController = TextEditingController();

  // ============================================================
  // LYRIC CONTROLLERS
  // ============================================================

  final simpleLyricsController = TextEditingController();

  final pallaviController = TextEditingController();
  final anupallaviController = TextEditingController();

  final List<TextEditingController> charanamControllers = [];

  final List<TextEditingController> stanzaControllers = [];

  // ============================================================
  // STATE
  // ============================================================

  String selectedType = 'Kriti';

  // simple / structured / stanza
  String lyricsType = 'structured';

  bool isSaving = false;

  final List<String> songTypes = [
    'Kriti',
    'Bhajan',
    'Keerthanai',
    'Varnam',
    'Devarnam',
    'Slokam',
    'Stotram',
    'Abhang',
    'Tillana',
    'Other',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Start with one charanam.
    charanamControllers.add(
      TextEditingController(),
    );

    // Start with one stanza.
    stanzaControllers.add(
      TextEditingController(),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    titleController.dispose();
    ragaController.dispose();
    talaController.dispose();
    authorController.dispose();
    deityController.dispose();

    simpleLyricsController.dispose();

    pallaviController.dispose();
    anupallaviController.dispose();

    for (final controller in charanamControllers) {
      controller.dispose();
    }

    for (final controller in stanzaControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // ADD CHARANAM
  // ============================================================

  void addCharanam() {
    setState(() {
      charanamControllers.add(
        TextEditingController(),
      );
    });
  }

  // ============================================================
  // REMOVE CHARANAM
  // ============================================================

  void removeCharanam(int index) {
    if (charanamControllers.length == 1) {
      return;
    }

    setState(() {
      charanamControllers[index].dispose();
      charanamControllers.removeAt(index);
    });
  }

  // ============================================================
  // ADD STANZA
  // ============================================================

  void addStanza() {
    setState(() {
      stanzaControllers.add(
        TextEditingController(),
      );
    });
  }

  // ============================================================
  // REMOVE STANZA
  // ============================================================

  void removeStanza(int index) {
    if (stanzaControllers.length == 1) {
      return;
    }

    setState(() {
      stanzaControllers[index].dispose();
      stanzaControllers.removeAt(index);
    });
  }

  // ============================================================
  // SAVE SONG
  // ============================================================

  Future<void> saveSong() async {
    // ----------------------------------------------------------
    // TITLE VALIDATION
    // ----------------------------------------------------------

    if (titleController.text.trim().isEmpty) {
      showMessage(
        'Please enter the song title.',
        isError: true,
      );
      return;
    }

    // ----------------------------------------------------------
    // LYRICS VALIDATION
    // ----------------------------------------------------------

    if (lyricsType == 'simple') {
      if (simpleLyricsController.text.trim().isEmpty) {
        showMessage(
          'Please enter the lyrics.',
          isError: true,
        );
        return;
      }
    }

    if (lyricsType == 'structured') {
      final hasPallavi =
          pallaviController.text.trim().isNotEmpty;

      final hasAnupallavi =
          anupallaviController.text.trim().isNotEmpty;

      final hasCharanam =
          charanamControllers.any(
        (controller) =>
            controller.text.trim().isNotEmpty,
      );

      if (!hasPallavi &&
          !hasAnupallavi &&
          !hasCharanam) {
        showMessage(
          'Please enter at least one lyric section.',
          isError: true,
        );
        return;
      }
    }

    if (lyricsType == 'stanza') {
      final hasStanza =
          stanzaControllers.any(
        (controller) =>
            controller.text.trim().isNotEmpty,
      );

      if (!hasStanza) {
        showMessage(
          'Please enter at least one stanza.',
          isError: true,
        );
        return;
      }
    }

    // ----------------------------------------------------------
    // START SAVING
    // ----------------------------------------------------------

    setState(() {
      isSaving = true;
    });

    try {
      Map<String, dynamic> lyrics;

      // ========================================================
      // SIMPLE
      // ========================================================

      if (lyricsType == 'simple') {
        lyrics = {
          'text': simpleLyricsController.text.trim(),
        };
      }

      // ========================================================
      // STRUCTURED
      // ========================================================

      else if (lyricsType == 'structured') {
        final charanams = charanamControllers
            .map(
              (controller) =>
                  controller.text.trim(),
            )
            .where(
              (text) => text.isNotEmpty,
            )
            .toList();

        lyrics = {
          'pallavi':
              pallaviController.text.trim(),

          'anupallavi':
              anupallaviController.text.trim(),

          'charanams': charanams,
        };
      }

      // ========================================================
      // STANZA BASED
      // ========================================================

      else {
        final stanzas = stanzaControllers
            .map(
              (controller) =>
                  controller.text.trim(),
            )
            .where(
              (text) => text.isNotEmpty,
            )
            .toList();

        lyrics = {
          'stanzas': stanzas,
        };
      }

      // ========================================================
      // FIREBASE
      // ========================================================

      await SongService().addSong(
        title: titleController.text.trim(),

        type: selectedType,

        raga: ragaController.text.trim(),

        tala: talaController.text.trim(),

        author: authorController.text.trim(),

        deity: deityController.text.trim(),

        lyricsType: lyricsType,

        lyrics: lyrics,
      );

      if (!mounted) return;

      showMessage(
        'Song added successfully! 🎶',
      );

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint(
        'Add song error: $e',
      );

      if (!mounted) return;

      showMessage(
        'Could not save the song. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor: isError
            ? Colors.red.shade800
            : AppColors.maroon,

        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: AppColors.maroon,

        foregroundColor:
            AppColors.ivory,

        elevation: 0,

        centerTitle: true,

        title: const Text(
          'ADD NEW SONG',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            18,
            20,
            18,
            40,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ==================================================
              // HEADER
              // ==================================================

              Center(
                child: Column(
                  children: const [

                    Icon(
                      Icons.music_note,
                      color: AppColors.gold,
                      size: 42,
                    ),

                    SizedBox(height: 6),

                    Text(
                      'Add a Song',
                      style: TextStyle(
                        color:
                            AppColors.maroon,

                        fontSize: 26,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Preserve a beautiful piece of music',
                      style: TextStyle(
                        color:
                            AppColors.mutedBrown,

                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const RoyalDivider(),

              const SizedBox(height: 24),

              // ==================================================
              // SONG DETAILS
              // ==================================================

              const SectionHeading(
                title: 'Song Details',
                icon:
                    Icons.library_music_outlined,
              ),

              const SizedBox(height: 14),

              buildTextField(
                controller:
                    titleController,

                label: 'Title *',

                hint:
                    'Enter song title',

                icon:
                    Icons.music_note,
              ),

              const SizedBox(height: 14),

              // ==================================================
              // TYPE
              // ==================================================

              DropdownButtonFormField<String>(
                value: selectedType,

                decoration:
                    const InputDecoration(
                  labelText: 'Type *',

                  prefixIcon:
                      Icon(
                    Icons.category_outlined,
                    color:
                        AppColors.maroon,
                  ),
                ),

                dropdownColor:
                    AppColors.ivory,

                items:
                    songTypes.map(
                  (type) {
                    return DropdownMenuItem(
                      value: type,
                      child:
                          Text(type),
                    );
                  },
                ).toList(),

                onChanged:
                    (value) {
                  if (value == null)
                    return;

                  setState(() {
                    selectedType =
                        value;
                  });
                },
              ),

              const SizedBox(height: 14),

              // ==================================================
              // RAGA
              // ==================================================

              buildTextField(
                controller:
                    ragaController,

                label: 'Raga',

                hint:
                    'e.g. Hamsadhwani or Unknown',

                icon:
                    Icons.auto_awesome,
              ),

              const SizedBox(height: 14),

              // ==================================================
              // TALA
              // ==================================================

              buildTextField(
                controller:
                    talaController,

                label: 'Tala',

                hint:
                    'e.g. Adi or Unknown',

                icon:
                    Icons.access_time,
              ),

              const SizedBox(height: 14),

              // ==================================================
              // AUTHOR
              // ==================================================

              buildTextField(
                controller:
                    authorController,

                label: 'Author',

                hint:
                    'e.g. Tyagaraja or Unknown',

                icon:
                    Icons.person_outline,
              ),

              const SizedBox(height: 14),

              // ==================================================
              // DEITY
              // ==================================================

              buildTextField(
                controller:
                    deityController,

                label: 'Dedicated To',

                hint:
                    'e.g. Ganesha, Krishna, Devi',

                icon:
                    Icons.temple_hindu,
              ),

              const SizedBox(height: 28),

              // ==================================================
              // LYRICS
              // ==================================================

              const SectionHeading(
                title: 'Lyrics',
                icon:
                    Icons.menu_book_outlined,
              ),

              const SizedBox(height: 8),

              const Text(
                'Choose the format that matches the song.',
                style: TextStyle(
                  color:
                      AppColors.mutedBrown,

                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // LYRICS TYPE SELECTOR
              // ==================================================

              buildLyricsTypeSelector(),

              const SizedBox(height: 24),

              // ==================================================
              // SIMPLE LYRICS
              // ==================================================

              if (lyricsType == 'simple')
                buildLyricsField(
                  controller:
                      simpleLyricsController,

                  label: 'Lyrics',

                  hint:
                      'Type or paste the lyrics here...',
                ),

              // ==================================================
              // STRUCTURED LYRICS
              // ==================================================

              if (lyricsType == 'structured')
                buildStructuredLyrics(),

              // ==================================================
              // STANZA LYRICS
              // ==================================================

              if (lyricsType == 'stanza')
                buildStanzaLyrics(),

              const SizedBox(height: 30),

              const RoyalDivider(),

              const SizedBox(height: 25),

              // ==================================================
              // SAVE
              // ==================================================

              SizedBox(
                width:
                    double.infinity,

                height: 55,

                child:
                    ElevatedButton.icon(
                  onPressed:
                      isSaving
                          ? null
                          : saveSong,

                  icon: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                AppColors.ivory,
                          ),
                        )
                      : const Icon(
                          Icons.save_outlined,
                        ),

                  label: Text(
                    isSaving
                        ? 'Saving Song...'
                        : 'SAVE SONG',
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.maroon,

                    foregroundColor:
                        AppColors.ivory,

                    disabledBackgroundColor:
                        AppColors.mutedBrown,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),

                    elevation: 4,

                    textStyle:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  'Every song helps preserve our musical heritage ✦',
                  style: TextStyle(
                    color:
                        AppColors.mutedBrown,

                    fontSize: 11,

                    fontStyle:
                        FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LYRICS TYPE SELECTOR
  // ============================================================

  Widget buildLyricsTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color:
              const Color(0xFFE0C992),
        ),
      ),

      padding:
          const EdgeInsets.all(5),

      child: Column(
        children: [

          buildLyricsTypeOption(
            value: 'simple',

            title:
                'Simple Lyrics',

            subtitle:
                'One continuous lyrics section',

            icon:
                Icons.notes_outlined,
          ),

          buildLyricsTypeOption(
            value: 'structured',

            title:
                'Structured Lyrics',

            subtitle:
                'Pallavi, Anupallavi & Charanams',

            icon:
                Icons.account_tree_outlined,
          ),

          buildLyricsTypeOption(
            value: 'stanza',

            title:
                'Stanza Based Lyrics',

            subtitle:
                'Separate Stanza 1, 2, 3...',

            icon:
                Icons.library_books_outlined,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SINGLE LYRICS TYPE OPTION
  // ============================================================

  Widget buildLyricsTypeOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected =
        lyricsType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          lyricsType = value;
        });
      },

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),

        margin:
            const EdgeInsets.only(
          bottom: 4,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),

        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.maroon
              : Colors.transparent,

          borderRadius:
              BorderRadius.circular(10),
        ),

        child: Row(
          children: [

            Icon(
              icon,

              color: isSelected
                  ? AppColors.ivory
                  : AppColors.maroon,

              size: 23,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    title,

                    style: TextStyle(
                      color: isSelected
                          ? AppColors.ivory
                          : AppColors.darkBrown,

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,

                    style: TextStyle(
                      color: isSelected
                          ? AppColors.cream
                          : AppColors.mutedBrown,

                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.gold,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STRUCTURED LYRICS
  // ============================================================

  Widget buildStructuredLyrics() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        buildLyricsField(
          controller:
              pallaviController,

          label: 'Pallavi',

          hint:
              'Enter Pallavi...',
        ),

        const SizedBox(height: 16),

        buildLyricsField(
          controller:
              anupallaviController,

          label: 'Anupallavi',

          hint:
              'Enter Anupallavi...',
        ),

        const SizedBox(height: 22),

        const Text(
          'Charanams',

          style: TextStyle(
            color:
                AppColors.darkBrown,

            fontSize: 17,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ...List.generate(
          charanamControllers.length,
          (index) {
            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 14,
              ),

              child:
                  buildCharanamField(index),
            );
          },
        ),

        const SizedBox(height: 4),

        Center(
          child:
              buildAddButton(
            label:
                'Add Charanam',

            icon:
                Icons.add,
            onPressed:
                addCharanam,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STANZA LYRICS
  // ============================================================

  Widget buildStanzaLyrics() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Container(
          padding:
              const EdgeInsets.all(14),

          decoration:
              BoxDecoration(
            color:
                AppColors.cream,

            borderRadius:
                BorderRadius.circular(
              12,
            ),

            border: Border.all(
              color:
                  const Color(
                0xFFE0C992,
              ),
            ),
          ),

          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: const [

              Icon(
                Icons.info_outline,
                color:
                    AppColors.maroon,
                size: 20,
              ),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Enter each stanza separately. '
                  'Line breaks inside a stanza will be preserved.',
                  style: TextStyle(
                    color:
                        AppColors.darkBrown,

                    fontSize: 12,

                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        ...List.generate(
          stanzaControllers.length,
          (index) {
            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 16,
              ),

              child:
                  buildStanzaField(index),
            );
          },
        ),

        Center(
          child:
              buildAddButton(
            label:
                'Add Stanza',

            icon:
                Icons.add,

            onPressed:
                addStanza,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NORMAL TEXT FIELD
  // ============================================================

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller:
          controller,

      textCapitalization:
          TextCapitalization.sentences,

      decoration:
          InputDecoration(
        labelText:
            label,

        hintText:
            hint,

        prefixIcon:
            Icon(
          icon,
          color:
              AppColors.maroon,
        ),
      ),
    );
  }

  // ============================================================
  // LYRICS FIELD
  // ============================================================

  Widget buildLyricsField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Container(
      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border: Border.all(
          color:
              const Color(
            0xFFE0C992,
          ),
        ),
      ),

      child:
          TextField(
        controller:
            controller,

        keyboardType:
            TextInputType.multiline,

        textCapitalization:
            TextCapitalization.sentences,

        minLines: 5,

        maxLines: 15,

        decoration:
            InputDecoration(
          labelText:
              label,

          hintText:
              hint,

          alignLabelWithHint:
              true,

          border:
              InputBorder.none,

          contentPadding:
              const EdgeInsets.all(
            16,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHARANAM FIELD
  // ============================================================

  Widget buildCharanamField(
    int index,
  ) {
    return Container(
      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border: Border.all(
          color:
              const Color(
            0xFFE0C992,
          ),
        ),
      ),

      child:
          Column(
        children: [

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              10,
              8,
              0,
            ),

            child:
                Row(
              children: [

                buildNumberCircle(
                  index + 1,
                ),

                const SizedBox(
                  width: 10,
                ),

                const Expanded(
                  child:
                      Text(
                    'Charanam',
                    style:
                        TextStyle(
                      color:
                          AppColors.darkBrown,

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 15,
                    ),
                  ),
                ),

                if (charanamControllers
                        .length >
                    1)
                  IconButton(
                    onPressed: () {
                      removeCharanam(
                        index,
                      );
                    },

                    icon:
                        const Icon(
                      Icons
                          .delete_outline,

                      color:
                          AppColors
                              .mutedBrown,
                    ),
                  ),
              ],
            ),
          ),

          TextField(
            controller:
                charanamControllers[
                    index],

            keyboardType:
                TextInputType.multiline,

            textCapitalization:
                TextCapitalization.sentences,

            minLines: 4,

            maxLines: 12,

            decoration:
                const InputDecoration(
              hintText:
                  'Enter Charanam lyrics...',

              border:
                  InputBorder.none,

              contentPadding:
                  EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STANZA FIELD
  // ============================================================

  Widget buildStanzaField(
    int index,
  ) {
    return Container(
      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border: Border.all(
          color:
              const Color(
            0xFFE0C992,
          ),
        ),
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              12,
              8,
              0,
            ),

            child:
                Row(
              children: [

                buildNumberCircle(
                  index + 1,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child:
                      Text(
                    'Stanza ${index + 1}',

                    style:
                        const TextStyle(
                      color:
                          AppColors.darkBrown,

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 15,
                    ),
                  ),
                ),

                if (stanzaControllers
                        .length >
                    1)
                  IconButton(
                    onPressed: () {
                      removeStanza(
                        index,
                      );
                    },

                    icon:
                        const Icon(
                      Icons
                          .delete_outline,

                      color:
                          AppColors
                              .mutedBrown,
                    ),
                  ),
              ],
            ),
          ),

          TextField(
            controller:
                stanzaControllers[
                    index],

            keyboardType:
                TextInputType.multiline,

            textCapitalization:
                TextCapitalization.sentences,

            minLines: 5,

            maxLines: 15,

            decoration:
                const InputDecoration(
              hintText:
                  'Enter the complete stanza here...\n\n'
                  'Line 1\n'
                  'Line 2\n'
                  'Line 3',

              border:
                  InputBorder.none,

              contentPadding:
                  EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NUMBER CIRCLE
  // ============================================================

  Widget buildNumberCircle(
    int number,
  ) {
    return Container(
      width: 30,
      height: 30,

      decoration:
          const BoxDecoration(
        color:
            AppColors.maroon,

        shape:
            BoxShape.circle,
      ),

      child:
          Center(
        child:
            Text(
          '$number',

          style:
              const TextStyle(
            color:
                AppColors.ivory,

            fontWeight:
                FontWeight.bold,

            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ADD BUTTON
  // ============================================================

  Widget buildAddButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed:
          onPressed,

      icon:
          Icon(
        icon,
        color:
            AppColors.maroon,
      ),

      label:
          Text(
        label,

        style:
            const TextStyle(
          color:
              AppColors.maroon,

          fontWeight:
              FontWeight.bold,
        ),
      ),

      style:
          OutlinedButton.styleFrom(
        side:
            const BorderSide(
          color:
              AppColors.gold,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
      ),
    );
  }
}

// ================================================================
// SECTION HEADING
// ================================================================

class SectionHeading
    extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeading({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [

        Container(
          width: 36,
          height: 36,

          decoration:
              BoxDecoration(
            color:
                AppColors.cream,

            borderRadius:
                BorderRadius.circular(
              10,
            ),

            border: Border.all(
              color:
                  AppColors.gold,
            ),
          ),

          child:
              Icon(
            icon,

            color:
                AppColors.maroon,

            size: 20,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Text(
          title,

          style:
              const TextStyle(
            color:
                AppColors.darkBrown,

            fontSize: 19,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }
}