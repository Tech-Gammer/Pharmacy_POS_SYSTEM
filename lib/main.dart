import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'auth_pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharmacy POS',
      home: LoginScreen(),
    );
  }
}
