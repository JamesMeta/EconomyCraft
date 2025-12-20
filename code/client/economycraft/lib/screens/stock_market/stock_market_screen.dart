import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/company_info.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/screens/stock_market/widgets/company_data_analytics_widget.dart';
import 'package:economycraft/screens/stock_market/widgets/company_information_widget.dart';
import 'package:economycraft/screens/stock_market/widgets/owned_shares_widget.dart';
import 'package:flutter/material.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:economycraft/classes/share_changes.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:economycraft/screens/stock_market/widgets/sliding_share_list_widget.dart';

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
                                  OwnedSharesWidget(
                                    selectedCompanyInfo: _selectedCompanyInfo,
                                  ),
                                  CompanyDataAnalyticsWidget(
                                    data: _data,
                                    lastDataRefreshed: _lastDataRefresh,
                                  ),
                                  CompanyInformationWidget(
                                    selectedCompany: _selectedCompany,
                                    selectedCompanyInfo: _selectedCompanyInfo,
                                    companyInfoMap: _companyInfoMap,
                                    companies: _companies,
                                    data: _data,
                                    localSetState: localSetState,
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
}
