// front_side/employee_dashboard.dart
import 'package:flutter/material.dart';

class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({Key? key}) : super(key: key);
// For Manager Dashboard
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Dashboard')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sales Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to new sale page
                        },
                        child: const Text('Start New Sale'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to transaction history page
                        },
                        child: const Text('View Transaction History'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Product Lookup Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Product Lookup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextField(
                        decoration: const InputDecoration(hintText: 'Search by name or barcode'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Implement product search
                        },
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Inventory Alerts Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Inventory Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to inventory alerts page
                        },
                        child: const Text('View Low Stock Alerts'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Daily Tasks Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Daily Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      // Add checklist or task list here
                      ElevatedButton(
                        onPressed: () {
                          // View daily tasks checklist
                        },
                        child: const Text('View Daily Tasks'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Customer Management Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Customer Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to customer management page
                        },
                        child: const Text('View Customer History'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
