import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jathwa1/pages/homeOne_page.dart';
import 'package:jathwa1/pages/homeTwo_page.dart';
import 'package:jathwa1/pages/login_page.dart';
import 'package:jathwa1/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:jathwa1/pages/main_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  await Supabase.initialize(
    url: 'https://zqhdnnbgpwzoawhrpjyj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpxaGRubmJncHd6b2F3aHJwanlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY0NjI0MjQsImV4cCI6MjA1MjAzODQyNH0.N-xM7HbTseVCn4WudaYzGUdo6kzLqAozG_-WMHCagfI',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
