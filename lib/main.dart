import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy_pos_system/auth_pages/Loginpage.dart';
import 'package:provider/provider.dart';

import 'EmployeeSide/Employee_DashBoard.dart';
import 'EmployeeSide/POS.dart';
import 'ManagerSide/Manager_DashBoard.dart';
import 'ManagerSide/add_item.dart';
import 'ManagerSide/add_units.dart';
import 'ManagerSide/total_items.dart';
import 'ManagerSide/total_units.dart';
import 'Providers/authProvieder.dart';
import 'Providers/itemprovider.dart';
import 'Providers/unitprovider.dart';
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
        ChangeNotifierProvider(create: (_) => UnitProvider()),
         ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/managerpage': (context) => const ManagerDashboard(),
          '/employeepage': (context) => const EmployeeDashboard(),
          '/add_items': (context) => const AddItem(),
          '/add_units': (context) => const Addunit(),
          '/total_units': (context) => const ShowUnit(),
          '/total_items': (context) => const ItemsPage(),
          '/POS_Page': (context) =>  SalesRegisterPage(),


        },
        title: 'Pharmacy POS',
        initialRoute: '/login', // Set the initial route to the login page
        // home: Navigator.pushNamed(context, routeName),
      ),
    );
  }
}
