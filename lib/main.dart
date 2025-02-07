
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/login.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://xmbnplpjxsngjupqtxim.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhtYm5wbHBqeHNuZ2p1cHF0eGltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MTM1OTAsImV4cCI6MjA1NDI4OTU5MH0.m26BTDj8q1LNVYgzVAQJRsIftQILGvKQn7okk2LqPWQ',
  );
  runApp(MyApp());
}
        

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LOGIN',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 181, 141, 141)),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}

