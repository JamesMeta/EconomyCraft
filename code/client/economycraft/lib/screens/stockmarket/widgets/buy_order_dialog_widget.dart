import 'package:economycraft/classes/company_info.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:economycraft/common_widgets/linegraph_2_widget.dart';
import 'package:flutter/material.dart';

class BuyOrderDialogWidget extends StatefulWidget {
  final CompanyInfo companyInfo;

  const BuyOrderDialogWidget({super.key, required this.companyInfo});

  @override
  State<BuyOrderDialogWidget> createState() => _BuyOrderDialogWidgetState();
}

class _BuyOrderDialogWidgetState extends State<BuyOrderDialogWidget> {
  TextEditingController amountController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController totalController = TextEditingController();

  late final String lastSalePrice;
  late final String cheapestSalePrice;
  late final String companyName;
  late final String companyOwner;

  bool isLoading = false;

  @override
  void initState() {
    lastSalePrice = widget.companyInfo.share.value.toStringAsFixed(2);
    cheapestSalePrice = widget.companyInfo.cheapestShare.toStringAsFixed(2);
    companyName = widget.companyInfo.company.name;
    companyOwner = widget.companyInfo.ownerName;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      content: SizedBox(
        width: screenWidth * (1 / 3),
        height: screenHeight * (4 / 5),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          "Create Buy Order",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Create a buy order to automatically purchase shares when they become available within your price target.",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 32,
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 229, 255, 252),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 1,
                                color: const Color.fromARGB(38, 0, 0, 0),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 0,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      "$companyName",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    Text(
                                      "By: $companyOwner",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      "Last Sold Price: \$$lastSalePrice",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      "Current Lowest Price: \$$cheapestSalePrice",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Linegraph2Widget(
                          title: "",
                          data: widget.companyInfo.stockPrice,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Target Share Price",
                                  hintText: "Enter max price per share",
                                  prefixIcon: Icon(Icons.money),
                                  filled: true,
                                  fillColor: Color.fromARGB(255, 229, 255, 252),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(38, 0, 0, 0),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 163, 255, 244),
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.redAccent,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                onChanged: (value) {
                                  bool isNum =
                                      int.tryParse(value) != null ||
                                      double.tryParse(value) != null;
                                  bool quantityExists =
                                      int.tryParse(amountController.text) !=
                                          null ||
                                      double.tryParse(amountController.text) !=
                                          null;

                                  if (isNum && quantityExists) {
                                    double total =
                                        double.parse(value) *
                                        double.parse(amountController.text);

                                    print(total);

                                    setState(() {
                                      totalController.text = total
                                          .toStringAsFixed(2);
                                    });
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.025),
                            Expanded(
                              child: TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Quantity",
                                  hintText: "Enter # of shares to purchase",
                                  prefixIcon: Icon(Icons.numbers),
                                  filled: true,
                                  fillColor: Color.fromARGB(255, 229, 255, 252),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(38, 0, 0, 0),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 163, 255, 244),
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.redAccent,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                onChanged: (value) {
                                  bool isNum =
                                      int.tryParse(value) != null ||
                                      double.tryParse(value) != null;
                                  bool priceExists =
                                      int.tryParse(priceController.text) !=
                                          null ||
                                      double.tryParse(amountController.text) !=
                                          null;

                                  if (isNum && priceExists) {
                                    double total =
                                        double.parse(value) *
                                        double.parse(priceController.text);

                                    print(total);

                                    setState(() {
                                      totalController.text = total
                                          .toStringAsFixed(2);
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: dateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: "Order Expiry",
                                  prefixIcon: Icon(Icons.calendar_month),
                                  filled: true,
                                  fillColor: Color.fromARGB(255, 229, 255, 252),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(38, 0, 0, 0),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 163, 255, 244),
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.redAccent,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),

                                onTap: () async {
                                  final DateTime? pickedDate =
                                      await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100),
                                      );

                                  if (pickedDate == null) return;
                                  // Then pick the time
                                  final TimeOfDay? pickedTime =
                                      await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );

                                  if (pickedTime == null) {
                                    return;
                                  } // user canceled

                                  final time = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );

                                  setState(() {
                                    dateController.text = time
                                        .toIso8601String()
                                        .substring(0, 16);
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.025),
                            Expanded(
                              child: TextField(
                                controller: totalController,
                                keyboardType: TextInputType.number,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: "Total",
                                  hintText: "Order Total",
                                  prefixIcon: Icon(Icons.attach_money),
                                  filled: true,

                                  fillColor: Color.fromARGB(255, 255, 255, 255),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(38, 0, 0, 0),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(0, 163, 255, 244),
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.redAccent,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                backgroundColor: Color.fromARGB(
                                  255,
                                  134,
                                  255,
                                  154,
                                ),
                              ),
                              onPressed: () async {
                                if (isLoading) {
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                bool priceExists =
                                    int.tryParse(priceController.text) !=
                                        null ||
                                    double.tryParse(amountController.text) !=
                                        null;
                                bool quantityExists =
                                    int.tryParse(amountController.text) !=
                                        null ||
                                    double.tryParse(amountController.text) !=
                                        null;
                                bool dateExists =
                                    DateTime.tryParse(dateController.text) !=
                                    null;

                                if (!priceExists ||
                                    !quantityExists ||
                                    !dateExists) {
                                  setState(() {
                                    totalController.text =
                                        "ERROR: Invalid Price, Quantity, or Date";
                                  });
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return;
                                }

                                final DateTime now = DateTime.now();
                                final DateTime then = DateTime.parse(
                                  dateController.text,
                                );

                                final double targetSharePrice = double.parse(
                                  priceController.text,
                                );
                                final double quantity = double.parse(
                                  amountController.text,
                                );

                                bool dateInFuture = then.isAfter(now);
                                bool targetSharePriceIsGreaterThanZero =
                                    targetSharePrice > 0;
                                bool quantityIsGreaterThanZero = quantity > 0;

                                if (!dateInFuture ||
                                    !targetSharePriceIsGreaterThanZero ||
                                    !quantityIsGreaterThanZero) {
                                  setState(() {
                                    totalController.text =
                                        "ERROR: Total must be greater than zero";
                                  });
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return;
                                }

                                await createBuyOrder(
                                  targetSharePrice,
                                  quantity,
                                  then,
                                  widget.companyInfo.share.companyShareId,
                                );
                                setState(() {
                                  isLoading = false;
                                });
                                Navigator.pop(context);
                              },
                              child:
                                  isLoading
                                      ? CircularProgressIndicator(
                                        color: Colors.black,
                                      )
                                      : Text(
                                        "Create Buy Order",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> createBuyOrder(
    final maximumPrice,
    final quantity,
    final expires,
    final companyShareId,
  ) async {
    final response = await SupabaseHelper.share.newBuyOrder(
      maximumPrice,
      quantity,
      expires,
      companyShareId,
    );
    if (response && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 201, 249, 255),
          content: Text(
            'Buy Order Created Successfully',
            style: TextStyle(color: Colors.black),
          ),
          duration: Duration(seconds: 3), // how long it stays visible
        ),
      );
    } else if (!response && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 247, 121, 121),
          content: Text(
            'Error: Unable to Complete Buy Order please try again',
            style: TextStyle(color: Colors.black),
          ),
          duration: Duration(seconds: 3), // how long it stays visible
        ),
      );
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    priceController.dispose();
    dateController.dispose();
    totalController.dispose();
    super.dispose();
  }
}
