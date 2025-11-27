import 'package:economycraft/classes/buy_order.dart';
import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/company_info.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/classes/share.dart';
import 'package:economycraft/screens/stockmarket/widgets/buy_order_dialog_widget.dart';
import 'package:economycraft/screens/stockmarket/widgets/sell_order_dialog_widget.dart';
import 'package:economycraft/common_widgets/linegraph_2_widget.dart';
import 'package:flutter/material.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:economycraft/classes/share_changes.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:economycraft/screens/stockmarket/widgets/sliding_share_list_widget.dart';
import 'package:economycraft/screens/stockmarket/widgets/view_buy_order_dialog_widget.dart';

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
  late final List<List<PriceVsTime>> _data = [];
  late final Map<String, CompanyInfo> _companyInfoMap = {};

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
      SupabaseHelper.home.getShareChanges().then(
        (value) => _shareChanges = value,
      ),
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

    _buildCompanyInfoMap(_companies);

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

  Future<void> _buildCompanyInfoMap(List<Company> companies) async {
    final futures =
        companies.map((company) async {
          final companyInfo = await getCompanyInfo(company);
          if (companyInfo != null &&
              !_companyInfoMap.containsKey(company.name)) {
            _companyInfoMap[company.name] = companyInfo;
          }
        }).toList();
    await Future.wait(futures);
  }

  void _changeCompany(final company, final companyInfo) {
    _selectedCompany = company;
    _selectedCompanyInfo = companyInfo;
    _data.clear();
    _data.addAll([
      _selectedCompanyInfo.stockPrice,
      _selectedCompanyInfo.companyEvaluation,
      _selectedCompanyInfo.sales,
      _selectedCompanyInfo.reputation,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final List<String> labels = [
      "Stock Price",
      "Evaluation",
      "Sales",
      "Reputation",
    ];

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
                                    height: screenHeight * 0.80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
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

                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                _selectedCompanyInfo
                                                        .usersShares
                                                        .isNotEmpty
                                                    ? Expanded(
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                "Shares Owned: ${_selectedCompanyInfo.usersShares.length}",
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                              ),
                                                              Text(
                                                                "Shares not on Market: ${_selectedCompanyInfo.usersShares.where((share) => share.purchasable == false).length}",
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 16),
                                                          Expanded(
                                                            child: ListView.builder(
                                                              itemCount:
                                                                  _selectedCompanyInfo
                                                                      .usersShares
                                                                      .length,
                                                              itemBuilder: (
                                                                context,
                                                                index,
                                                              ) {
                                                                return _buildUserShares(
                                                                  _selectedCompanyInfo
                                                                      .usersShares[index],
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                    : Expanded(
                                                      child: Text(
                                                        "No Shares Owned for ${_selectedCompanyInfo.company.name}",
                                                      ),
                                                    ),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (
                                                          BuildContext context,
                                                        ) {
                                                          return SellOrderDialogWidget(
                                                            companyInfo:
                                                                _selectedCompanyInfo,
                                                          );
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
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: screenWidth * 0.485,
                                    height: screenHeight * 0.80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
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
                                            padding: const EdgeInsets.fromLTRB(
                                              32,
                                              8,
                                              32,
                                              16,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: _sectionButton(
                                                        localSetState,
                                                        labels[1],
                                                        1,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: _sectionButton(
                                                        localSetState,
                                                        labels[0],
                                                        0,
                                                      ),
                                                    ),

                                                    Expanded(
                                                      child: _sectionButton(
                                                        localSetState,
                                                        labels[2],
                                                        2,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: _sectionButton(
                                                        localSetState,
                                                        labels[3],
                                                        3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(),
                                                    ),
                                                    child: Linegraph2Widget(
                                                      title: "",
                                                      data: _data[_buttonState],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text("Data Last Updated:"),
                                                    Text(
                                                      _lastDataRefresh!
                                                          .toString(),
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
                                  Container(
                                    width: screenWidth * 0.23,
                                    height: screenHeight * 0.80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
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
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: DropdownButton<
                                                        Company
                                                      >(
                                                        value: _selectedCompany,
                                                        hint: const Text(
                                                          'Select a company',
                                                        ),
                                                        isExpanded: true,
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
                                                        ) async {
                                                          if (_companyInfoMap
                                                              .containsKey(
                                                                newCompany!
                                                                    .name,
                                                              )) {
                                                            localSetState(
                                                              () => _changeCompany(
                                                                newCompany,
                                                                _companyInfoMap[newCompany
                                                                    .name],
                                                              ),
                                                            );
                                                          } else {
                                                            final String
                                                            companyNameCopy =
                                                                _selectedCompany!
                                                                    .name;

                                                            localSetState(() {
                                                              _selectedCompany!
                                                                      .name =
                                                                  "Loading...";
                                                            });

                                                            final companyInfo =
                                                                await getCompanyInfo(
                                                                  newCompany,
                                                                );

                                                            _selectedCompany
                                                                    ?.name =
                                                                companyNameCopy;

                                                            localSetState(
                                                              () =>
                                                                  _changeCompany(
                                                                    newCompany,
                                                                    companyInfo,
                                                                  ),
                                                            );
                                                          }
                                                        },
                                                      ),
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
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (
                                                              BuildContext
                                                              context,
                                                            ) {
                                                              return FutureBuilder(
                                                                future:
                                                                    getUserBuyOrders(),
                                                                builder: (
                                                                  context,
                                                                  snapshot,
                                                                ) {
                                                                  if (snapshot
                                                                      .hasData) {
                                                                    final orders =
                                                                        snapshot
                                                                            .data!;
                                                                    return ViewBuyOrderDialogWidget(
                                                                      companyInfoMap:
                                                                          _companyInfoMap,
                                                                      userBuyOrders:
                                                                          orders,
                                                                    );
                                                                  } else {
                                                                    return _loadingDialog();
                                                                  }
                                                                },
                                                              );
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
                                                                243,
                                                                245,
                                                                244,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          "View My Buy Orders",
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (
                                                              BuildContext
                                                              context,
                                                            ) {
                                                              return BuyOrderDialogWidget(
                                                                companyInfo:
                                                                    _selectedCompanyInfo,
                                                              );
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
                                                                74,
                                                                237,
                                                                217,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          "Create Buy Order",
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
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.045),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Starting MineExchange Stock Market",
                            style: TextStyle(fontSize: 32),
                          ),
                          LinearProgressIndicator(minHeight: 20),
                          Text(
                            "This should only take a moment.",
                            style: TextStyle(fontSize: 32),
                          ),
                        ],
                      ),
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
    double percentChange =
        (((share.value - share.purchasePrice) / share.purchasePrice)) * 100;

    final isPositive = percentChange >= 0 ? true : false;
    final changeText =
        '${isPositive ? '+' : ''}${percentChange.toStringAsFixed(2)}%';
    final changeColor =
        isPositive ? const Color.fromARGB(255, 23, 221, 97) : Colors.redAccent;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
          ),
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
          child: Stack(
            children: [
              ListTile(
                leading: ClipRRect(
                  child: Image.network(
                    share.company!.avatarUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        share.company?.name ?? 'Unknown Company',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (share.purchasable)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 224, 255, 252),
                          border: Border.all(width: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "On Market",
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                  ],
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
                      "${(share.stake * 100).toStringAsFixed(3)}%",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                dense: true,
                visualDensity: const VisualDensity(vertical: -2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Share>> getUsersShares() async {
    return SupabaseHelper.share.getSharesByUser();
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

  Widget _loadingDialog() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      content: SizedBox(
        width: screenWidth * (1 / 3),
        height: screenHeight * (3 / 4),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _sectionButton(
    void Function(void Function()) localSetState,
    label,
    buttonStateIndex,
  ) {
    return TextButton(
      onPressed: () {
        if (_buttonState != buttonStateIndex) {
          localSetState(() {
            _buttonState = buttonStateIndex;
          });
        }
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        foregroundColor:
            _buttonState == buttonStateIndex
                ? Colors.black
                : Colors.grey[600], // text color
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight:
                  _buttonState == buttonStateIndex
                      ? FontWeight.bold
                      : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          // underline effect
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: _buttonState == buttonStateIndex ? 120 : 60,
            color:
                _buttonState == buttonStateIndex
                    ? const Color(0xFF00BCD4)
                    : const Color.fromARGB(255, 196, 196, 196),
          ),
        ],
      ),
    );
  }

  Future<List<Company>> getAllPublicCompanies() async {
    final companies = await SupabaseHelper.company.getAllPublicCompanies();

    if (companies != null) {
      return companies;
    } else {
      return [];
    }
  }

  Future<CompanyInfo?> getCompanyInfo(Company company) async {
    final companyInfo = await SupabaseHelper.company.getCompanyInfo(company);
    _companyInfoMap[company.name] = companyInfo!;
    return companyInfo;
  }

  Future<List<BuyOrder>> getUserBuyOrders() async {
    return await SupabaseHelper.share.getUserBuyOrders();
  }
}
