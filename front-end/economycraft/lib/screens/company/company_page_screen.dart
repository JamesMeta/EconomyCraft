import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/product.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:economycraft/widgets/product_market_tile_widget.dart';
import 'package:economycraft/widgets/shopping_cart_widget.dart';

class CompanyPageScreen extends StatefulWidget {
  final Company company;

  const CompanyPageScreen({super.key, required this.company});

  @override
  State<CompanyPageScreen> createState() => _CompanyPageScreenState();
}

class _CompanyPageScreenState extends State<CompanyPageScreen> {
  bool isOwner = false;

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
                        const Divider(height: 32),
                        _buildReputationIndicator(widget.company.reputation),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Right Column - Financial Data and Operations
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company Valuation Section
                        Container(
                          width: double.infinity,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Company Valuation',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    currencyFormat.format(
                                      widget.company.evaluation,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 23, 221, 97),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Stock Information Section (if public)
                        if (widget.company.isPublic)
                          Container(
                            width: double.infinity,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Stock Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildStockInfo(),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Buy stock action
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
                                        'Buy Stock',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Sell stock action
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          23,
                                          221,
                                          97,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text(
                                        'Sell Stock',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Products Section
                        Expanded(
                          child: Container(
                            width: double.infinity,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Available Products',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(child: _buildProductsList()),
                              ],
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

  Widget _buildStockInfo() {
    // Placeholder for stock price chart
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('Stock Price Chart', style: TextStyle(color: Colors.grey)),
      ),
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
    final companyId = widget.company.id;
    final response = await SupabaseHelper.getProductsByCompanyId(companyId);
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
}
