import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/company_info.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/classes/share.dart';
import 'package:economycraft/widgets/linegraph_1_widget.dart';
import 'package:economycraft/widgets/linegraph_2_widget.dart';
import 'package:flutter/material.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:economycraft/classes/share_changes.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:economycraft/widgets/sliding_share_list_widget.dart';

class StockMarketScreen extends StatefulWidget {
  const StockMarketScreen({super.key, shareChanges});

  @override
  State<StockMarketScreen> createState() => _StockMarketScreenState();
}

class _StockMarketScreenState extends State<StockMarketScreen> {
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  DateTime? _lastDataRefresh;
  List<ShareChanges> _shareChanges = List.empty(growable: true);
  late CompanyInfo _selectedCompanyInfo;
  late List<Company> _companies;
  final List<List<ShareChanges>> chunks = [];
  late List<List<PriceVsTime>> _data = [];

  int _buttonState = 0;
  late Company? _selectedCompany;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchAllData() async {
    _lastDataRefresh = DateTime.now();

    // Load all data in parallel
    await Future.wait([
      SupabaseHelper.getShareChanges().then((value) => _shareChanges = value),
      getAllPublicCompanies().then((value) => _companies = value),
    ]);

    _selectedCompanyInfo = (await getCompanyInfo(_companies.first))!;
    _selectedCompany = _companies.first;
    _data.addAll([
      _selectedCompanyInfo.stockPrice,
      _selectedCompanyInfo.companyEvaluation,
      _selectedCompanyInfo.sales,
      _selectedCompanyInfo.reputation,
    ]);

    List<ShareChanges> currentChunk = [];
    for (var item in _shareChanges) {
      if (currentChunk.length == 5) {
        chunks.add([...currentChunk]);
        currentChunk.clear();
      }
      currentChunk.add(item);
    }
    if (currentChunk.isNotEmpty) {
      chunks.add([...currentChunk]);
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: _fetchAllData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StatefulBuilder(
            builder: (context, localSetState) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text(
                    'Stock Market',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  backgroundColor: const Color.fromARGB(255, 229, 255, 252),
                ),
                body: Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/background_images/quartz_background.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: const EdgeInsets.all(16.0),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SlidingShareListWidget(chunks: chunks),
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: screenWidth * 0.23,
                                    height: screenHeight * 0.75,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: screenHeight * 0.08,
                                          padding: const EdgeInsets.all(20),
                                          decoration: const BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              229,
                                              255,
                                              252,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            "Owned Shares",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 26,
                                            ),
                                          ),
                                        ),
                                        Divider(height: 1),

                                        SizedBox(height: 10),

                                        _selectedCompanyInfo
                                                .usersShares
                                                .isNotEmpty
                                            ? Expanded(
                                              child: ListView.builder(
                                                itemCount:
                                                    _selectedCompanyInfo
                                                        .usersShares
                                                        .length,
                                                itemBuilder: (context, index) {
                                                  return _buildUserShares(
                                                    _selectedCompanyInfo
                                                        .usersShares[index],
                                                  );
                                                },
                                              ),
                                            )
                                            : Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "No Shares Owned for ${_selectedCompanyInfo.company.name}",
                                                  ),
                                                ],
                                              ),
                                            ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: screenWidth * 0.485,
                                    height: screenHeight * 0.75,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: screenHeight * 0.08,
                                          padding: const EdgeInsets.all(20),
                                          decoration: const BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              229,
                                              255,
                                              252,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            "Company Data Analytics",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 26,
                                            ),
                                          ),
                                        ),
                                        Divider(height: 1),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(32.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: ElevatedButton(
                                                              onPressed: () {
                                                                if (_buttonState !=
                                                                    0) {
                                                                  localSetState(
                                                                    () {
                                                                      _buttonState =
                                                                          0;
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                              child: Text(
                                                                "Stock Price",
                                                              ),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    _buttonState ==
                                                                            0
                                                                        ? Color.fromARGB(
                                                                          255,
                                                                          133,
                                                                          133,
                                                                          133,
                                                                        )
                                                                        : Color.fromARGB(
                                                                          255,
                                                                          209,
                                                                          209,
                                                                          209,
                                                                        ),
                                                                fixedSize:
                                                                    Size.fromHeight(
                                                                      screenHeight *
                                                                          0.05,
                                                                    ),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.only(
                                                                    topLeft:
                                                                        Radius.circular(
                                                                          5,
                                                                        ),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                          5,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: ElevatedButton(
                                                              onPressed: () {
                                                                if (_buttonState !=
                                                                    1) {
                                                                  localSetState(
                                                                    () {
                                                                      _buttonState =
                                                                          1;
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                              child: Text(
                                                                "Evaluation",
                                                              ),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    _buttonState ==
                                                                            1
                                                                        ? Color.fromARGB(
                                                                          255,
                                                                          133,
                                                                          133,
                                                                          133,
                                                                        )
                                                                        : Color.fromARGB(
                                                                          255,
                                                                          209,
                                                                          209,
                                                                          209,
                                                                        ),
                                                                fixedSize:
                                                                    Size.fromHeight(
                                                                      screenHeight *
                                                                          0.05,
                                                                    ),
                                                                shape:
                                                                    RoundedRectangleBorder(),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: ElevatedButton(
                                                              onPressed: () {
                                                                if (_buttonState !=
                                                                    2) {
                                                                  localSetState(
                                                                    () {
                                                                      _buttonState =
                                                                          2;
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                              child: Text(
                                                                "Sales",
                                                              ),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    _buttonState ==
                                                                            2
                                                                        ? Color.fromARGB(
                                                                          255,
                                                                          133,
                                                                          133,
                                                                          133,
                                                                        )
                                                                        : Color.fromARGB(
                                                                          255,
                                                                          209,
                                                                          209,
                                                                          209,
                                                                        ),
                                                                fixedSize:
                                                                    Size.fromHeight(
                                                                      screenHeight *
                                                                          0.05,
                                                                    ),
                                                                shape:
                                                                    RoundedRectangleBorder(),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: ElevatedButton(
                                                              onPressed: () {
                                                                if (_buttonState !=
                                                                    3) {
                                                                  localSetState(
                                                                    () {
                                                                      _buttonState =
                                                                          3;
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                              child: Text(
                                                                "Reputation",
                                                              ),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    _buttonState ==
                                                                            3
                                                                        ? Color.fromARGB(
                                                                          255,
                                                                          133,
                                                                          133,
                                                                          133,
                                                                        )
                                                                        : Color.fromARGB(
                                                                          255,
                                                                          209,
                                                                          209,
                                                                          209,
                                                                        ),
                                                                fixedSize:
                                                                    Size.fromHeight(
                                                                      screenHeight *
                                                                          0.05,
                                                                    ),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.only(
                                                                    topRight:
                                                                        Radius.circular(
                                                                          5,
                                                                        ),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                          5,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 4),
                                                      Expanded(
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                border:
                                                                    Border.all(),
                                                              ),
                                                          child: Linegraph2Widget(
                                                            title: "",
                                                            data:
                                                                _data[_buttonState],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 16),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Data Last Updated:",
                                                          ),
                                                          Text(
                                                            _lastDataRefresh!
                                                                .toString(),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: screenWidth * 0.23,
                                    height: screenHeight * 0.75,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: screenHeight * 0.08,
                                          padding: const EdgeInsets.all(20),
                                          decoration: const BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              229,
                                              255,
                                              252,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            "Company Information",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 26,
                                            ),
                                          ),
                                        ),
                                        Divider(height: 1),
                                        const SizedBox(height: 20),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              0,
                                              16,
                                              16,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    DropdownButton<Company>(
                                                      value: _selectedCompany,
                                                      hint: const Text(
                                                        'Select a company',
                                                      ),
                                                      items:
                                                          _companies.map((
                                                            company,
                                                          ) {
                                                            return DropdownMenuItem<
                                                              Company
                                                            >(
                                                              value: company,
                                                              child: Text(
                                                                company.name,
                                                              ),
                                                            );
                                                          }).toList(),
                                                      onChanged: (
                                                        Company? newCompany,
                                                      ) {
                                                        localSetState(() {
                                                          _selectedCompany =
                                                              newCompany;
                                                        });
                                                      },
                                                    ),
                                                    _buildInfoRow(
                                                      "Company Name:",
                                                      _selectedCompanyInfo
                                                          .company
                                                          .name,
                                                      textColor: Colors.black,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _buildInfoRow(
                                                      "Current Owner:",
                                                      _selectedCompanyInfo
                                                          .ownerName,
                                                      textColor:
                                                          const Color.fromARGB(
                                                            255,
                                                            175,
                                                            175,
                                                            175,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _buildInfoRow(
                                                      "Founded:",
                                                      _selectedCompanyInfo
                                                          .company
                                                          .createdAt
                                                          .toIso8601String()
                                                          .substring(0, 10),
                                                      textColor:
                                                          const Color.fromARGB(
                                                            255,
                                                            175,
                                                            175,
                                                            175,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _buildInfoRow(
                                                      "Current Reputation:",
                                                      "${_selectedCompanyInfo.company.reputation.toString()}/1000",
                                                      textColor:
                                                          const Color.fromARGB(
                                                            255,
                                                            31,
                                                            81,
                                                            248,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _buildInfoRow(
                                                      "Current Evaluation:",
                                                      "${_selectedCompanyInfo.company.evaluation.toStringAsFixed(2)}\$",
                                                      textColor:
                                                          const Color.fromARGB(
                                                            255,
                                                            23,
                                                            221,
                                                            97,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _buildInfoRow(
                                                      "Current Month Sales:",
                                                      "${_selectedCompanyInfo.thisMonthTotalSales.toStringAsFixed(2)}\$",
                                                      textColor:
                                                          const Color.fromARGB(
                                                            255,
                                                            74,
                                                            237,
                                                            217,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _buildInfoRow(
                                                      "Last Month Sales:",
                                                      "${_selectedCompanyInfo.lastMonthTotalSales.toStringAsFixed(2)}\$",
                                                      textColor:
                                                          const Color.fromARGB(
                                                            255,
                                                            7,
                                                            138,
                                                            35,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _buildInfoRow(
                                                      "Last 120 Days Sales:",
                                                      "${_selectedCompanyInfo.total120DaySales.toStringAsFixed(2)}\$",
                                                      textColor:
                                                          const Color.fromARGB(
                                                            255,
                                                            9,
                                                            124,
                                                            190,
                                                          ),
                                                    ),
                                                  ],
                                                ),

                                                Column(
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (
                                                              BuildContext
                                                              context,
                                                            ) {
                                                              return _buyOrderDialog();
                                                            },
                                                          );
                                                        },
                                                        child: Text(
                                                          "Create Buy Order",
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  5,
                                                                ),
                                                          ),
                                                          fixedSize: Size(
                                                            double.infinity,
                                                            screenHeight * 0.05,
                                                          ),
                                                          backgroundColor:
                                                              Color.fromARGB(
                                                                255,
                                                                74,
                                                                237,
                                                                217,
                                                              ),
                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(height: 8),

                                                    Container(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (
                                                              BuildContext
                                                              context,
                                                            ) {
                                                              return _buyOrderDialog();
                                                            },
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  5,
                                                                ),
                                                          ),
                                                          fixedSize: Size(
                                                            double.infinity,
                                                            screenHeight * 0.05,
                                                          ),
                                                          backgroundColor:
                                                              Color.fromARGB(
                                                                255,
                                                                23,
                                                                221,
                                                                97,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          "Create Sell Order",
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return Scaffold(
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/background_images/quartz_background.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.white,
                    ),
                    height: screenHeight * 0.6,
                    width: screenWidth * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Starting MineExchange Stock Market",
                          style: TextStyle(fontSize: 32),
                        ),
                        CircularProgressIndicator(),
                        Text(
                          "This should only take a moment.",
                          style: TextStyle(fontSize: 32),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildUserShares(Share share) {
    double percentChange = (share.value / share.purchasePrice) * 100;
    final isPositive = percentChange > 1 ? true : false;
    final changeText =
        '${isPositive ? '+' : ''}${percentChange.toStringAsFixed(2)}%';
    final changeColor =
        isPositive ? const Color.fromARGB(255, 23, 221, 97) : Colors.redAccent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: InkWell(
            onTap: () {
              context.go('/home/stock_market/sell_share', extra: share);
            },
            hoverColor: Color.fromARGB(255, 201, 249, 255),
            borderRadius: BorderRadius.circular(12.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              leading: ClipRRect(
                child: Image.network(
                  share.company!.avatarUrl,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                share.company?.name ?? 'Unknown Company',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: changeColor,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    changeText,
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currencyFormat.format(share.value),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    (share.stake * 100).toStringAsFixed(3) + "%",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              dense: true,
              visualDensity: const VisualDensity(vertical: -2),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Share>> getUsersShares() async {
    return SupabaseHelper.getSharesByUser();
  }

  Widget _buildInfoRow(String label, String value, {Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buyOrderDialog() {
    return StatefulBuilder(
      builder: (context, dialogSetState) {
        return AlertDialog(
          title: Text("Create Buy Order"),
          content: Text("Create Buy order based on these requirements"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Create Buy Order"),
            ),
          ],
        );
      },
    );
  }

  Future<List<Company>> getAllPublicCompanies() async {
    final companies = await SupabaseHelper.getAllPublicCompanies();

    if (companies != null) {
      return companies;
    } else {
      return [];
    }
  }

  Future<CompanyInfo?> getCompanyInfo(Company company) async {
    final companyInfo = await SupabaseHelper.getCompanyInfo(company);
    return companyInfo;
  }
}
