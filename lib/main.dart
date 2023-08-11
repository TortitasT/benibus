import 'package:benibus/stops.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BeniBusApp());
}

class BeniBusApp extends StatelessWidget {
  const BeniBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Benibus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: const StopsPage(title: 'Benibus 🚍'),
      debugShowCheckedModeBanner: false,
    );
  }
}
