import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy_pos_system/ManagerSide/total_purchases.dart';
import 'package:pharmacy_pos_system/Providers/purchaseprovider.dart';
import 'package:pharmacy_pos_system/Providers/supplierprovider.dart';
import 'package:pharmacy_pos_system/auth_pages/Loginpage.dart';
import 'package:provider/provider.dart';
import 'EmployeeSide/Employee_DashBoard.dart';
import 'EmployeeSide/POS.dart';
import 'EmployeeSide/salesreturn.dart';
import 'EmployeeSide/total_sales.dart';
import 'ManagerSide/Manager_DashBoard.dart';
import 'ManagerSide/add_category.dart';
import 'ManagerSide/add_item.dart';
import 'ManagerSide/add_supplier.dart';
import 'ManagerSide/add_units.dart';
import 'ManagerSide/purchase_item.dart';
import 'ManagerSide/total_category.dart';
import 'ManagerSide/total_items.dart';
import 'ManagerSide/total_suppliers.dart';
import 'ManagerSide/total_units.dart';
import 'Providers/authProvieder.dart';
import 'Providers/categoryprovider.dart';
import 'Providers/itemprovider.dart';
import 'Providers/saleprovider.dart';
import 'Providers/unitprovider.dart';
import 'Providers/userprovider.dart';
import 'auth_pages/Registerpage.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize with the generated options
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UnitProvider()),
         ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
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
          '/add_category': (context) =>  const Addcategory(),
          '/total_categories': (context) =>  const Showcategory(),
          '/total_suppliers': (context) =>  ViewSuppliersPage(),
          '/add_suppliers': (context) =>  AddSupplierPage(),
          '/purchase_page': (context) =>  const PurchasePage(),
          '/total_purchases': (context) =>  const TotalPurchases(),
          '/POS_PAGE': (context) =>  const POSPage(),
          '/sales_return': (context) =>   SalesReturnSearchScreen(),
          '/total_sales': (context) =>   SalesListPage(),
        },
        title: 'Pharmacy POS',
        initialRoute: '/login', // Set the initial route to the login page
      ),
    );
  }
}

