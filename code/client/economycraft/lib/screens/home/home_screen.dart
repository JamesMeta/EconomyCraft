import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:economycraft/screens/home/widgets/build_side_navigation.dart';
import 'package:economycraft/screens/home/widgets/market_movers.dart';
import 'package:economycraft/screens/home/widgets/networth_graph.dart';
import 'package:economycraft/screens/home/widgets/pending_orders.dart';
import 'package:economycraft/screens/home/widgets/quick_access.dart';
import 'package:economycraft/screens/home/widgets/snp500_graph.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:economycraft/common_widgets/shopping_cart_widget.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  late TabController _tabController;
  bool _isNavExpanded = false;

  // Cached data to prevent unnecessary database calls
  double? _userBalance;
  String? _userName;
  String? _userAvatarUrl;
  DateTime? _lastDataRefresh;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    updateUserData();
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
                        shadowColor: const Color.fromARGB(51, 70, 51, 51),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: BuildSideNavigation(flipNav: modifyNavBool),
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
            color: const Color.fromARGB(13, 0, 0, 0),
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
                      color: const Color.fromARGB(25, 0, 0, 0),
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

          // Admin button (only visible to admins)
          FutureBuilder(
            future: isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink(); // Show nothing while loading
              }
              final isAdmin = snapshot.data ?? false;
              return Visibility(
                visible: isAdmin,
                child: Tooltip(
                  message: 'Admin Panel',
                  child: IconButton(
                    icon: const Icon(
                      Icons.admin_panel_settings,
                      color: Color.fromARGB(255, 23, 221, 97),
                    ),
                    onPressed: () {
                      context.go('/home/admin');
                    },
                  ),
                ),
              );
            },
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
            onPressed: updateUserData,
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
                  color: const Color.fromARGB(13, 0, 0, 0),
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
                      color: const Color.fromARGB(13, 0, 0, 0),
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

  Widget _buildDashboardContent(double screenHeight) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shadowColor: const Color.fromARGB(51, 112, 16, 16),
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
          Expanded(flex: 60, child: NetworthGraph()),

          const SizedBox(height: 16),

          // Pending Orders
          Expanded(flex: 40, child: PendingOrders()),
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
          Expanded(flex: 6, child: Snp500Graph()),
          const SizedBox(height: 16),

          // Bottom section: Share Changes and Quick Access
          Expanded(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Share Changes - moved from portfolio to market tab
                Expanded(flex: 3, child: MarketMovers()),

                const SizedBox(width: 16),

                // Quick access buttons - more compact layout
                Expanded(flex: 2, child: QuickAccess()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void modifyNavBool() {
    setState(() {
      _isNavExpanded = !_isNavExpanded;
    });
  }

  Future<bool> isAdmin() async {
    final response = await SupabaseHelper.admin.isAdmin();
    developer.log('Is admin: $response');
    return response;
  }

  Future<void> updateUserData() async {
    final data = await SupabaseHelper.player.getUserData();

    setState(() {
      _userBalance = data["money"];
      _userName = data["minecraft_username"];
      _userAvatarUrl = data["avatar_url"];
    });
  }
}
