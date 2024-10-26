import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final double length;
  final String hintText;
  final TextEditingController controller; // TextEditingController ko add kiya

  CustomTextField({
    required this.length,
    required this.hintText,
    required this.controller, // Constructor mein controller ko include kiya
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * length; // TextField ki width yahan set hoti hai

    return Container(
        margin: EdgeInsets.all(0),
        width: width,
        child: TextField(
            controller: controller, // TextEditingController ko yahan set kiya
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: hintText,
            ),
           ),
       );
   }
}