import 'package:flutter/material.dart';

class POSPage extends StatelessWidget {
  const POSPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: const [
            Text(
              'POS Page',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Header Section with Dropdowns and Search Field
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: "main",
                  items: ["main", "branch1"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: "Ali (main)",
                  items: ["Ali (main)", "User 2"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: "Walk (0987654321)",
                  items: ["Walk (0987654321)", "Customer 2"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Scan/Search product by name/code",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Cart Section (Left Side)
                Expanded(
                  flex: 2,
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Product"),
                              Text("Price"),
                              Text("Quantity"),
                              Text("SubTotal"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3, // replace with actual item count
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: const Text("Product [1212]"),
                                subtitle: const Text("In Stock: 1775"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {},
                                    ),
                                    const Text("1"),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {},
                                    ),
                                    const SizedBox(width: 10),
                                    const Text("123.00"),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Items: 1"),
                              Text("Total: 123.00"),
                              Text("Discount: 0.00"),
                              Text("Shipping: 0.00"),
                              Text("Grand Total: 123.00"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Product Grid Section (Right Side)
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Tabs for Category, Brand, and Featured
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                              ),
                              child: const Text("Category"),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                              ),
                              child: const Text("Brand"),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Featured"),
                            ),
                          ],
                        ),
                      ),
                      // Product Grid
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2 / 3,
                          ),
                          itemCount: 6, // replace with actual product count
                          itemBuilder: (context, index) {
                            return Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.image, size: 60),
                                  Text("Product Name"),
                                  Text("Product Code"),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Footer with Payment Options
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text("Card"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text("Cash"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text("Draft"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text("Cheque"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text("Gift Card"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
