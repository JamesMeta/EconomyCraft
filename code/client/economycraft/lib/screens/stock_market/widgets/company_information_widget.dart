import 'package:economycraft/classes/buy_order.dart';
import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/company_info.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:economycraft/screens/stock_market/widgets/buy_order_dialog_widget.dart';
import 'package:economycraft/screens/stock_market/widgets/view_buy_order_dialog_widget.dart';
import 'package:flutter/material.dart';

class CompanyInformationWidget extends StatefulWidget {
  final Company? selectedCompany;
  final CompanyInfo selectedCompanyInfo;
  final Map<String, CompanyInfo> companyInfoMap;
  final List<Company> companies;
  final List<List<PriceVsTime>> data;
  final void Function(void Function()) localSetState;
  final void Function(Company, CompanyInfo, List<List<PriceVsTime>>)
  modifySelectedCompany;

  const CompanyInformationWidget({
    super.key,
    required this.selectedCompany,
    required this.selectedCompanyInfo,
    required this.companyInfoMap,
    required this.companies,
    required this.data,
    required this.localSetState,
    required this.modifySelectedCompany,
  });

  @override
  State<CompanyInformationWidget> createState() =>
      _CompanyInformationWidgetState();
}

class _CompanyInformationWidgetState extends State<CompanyInformationWidget> {
  late Company _selectedCompany;
  late CompanyInfo _selectedCompanyInfo;
  late Map<String, CompanyInfo> _companyInfoMap;
  late List<Company> _companies;

  @override
  void initState() {
    _selectedCompany = widget.selectedCompany!;
    _selectedCompanyInfo = widget.selectedCompanyInfo;
    _companyInfoMap = widget.companyInfoMap;
    _companies = widget.companies;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.23,
      height: screenHeight * 0.80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
              color: Color.fromARGB(255, 229, 255, 252),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              "Company Information",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),
          Divider(height: 1),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButton<Company>(
                          value: _selectedCompany,
                          hint: const Text('Select a company'),
                          isExpanded: true,
                          items:
                              _companies.map((company) {
                                return DropdownMenuItem<Company>(
                                  value: company,
                                  child: Text(company.name),
                                );
                              }).toList(),
                          onChanged: (Company? newCompany) async {
                            if (_companyInfoMap.containsKey(newCompany!.name)) {
                              final List<List<PriceVsTime>> newData = [];

                              newData.addAll([
                                _selectedCompanyInfo.companyEvaluation,
                                _selectedCompanyInfo.stockPrice,
                                _selectedCompanyInfo.sales,
                                _selectedCompanyInfo.reputation,
                              ]);

                              widget.localSetState(
                                () => _changeCompany(
                                  newCompany,
                                  _companyInfoMap[newCompany.name],
                                  newData,
                                ),
                              );
                            } else {
                              final String companyNameCopy =
                                  _selectedCompany.name;

                              widget.localSetState(() {
                                _selectedCompany.name = "Loading...";
                              });

                              final companyInfo = await getCompanyInfo(
                                newCompany,
                              );

                              _selectedCompany.name = companyNameCopy;

                              final List<List<PriceVsTime>> newData = [];

                              newData.addAll([
                                _selectedCompanyInfo.companyEvaluation,
                                _selectedCompanyInfo.stockPrice,
                                _selectedCompanyInfo.sales,
                                _selectedCompanyInfo.reputation,
                              ]);

                              widget.localSetState(
                                () => _changeCompany(
                                  newCompany,
                                  companyInfo,
                                  newData,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      _buildInfoRow(
                        "Company Name:",
                        _selectedCompanyInfo.company.name,
                        textColor: Colors.black,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        "Current Owner:",
                        _selectedCompanyInfo.ownerName,
                        textColor: Colors.black,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        "Founded:",
                        _selectedCompanyInfo.company.createdAt
                            .toIso8601String()
                            .substring(0, 10),
                        textColor: Colors.black,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        "Current Reputation:",
                        "${_selectedCompanyInfo.company.reputation.toString()}/1000",
                        textColor: Colors.black,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        "Current Evaluation:",
                        "${_selectedCompanyInfo.company.evaluation.toStringAsFixed(2)}\$",
                        textColor: Colors.black,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        "Current Month Sales:",
                        "${_selectedCompanyInfo.thisMonthTotalSales.toStringAsFixed(2)}\$",
                        textColor: Colors.black,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        "Last Month Sales:",
                        "${_selectedCompanyInfo.lastMonthTotalSales.toStringAsFixed(2)}\$",
                        textColor: Colors.black,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        "Last 120 Days Sales:",
                        "${_selectedCompanyInfo.total120DaySales.toStringAsFixed(2)}\$",
                        textColor: Colors.black,
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
                              builder: (BuildContext context) {
                                return FutureBuilder(
                                  future: getUserBuyOrders(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final orders = snapshot.data!;
                                      return ViewBuyOrderDialogWidget(
                                        companyInfoMap: _companyInfoMap,
                                        userBuyOrders: orders,
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
                              borderRadius: BorderRadius.circular(5),
                            ),
                            fixedSize: Size(
                              double.infinity,
                              screenHeight * 0.05,
                            ),
                            backgroundColor: Color.fromARGB(255, 243, 245, 244),
                          ),
                          child: Text("View My Buy Orders"),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return BuyOrderDialogWidget(
                                  companyInfo: _selectedCompanyInfo,
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            fixedSize: Size(
                              double.infinity,
                              screenHeight * 0.05,
                            ),
                            backgroundColor: Color.fromARGB(255, 74, 237, 217),
                          ),
                          child: Text("Create Buy Order"),
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
    );
  }

  Future<CompanyInfo?> getCompanyInfo(Company company) async {
    final companyInfo = await SupabaseHelper.company.getCompanyInfo(company);
    _companyInfoMap[company.name] = companyInfo!;
    return companyInfo;
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

  void _changeCompany(final company, final companyInfo, final data) {
    _selectedCompany = company;
    _selectedCompanyInfo = companyInfo;
    widget.modifySelectedCompany(company, companyInfo, data);
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

  Future<List<BuyOrder>> getUserBuyOrders() async {
    return await SupabaseHelper.share.getUserBuyOrders();
  }
}
