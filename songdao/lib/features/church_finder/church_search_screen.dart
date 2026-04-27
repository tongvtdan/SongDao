import 'package:flutter/material.dart';

class ChurchSearchScreen extends StatelessWidget {
  const ChurchSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhà thờ'),
      ),
      body: const Center(
        child: Text('Church Search Screen'),
      ),
    );
  }
}
