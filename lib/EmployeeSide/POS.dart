import 'package:flutter/material.dart';

class SalesRegisterPage extends StatefulWidget {
  @override
  _SalesRegisterPageState createState() => _SalesRegisterPageState();
}

class _SalesRegisterPageState extends State<SalesRegisterPage> {
  String? _selectedMode = 'Sale';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();
  List<String> _items = [];
  double _totalAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.pushNamed(context, ('/employeepage'));
        }, icon: Icon(Icons.arrow_back)),
        title: const Text('Sales Page'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Search bar and actions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Enter item name or scan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: () {}, child: const Text('New Item')),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: () {}, child: const Text('Suspended Sales')),
              ],
            ),
          ),

          // Item List and Cart Summary
          Expanded(
            child: ListView(
              children: _items.map((item) {
                return ListTile(
                  title: Text(item),
                  trailing: const Text('BDT 1150'),
                );
              }).toList(),
            ),
          ),

          // Sale Summary
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _discountController,
                        decoration: const InputDecoration(
                          labelText: 'Global Sale Discount',
                        ),
                      ),
                    ),
                    ElevatedButton(onPressed: () {}, child: const Text('Submit')),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total: ', style: TextStyle(fontSize: 18)),
                    const Text('Amount Due: ', style: TextStyle(fontSize: 18)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _paymentController,
                        decoration: const InputDecoration(
                          labelText: 'Add Payment',
                        ),
                      ),
                    ),
                    ElevatedButton(onPressed: () {}, child: const Text('Add Payment')),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Suspend Sale')),
              OutlinedButton(onPressed: () {}, child: const Text('Cancel Sale')),
            ],
          ),
        ],
      ),
    );
  }
}
