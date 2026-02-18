import 'package:economycraft/classes/company.dart';
import 'package:economycraft/screens/order/company/widgets/company_dropdown_widget.dart';
import 'package:economycraft/screens/order/company/widgets/company_order_footer.dart';
import 'package:economycraft/screens/order/company/widgets/company_order_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:economycraft/classes/order.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';

class OrderCompanyScreen extends StatefulWidget {
  const OrderCompanyScreen({super.key});

  @override
  State<OrderCompanyScreen> createState() => _OrderCompanyScreenState();
}

class _OrderCompanyScreenState extends State<OrderCompanyScreen> {
  bool _showCompletedOrders = false;
  late Company _selectedCompany;
  late final Future<List<Company>> _userCompanies;

  @override
  void initState() {
    _userCompanies = _loadCompanies();

    super.initState();
  }

  Future<List<Company>> _loadCompanies() async {
    final companies = await SupabaseHelper.company.getCompaniesByUser();
    _selectedCompany = companies.first;
    return companies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Company Orders',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 255, 252),
      ),
      body: Stack(
        children: [
          // Background image
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

          // Main content
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 189, 189, 189),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 233, 233, 233),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and company selector
                        Row(
                          children: [
                            const Icon(
                              Icons.business_center_outlined,
                              size: 28,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _showCompletedOrders
                                  ? 'All Company Orders'
                                  : 'Active Orders',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Company dropdown and toggle button row
                        Row(
                          children: [
                            // Company Dropdown
                            Expanded(
                              flex: 3,
                              child: FutureBuilder(
                                future: _userCompanies,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.data!.isNotEmpty) {
                                      final userCompanies = snapshot.data;

                                      return CompanyDropdownWidget(
                                        selectedCompany: _selectedCompany,
                                        userCompanies: userCompanies ?? [],
                                        modifySelectedCompany: (
                                          Company? newCompany,
                                        ) {
                                          if (newCompany != null) {
                                            setState(() {
                                              _selectedCompany = newCompany;
                                            });
                                          }
                                        },
                                      );
                                    } else {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: Text(
                                          "You don't have any companies",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      );
                                    }
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color.fromARGB(255, 74, 237, 217),
                                            ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Toggle button
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showCompletedOrders = !_showCompletedOrders;
                                });
                              },
                              icon: Icon(
                                _showCompletedOrders
                                    ? Icons.history_toggle_off
                                    : Icons.history,
                                color: const Color.fromARGB(255, 74, 237, 217),
                              ),
                              label: Text(
                                _showCompletedOrders
                                    ? 'Hide Completed'
                                    : 'Show All',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 74, 237, 217),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Order List
                  Expanded(
                    child: FutureBuilder(
                      future: _userCompanies,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data!.isNotEmpty) {
                            return FutureBuilder<List<Order>>(
                              future: getOrders(_selectedCompany.id),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color.fromARGB(255, 74, 237, 217),
                                      ),
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  return CompanyOrderListWidget(
                                    orders: snapshot.data ?? [],
                                    showCompletedOrders: _showCompletedOrders,
                                  );
                                } else {
                                  return Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                          size: 60,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Error loading orders',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          snapshot.error.toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            );
                          } else {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.business_outlined,
                                    color: Colors.grey[400],
                                    size: 60,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Create a company to view orders',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),

                  CompanyOrderFooter(setParentState: setState),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Order>> getOrders(int companyId) async {
    return await SupabaseHelper.order.getOrdersMadeForCompany(companyId);
  }

  Future<List<Company>> getCompanies() async {
    return await SupabaseHelper.company.getCompaniesByUser();
  }
}
