import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: KodiraApp()));
}

class KodiraApp extends StatelessWidget {
  const KodiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KODIRA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Inter'),
      home: const Scaffold(body: Center(child: Text('KODIRA — Loading...'))),
    );
  }
}
