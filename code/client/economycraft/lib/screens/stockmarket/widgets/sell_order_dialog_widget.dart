import 'package:economycraft/classes/company_info.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:economycraft/common_widgets/linegraph_2_widget.dart';

class SellOrderDialogWidget extends StatefulWidget {
  final CompanyInfo companyInfo;

  const SellOrderDialogWidget({super.key, required this.companyInfo});

  @override
  State<SellOrderDialogWidget> createState() => _SellOrderDialogWidgetState();
}

class _SellOrderDialogWidgetState extends State<SellOrderDialogWidget> {
  late final String lastSalePrice;
  late final String cheapestSalePrice;
  late final String companyName;
  late final String companyOwner;
  late final dynamic formKey;
  double minPrice = 0;
  double maxPrice = 0;
  double medianPrice = 0;
  double meanPrice = 0;
  double totalValue = 0;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController coefficientController = TextEditingController();

  bool isLoading = false;
  int spreadState = 0;

  double f(a, x, b) => a * x + b;
  double logx(a, x, b) => x == 1 ? b : a * log(x) + b;

  @override
  void initState() {
    lastSalePrice = widget.companyInfo.share.value.toStringAsFixed(2);
    cheapestSalePrice = widget.companyInfo.cheapestShare.toStringAsFixed(2);
    companyName = widget.companyInfo.company.name;
    companyOwner = widget.companyInfo.ownerName;
    formKey = GlobalKey<FormState>();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      content: SizedBox(
        width: screenWidth * (1 / 2),
        height: screenHeight * (7 / 8),
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
                          "Create Sell Order",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Create a sell order to offload a volume of shares with a static or variable price spread",
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
                              child: spreadButton(
                                Icons.money,
                                0,
                                "Static Price",
                                "Have your shares have a static sale price",
                                0,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: spreadButton(
                                Icons.linear_scale,
                                -45,
                                "Linear Spread",
                                "Have your shares increase/decrease in sale price linearly",
                                1,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: spreadButton(
                                Icons.redo,
                                0,
                                "Logarithmic Spread",
                                "Have your shares increase/decrease in sale price on a curve",
                                2,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        Form(
                          key: formKey,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: quantityController,
                                              decoration: InputDecoration(
                                                labelText: "Order Quantity",
                                                prefixIcon: Icon(Icons.numbers),
                                                filled: true,
                                                fillColor: Color.fromARGB(
                                                  255,
                                                  229,
                                                  255,
                                                  252,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            const Color.fromARGB(
                                                              38,
                                                              0,
                                                              0,
                                                              0,
                                                            ),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.0,
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Color.fromARGB(
                                                          255,
                                                          163,
                                                          255,
                                                          244,
                                                        ),
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.0,
                                                          ),
                                                    ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.0,
                                                      ),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.redAccent,
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.0,
                                                          ),
                                                    ),
                                              ),
                                              validator:
                                                  (value) =>
                                                      spreadState == 0
                                                          ? (value == null ||
                                                                  int.tryParse(
                                                                        value,
                                                                      ) ==
                                                                      null ||
                                                                  int.tryParse(
                                                                        value,
                                                                      )! <
                                                                      1)
                                                              ? "Quantity must be a positive integer"
                                                              : null
                                                          : (value == null ||
                                                              int.tryParse(
                                                                    value,
                                                                  ) ==
                                                                  null ||
                                                              int.tryParse(
                                                                    value,
                                                                  )! <
                                                                  2)
                                                          ? "Quantity must be greater than 1"
                                                          : null,
                                              onChanged: (newValue) {
                                                changeValues();
                                              },

                                              autovalidateMode:
                                                  AutovalidateMode
                                                      .onUserInteraction,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: priceController,
                                              decoration: InputDecoration(
                                                labelText:
                                                    spreadState != 0
                                                        ? "Starting share price"
                                                        : "Price per share",
                                                prefixIcon: Icon(
                                                  Icons.price_change,
                                                ),
                                                filled: true,
                                                fillColor: Color.fromARGB(
                                                  255,
                                                  229,
                                                  255,
                                                  252,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            const Color.fromARGB(
                                                              38,
                                                              0,
                                                              0,
                                                              0,
                                                            ),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.0,
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Color.fromARGB(
                                                          255,
                                                          163,
                                                          255,
                                                          244,
                                                        ),
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.0,
                                                          ),
                                                    ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.0,
                                                      ),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.redAccent,
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.0,
                                                          ),
                                                    ),
                                              ),
                                              validator:
                                                  (value) =>
                                                      (value == null ||
                                                              double.tryParse(
                                                                    value,
                                                                  ) ==
                                                                  null ||
                                                              double.tryParse(
                                                                    value,
                                                                  )! <=
                                                                  0)
                                                          ? "Price must be a positive real"
                                                          : null,
                                              onChanged: (newValue) {
                                                changeValues();
                                              },
                                              autovalidateMode:
                                                  AutovalidateMode
                                                      .onUserInteraction,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          spreadState != 0
                                              ? Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      coefficientController,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        "Function coefficient",
                                                    prefixIcon: Icon(
                                                      Icons.functions,
                                                    ),
                                                    filled: true,
                                                    fillColor: Color.fromARGB(
                                                      255,
                                                      229,
                                                      255,
                                                      252,
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            const Color.fromARGB(
                                                              38,
                                                              0,
                                                              0,
                                                              0,
                                                            ),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.0,
                                                          ),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color:
                                                                Color.fromARGB(
                                                                  255,
                                                                  163,
                                                                  255,
                                                                  244,
                                                                ),
                                                            width: 2.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.0,
                                                              ),
                                                        ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.red,
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.0,
                                                          ),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color:
                                                                Colors
                                                                    .redAccent,
                                                            width: 2.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.0,
                                                              ),
                                                        ),
                                                  ),
                                                  validator:
                                                      (value) =>
                                                          (value == null ||
                                                                  double.tryParse(
                                                                        value,
                                                                      ) ==
                                                                      null ||
                                                                  double.tryParse(
                                                                        value,
                                                                      )! ==
                                                                      0)
                                                              ? "Coefficient must not be zero"
                                                              : null,
                                                  onChanged: (newValue) {
                                                    changeValues();
                                                  },
                                                  autovalidateMode:
                                                      AutovalidateMode
                                                          .onUserInteraction,
                                                ),
                                              )
                                              : SizedBox(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                          38,
                                          0,
                                          0,
                                          0,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Minimum Price: ",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              minPrice.toStringAsFixed(2),
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Maximum Price:",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              maxPrice.toStringAsFixed(2),
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Median Price: ",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              medianPrice.toStringAsFixed(2),
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Average Price: ",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              meanPrice.toStringAsFixed(2),
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Total Order Sale Price: ",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              totalValue.toStringAsFixed(2),
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),

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
                            SizedBox(width: 16),
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
                                if (formKey.currentState!.validate()) {
                                  if (spreadState == 0) {
                                    await createSellOrder((int value) {
                                      return double.parse(priceController.text);
                                    }, int.parse(quantityController.text));
                                  } else if (spreadState == 1) {
                                    await createSellOrder(
                                      (x) => f(
                                        double.parse(
                                          coefficientController.text,
                                        ),
                                        x,
                                        double.parse(priceController.text),
                                      ),
                                      int.parse(quantityController.text),
                                    );
                                  } else if (spreadState == 2) {
                                    await createSellOrder(
                                      (x) => logx(
                                        double.parse(
                                          coefficientController.text,
                                        ),
                                        x,
                                        double.parse(priceController.text),
                                      ),
                                      int.parse(quantityController.text),
                                    );
                                  }
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return;
                                }
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
                                        "Create Sell Order",
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

  Widget spreadButton(
    IconData icon,
    double angle,
    String title,
    String subtitle,
    int enabledSpreadState,
  ) {
    bool isEnabled = spreadState == enabledSpreadState;

    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isEnabled ? Colors.black : Colors.grey),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        hoverColor: const Color.fromARGB(255, 236, 236, 236),
        onTap: () {
          setState(() {
            spreadState = enabledSpreadState;
            minPrice = 0;
            maxPrice = 0;
            medianPrice = 0;
            meanPrice = 0;
            totalValue = 0;
          });
        },
        child: ListTile(
          leading: Transform.rotate(
            angle: angle,
            child: Icon(
              icon,
              size: 40,
              color: isEnabled ? Colors.black : Colors.grey,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isEnabled ? Colors.black : Colors.grey,
            ),
            maxLines: 1,
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isEnabled ? Colors.black : Colors.grey,
            ),
            maxLines: 2,
          ),
        ),
      ),
    );
  }

  bool hasAllValues(bool needsCoefficient) {
    bool hasQuantity = int.tryParse(quantityController.text) != null;
    bool hasPrice = double.tryParse(priceController.text) != null;
    bool hasCoefficient = double.tryParse(coefficientController.text) != null;
    if (needsCoefficient) {
      return hasQuantity && hasPrice && hasCoefficient;
    } else {
      return hasQuantity && hasPrice;
    }
  }

  void changeValues() {
    if (hasAllValues(spreadState != 0)) {
      if (spreadState == 0) {
        setState(() {
          minPrice = double.parse(priceController.text);
          maxPrice = double.parse(priceController.text);
          medianPrice = double.parse(priceController.text);
          meanPrice = double.parse(priceController.text);
          totalValue =
              double.parse(priceController.text) *
              int.parse(quantityController.text);
        });
      } else if (spreadState == 1) {
        double total = 0;
        for (int x = 0; x < int.parse(quantityController.text); x++) {
          total += f(
            double.parse(coefficientController.text),
            x,
            double.parse(priceController.text),
          );
        }

        setState(() {
          minPrice = double.parse(priceController.text);
          maxPrice = f(
            double.parse(coefficientController.text),
            int.parse(quantityController.text),
            double.parse(priceController.text),
          );
          medianPrice = f(
            double.parse(coefficientController.text),

            int.parse(quantityController.text) ~/ 2,
            double.parse(priceController.text),
          );
          meanPrice = f(
            double.parse(coefficientController.text),
            int.parse(quantityController.text) / 2,
            double.parse(priceController.text),
          );
          totalValue = total;
        });
      } else if (spreadState == 2) {
        double total = 0;
        for (int x = 1; x < int.parse(quantityController.text) + 1; x++) {
          total += logx(
            double.parse(coefficientController.text),
            x,
            double.parse(priceController.text),
          );
        }

        setState(() {
          minPrice = double.parse(priceController.text);
          maxPrice = logx(
            double.parse(coefficientController.text),
            int.parse(quantityController.text),
            double.parse(priceController.text),
          );
          medianPrice = logx(
            double.parse(coefficientController.text),

            int.parse(quantityController.text) ~/ 2,
            double.parse(priceController.text),
          );
          meanPrice = total / int.parse(quantityController.text);
          totalValue = total;
        });
      }
    }
  }

  Future<void> createSellOrder(double Function(int x) f, int quantity) async {
    if (!await SupabaseHelper.sellOrderPreCheck(
      quantity,
      widget.companyInfo.share.companyShareId,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 247, 121, 121),
          content: Text(
            'Error: Sell Order Quantity exceeds number of owned not for sale shares for this company',
            style: TextStyle(color: Colors.black),
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final response = await SupabaseHelper.newSellOrder(
      f,
      quantity,
      widget.companyInfo.share.companyShareId,
    );
    if (response && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 201, 249, 255),
          content: Text(
            'Sell Order Created Successfully',
            style: TextStyle(color: Colors.black),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    } else if (!response && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 247, 121, 121),
          content: Text(
            'Error: Unable to Complete Sell Order please try again',
            style: TextStyle(color: Colors.black),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    coefficientController.dispose();
    super.dispose();
  }
}
