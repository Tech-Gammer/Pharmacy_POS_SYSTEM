import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/userprovider.dart';

class Drawerfrontside extends StatelessWidget {
  const Drawerfrontside({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    // Check if user is still loading
    if (user == null) {
      return const Center(child: CircularProgressIndicator()); // Show loading spinner
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double getFontSize() {
      if (screenWidth < 400) {
        return 10;
      } else if (screenWidth < 600) {
        return 12;
      } else if (screenWidth < 900) {
        return 14;
      } else if (screenWidth < 1200) {
        return 16;
      } else {
        return 18;
      }
    }

    double getDrawerSize() {
      if (screenWidth < 400) {
        return screenWidth * 0.75;
      } else if (screenWidth < 600) {
        return screenWidth * 0.5;
      } else {
        return screenWidth * 0.35;
      }
    }

    double fontSize = getFontSize();
    double drawerSize = getDrawerSize();

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20.0),
        bottomRight: Radius.circular(20.0),
      ),
      child: Drawer(
        width: drawerSize,
        backgroundColor: const Color(0xFFDEE5D4),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role: ${user.role == 'Manager' ? "Manager" : "User"}',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: fontSize,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Name: ${user.name ?? "Not Available"}',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: fontSize * 0.9,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            buildListTile(Icons.logout, "Log out", () async {
              try {
                // Handle logout using UserProvider
                 await userProvider.logout(); // Implement logout in UserProvider
                 Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Logout failed: ${e.toString()}")),
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'Lora', fontSize: 16, color: Colors.black),
      ),
      onTap: onTap,
    );
  }
}
