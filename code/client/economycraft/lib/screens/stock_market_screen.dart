import 'package:economycraft/classes/buy_order.dart';
import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/company_info.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/classes/share.dart';
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
  late final List<List<PriceVsTime>> _data = [];
  late final Map<String, CompanyInfo> _companyInfoMap = {};
  late List<BuyOrder> _userBuyOrders = [];

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
      getUserBuyOrders().then((value) => _userBuyOrders = value),
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

                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                _selectedCompanyInfo
                                                        .usersShares
                                                        .isNotEmpty
                                                    ? Expanded(
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
                                                          return _sellOrderDialog(
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
                                                              return _viewbuyOrderDialog();
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
                                                              return _buyOrderDialog(
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
    double percentChange = (share.value / share.purchasePrice) * 100;
    final isPositive = percentChange > 1 ? true : false;
    final changeText =
        '${isPositive ? '+' : ''}${percentChange.toStringAsFixed(2)}%';
    final changeColor =
        isPositive ? const Color.fromARGB(255, 23, 221, 97) : Colors.redAccent;

    return Container(
      decoration: BoxDecoration(
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
            leading: ClipRRect(
              child: Image.network(share.company!.avatarUrl, fit: BoxFit.cover),
            ),
            title: Text(
              share.company?.name ?? 'Unknown Company',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                  "${(share.stake * 100).toStringAsFixed(3)}%",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            dense: true,
            visualDensity: const VisualDensity(vertical: -2),
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

  Widget _buyOrderListItem(
    BuyOrder buyOrder,
    void Function(void Function()) setDialogState,
  ) {
    CompanyInfo? companyInfo;

    _companyInfoMap.forEach((key, value) {
      if (value.share.companyShareId == buyOrder.companyShareId) {
        companyInfo = value;
      }
    });

    if (companyInfo == null) {
      return ListTile();
    } else {
      return ListTile(
        leading: Image(
          height: 40,
          width: 40,
          image: NetworkImage(companyInfo!.company.avatarUrl),
        ),
        title: Text(companyInfo!.company.name),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Target Price: \$${buyOrder.maximumSharePrice.toString()}"),
            SizedBox(width: 16),
            Text("Remaining Quantity: ${buyOrder.orderQuality.toString()}"),
          ],
        ),
        trailing: IconButton(
          onPressed: () {
            SupabaseHelper.deleteBuyOrder(buyOrder.id);
            setDialogState(() {
              _userBuyOrders.remove(buyOrder);
            });
          },
          icon: Icon(Icons.delete),
        ),
      );
    }
  }

  Widget _viewbuyOrderDialog() {
    // List<BuyOrder> buyOrdersCopy = _userBuyOrders.where((element) {
    //   return true;
    // },).toList();

    return StatefulBuilder(
      builder: (context, viewBuyDialogSetState) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return AlertDialog(
          content: SizedBox(
            width: screenWidth * (1 / 3),
            height: screenHeight * (3 / 4),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Currently Active Buy Orders",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(),
                      SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _userBuyOrders.length,
                          itemBuilder: (context, index) {
                            return _buyOrderListItem(
                              _userBuyOrders[index],
                              viewBuyDialogSetState,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buyOrderDialog(CompanyInfo companyInfo) {
    TextEditingController amountController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController totalController = TextEditingController();

    final lastSalePrice = companyInfo.share.value.toStringAsFixed(2);
    final cheapestSalePrice = companyInfo.cheapestShare.toStringAsFixed(2);
    final companyName = companyInfo.company.name;
    final companyOwner = companyInfo.ownerName;

    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, buyDialogSetState) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        return AlertDialog(
          content: SizedBox(
            width: screenWidth * (1 / 3),
            height: screenHeight * (3 / 4),
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
                              data: companyInfo.stockPrice,
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
                                      fillColor: Color.fromARGB(
                                        255,
                                        229,
                                        255,
                                        252,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: const Color.fromARGB(
                                            38,
                                            0,
                                            0,
                                            0,
                                          ),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            163,
                                            255,
                                            244,
                                          ),
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.redAccent,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      bool isNum =
                                          int.tryParse(value) != null ||
                                          double.tryParse(value) != null;
                                      bool quantityExists =
                                          int.tryParse(amountController.text) !=
                                              null ||
                                          double.tryParse(
                                                amountController.text,
                                              ) !=
                                              null;

                                      if (isNum && quantityExists) {
                                        double total =
                                            double.parse(value) *
                                            double.parse(amountController.text);

                                        print(total);

                                        buyDialogSetState(() {
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
                                      fillColor: Color.fromARGB(
                                        255,
                                        229,
                                        255,
                                        252,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: const Color.fromARGB(
                                            38,
                                            0,
                                            0,
                                            0,
                                          ),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            163,
                                            255,
                                            244,
                                          ),
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.redAccent,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      bool isNum =
                                          int.tryParse(value) != null ||
                                          double.tryParse(value) != null;
                                      bool priceExists =
                                          int.tryParse(priceController.text) !=
                                              null ||
                                          double.tryParse(
                                                amountController.text,
                                              ) !=
                                              null;

                                      if (isNum && priceExists) {
                                        double total =
                                            double.parse(value) *
                                            double.parse(priceController.text);

                                        print(total);

                                        buyDialogSetState(() {
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
                                      fillColor: Color.fromARGB(
                                        255,
                                        229,
                                        255,
                                        252,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: const Color.fromARGB(
                                            38,
                                            0,
                                            0,
                                            0,
                                          ),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            163,
                                            255,
                                            244,
                                          ),
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.redAccent,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
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

                                      buyDialogSetState(() {
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

                                      fillColor: Color.fromARGB(
                                        255,
                                        255,
                                        255,
                                        255,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: const Color.fromARGB(
                                            38,
                                            0,
                                            0,
                                            0,
                                          ),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          2.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color.fromARGB(
                                            0,
                                            163,
                                            255,
                                            244,
                                          ),
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.redAccent,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
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

                                    buyDialogSetState(() {
                                      isLoading = true;
                                    });

                                    bool priceExists =
                                        int.tryParse(priceController.text) !=
                                            null ||
                                        double.tryParse(
                                              amountController.text,
                                            ) !=
                                            null;
                                    bool quantityExists =
                                        int.tryParse(amountController.text) !=
                                            null ||
                                        double.tryParse(
                                              amountController.text,
                                            ) !=
                                            null;
                                    bool dateExists =
                                        DateTime.tryParse(
                                          dateController.text,
                                        ) !=
                                        null;

                                    if (!priceExists ||
                                        !quantityExists ||
                                        !dateExists) {
                                      buyDialogSetState(() {
                                        totalController.text =
                                            "ERROR: Invalid Price, Quantity, or Date";
                                      });
                                      buyDialogSetState(() {
                                        isLoading = false;
                                      });
                                      return;
                                    }

                                    final DateTime now = DateTime.now();
                                    final DateTime then = DateTime.parse(
                                      dateController.text,
                                    );

                                    final double targetSharePrice =
                                        double.parse(priceController.text);
                                    final double quantity = double.parse(
                                      amountController.text,
                                    );

                                    bool dateInFuture = then.isAfter(now);
                                    bool targetSharePriceIsGreaterThanZero =
                                        targetSharePrice > 0;
                                    bool quantityIsGreaterThanZero =
                                        quantity > 0;

                                    if (!dateInFuture ||
                                        !targetSharePriceIsGreaterThanZero ||
                                        !quantityIsGreaterThanZero) {
                                      buyDialogSetState(() {
                                        totalController.text =
                                            "ERROR: Total must be greater than zero";
                                      });
                                      buyDialogSetState(() {
                                        isLoading = false;
                                      });
                                      return;
                                    }

                                    await createBuyOrder(
                                      targetSharePrice,
                                      quantity,
                                      then,
                                      _selectedCompanyInfo.share.companyShareId,
                                    );
                                    buyDialogSetState(() {
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
      },
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

  Widget _sellOrderDialog(CompanyInfo companyInfo) {
    final lastSalePrice = companyInfo.share.value.toStringAsFixed(2);
    final cheapestSalePrice = companyInfo.cheapestShare.toStringAsFixed(2);
    final companyName = companyInfo.company.name;
    final companyOwner = companyInfo.ownerName;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    bool isLoading = false;
    int spreadState = 0;

    return StatefulBuilder(
      builder: (context, buyDialogSetState) {
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
                buyDialogSetState(() {
                  spreadState = enabledSpreadState;
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

        Widget spreadForms() {
          final formKey = GlobalKey<FormState>();

          final TextEditingController quantityController =
              TextEditingController();
          final TextEditingController priceController = TextEditingController();
          final TextEditingController coefficientController =
              TextEditingController();

          return Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(controller: quantityController),
                TextFormField(controller: priceController),
                TextFormField(controller: coefficientController),
              ],
            ),
          );
        }

        return AlertDialog(
          content: SizedBox(
            width: screenWidth * (1 / 3),
            height: screenHeight * (3 / 4),
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
                        padding: const EdgeInsets.fromLTRB(16, 32, 32, 0),

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
                              data: companyInfo.stockPrice,
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: spreadButton(
                                    Icons.linear_scale,
                                    -45,
                                    "Linear Spread",
                                    "Have your shares +/- in sale price linearly",
                                    0,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: spreadButton(
                                    Icons.redo,
                                    0,
                                    "Logarithmic Spread",
                                    "Have your shares +/- in sale price on a log curve",
                                    1,
                                  ),
                                ),
                              ],
                            ),

                            if (spreadState == 0) spreadForms(),
                            if (spreadState == 1) spreadForms(),
                            if (spreadState == 2) spreadForms(),

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
                                    buyDialogSetState(() {
                                      isLoading = true;
                                    });
                                    buyDialogSetState(() {
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
    _companyInfoMap[company.name] = companyInfo!;
    return companyInfo;
  }

  Future<List<BuyOrder>> getUserBuyOrders() async {
    return await SupabaseHelper.getUserBuyOrders();
  }

  Future<void> createBuyOrder(
    final maximumPrice,
    final quantity,
    final expires,
    final companyShareId,
  ) async {
    final response = await SupabaseHelper.newBuyOrder(
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
}
