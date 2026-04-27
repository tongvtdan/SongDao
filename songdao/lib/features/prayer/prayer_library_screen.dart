import 'package:flutter/material.dart';

class PrayerLibraryScreen extends StatelessWidget {
  const PrayerLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cầu nguyện'),
      ),
      body: const Center(
        child: Text('Prayer Library Screen'),
      ),
    );
  }
}
