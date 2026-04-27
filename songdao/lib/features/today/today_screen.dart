import 'package:flutter/material.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hôm nay'),
      ),
      body: const Center(
        child: Text('Today Screen'),
      ),
    );
  }
}
