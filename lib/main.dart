import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy_pos_system/auth_pages/Loginpage.dart';
import 'package:provider/provider.dart';

import 'Front_side/Employee_DashBoard.dart';
import 'Front_side/Manager_DashBoard.dart';
import 'Providers/userprovider.dart';
import 'auth_pages/Registerpage.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize with the generated options
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => const LoginPage(),
          '/managerpage': (context) => const ManagerDashboard(),
          '/employeepage': (context) => const EmployeeDashboard(),
        },
        title: 'Pharmacy POS',
        initialRoute: '/login', // Set the initial route to the login page
        // home: Navigator.pushNamed(context, routeName),
      ),
    );
  }
}
