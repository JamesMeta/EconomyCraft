import 'package:economycraft/classes/share.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:economycraft/widgets/linegraph_1_widget.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:intl/intl.dart';

class SellHoldingScreen extends StatefulWidget {
  final Share share;

  const SellHoldingScreen({super.key, required this.share});

  @override
  State<SellHoldingScreen> createState() => _SellHoldingScreenState();
}

class _SellHoldingScreenState extends State<SellHoldingScreen> {
  final TextEditingController _priceController = TextEditingController();
  bool _isProcessing = false;
  bool _isbuilt = false;
  List<PriceVsTime> _priceVsTimeData = [];
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  double _suggestedPrice = 0;

  @override
  void initState() {
    super.initState();
    _suggestedPrice = widget.share.value;
    _priceController.text = _suggestedPrice.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sell Share',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 255, 252),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
            child: SingleChildScrollView(
              child: Container(
                width: screenWidth * 0.7,
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.all(24),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header section with company info
                    _buildHeaderSection(),

                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 15),

                    // Chart section
                    _buildChartSection(screenWidth, screenHeight),

                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 15),

                    // Sale price section
                    _buildSalePriceSection(),

                    const SizedBox(height: 15),

                    // Action buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      children: [
        // Company logo
        if (widget.share.company != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.share.company?.avatarUrl ?? '',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.business,
                    size: 40,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),

        const SizedBox(width: 20),

        // Company and share info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.share.company?.name ?? 'Unknown Company',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.share.company?.slogan ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 229, 255, 252),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color.fromARGB(255, 74, 237, 217),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Current Value: ${currencyFormat.format(widget.share.value)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 74, 237, 217),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 245, 230),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color.fromARGB(255, 255, 193, 7),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Stake: ${(widget.share.stake * 100).toStringAsFixed(4)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 153, 0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      height: screenHeight * 0.35,
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
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                      return Linegraph1Widget(
                        title: 'Share Price History',
                        subtitle:
                            '${widget.share.company!.name} ${widget.share.value.toStringAsFixed(5)}',
                        data: snapshot.data!,
                        xAxisLabel: 'Time',
                        yAxisLabel: 'Price',
                      );
                    }
                  },
                )
                : Linegraph1Widget(
                  title: 'Share Price History',
                  subtitle:
                      '${widget.share.company!.name} ${widget.share.value.toStringAsFixed(5)}',
                  data: _priceVsTimeData,
                  xAxisLabel: 'Time',
                  yAxisLabel: 'Price',
                ),
      ),
    );
  }

  Widget _buildSalePriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'List Share for Sale',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 74, 237, 217),
          ),
        ),
        const SizedBox(height: 16),

        // Price input section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Purchase Price',
                currencyFormat.format(widget.share.purchasePrice),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Current Market Value',
                currencyFormat.format(widget.share.value),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Price input
              const Text(
                'Set Your Sale Price',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Sale Price',
                  hintText: 'Enter the price you want to sell for',
                  prefixIcon: const Icon(
                    Icons.attach_money,
                    color: Color.fromARGB(255, 74, 237, 217),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 74, 237, 217),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (value) {
                  // This helps validate the input but we'll also check on submission
                  if (value.isEmpty) return;

                  // Allow only valid decimal inputs
                  try {
                    double.parse(value);
                  } catch (e) {
                    _priceController.text = _suggestedPrice.toStringAsFixed(2);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Price suggestion buttons
              const Text(
                'Quick Price Options:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPriceSuggestionChip(
                    widget.share.value * 0.95,
                    'Market -5%',
                  ),
                  _buildPriceSuggestionChip(widget.share.value, 'Market Value'),
                  _buildPriceSuggestionChip(
                    widget.share.value * 1.05,
                    'Market +5%',
                  ),
                  _buildPriceSuggestionChip(
                    widget.share.value * 1.10,
                    'Market +10%',
                  ),
                ],
              ),
            ],
          ),
        ),

        // Profit calculation
        if (_calculateProfit() != 0)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    _calculateProfit() > 0
                        ? const Color.fromARGB(255, 232, 255, 242)
                        : const Color.fromARGB(255, 255, 232, 232),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      _calculateProfit() > 0
                          ? const Color.fromARGB(255, 23, 221, 97)
                          : Colors.red,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _calculateProfit() > 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color:
                        _calculateProfit() > 0
                            ? const Color.fromARGB(255, 23, 221, 97)
                            : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _calculateProfit() > 0
                              ? 'Estimated Profit'
                              : 'Estimated Loss',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                _calculateProfit() > 0
                                    ? const Color.fromARGB(255, 23, 221, 97)
                                    : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _calculateProfitText(),
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                _calculateProfit() > 0
                                    ? const Color.fromARGB(255, 23, 221, 97)
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        // Explanatory text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 229, 255, 252),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color.fromARGB(255, 74, 237, 217),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color.fromARGB(255, 74, 237, 217),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'About Listing Shares',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 74, 237, 217),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Setting the right price is crucial for a successful sale. Your share will be listed on the market at the price you specify. Other players can purchase it at that price. If priced too high, it may not sell. If priced too low, you might miss out on potential profits.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSuggestionChip(double price, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _priceController.text = price.toStringAsFixed(2);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 74, 237, 217),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              currencyFormat.format(price),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 74, 237, 217),
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.cancel),
          label: const Text('Cancel'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            side: BorderSide(color: Colors.grey[400]!),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _confirmListForSale,
          icon:
              _isProcessing
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Icon(Icons.sell),
          label: Text(_isProcessing ? 'Listing...' : 'List for Sale'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 23, 221, 97),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            disabledBackgroundColor: const Color.fromARGB(
              255,
              23,
              221,
              97,
            ).withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  // Calculate profit based on current input price
  double _calculateProfit() {
    double salePrice = 0;
    try {
      salePrice = double.parse(_priceController.text);
    } catch (e) {
      salePrice = widget.share.value; // Default to current value
    }
    return salePrice - widget.share.purchasePrice;
  }

  // Format the profit text display
  String _calculateProfitText() {
    double profit = _calculateProfit();
    double profitPercentage = (profit / widget.share.purchasePrice) * 100;

    String sign = profit >= 0 ? '+' : '';
    return '$sign${currencyFormat.format(profit)} (${sign}${profitPercentage.toStringAsFixed(2)}%)';
  }

  Future<List<PriceVsTime>> _getPriceVsTimeData() async {
    try {
      if (widget.share.isPublic) {
        return await SupabaseHelper.getSharePriceHistory(
          widget.share!.companyId,
        );
      } else {
        return await SupabaseHelper.getCompanyPriceHistory(
          widget.share.company!.id,
          widget.share.stake,
        );
      }
    } catch (e) {
      debugPrint('Error fetching price history: $e');
      rethrow;
    }
  }

  void _confirmListForSale() {
    // Validate price input
    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a sale price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double salePrice;
    try {
      salePrice = double.parse(_priceController.text);
      if (salePrice <= 0) {
        throw FormatException('Price must be greater than zero');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid positive number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Confirm listing at the specified price
    showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Share Listing'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to list this share for sale at ${currencyFormat.format(salePrice)}?',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // Show comparison with purchase price
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Purchase Price',
                        currencyFormat.format(widget.share.purchasePrice),
                      ),
                      const SizedBox(height: 6),
                      _buildDetailRow(
                        'Current Value',
                        currencyFormat.format(widget.share.value),
                      ),
                      const SizedBox(height: 6),
                      const Divider(),
                      const SizedBox(height: 6),
                      _buildDetailRow(
                        'Your Sale Price',
                        currencyFormat.format(salePrice),
                        valueColor: const Color.fromARGB(255, 23, 221, 97),
                      ),

                      if (_calculateProfit() != 0) ...[
                        const SizedBox(height: 6),
                        _buildDetailRow(
                          _calculateProfit() > 0 ? 'Profit' : 'Loss',
                          _calculateProfitText(),
                          valueColor:
                              _calculateProfit() > 0
                                  ? const Color.fromARGB(255, 23, 221, 97)
                                  : Colors.red,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'Once listed, your share will be available on the market until sold or removed.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 23, 221, 97),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm Listing'),
              ),
            ],
          ),
    ).then((confirmed) {
      if (confirmed == true) {
        _listShareForSale();
      }
    });
  }

  Future<void> _listShareForSale() async {
    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a sale price')),
      );
      return;
    }

    double? salePrice = double.tryParse(_priceController.text);
    if (salePrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid sale price')),
      );
      return;
    }

    if (salePrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale price must be greater than zero')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      widget.share.salePrice = salePrice;
      final List<Share> shareList = [widget.share];
      final response = await SupabaseHelper.makeSharesPurchasable(shareList);

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        if (!response) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error listing share for sale'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Share listed for sale successfully!'),
              backgroundColor: Color.fromARGB(255, 23, 221, 97),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
