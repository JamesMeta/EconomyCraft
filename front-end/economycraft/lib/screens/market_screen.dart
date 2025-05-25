import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:economycraft/classes/company.dart';
import 'package:economycraft/widgets/company_tile_widget.dart';
import 'package:economycraft/widgets/shopping_cart_widget.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _filterType = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Market',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 255, 252),
        actions: [ShoppingCartWidget()],
      ),
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
              width: screenWidth * 0.6,
              height: screenHeight * 0.9,
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
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
                        const Text(
                          'Companies Directory',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Search and Filter Row
                        Row(
                          children: [
                            // Search Box
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search companies...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Filter Dropdown
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: _filterType,
                                    icon: const Icon(Icons.filter_list),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'All',
                                        child: Text('All Companies'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Public',
                                        child: Text('Public Only'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Private',
                                        child: Text('Private Only'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _filterType = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Company List
                  Expanded(
                    child: FutureBuilder(
                      future: getCompanies(),
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
                        } else if (snapshot.hasError) {
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
                                Text(
                                  'Error loading companies',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  snapshot.error.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  color: Colors.grey[400],
                                  size: 60,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No companies found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          List<Company> companies = snapshot.data!;

                          // Apply search filter
                          if (_searchQuery.isNotEmpty) {
                            companies =
                                companies
                                    .where(
                                      (company) => company.name
                                          .toLowerCase()
                                          .contains(_searchQuery.toLowerCase()),
                                    )
                                    .toList();
                          }

                          // Apply type filter
                          if (_filterType == 'Public') {
                            companies =
                                companies
                                    .where((company) => company.isPublic)
                                    .toList();
                          } else if (_filterType == 'Private') {
                            companies =
                                companies
                                    .where((company) => !company.isPublic)
                                    .toList();
                          }

                          if (companies.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    color: Colors.grey[400],
                                    size: 60,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No matching companies found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _filterType = 'All';
                                        _searchController.clear();
                                      });
                                    },
                                    child: const Text('Clear Filters'),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              itemCount: companies.length,
                              itemBuilder: (context, index) {
                                final company = companies[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: CompanyTileWidget(
                                    company: company,
                                    onTap: () {
                                      context.go(
                                        '/home/market/company_page',
                                        extra: company,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  // Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color.fromARGB(255, 229, 255, 252),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing companies in MineExchange',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.refresh,
                            size: 18,
                            color: Color.fromARGB(255, 74, 237, 217),
                          ),
                          label: const Text(
                            'Refresh',
                            style: TextStyle(
                              color: Color.fromARGB(255, 74, 237, 217),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Company>> getCompanies() async {
    final companies = await SupabaseHelper.getCompanies();
    return companies;
  }
}
