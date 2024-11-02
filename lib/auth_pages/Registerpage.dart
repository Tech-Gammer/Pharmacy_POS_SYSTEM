import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/usermodel.dart';
import '../Providers/userprovider.dart';
import 'Loginpage.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nc = TextEditingController();
  final ec = TextEditingController();
  final phonec = TextEditingController();
  final pass = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Add loading state
  bool obscurePassword = true;


  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // First, create the user using Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: ec.text.trim(),
        password: pass.text.trim(),
      );

      // Get the user's UID from FirebaseAuth
      String uid = userCredential.user!.uid;

      // Now, create the UserModel instance
      final user = UserModel(
        name: nc.text.trim(),
        email: ec.text.trim(),
        phone: phonec.text.trim(),
        password: pass.text.trim(), // Store the plain password (optional: hash it later)
        role: '', // The role will be assigned in the provider
        uid: uid,
          isActive: true
      );

      // Register the user in Firebase Realtime Database
      await userProvider.registerUser(user, uid); // Pass the UID

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );

      // Clear input fields
      nc.clear();
      ec.clear();
      phonec.clear();
      pass.clear();

      // Optionally, navigate to another page after registration
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
      Navigator.pushNamed(context, ('/login'));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }




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
                  child: const Align(
                    alignment: Alignment.bottomLeft,
                    child: Image(image: AssetImage('assets/images/login.png')),
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
                )
              ],
            ),
          ),

          // Centered container on top of the grey container
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85, // Responsive width
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Wrap content tightly
                    children: [
                      TextField(
                        controller: nc,
                        decoration: const InputDecoration(
                          hintText: "Enter Your Name",
                          labelText: "Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Add spacing between fields
                      TextFormField(
                        controller: ec,
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
                          // Email regex pattern
                          String pattern =
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                          RegExp regex = RegExp(pattern);
                          if (!regex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null; // Return null if the input is valid
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phonec,
                        decoration: const InputDecoration(
                          hintText: "Enter Your Phone No",
                          labelText: "Phone No",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          // Phone number regex pattern for Pakistani numbers
                          String pattern =
                              r'^(03[0-9]{9}|\+92[0-9]{10})$';
                          RegExp regex = RegExp(pattern);
                          if (!regex.hasMatch(value)) {
                            return 'Please enter a valid Pakistani phone number';
                          }
                          return null; // Return null if the input is valid
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: pass,
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
                        obscureText: obscurePassword,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _register, // Disable button if loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(double.infinity, 50), // Make button full width
                        ),
                        child: _isLoading // Show loading indicator if loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Register",
                          style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("If you are already registered, please click on"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, ('/login'));
                        },
                        child: const Text("Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
