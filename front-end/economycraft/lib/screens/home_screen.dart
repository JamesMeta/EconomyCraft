import 'package:economycraft/classes/order.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/classes/share_changes.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:economycraft/widgets/linegraph_1_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:economycraft/widgets/shopping_cart_widget.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  late TabController _tabController;
  int _selectedIndex = 0;
  bool _isNavExpanded = false;

  // Cached data to prevent unnecessary database calls
  double? _userBalance;
  String? _userName;
  String? _userAvatarUrl;
  List<PriceVsTime>? _networthData;
  List<PriceVsTime>? _snpData;
  List<Order>? _orders;
  List<ShareChanges>? _shareChanges;
  DateTime? _lastDataRefresh;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });

    // Initial data load
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() {
      _lastDataRefresh = DateTime.now();
    });

    // Load all data in parallel
    await Future.wait([
      SupabaseHelper.getUserBalance().then((value) => _userBalance = value),
      SupabaseHelper.getUserName().then((value) => _userName = value),
      SupabaseHelper.getUserAvatar().then((value) => _userAvatarUrl = value),
      SupabaseHelper.getNetworthvsTime().then((value) => _networthData = value),
      SupabaseHelper.getSnP500PriceHistory().then((value) => _snpData = value),
      SupabaseHelper.getOrdersForUsersCompanies().then((value) {
        // Filter out completed and received orders
        value.removeWhere((order) => order.complete && order.received);
        _orders = value;
      }),
      SupabaseHelper.getShareChanges().then((value) => _shareChanges = value),
    ]);

    // Update UI if component is still mounted
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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

          // Main content layout
          Column(
            children: [
              // App Bar
              _buildAppBar(screenWidth),

              // Main content
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Side Navigation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: _isNavExpanded ? 220 : 80,
                      child: Card(
                        margin: const EdgeInsets.all(12),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildSideNavigation(),
                      ),
                    ),

                    // Main dashboard content
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 12,
                          right: 12,
                          bottom: 12,
                        ),
                        child: _buildDashboardContent(screenHeight),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(double screenWidth) {
    return Container(
      height: 70, // Slightly reduced height
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 229, 255, 252),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // App logo and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/diamond.png',
                  width: 28,
                  height: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Mine',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 74, 237, 217),
                ),
              ),
              const Text(
                'Exchange',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 23, 221, 97),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Last refresh indicator
          if (_lastDataRefresh != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Last refreshed:',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  Text(
                    DateFormat('HH:mm:ss').format(_lastDataRefresh!),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 74, 237, 217),
                    ),
                  ),
                ],
              ),
            ),

          // Refresh button
          IconButton(
            tooltip: 'Refresh data',
            onPressed: _fetchAllData,
            icon: const Icon(
              Icons.refresh,
              color: Color.fromARGB(255, 74, 237, 217),
              size: 22,
            ),
          ),

          const SizedBox(width: 8),

          // User balance display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: Color.fromARGB(255, 23, 221, 97),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Balance',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      currencyFormat.format(_userBalance ?? 0),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 23, 221, 97),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Shopping cart
          const ShoppingCartWidget(),

          const SizedBox(width: 16),

          // Profile button with avatar
          Tooltip(
            message: 'My Profile',
            child: InkWell(
              onTap: () {
                context.go('/home/profile');
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  image:
                      _userAvatarUrl != null && _userAvatarUrl!.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(_userAvatarUrl!),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    _userAvatarUrl == null || _userAvatarUrl!.isEmpty
                        ? const Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 74, 237, 217),
                        )
                        : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavigation() {
    final List<Map<String, dynamic>> navItems = [
      {
        'title': 'Dashboard',
        'icon': Icons.dashboard,
        'route': '/home',
        'isActive': true,
      },
      {
        'title': 'My Holdings',
        'icon': Icons.pie_chart,
        'route': '/home/holdings',
      },
      {'title': 'Market', 'icon': Icons.storefront, 'route': '/home/market'},
      {'title': 'Orders', 'icon': Icons.receipt_long, 'route': '/home/orders'},
      {
        'title': 'Players',
        'icon': Icons.groups,
        'route': '/home/player_overview',
      },
      {
        'title': 'Funds',
        'icon': Icons.account_balance_wallet,
        'route': '/home/withdrawl_deposit_funds',
      },
      {
        'title': 'Server Info',
        'icon': Icons.info,
        'route': '/home/server_info',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle button for navigation
        Container(
          padding: const EdgeInsets.all(12),
          alignment: _isNavExpanded ? Alignment.centerRight : Alignment.center,
          child: Tooltip(
            message: _isNavExpanded ? 'Collapse Menu' : 'Expand Menu',
            child: IconButton(
              icon: Icon(
                _isNavExpanded ? Icons.chevron_left : Icons.menu,
                color: const Color.fromARGB(255, 74, 237, 217),
              ),
              onPressed: () {
                setState(() {
                  _isNavExpanded = !_isNavExpanded;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ),

        const Divider(height: 1),

        // Navigation items
        Expanded(
          child: ListView.builder(
            itemCount: navItems.length,
            padding: const EdgeInsets.only(top: 8),
            itemBuilder: (context, index) {
              final item = navItems[index];
              final isActive = item['isActive'] ?? false;

              return Tooltip(
                message: _isNavExpanded ? '' : item['title'],
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color:
                        isActive
                            ? const Color.fromARGB(255, 229, 255, 252)
                            : null,
                  ),
                  child: InkWell(
                    onTap: () {
                      context.go(item['route']);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            _isNavExpanded
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'],
                            color:
                                isActive
                                    ? const Color.fromARGB(255, 74, 237, 217)
                                    : Colors.grey[700],
                            size: 24,
                          ),
                          if (_isNavExpanded) ...[
                            const SizedBox(width: 12),
                            Text(
                              item['title'],
                              style: TextStyle(
                                color:
                                    isActive
                                        ? const Color.fromARGB(
                                          255,
                                          74,
                                          237,
                                          217,
                                        )
                                        : Colors.grey[800],
                                fontWeight:
                                    isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const Divider(height: 1),

        // Logout button
        Tooltip(
          message: _isNavExpanded ? '' : 'Logout',
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.red.withOpacity(0.1),
            ),
            child: InkWell(
              onTap: () {
                _showLogoutDialog(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Row(
                  mainAxisAlignment:
                      _isNavExpanded
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.red[400], size: 24),
                    if (_isNavExpanded) ...[
                      const SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDashboardContent(double screenHeight) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dashboard header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.dashboard,
                  size: 24,
                  color: Color.fromARGB(255, 74, 237, 217),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Welcome back, ${_userName ?? 'Trader'}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const Spacer(),
                _buildDateTimeDisplay(),
              ],
            ),
          ),

          const Divider(height: 1),

          // Tab bar for switching between Portfolio and Market views
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color.fromARGB(255, 74, 237, 217),
              unselectedLabelColor: Colors.grey[700],
              indicatorColor: const Color.fromARGB(255, 74, 237, 217),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'YOUR PORTFOLIO'),
                Tab(text: 'MARKET ACTIVITY'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPortfolioTab(screenHeight),
                _buildMarketActivityTab(screenHeight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 1)),
        builder: (context, snapshot) {
          final now = DateTime.now();
          final dateFormat = DateFormat('MMM d, yyyy • HH:mm');
          return Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: Color.fromARGB(255, 74, 237, 217),
              ),
              const SizedBox(width: 6),
              Text(
                dateFormat.format(now),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPortfolioTab(double screenHeight) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Net worth chart - increased height
          _buildSectionCard(
            title: 'Your Net Worth',
            icon: Icons.account_balance_wallet,
            iconColor: const Color.fromARGB(255, 23, 221, 97),
            height: screenHeight * 0.42, // Increased height
            child:
                _networthData == null
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 23, 221, 97),
                        ),
                      ),
                    )
                    : _networthData!.isEmpty
                    ? _buildEmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      message: 'No net worth data available',
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currencyFormat.format(
                                      _networthData!.last.price,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 23, 221, 97),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildChangeIndicator(
                                    _networthData!.first.price,
                                    _networthData!.last.price,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.go('/home/holdings');
                                },
                                icon: const Icon(
                                  Icons.pie_chart_outline,
                                  size: 16,
                                ),
                                label: const Text('View Holdings'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color.fromARGB(
                                    255,
                                    23,
                                    221,
                                    97,
                                  ),
                                  side: const BorderSide(
                                    color: Color.fromARGB(255, 23, 221, 97),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Linegraph1Widget(
                              title: "Net Worth Over Time",
                              data: _networthData!,
                            ),
                          ),
                        ),
                      ],
                    ),
          ),

          const SizedBox(height: 16),

          // Pending Orders
          Expanded(
            child: _buildSectionCard(
              title: 'Pending Orders',
              icon: Icons.receipt_long,
              iconColor: const Color.fromARGB(255, 74, 237, 217),
              child:
                  _orders == null
                      ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(255, 74, 237, 217),
                          ),
                        ),
                      )
                      : _orders!.isEmpty
                      ? _buildEmptyState(
                        icon: Icons.receipt_long_outlined,
                        message: 'No pending orders',
                      )
                      : Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _orders!.length,
                              separatorBuilder:
                                  (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                return _buildOrderItem(_orders![index]);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            child: OutlinedButton(
                              onPressed: () {
                                context.go('/home/orders');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color.fromARGB(
                                  255,
                                  74,
                                  237,
                                  217,
                                ),
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 74, 237, 217),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('View All Orders'),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
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

  Widget _buildMarketActivityTab(double screenHeight) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // S&P 500 chart - increased height
          _buildSectionCard(
            title: 'S&P 500 Market Index',
            icon: Icons.show_chart,
            iconColor: const Color.fromARGB(255, 74, 237, 217),
            height: screenHeight * 0.42, // Increased height
            child:
                _snpData == null
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 74, 237, 217),
                        ),
                      ),
                    )
                    : _snpData!.isEmpty
                    ? _buildEmptyState(
                      icon: Icons.show_chart_outlined,
                      message: 'No market data available',
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currencyFormat.format(_snpData!.last.price),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _snpData!.last.price >=
                                                  _snpData!.first.price
                                              ? const Color.fromARGB(
                                                255,
                                                23,
                                                221,
                                                97,
                                              )
                                              : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildChangeIndicator(
                                    _snpData!.first.price,
                                    _snpData!.last.price,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Last updated: ${_lastDataRefresh != null ? DateFormat('HH:mm').format(_lastDataRefresh!) : "N/A"}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Linegraph1Widget(
                              title: "S&P 500 Price History",
                              data: _snpData!,
                            ),
                          ),
                        ),
                      ],
                    ),
          ),

          const SizedBox(height: 16),

          // Bottom section: Share Changes and Quick Access
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Share Changes - moved from portfolio to market tab
                Expanded(
                  flex: 3,
                  child: _buildSectionCard(
                    title: 'Market Movers',
                    icon: Icons.trending_up,
                    iconColor: const Color.fromARGB(255, 23, 221, 97),
                    child:
                        _shareChanges == null
                            ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.fromARGB(255, 23, 221, 97),
                                ),
                              ),
                            )
                            : _shareChanges!.isEmpty
                            ? _buildEmptyState(
                              icon: Icons.trending_up_outlined,
                              message: 'No share changes to display',
                            )
                            : Column(
                              children: [
                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    itemCount: _shareChanges!.length,
                                    separatorBuilder:
                                        (context, index) =>
                                            const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      return _buildShareChangeItem(
                                        _shareChanges![index],
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      context.go('/home/market');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color.fromARGB(
                                        255,
                                        23,
                                        221,
                                        97,
                                      ),
                                      side: const BorderSide(
                                        color: Color.fromARGB(255, 23, 221, 97),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text('Explore Market'),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),

                const SizedBox(width: 16),

                // Quick access buttons - more compact layout
                Expanded(
                  flex: 2,
                  child: _buildSectionCard(
                    title: 'Quick Access',
                    icon: Icons.bolt,
                    iconColor: const Color.fromARGB(255, 255, 193, 7),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickActionButton(
                              icon: Icons.add_shopping_cart,
                              label: 'Market',
                              color: const Color.fromARGB(255, 23, 221, 97),
                              onTap: () => context.go('/home/market'),
                            ),
                            _buildQuickActionButton(
                              icon: Icons.pie_chart_outline,
                              label: 'Holdings',
                              color: const Color.fromARGB(255, 74, 237, 217),
                              onTap: () => context.go('/home/holdings'),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickActionButton(
                              icon: Icons.business_center_outlined,
                              label: 'New Co.',
                              color: Colors.deepPurpleAccent,
                              onTap:
                                  () => context.go(
                                    '/home/holdings/make_new_company',
                                  ),
                            ),
                            _buildQuickActionButton(
                              icon: Icons.account_balance,
                              label: 'Funds',
                              color: Colors.blue,
                              onTap:
                                  () => context.go(
                                    '/home/withdrawl_deposit_funds',
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
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    double? height,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Add refresh button to each card
                IconButton(
                  icon: const Icon(Icons.refresh, size: 16, color: Colors.grey),
                  tooltip: 'Refresh data',
                  onPressed: _fetchAllData,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 90, // Fixed width
        height: 90, // Fixed height
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeIndicator(double startValue, double endValue) {
    final change = endValue - startValue;
    final percentChange = startValue != 0 ? (change / startValue) * 100 : 0;
    final isPositive = change >= 0;

    return Row(
      children: [
        Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          size: 14,
          color: isPositive ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          '${isPositive ? "+" : ""}${currencyFormat.format(change)} (${isPositive ? "+" : ""}${percentChange.toStringAsFixed(2)}%)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(Order order) {
    final statusColor =
        order.complete
            ? order.received
                ? const Color.fromARGB(255, 23, 221, 97)
                : const Color.fromARGB(255, 74, 237, 217)
            : const Color.fromARGB(255, 255, 193, 7);

    final statusText =
        order.complete
            ? order.received
                ? 'Received'
                : 'Delivered'
            : 'Pending';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image:
              order.product?.avatarUrl != null
                  ? DecorationImage(
                    image: NetworkImage(order.product!.avatarUrl),
                    fit: BoxFit.cover,
                  )
                  : null,
          color: Colors.grey[200],
        ),
        child:
            order.product?.avatarUrl == null
                ? const Icon(Icons.inventory_2, color: Colors.grey)
                : null,
      ),
      title: Text(
        order.product?.name ?? 'Unknown Product',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${order.quantity} units • ${currencyFormat.format(order.payment)}',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor),
        ),
        child: Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
      dense: true,
      onTap: () {
        // Navigate to order details
        context.go('/home/orders');
      },
    );
  }

  Widget _buildShareChangeItem(ShareChanges shareChange) {
    final isPositive = shareChange.change >= 0;
    final changeText =
        '${isPositive ? '+' : ''}${shareChange.change.toStringAsFixed(2)}%';
    final changeColor =
        isPositive ? const Color.fromARGB(255, 23, 221, 97) : Colors.redAccent;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        shareChange.share.company?.name ?? 'Unknown Company',
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
            currencyFormat.format(shareChange.latestValue),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            currencyFormat.format(shareChange.previousValue),
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      onTap: () {
        // Navigate to company details
        if (shareChange.share.company != null) {
          context.go(
            '/home/market/company_page',
            extra: shareChange.share.company,
          );
        }
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[350], size: 36),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.logout, color: Colors.red[400], size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Confirm Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from MineExchange? Any unsaved changes may be lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                logout();
              },
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Keep your existing methods
  Future<void> logout() async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();

    if (mounted) {
      context.go('/login');
    }
  }
}
