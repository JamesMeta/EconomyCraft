import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/companyShare.dart';
import 'package:economycraft/classes/product.dart';
import 'package:economycraft/classes/share.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:economycraft/widgets/product_market_tile_widget.dart';
import 'package:economycraft/widgets/share_market_tile_widget.dart';
import 'package:economycraft/widgets/shopping_cart_widget.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/widgets/linegraph_2_widget.dart';

class CompanyPageScreen extends StatefulWidget {
  final Company company;

  const CompanyPageScreen({super.key, required this.company});

  @override
  State<CompanyPageScreen> createState() => _CompanyPageScreenState();
}

class _CompanyPageScreenState extends State<CompanyPageScreen> {
  bool isOwner = false;
  bool _isbuilt = false;
  List<PriceVsTime> _priceVsTimeData = [];
  List<Share> _shares = [];
  List<Product> _products = [];
  double _topSectionHeight = 0.75; // Initial distribution ratio (50% each)
  double _dragStartY = 0.0;
  double _dragStartTopHeight = 0.0;
  final double _minSectionHeight = 0.2;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('MMM dd, yyyy');
    // Add these variables to your state class:
    // Minimum 20% height for any section

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.company.name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 255, 252),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home/market'),
        ),
        actions: [_takeOverCompanyButton(), ShoppingCartWidget()],
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
              width: screenWidth * 0.8,
              height: screenHeight * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 189, 189, 189),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column - Company Profile
                  Container(
                    width: screenWidth * 0.25,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color.fromARGB(255, 201, 201, 201),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.company.avatarUrl,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.company.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"${widget.company.slogan}"',
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const Divider(height: 32),
                        _buildReputationIndicator(widget.company.reputation),

                        if (widget.company.isPublic) ...[
                          const Divider(height: 32),
                          _buildStockInfo(screenWidth, screenHeight),
                        ],
                        const Divider(height: 32),
                        _buildInfoRow(
                          'Company Type:',
                          widget.company.isPublic ? 'Public' : 'Private',
                          textColor:
                              widget.company.isPublic
                                  ? Colors.green
                                  : Colors.red,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Founded:',
                          dateFormat.format(widget.company.createdAt),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Evaluation:',
                          currencyFormat.format(widget.company.evaluation),
                          textColor: const Color.fromARGB(255, 74, 237, 217),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Right Column - Financial Data and Operations
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Products and Shares section with resize handle
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return _buildResizableSections(
                                constraints.maxHeight,
                              );
                            },
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

  Widget _buildReputationIndicator(int reputation) {
    final score = reputation ~/ 100; // Convert to score out of 10

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reputation Score:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$score/10',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _getReputationColor(score),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: score / 10,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getReputationColor(score)),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Color _getReputationColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.lightGreen;
    if (score >= 4) return Colors.amber;
    if (score >= 2) return Colors.orange;
    return Colors.red;
  }

  // Add this method to build the resizable sections
  Widget _buildResizableSections(double totalHeight) {
    final double dividerHeight = 16.0; // Height of the resize handle
    final double actualTopHeight = totalHeight * _topSectionHeight;
    final double actualBottomHeight =
        totalHeight - actualTopHeight - dividerHeight;

    return Column(
      children: [
        // Top section - Products
        Container(
          height: actualTopHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color.fromARGB(255, 201, 201, 201),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Available Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.drag_handle, color: Colors.grey, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${(_topSectionHeight * 100).toInt()}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: _buildProductsList(),
                ),
              ),
            ],
          ),
        ),

        // Resize handle
        MouseRegion(
          cursor: SystemMouseCursors.resizeUpDown,
          child: GestureDetector(
            onVerticalDragStart: (details) {
              _dragStartY = details.globalPosition.dy;
              _dragStartTopHeight = _topSectionHeight;
            },
            onVerticalDragUpdate: (details) {
              final double dragDistance =
                  details.globalPosition.dy - _dragStartY;
              final double dragFraction = dragDistance / totalHeight;
              setState(() {
                _topSectionHeight = (_dragStartTopHeight + dragFraction).clamp(
                  _minSectionHeight,
                  1 - _minSectionHeight,
                );
              });
            },
            child: Container(
              height: dividerHeight,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  height: 4,
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 74, 237, 217),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Bottom section - Shares (only for public companies)
        Container(
          height: actualBottomHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color.fromARGB(255, 201, 201, 201),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Available Shares',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.drag_handle, color: Colors.grey, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${((1 - _topSectionHeight) * 100).toInt()}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: _buildAvailableStock(),
                ),
              ),
            ],
          ),
        ),
        // Empty widget when company is not public
      ],
    );
  }

  Widget _buildAvailableStock() {
    return FutureBuilder<List<Share>>(
      future: _getShares(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading shares'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No shares available'));
        } else {
          final shares = snapshot.data!;
          return ListView.builder(
            itemCount: shares.length,
            itemBuilder: (context, index) {
              final share = shares[index];
              return ShareMarketTileWidget(share: share);
            },
          );
        }
      },
    );
  }

  Widget _buildStockInfo(screenWidth, screenHeight) {
    // Placeholder for stock price chart
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Stock Price:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: screenHeight * 0.25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1),
            color: const Color.fromARGB(255, 250, 250, 250),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child:
                !_isbuilt
                    ? FutureBuilder<List<PriceVsTime>>(
                      future: _getPriceVsTimeData(),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 60,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _isbuilt = false;
                                    });
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Try Again'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      74,
                                      237,
                                      217,
                                    ),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.show_chart,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No price history available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          _priceVsTimeData = snapshot.data!;
                          _isbuilt = true;
                          return Linegraph2Widget(
                            title: 'Share Price History',
                            subtitle: '${widget.company!.name}',
                            data: snapshot.data!,
                            xAxisLabel: 'Time',
                            yAxisLabel: 'Price',
                          );
                        }
                      },
                    )
                    : Linegraph2Widget(
                      title: 'Share Price History',
                      subtitle: '${widget.company!.name} ',
                      data: _priceVsTimeData,
                      xAxisLabel: 'Time',
                      yAxisLabel: 'Price',
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    return FutureBuilder<List<Product>>(
      future: _getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading products'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products available'));
        } else {
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductMarketTileWidget(product: product);
            },
          );
        }
      },
    );
  }

  Widget _manageCompanyButton() {
    return ElevatedButton(
      onPressed: () {
        // Navigate to company management screen
        context.go('/home/market/company_page/backend', extra: widget.company);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 23, 221, 97),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: const Text(
        'Manage Company',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<List<Product>> _getProducts() async {
    if (_products.isNotEmpty) return _products;

    final companyId = widget.company.id;
    final response = await SupabaseHelper.getProductsByCompanyId(companyId);
    _products = response;
    return response;
  }

  Future<List<Share>> _getShares() async {
    if (_shares.isNotEmpty) return _shares;

    final companyId = widget.company.id;
    final response = await SupabaseHelper.getForSaleSharesByCompanyId(
      companyId,
    );
    _shares = response;
    return response;
  }

  Widget _takeOverCompanyButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton.icon(
        onPressed: () async {
          if (!isOwner) {
            _showTakeOverDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You are already the owner of this company!'),
                backgroundColor: Color.fromARGB(255, 74, 237, 217),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 23, 221, 97),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.business_center, color: Colors.white),
        label: const Text(
          'Take Over',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showTakeOverDialog() async {
    // Show loading indicator while fetching stake data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 74, 237, 217),
              ),
            ),
          ),
    );

    try {
      // Fetch stake data
      final double usersStake = await SupabaseHelper.getPlayersCompanyStake(
        await SupabaseHelper.getPlayerId(),
        widget.company.id,
      );
      final double ownerStake = await SupabaseHelper.getPlayersCompanyStake(
        widget.company.userId,
        widget.company.id,
      );

      // Close loading indicator
      if (context.mounted) Navigator.of(context).pop();

      if (!context.mounted) return;

      final currencyFormat = NumberFormat.percentPattern();

      // Show takeover dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final bool canTakeOver = usersStake > ownerStake;

          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.business_center,
                  color: const Color.fromARGB(255, 74, 237, 217),
                  size: 24,
                ),
                const SizedBox(width: 10),
                const Text('Company Takeover'),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Container(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'To take ownership of this company, you must have more shares than the current owner.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Stake comparison visualization
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Your stake
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your Stake:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              currencyFormat.format(usersStake),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 23, 221, 97),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: usersStake,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(255, 23, 221, 97),
                          ),
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        const SizedBox(height: 20),

                        // Owner stake
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Owner Stake:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              currencyFormat.format(ownerStake),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: ownerStake,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.deepOrangeAccent,
                          ),
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          canTakeOver
                              ? const Color.fromARGB(255, 232, 255, 242)
                              : const Color.fromARGB(255, 255, 232, 232),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            canTakeOver
                                ? const Color.fromARGB(255, 23, 221, 97)
                                : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          canTakeOver
                              ? Icons.check_circle
                              : Icons.error_outline,
                          color:
                              canTakeOver
                                  ? const Color.fromARGB(255, 23, 221, 97)
                                  : Colors.red,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            canTakeOver
                                ? 'You have sufficient shares to take over this company!'
                                : 'You need more shares than the current owner (${((ownerStake - usersStake) * 100 + 0.01).toStringAsFixed(2)}% more needed)',
                            style: TextStyle(
                              color:
                                  canTakeOver
                                      ? const Color.fromARGB(255, 23, 221, 97)
                                      : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[400]!),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed:
                    canTakeOver
                        ? () async {
                          // Show loading indicator
                          Navigator.of(context).pop();
                          _processTakeoverRequest();
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 23, 221, 97),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.gavel, size: 18),
                label: const Text('Take Over Company'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Close loading indicator if error occurs
      if (context.mounted) Navigator.of(context).pop();

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // New helper method to process the takeover
  Future<void> _processTakeoverRequest() async {
    // Show loading dialog during processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 74, 237, 217),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Processing Takeover Request...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('This may take a moment.'),
                ],
              ),
            ),
          ),
    );

    try {
      final response = await SupabaseHelper.takeOverCompany(widget.company.id);

      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      if (response) {
        setState(() {
          isOwner = true;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('You are now the owner of this company!'),
                ],
              ),
              backgroundColor: Color.fromARGB(255, 23, 221, 97),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Failed to take over the company. The owner has more shares than you.',
                  ),
                ],
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if error occurs
      if (context.mounted) Navigator.of(context).pop();

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<CompanyShare> _fetchCompanyStock() async {
    try {
      final share = await SupabaseHelper.getCompanyShareByCompanyId(
        widget.company.id,
      );
      return share;
    } catch (e) {
      debugPrint('Error fetching company stock: $e');
      throw Exception('Failed to fetch company stock');
    }
  }

  Future<List<PriceVsTime>> _getPriceVsTimeData() async {
    try {
      if (_priceVsTimeData.isNotEmpty) return _priceVsTimeData;

      final share = await _fetchCompanyStock();
      if (share.isPublic) {
        return await SupabaseHelper.getSharePriceHistory(share.companyId);
      } else {
        return await SupabaseHelper.getCompanyPriceHistory(
          share.companyId,
          100 / share.numberOfShares,
        );
      }
    } catch (e) {
      debugPrint('Error fetching price history: $e');
      rethrow;
    }
  }
}
