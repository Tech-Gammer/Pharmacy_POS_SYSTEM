import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/userprovider.dart';
import 'drawerfile.dart';


class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _contentSlideAnimation; // For the content slide
  bool isDrawerOpen = false;
  User? user; // Store the user information

  @override
  void initState() {
    super.initState();
//new
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _contentSlideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.18, 0.0))
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Delay fetch operation until the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user != null) {
        Provider.of<UserProvider>(context, listen: false).fetchUserDetails(user!.uid);
      }
    });
  }



  /// Build the responsive GridView based on screen width.
  Widget _buildGridView(double screenWidth) {
    int crossAxisCount;

    // Determine the number of columns based on screen width using MediaQuery
    if (screenWidth < 600) {
      crossAxisCount = 2; // Mobile screens
    } else if (screenWidth < 1200) {
      crossAxisCount = 3; // Tablet screens
    } else {
      crossAxisCount = 5; // Large screens (like laptops and desktops)
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 20.0,
      mainAxisSpacing: 20.0,
      padding: const EdgeInsets.all(16.0), // Add padding if necessary
      children: [
        DashboardItem(
          icon: Icons.work_outline,
          label: 'Add Departments',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/adddepartments');
          },
        ),
        DashboardItem(
          icon: Icons.work_outline,
          label: 'Departments',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/totaldepartments');
          },
        ),
        // Add other DashboardItems as needed
        DashboardItem(
          icon: Icons.people_alt_outlined,
          label: 'Managers',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/totalmanagers');
            // Navigator.push(context, MaterialPageRoute(builder: (context)=>const ManagersListPage()));
          },
        ),
        DashboardItem(
          icon: Icons.rule,
          label: 'Terminations',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/totalresticated');
          },
        ),
        DashboardItem(
          icon: Icons.rule,
          label: 'Goal Assignments',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/goalassignments');
          },
        ),DashboardItem(
          icon: Icons.rule,
          label: 'Total Goals',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/totalgoalslist');
          },
        ),

        // Add more items as needed
      ],
    );
  }

  /// Handle drawer toggle animation.
  void toggleDrawer() {
    if (isDrawerOpen) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final userModel = Provider.of<UserModel>(context); // Listen to user model for updates
    final screenSize = MediaQuery.of(context).size; // Get screen size dynamically

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: toggleDrawer,
        ),
        title: const Text("Manager Dash Board",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
      ),
      body: Stack(
        children: [
          // Animated content that moves to the side when the drawer is open
          SlideTransition(
            position: _contentSlideAnimation,
            child: _buildGridView(screenSize.width), // Pass screen width for responsive grid
          ),
          // Drawer widget that slides in/out
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: screenSize.width * 0.18, // Adjust width of the drawer (80% of the screen)
              child:  Drawerfrontside(), // Your custom drawer widget
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class DashboardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onButtonPressed;

  const DashboardItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onButtonPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.teal,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.black87,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
