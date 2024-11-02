import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/userprovider.dart';

class SuperAdminPage extends StatefulWidget {
  @override
  _SuperAdminPageState createState() => _SuperAdminPageState();
}

class _SuperAdminPageState extends State<SuperAdminPage> {
  @override
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<UserProvider>(context, listen: false).fetchAllUsers();
    });
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Page'),
      ),
      body: userProvider.users.isEmpty
          ? const Center(child: Text('No users found.'))
          : ListView.builder(
        itemCount: userProvider.users.length,
        itemBuilder: (context, index) {
          final user = userProvider.users[index];

          return Card(
            child: ListTile(
              title: Text(user.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.role),
                  Text(user.email),
                  Text(user.phone),
                  Text(
                    user.isActive ? 'Status: Active' : 'Status: Inactive',
                    style: TextStyle(
                      color: user.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: user.role,
                    items: const [
                      DropdownMenuItem(
                        value: 'Manager',
                        child: Text('Manager'),
                      ),
                      DropdownMenuItem(
                        value: 'User',
                        child: Text('User'),
                      ),
                    ],
                    onChanged: (newRole) {
                      if (newRole != null && newRole != user.role) {
                        userProvider.changeUserRole(user.uid, newRole);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      user.isActive
                          ? Icons.check_circle
                          : Icons.remove_circle,
                      color: user.isActive ? Colors.green : Colors.red,
                    ),
                    onPressed: () async {
                      if (user.isActive) {
                        userProvider.setUserInactive(user.uid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("User marked inactive")),
                        );
                      } else {
                        userProvider.setUserActive(user.uid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("User marked active")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
