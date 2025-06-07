import 'package:economycraft/classes/share.dart';
import 'package:flutter/material.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:economycraft/widgets/linegraph_1_widget.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:intl/intl.dart';

class ShareModificationScreen extends StatefulWidget {
  final Share share;

  const ShareModificationScreen({super.key, required this.share});

  @override
  State<ShareModificationScreen> createState() =>
      _ShareModificationScreenState();
}

class _ShareModificationScreenState extends State<ShareModificationScreen> {
  double _numberOfNewShares = 2;
  late double sharesStake;
  bool _isProcessing = false;
  bool _isbuilt = false;
  List<PriceVsTime> _priceVsTimeData = [];
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  // Define min and max share split values
  final double _minShareSplit = 2;
  final double _maxShareSplit = 100;

  @override
  void initState() {
    super.initState();
    sharesStake = widget.share.stake;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Share Modification',
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

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    // Chart section
                    _buildChartSection(screenWidth, screenHeight),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    // Share split controls
                    _buildShareSplitControls(),

                    const SizedBox(height: 32),

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
                      'Share Value: ${currencyFormat.format(widget.share.value)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 74, 237, 217),
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
      height: screenHeight * 0.45,
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

  Widget _buildShareSplitControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share Split Configuration',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 74, 237, 217),
          ),
        ),
        const SizedBox(height: 16),

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
                    'About Share Splitting',
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
                'Share splitting allows you to divide your current share into multiple smaller shares. '
                'The total value remains the same, but each new share will have a proportionally smaller stake percentage allowing you to sell smaller portions of a large share.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Number of shares slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Number of Shares after Split',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 23, 221, 97),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _numberOfNewShares.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color.fromARGB(255, 23, 221, 97),
                inactiveTrackColor: Colors.grey[300],
                thumbColor: const Color.fromARGB(255, 74, 237, 217),
                overlayColor: const Color.fromARGB(30, 74, 237, 217),
                valueIndicatorColor: const Color.fromARGB(255, 74, 237, 217),
                valueIndicatorTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              child: Slider(
                value: _numberOfNewShares,
                min: _minShareSplit,
                max: _maxShareSplit,
                divisions: (_maxShareSplit - _minShareSplit).toInt(),
                label: _numberOfNewShares.toStringAsFixed(0),
                onChanged: (value) {
                  setState(() {
                    _numberOfNewShares = value;
                    sharesStake = widget.share.stake / (value + 1);
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '2 shares',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Text(
                  '100 shares',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Share split details
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
                'Current Stake',
                '${(widget.share.stake * 100).toStringAsFixed(4)}%',
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Current Share Value',
                currencyFormat.format(widget.share.value),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              _buildDetailRow(
                'New Stake Per Share',
                '${(sharesStake / _numberOfNewShares * 100).toStringAsFixed(4)}%',
                valueColor: const Color.fromARGB(255, 23, 221, 97),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'New Value Per Share',
                currencyFormat.format(widget.share.value / _numberOfNewShares),
                valueColor: const Color.fromARGB(255, 23, 221, 97),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Total New Shares',
                '${_numberOfNewShares.toInt()}',
                valueColor: const Color.fromARGB(255, 23, 221, 97),
              ),
            ],
          ),
        ),
      ],
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
          onPressed: _isProcessing ? null : _splitShare,
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
                  : const Icon(Icons.call_split),
          label: Text(_isProcessing ? 'Processing...' : 'Confirm Split'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 74, 237, 217),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            disabledBackgroundColor: const Color.fromARGB(
              255,
              74,
              237,
              217,
            ).withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Future<List<PriceVsTime>> _getPriceVsTimeData() async {
    try {
      return await SupabaseHelper.getSharePriceHistory(widget.share.id);
    } catch (e) {
      // Log error for debugging
      debugPrint('Error fetching price history: $e');
      rethrow;
    }
  }

  Future<void> _splitShare() async {
    // Input validation
    if (_numberOfNewShares < _minShareSplit ||
        _numberOfNewShares > _maxShareSplit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a number of shares between $_minShareSplit and $_maxShareSplit.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show user a confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Share Split'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Are you sure you want to split this share? This action cannot be undone.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'You will create ${_numberOfNewShares.toStringAsFixed(0)} new shares, each with ${(sharesStake * 100).toStringAsFixed(4)}% stake.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                  backgroundColor: const Color.fromARGB(255, 74, 237, 217),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm Split'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await SupabaseHelper.splitSharePrivate(
        widget.share.id,
        _numberOfNewShares.toInt(),
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        if (response) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Share split successfully!'),
              backgroundColor: Color.fromARGB(255, 23, 221, 97),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to split share. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
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
