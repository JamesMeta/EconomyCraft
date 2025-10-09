import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/share.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/common_widgets/linegraph_2_widget.dart';

class HoldingsScreen extends StatefulWidget {
  const HoldingsScreen({super.key});

  @override
  State<HoldingsScreen> createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends State<HoldingsScreen> {
  bool companySelected = true;
  List<Share> _selectedShares = [];
  late Future<List<Share>?>? _sharesFuture;
  late Future<double> _totalValuation;
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _sharesFuture = getUsersShares();
    _totalValuation = getUsersValue();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Holdings',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 255, 252),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: createNewCompanyButton(),
          ),
        ],
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

          // Main content container
          Center(
            child: Container(
              width: screenWidth * 0.7,
              height: screenHeight * 0.85,
              padding: const EdgeInsets.all(20),
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
                  // Tab selector
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 233, 233, 233),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (!companySelected) toggleCompanySelected();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color:
                                    companySelected
                                        ? const Color.fromARGB(255, 23, 221, 97)
                                        : const Color.fromARGB(
                                          255,
                                          233,
                                          233,
                                          233,
                                        ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.business,
                                    size: 24,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'My Companies',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          companySelected
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (companySelected) toggleCompanySelected();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color:
                                    !companySelected
                                        ? const Color.fromARGB(
                                          255,
                                          74,
                                          237,
                                          217,
                                        )
                                        : const Color.fromARGB(
                                          255,
                                          233,
                                          233,
                                          233,
                                        ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.pie_chart,
                                    size: 24,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'My Shares',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          !companySelected
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content based on selection
                  Expanded(
                    child:
                        companySelected
                            ? _buildCompaniesView()
                            : _buildSharesView(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Companies View
  Widget _buildCompaniesView() {
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Owned Companies',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),

        // Companies list
        Expanded(
          child: FutureBuilder<List<Company>?>(
            future: getUsersCompanies(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
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
                      const Text(
                        'Error loading companies',
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
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                        'You don\'t own any companies yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.go('/home/holdings/make_new_company');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            74,
                            237,
                            217,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Create Your First Company',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                final companies = snapshot.data!;
                return ListView.builder(
                  itemCount: companies.length,
                  itemBuilder: (context, index) {
                    return buildCompanyCard(companies[index]);
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  // Shares View
  Widget _buildSharesView() {
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Share Portfolio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<double>(
              future: _totalValuation,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final value = snapshot.data ?? 0.0;
                return Text(
                  'Total Valuation: ${currencyFormat.format(value)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),

        // Shares list
        Expanded(
          child: FutureBuilder<List<Share>?>(
            future: _sharesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
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
                      const Text(
                        'Error loading shares',
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
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pie_chart_outline,
                        color: Colors.grey[400],
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'You don\'t own any shares yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              } else {
                final shares = snapshot.data!;
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: shares.length,
                        itemBuilder: (context, index) {
                          return buildShareCard(shares[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildShareActions(),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  bool allSharesForSale() {
    return _selectedShares.every((share) => share.purchasable);
  }

  bool allSharesNotForSale() {
    return _selectedShares.every((share) => !share.purchasable);
  }

  bool allSharesArePrivate() {
    return _selectedShares.every((share) => !share.isPublic);
  }

  void selectAllNotForSaleShares() async {
    final shares = await _sharesFuture;
    setState(() {
      _selectedShares.addAll(
        (shares ?? [])
            .where(
              (share) => !share.purchasable && !_selectedShares.contains(share),
            )
            .toList(),
      );
    });
  }

  void selectAllForSaleShares() async {
    final shares = await _sharesFuture;
    setState(() {
      _selectedShares.addAll(
        (shares ?? [])
            .where(
              (share) => share.purchasable && !_selectedShares.contains(share),
            )
            .toList(),
      );
    });
  }

  // Share action buttons
  Widget _buildShareActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        // Quick Sell button
        _buildActionButton(
          icon: Icons.sell,
          label: 'Quick Sell',
          count: _selectedShares.length,
          color: const Color.fromARGB(255, 23, 221, 97),
          isEnabled: _selectedShares.isNotEmpty && allSharesNotForSale(),
          enabledToolTip: 'List all selected shares for current market price',
          disabledToolTip: 'Must have shares selected that are not for sale',
          onPressed: () async {
            if (_selectedShares.isNotEmpty) {
              await quickSell();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No shares selected.')),
              );
            }
          },
        ),

        // Sell Share button
        _buildActionButton(
          icon: Icons.storefront,
          label: 'Sell Share',
          color: const Color.fromARGB(255, 25, 109, 14),
          isEnabled: _selectedShares.length == 1 && allSharesNotForSale(),
          enabledToolTip: 'Sell a single share on the market',
          disabledToolTip:
              'Must have exactly one share selected that is not for sale',
          onPressed: () {
            if (_selectedShares.isNotEmpty) {
              context.go(
                '/home/holdings/sell_share',
                extra: _selectedShares.first,
              );
            }
          },
        ),

        // Remove from Market button
        _buildActionButton(
          icon: Icons.remove_shopping_cart,
          label: 'Delist',
          color: Colors.blueGrey,
          isEnabled: _selectedShares.isNotEmpty && allSharesForSale(),
          enabledToolTip: 'Delist all selected shares from the market',
          disabledToolTip: 'Must have shares selected that are for sale',
          onPressed: () {
            if (_selectedShares.isNotEmpty) {
              makeSharesUnPurchasable();
            }
          },
        ),

        // Clear Selection button
        _buildActionButton(
          icon: Icons.deselect,
          label: 'Clear',
          color: const Color.fromARGB(255, 187, 187, 187),
          isEnabled: _selectedShares.isNotEmpty,
          enabledToolTip: 'Clear all selected shares',
          disabledToolTip: 'No shares selected',
          onPressed: () {
            setState(() {
              _selectedShares.clear();
            });
          },
        ),

        // Select Not For Sale button
        _buildActionButton(
          icon: Icons.unpublished,
          label: 'Select Unlisted',
          color: const Color.fromARGB(255, 255, 193, 7),
          isEnabled: true, // Always enabled
          enabledToolTip: 'Select all shares that are not for sale',
          disabledToolTip: 'All shares are already selected',
          onPressed: () {
            selectAllNotForSaleShares();
          },
        ),

        // Select For Sale button
        _buildActionButton(
          icon: Icons.shopping_cart,
          label: 'Select Listed',
          color: const Color.fromARGB(255, 23, 221, 97),
          isEnabled: true, // Always enabled
          enabledToolTip: 'Select all shares that are for sale',
          disabledToolTip: 'All shares are already selected',
          onPressed: () {
            selectAllForSaleShares();
          },
        ),

        // Refresh Shares button
        _buildActionButton(
          icon: Icons.refresh,
          label: 'Refresh',
          color: const Color.fromARGB(255, 75, 210, 214),
          isEnabled: true, // Always enabled
          enabledToolTip: 'Refresh shares list',
          disabledToolTip: 'Already refreshing',
          onPressed: () {
            _sharesFuture = getUsersShares();
            setState(() {
              _selectedShares.clear();
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isEnabled,
    required String enabledToolTip,
    required String disabledToolTip,
    required VoidCallback onPressed,
    int? count,
  }) {
    return Tooltip(
      message: isEnabled ? enabledToolTip : disabledToolTip,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? color : Colors.grey[350],
          disabledBackgroundColor: Colors.grey[350],
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.grey[600],
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(
              count != null ? '$label (${count.toString()})' : label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Individual company card
  Widget buildCompanyCard(Company company) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color.fromARGB(255, 229, 255, 252),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Keep the navigation to the backend page
          context.go('/home/holdings/backend', extra: company);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Company Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  company.avatarUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[300],
                      child: const Icon(Icons.business, size: 40),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Company Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          company.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (company.isPublic) ...{
                          Tooltip(
                            message: 'Publicly traded company',
                            child: const Icon(
                              Icons.public,
                              color: Color.fromARGB(255, 0, 0, 0),
                              size: 16,
                            ),
                          ),
                        } else ...{
                          Tooltip(
                            message: 'Privately held company',
                            child: const Icon(
                              Icons.lock,
                              color: Color.fromARGB(255, 0, 0, 0),
                              size: 16,
                            ),
                          ),
                        },
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company.slogan,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Founded: ${dateFormat.format(company.createdAt)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Company Valuation
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(company.evaluation),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 23, 221, 97),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(
                      company.verified
                          ? (company.isPublic ? 'Public' : 'Private')
                          : 'Unverified',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor:
                        company.verified
                            ? (company.isPublic
                                ? const Color.fromARGB(255, 23, 221, 97)
                                : Colors.red)
                            : const Color.fromARGB(255, 229, 255, 252),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Individual share card
  Widget buildShareCard(Share share) {
    final percentChange =
        share.value > 0
            ? ((share.value - share.purchasePrice) / share.purchasePrice) * 100
            : 0.0;
    final isProfit = share.value >= share.purchasePrice;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color:
          _selectedShares.contains(share)
              ? const Color.fromARGB(255, 212, 207, 214)
              : const Color.fromARGB(255, 247, 242, 250),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              share.purchasable
                  ? const Color.fromARGB(
                    255,
                    255,
                    193,
                    7,
                  ) // Amber for on market
                  : const Color.fromARGB(255, 229, 255, 252),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (_selectedShares.contains(share)) {
              _selectedShares.remove(share);
            } else {
              _selectedShares.add(share);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  // Selection checkbox
                  const SizedBox(width: 8),

                  // Company Logo
                  if (share.company != null && share.company?.avatarUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        share.company!.avatarUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.business, size: 30),
                          );
                        },
                      ),
                    ),
                  const SizedBox(width: 16),

                  // Share Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              share.company?.name ?? 'Unknown Company',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (share.isPublic) ...{
                              const SizedBox(width: 8),
                              Tooltip(
                                message: 'Public Share',
                                child: const Icon(
                                  Icons.public,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  size: 16,
                                ),
                              ),
                            } else ...{
                              const SizedBox(width: 8),
                              Tooltip(
                                message: 'Private Share',
                                child: const Icon(
                                  Icons.lock,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  size: 16,
                                ),
                              ),
                            },
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stake: ${(share.stake * 100).toStringAsFixed(2)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Share Value & Change
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(share.value),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              isProfit
                                  ? const Color.fromARGB(
                                    255,
                                    23,
                                    221,
                                    97,
                                  ) // Green for profit
                                  : Colors.red, // Red for loss
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            isProfit ? Icons.trending_up : Icons.trending_down,
                            size: 16,
                            color:
                                isProfit
                                    ? const Color.fromARGB(255, 23, 221, 97)
                                    : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isProfit ? '+' : ''}${percentChange.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isProfit
                                      ? const Color.fromARGB(255, 23, 221, 97)
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      showShareDetails(share);
                    },
                    icon: const Icon(
                      Icons.info_outline,
                      color: Color.fromARGB(255, 0, 0, 0),
                      size: 24,
                    ),
                  ),
                ],
              ),

              // Action buttons row
            ],
          ),
        ),
      ),
    );
  }

  void toggleCompanySelected() {
    setState(() {
      companySelected = !companySelected;
      // Clear selected shares when switching tabs
      _selectedShares.clear();
    });
  }

  Widget createNewCompanyButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Navigate to the new company screen
        context.go('/home/holdings/make_new_company');
      },
      icon: const Icon(Icons.add_business, color: Colors.white),
      label: const Text(
        'Create New Company',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 74, 237, 217),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  void showShareDetails(Share share) {
    final percentChange =
        share.value > 0
            ? ((share.value - share.purchasePrice) / share.purchasePrice) * 100
            : 0.0;
    final isProfit = share.value >= share.purchasePrice;

    final TextEditingController splitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.pie_chart,
                color: Color.fromARGB(255, 74, 237, 217),
              ),
              const SizedBox(width: 10),
              const Text('Share Details', style: TextStyle(fontSize: 24)),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company header
                if (share.company != null)
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          share.company!.avatarUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.business, size: 36),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              share.company!.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              share.company!.slogan,
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Share performance graph
                FutureBuilder<List<PriceVsTime>>(
                  future: _getPriceVsTimeData(share),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No price history available'),
                      );
                    } else {
                      final priceHistory = snapshot.data!;
                      return SizedBox(
                        height: 200,
                        child: Linegraph2Widget(
                          title: share.company!.name,
                          data: priceHistory,
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Share details
                _buildDetailRow(
                  'Stake Percentage',
                  '${(share.stake * 100).toStringAsFixed(2)}%',
                ),
                _buildDetailRow(
                  'Purchase Price',
                  currencyFormat.format(share.purchasePrice),
                ),
                _buildDetailRow(
                  'Current Value',
                  currencyFormat.format(share.value),
                ),
                _buildDetailRow(
                  'Value Change',
                  '${isProfit ? '+' : ''}${currencyFormat.format(share.value - share.purchasePrice)} (${isProfit ? '+' : ''}${percentChange.toStringAsFixed(2)}%)',
                  textColor: isProfit ? Colors.green : Colors.red,
                ),
                _buildDetailRow(
                  'Market Status',
                  share.purchasable ? 'Listed for Sale' : 'Not on Market',
                  textColor: share.purchasable ? Colors.orange : Colors.blue,
                ),
                _buildDetailRow(
                  'Share Type',
                  share.isPublic ? 'Public' : 'Private',
                  textColor:
                      share.isPublic
                          ? const Color.fromARGB(255, 105, 199, 93)
                          : const Color.fromARGB(255, 250, 72, 72),
                ),

                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),

                // Visual performance indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Investment Performance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value:
                          isProfit
                              ? (percentChange > 100
                                  ? 1.0
                                  : percentChange / 100)
                              : 0.0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isProfit
                            ? const Color.fromARGB(255, 23, 221, 97)
                            : Colors.red,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isProfit
                          ? 'This investment is performing well!'
                          : 'This investment is currently at a loss',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isProfit
                                ? const Color.fromARGB(255, 23, 221, 97)
                                : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            if (!share.purchasable)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/home/holdings/sell_share', extra: share);
                },
                icon: const Icon(Icons.sell, color: Colors.white),
                label: const Text(
                  'List for Sale',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 23, 221, 97),
                ),
              ),
            if (share.purchasable)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    if (!_selectedShares.contains(share)) {
                      _selectedShares.add(share);
                    }
                    makeSharesUnPurchasable();
                  });
                },
                icon: const Icon(
                  Icons.remove_shopping_cart,
                  color: Colors.white,
                ),
                label: const Text(
                  'Remove Listing',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
              ),
            if (!share.isPublic)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/home/holdings/modify_share', extra: share);
                },
                icon: const Icon(Icons.call_split, color: Colors.white),
                label: const Text(
                  'Split Share',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 204, 255),
                ),
              ),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.close,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              label: const Text(
                'Close',
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 187, 187, 187),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Keep existing methods for data fetching
  Future<double> getUsersValue() async {
    return await SupabaseHelper.getUsersAssetEvaluation();
  }

  Future<List<Share>?> getUsersShares() async {
    return await SupabaseHelper.getSharesByUser();
  }

  Future<List<Company>> getUsersCompanies() async {
    return await SupabaseHelper.getCompaniesByUser();
  }

  Future<void> quickSell() async {
    for (var share in _selectedShares) {
      share.salePrice = share.value; // Set sale price to current value
    }
    await makeSharesPurchasable();
  }

  Future<void> makeSharesPurchasable() async {
    final response = await SupabaseHelper.makeSharesPurchasable(
      _selectedShares,
    );

    if (response) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shares placed on the market!'),
          backgroundColor: Color.fromARGB(255, 23, 221, 97),
        ),
      );

      for (var share in _selectedShares) {
        setState(() {
          share.purchasable = true;
        });
      }

      // Clear selected shares after action
      setState(() {
        _selectedShares = [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place shares on the market.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> makeSharesUnPurchasable() async {
    final response = await SupabaseHelper.makeSharesUnpurchasable(
      _selectedShares,
    );

    if (response) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shares removed from the market!'),
          backgroundColor: Color.fromARGB(255, 74, 237, 217),
        ),
      );

      for (var share in _selectedShares) {
        setState(() {
          share.purchasable = false;
        });
      }

      // Clear selected shares after action
      setState(() {
        _selectedShares = [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove shares from the market.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool allSharesFromSameCompany() {
    if (_selectedShares.isEmpty) return false;
    final companyId = _selectedShares.first.company?.id;
    return _selectedShares.every((share) => share.company?.id == companyId);
  }

  Future<List<PriceVsTime>> _getPriceVsTimeData(share) async {
    try {
      if (share.isPublic) {
        return await SupabaseHelper.getSharePriceHistory(share.companyId);
      } else {
        return await SupabaseHelper.getCompanyPriceHistory(
          share.company!.id,
          share.stake,
        );
      }
    } catch (e) {
      // Log error for debugging
      debugPrint('Error fetching price history: $e');
      rethrow;
    }
  }
}
