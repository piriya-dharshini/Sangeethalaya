import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
  final String name;

  const AdminHome({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF7B0F1A),
        foregroundColor: const Color(0xFFFFF8EA),
        title: const Text(
          'Sangeethalaya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.music_note,
              size: 70,
              color: Color(0xFFD4AF37),
            ),

            const SizedBox(height: 20),

            Text(
              'Welcome, $name!',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B0F1A),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF765C4A),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.library_music),
              label: const Text('Manage Songs'),
            ),
          ],
        ),
      ),
    );
  }
}