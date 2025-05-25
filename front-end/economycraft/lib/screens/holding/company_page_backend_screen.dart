import 'package:economycraft/classes/company.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:economycraft/classes/product.dart';
import 'package:economycraft/widgets/product_tile_widget.dart';
import 'package:economycraft/widgets/new_product_button_widget.dart';
import 'package:intl/intl.dart';
import 'package:economycraft/widgets/build_stat_card_widget.dart';
import 'package:economycraft/widgets/build_edit_dialog_widget.dart';
import 'package:economycraft/widgets/build_editable_field_widget.dart';

class CompanyPageBackendScreen extends StatefulWidget {
  final Company? company;

  const CompanyPageBackendScreen({super.key, required this.company});

  @override
  State<CompanyPageBackendScreen> createState() =>
      _CompanyPageBackendScreenState();
}

class _CompanyPageBackendScreenState extends State<CompanyPageBackendScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _minecraftTagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage ${widget.company?.name ?? 'Company'}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            child: SingleChildScrollView(
              child: Container(
                width: screenWidth * 0.7,
                margin: const EdgeInsets.symmetric(vertical: 20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 229, 255, 252),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Company Management',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage company details and products',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Company Information Section
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Company Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 74, 237, 217),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Company information cards
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Company avatar section
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Container(
                                      height: 180,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                            255,
                                            201,
                                            201,
                                            201,
                                          ),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(9),
                                        child: Image.network(
                                          widget.company?.avatarUrl ?? '',
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.business,
                                                size: 64,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _updateCompanyAvatar();
                                      },
                                      icon: const Icon(Icons.photo_camera),
                                      label: const Text('Update Company Logo'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          74,
                                          237,
                                          217,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        minimumSize: const Size(
                                          double.infinity,
                                          45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),

                              // Company details section
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Company name with edit button
                                    BuildEditableFieldWidget(
                                      label: 'Company Name',
                                      value: widget.company?.name ?? '',
                                      onEdit: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (
                                                context,
                                              ) => BuildEditDialogWidget(
                                                title: 'Update Company Name',
                                                initialValue:
                                                    widget.company?.name ?? '',
                                                onSave: _updateCompanyName,
                                              ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Company slogan with edit button
                                    BuildEditableFieldWidget(
                                      label: 'Company Slogan',
                                      value: widget.company?.slogan ?? '',
                                      onEdit: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (
                                                context,
                                              ) => BuildEditDialogWidget(
                                                title: 'Update Company Slogan',
                                                initialValue:
                                                    widget.company?.slogan ??
                                                    '',
                                                onSave: _updateCompanySlogan,
                                              ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Company status with toggle button
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Company Status',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      widget
                                                                  .company
                                                                  ?.isPublic ??
                                                              false
                                                          ? const Color.fromARGB(
                                                            255,
                                                            229,
                                                            255,
                                                            238,
                                                          )
                                                          : const Color.fromARGB(
                                                            255,
                                                            255,
                                                            235,
                                                            235,
                                                          ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color:
                                                        widget
                                                                    .company
                                                                    ?.isPublic ??
                                                                false
                                                            ? const Color.fromARGB(
                                                              255,
                                                              23,
                                                              221,
                                                              97,
                                                            )
                                                            : Colors.red[300]!,
                                                  ),
                                                ),
                                                child: Text(
                                                  widget.company?.isPublic ??
                                                          false
                                                      ? 'PUBLIC'
                                                      : 'PRIVATE',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        widget
                                                                    .company
                                                                    ?.isPublic ??
                                                                false
                                                            ? const Color.fromARGB(
                                                              255,
                                                              23,
                                                              221,
                                                              97,
                                                            )
                                                            : Colors.red[600],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _updateCompanyPublicStatus(
                                              !(widget.company?.isPublic ??
                                                  false),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                widget.company?.isPublic ??
                                                        false
                                                    ? Colors.red[400]
                                                    : const Color.fromARGB(
                                                      255,
                                                      23,
                                                      221,
                                                      97,
                                                    ),
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(
                                            widget.company?.isPublic ?? false
                                                ? 'Make Private'
                                                : 'Make Public',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 40, thickness: 1),

                          // Company statistics
                          Row(
                            children: [
                              BuildStatCardWidget(
                                title: 'Reputation',
                                value:
                                    '${widget.company?.reputation ?? 0} / 1000',
                                icon: Icons.thumbs_up_down,
                                color: const Color.fromARGB(255, 74, 237, 217),
                              ),
                              const SizedBox(width: 16),
                              BuildStatCardWidget(
                                title: 'Company Value',
                                value: currencyFormat.format(
                                  widget.company?.evaluation ?? 0,
                                ),
                                icon: Icons.monetization_on,
                                color: const Color.fromARGB(255, 23, 221, 97),
                              ),
                              const SizedBox(width: 16),
                              BuildStatCardWidget(
                                title: 'Founded On',
                                value: dateFormat.format(
                                  widget.company?.createdAt ?? DateTime.now(),
                                ),
                                icon: Icons.calendar_today,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Add this section after the company statistics section and before the products section
                      // Within the main Padding widget after the company statistics Row

                      // Then continue with the existing Products Section
                    ),
                    const Divider(height: 40, thickness: 1),

                    // Stock Market Section - Only visible for public companies
                    if (widget.company?.isPublic ?? false)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Stock Market',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 74, 237, 217),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Stock configuration action
                                    _configureStockSettings();
                                  },
                                  icon: const Icon(Icons.settings),
                                  label: const Text('Configure Stock'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      23,
                                      221,
                                      97,
                                    ),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Stock price chart
                            Container(
                              height: 200,
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color.fromARGB(
                                    255,
                                    201,
                                    201,
                                    201,
                                  ),
                                  width: 1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 244, 244, 244),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Stock Price History',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.trending_up,
                                            size: 48,
                                            color: Colors.grey[300],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Stock price chart will appear here',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Stock information grid
                            Row(
                              children: [
                                // Current stock price
                                Expanded(
                                  child: _buildStockInfoCardWidget(
                                    title: 'Current Price',
                                    value: '\$${(0.0).toStringAsFixed(2)}',
                                    icon: Icons.attach_money,
                                    color: const Color.fromARGB(
                                      255,
                                      74,
                                      237,
                                      217,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Available shares
                                Expanded(
                                  child: _buildStockInfoCardWidget(
                                    title: 'Available Shares',
                                    value: '${1000}',
                                    icon: Icons.pie_chart,
                                    color: const Color.fromARGB(
                                      255,
                                      23,
                                      221,
                                      97,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Market cap
                                Expanded(
                                  child: _buildStockInfoCardWidget(
                                    title: 'Market Cap',
                                    value:
                                        '\$${((0.0) * (1000)).toStringAsFixed(2)}',
                                    icon: Icons.business_center,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Stock actions
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Issue new shares
                                      _issueNewShares();
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                    label: const Text('Issue New Shares'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        74,
                                        237,
                                        217,
                                      ),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // View investors
                                      _viewInvestors();
                                    },
                                    icon: const Icon(Icons.people_outline),
                                    label: const Text('View Investors'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        23,
                                        221,
                                        97,
                                      ),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const Divider(height: 40, thickness: 1),

                    const Divider(height: 1, thickness: 1),

                    // Products Section
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Company Products',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 74, 237, 217),
                                ),
                              ),
                              NewProductButtonWidget(
                                companyId: widget.company!.id,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Products list
                          FutureBuilder(
                            future: _getProducts(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(30.0),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color.fromARGB(255, 74, 237, 217),
                                      ),
                                    ),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          size: 48,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(height: 16),
                                        Text('Error: ${snapshot.error}'),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No products found',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Add your first product to start selling',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                final products = snapshot.data as List<Product>;
                                return ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      child: ProductTileWidget(
                                        product: product,
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCompanyName(String newName) async {
    if (widget.company != null) {
      await SupabaseHelper.updateCompanyName(widget.company!.id, newName);
      setState(() {
        widget.company!.name = newName;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company name updated successfully')),
        );
      }
    }
  }

  Future<void> _updateCompanySlogan(String newSlogan) async {
    if (widget.company != null) {
      await SupabaseHelper.updateCompanySlogan(widget.company!.id, newSlogan);
      setState(() {
        widget.company!.slogan = newSlogan;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company slogan updated successfully')),
        );
      }
    }
  }

  Future<void> _updateCompanyAvatar() async {
    if (widget.company != null) {
      final url = await SupabaseHelper.updateCompanyAvatar(widget.company!.id);
      setState(() {
        widget.company!.avatarUrl = url ?? widget.company!.avatarUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company logo updated successfully')),
        );
      }
    }
  }

  Future<void> _updateCompanyPublicStatus(bool isPublic) async {
    if (widget.company != null) {
      await SupabaseHelper.updateCompanyPublicStatus(
        widget.company!.id,
        isPublic,
      );
      setState(() {
        widget.company!.isPublic = isPublic;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Company is now ${isPublic ? 'public' : 'private'}'),
          ),
        );
      }
    }
  }

  Future<List<Product>> _getProducts() async {
    if (widget.company != null) {
      return await SupabaseHelper.getProductsByCompanyId(widget.company!.id);
    }
    return [];
  }

  // Add these helper methods at the end of the _CompanyPageBackendScreenState class

  // Helper widget for stock information cards
  Widget _buildStockInfoCardWidget({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color.fromARGB(255, 201, 201, 201),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 244, 244, 244),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Method to handle stock configuration
  void _configureStockSettings() {
    final priceController = TextEditingController(text: (10.0).toString());

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Configure Stock Settings'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Set Initial Stock Price',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Configure your company\'s initial stock price. This will determine the starting value of shares available for investors.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save stock price
                  _updateStockPrice(
                    double.tryParse(priceController.text) ?? 10.0,
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 74, 237, 217),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  // Method to issue new shares
  void _issueNewShares() {
    final sharesController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Issue New Shares'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: sharesController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Shares',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Issuing new shares will dilute the value of existing shares. Use this feature carefully.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Issue new shares logic
                  _processNewShares(int.tryParse(sharesController.text) ?? 100);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 23, 221, 97),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Issue Shares'),
              ),
            ],
          ),
    );
  }

  // Method to view investors
  void _viewInvestors() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Company Investors'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: FutureBuilder(
                future: _getInvestors(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading investors: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData ||
                      (snapshot.data as List).isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text('No investors yet'),
                          const SizedBox(height: 8),
                          const Text(
                            'When players invest in your company, they will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Display investor list
                    final investors = snapshot.data as List;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: investors.length,
                      itemBuilder: (context, index) {
                        final investor = investors[index];
                        return ListTile(
                          title: Text(investor['username'] ?? 'Anonymous'),
                          subtitle: Text('${investor['shares']} shares'),
                          trailing: Text(
                            '\$${(investor['shares'] * (0.0)).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 23, 221, 97),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 74, 237, 217),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  // Methods to interact with backend services
  Future<void> _updateStockPrice(double price) async {
    // if (widget.company != null) {
    //   // Call your helper service to update stock price
    //   await SupabaseHelper.updateCompanyStockPrice(widget.company!.id, price);

    //   setState(() {
    //     // Update the local object
    //     widget.company!.stockPrice = price;
    //   });

    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Stock price updated successfully')),
    //     );
    //   }
    // }
  }

  Future<void> _processNewShares(int shares) async {
    // if (widget.company != null) {
    //   // Call your helper service to issue new shares
    //   await SupabaseHelper.issueNewCompanyShares(widget.company!.id, shares);

    //   setState(() {
    //     // Update the local object
    //     widget.company!.totalShares = (widget.company!.totalShares ?? 1000) + shares;
    //   });

    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Successfully issued $shares new shares')),
    //     );
    //   }
    // }
  }

  Future<List<Map<String, dynamic>>> _getInvestors() async {
    // if (widget.company != null) {
    //   // Call your helper service to get investors
    //   return await SupabaseHelper.getCompanyInvestors(widget.company!.id);
    // }
    // return [];
    return [
      {'username': 'Investor1', 'shares': 50},
      {'username': 'Investor2', 'shares': 30},
      {'username': 'Investor3', 'shares': 20},
    ];
  }
}
