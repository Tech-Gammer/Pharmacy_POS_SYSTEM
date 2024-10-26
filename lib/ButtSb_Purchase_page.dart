import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'components.dart'; // Date formatting ke liye

class DetailsSide extends StatefulWidget {
  const DetailsSide({super.key});

  @override
  State<DetailsSide> createState() => _DetailsSideState();
}

class _DetailsSideState extends State<DetailsSide> {
  // TextEditingControllers banaye gaye hain
  final TextEditingController invoiceNoController = TextEditingController();
  final TextEditingController dateController1 = TextEditingController();
  final TextEditingController godownController = TextEditingController();
  final TextEditingController aliasNameController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController suppInvController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController printBalController = TextEditingController();
  final TextEditingController invSizeController = TextEditingController();
  final TextEditingController orderCodeController = TextEditingController();
  final TextEditingController dateController2 = TextEditingController();
  final TextEditingController sOrdNumController = TextEditingController();

  // Search results ki list
  List<String> searchResults = [];

  @override
  void initState() {
    super.initState();
    // Current date and time ko set karna
    String currentDateTime = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
    dateController1.text = currentDateTime; // First date field
    dateController2.text = currentDateTime; // Second date field (if needed)
  }

  void searchItem(String query) {
    if (query.isNotEmpty) {
      setState(() {
        searchResults.add(query); // Add the query to the results list
      });
      print("Searching for: $query");
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    Widget setText(String text) {
      return Text(
        text,
        style: TextStyle(fontSize: height * 0.02, fontWeight: FontWeight.bold),
      );
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Detail",
            style: TextStyle(fontSize: height * 0.05, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    setText("Invoice No: "),
                    SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(length: 0.2, hintText: "", controller: invoiceNoController),
                    ),
                    SizedBox(width: 30),
                    setText("Date: "),
                    SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(length: 0.2, hintText: "", controller: dateController1),
                    ),
                    SizedBox(width: 30),
                    setText("Godown: "),
                    SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(length: 0.2, hintText: "", controller: godownController),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    setText("Name / Item Code: "),
                    SizedBox(width: 10),
                    Expanded(
                      child:
                      Row(
                        children: [
                          Expanded(
                            child:
                            CustomTextField(length :0.2,hintText:"",controller :aliasNameController),
                          ),
                          IconButton(
                            icon: Icon(Icons.search), // Search icon
                            onPressed: () {
                              String query = aliasNameController.text;
                              searchItem(query); // Call the search function
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width :30),
                    setText("Supplier :"),
                    SizedBox(width :10),
                    Expanded(
                      child:
                      CustomTextField(length :0.5,hintText:"",controller :supplierController),
                    ),
                  ],
                ),
                SizedBox(height :10,),
                Row(
                  mainAxisAlignment :MainAxisAlignment.start,
                  crossAxisAlignment :CrossAxisAlignment.center,
                  children :[
                    setText("Supp. Inv# "),
                    SizedBox(width :10),
                    Expanded(
                      child:
                      CustomTextField(length :0.2,hintText:"",controller :suppInvController)
                      ,
                    ),
                  ],
                ),
                SizedBox(height :10,),
                Row(
                  mainAxisAlignment :MainAxisAlignment.start,
                  crossAxisAlignment :CrossAxisAlignment.center,
                  children :[
                    setText("Remarks :"),
                    SizedBox(width :10),
                    Expanded(
                      child:
                      CustomTextField(length :0.2,hintText:"",controller :remarksController)
                      ,
                    ),
                    SizedBox(width :30),
                    setText("Print Bal :"),
                    SizedBox(width :10),
                    Expanded(
                      child:
                      CustomTextField(length :0.2,hintText:"",controller :printBalController)
                      ,
                    ),
                    SizedBox(width :30),
                    setText("Inv Size :"),
                    SizedBox(width :10),
                    Expanded(
                      child:
                      CustomTextField(length :0.2,hintText:"",controller :invSizeController)
                      ,
                    )
                  ],
                ),
                SizedBox(height :10,),
                Row(
                  mainAxisAlignment :MainAxisAlignment.start,
                  crossAxisAlignment :CrossAxisAlignment.center,
                  children :[
                    setText("Order Code :"),
                    SizedBox(width :10),
                    Expanded(
                      child:
                      CustomTextField(length :0.2,hintText:"",controller :orderCodeController)
                      ,
                    ),
                    SizedBox(width :30),
                    setText("Date (2):"),
                    SizedBox(width :10),
                    Expanded(
                      child:
                      CustomTextField(length :0.2,hintText:"",controller :dateController2)
                      ,
                    ),
                    SizedBox(width :30),
                    setText("S / Ord #:"),
                    SizedBox(width :10),
                    Expanded(
                      child:
                      CustomTextField(length :0.2,hintText:"",controller:sOrdNumController)
                      ,
                    )
                  ],
                ),
                // Displaying search results at the bottom
                SizedBox(height: 20), // Add some space before the results
                Text("Search Results:", style: TextStyle(fontSize: height * 0.025, fontWeight: FontWeight.bold)),
                ...searchResults.map((result) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(result, style: TextStyle(fontSize: height * 0.02)),
                )).toList(),
              ],
            ),
          ),
       );
    }
}