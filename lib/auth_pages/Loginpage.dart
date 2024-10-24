
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/userprovider.dart';
import 'Registerpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen grey container
          Container(
            color: Colors.grey,
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(280),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Image.asset('assets/images/login.png'),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(280),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Centered container on top of the grey container
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Consumer<UserProvider>(
                    builder: (context, authProvider, child) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              hintText: "Enter Your Email Address",
                              labelText: "Email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email address';
                              }
                              String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                              RegExp regex = RegExp(pattern);
                              if (!regex.hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              hintText: "Enter Your Password",
                              labelText: "Password",
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword; // Toggle the visibility state
                                  });
                                },
                              ),
                            ),
                            obscureText: obscurePassword, // Correctly reference the state variable
                          ),

                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: authProvider.isLoggingIn
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                loginUser(authProvider);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: authProvider.isLoggingIn
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "Log In",
                              style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text("If you have not registered please click on"),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, ('/register'));
                            },
                            child: const Text("Register"),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void loginUser(UserProvider authProvider) async {
    try {
      String? role = await authProvider.loginUser(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Navigate based on the role
      if (role != null) {
        switch (role) {
          case 'Manager':
            Navigator.pushReplacementNamed(context, '/managerpage');
            break;
          case 'User':
            Navigator.pushReplacementNamed(context, '/employeepage');
            break;
          default:
            _showSnackbar(context, 'User role is not recognized.');
        }
      } else {
        _showSnackbar(context, 'Role is null. Please try again.');
      }
    } catch (e) {
      _showSnackbar(context, 'Error: ${e.toString()}');
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

}
