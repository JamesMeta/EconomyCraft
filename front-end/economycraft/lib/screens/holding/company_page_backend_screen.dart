import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:economycraft/classes/product.dart';
import 'package:economycraft/widgets/product_tile_widget.dart';
import 'package:economycraft/widgets/new_product_button_widget.dart';
import 'package:intl/intl.dart';
import 'package:economycraft/widgets/build_stat_card_widget.dart';
import 'package:economycraft/widgets/build_edit_dialog_widget.dart';
import 'package:economycraft/widgets/build_editable_field_widget.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/widgets/linegraph_2_widget.dart';
import 'package:economycraft/classes/share.dart';

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
  final TextEditingController _shippingCostController = TextEditingController();

  String _avatarUrl = '';
  bool _imageUploading = false;

  bool _isbuilt = false;
  List<PriceVsTime> _priceVsTimeData = [];
  double _sharePrice = 0.0;
  int _availableShares = 0;
  double _marketCap = 0.0;

  @override
  void initState() {
    super.initState();
    _updateShareDetails();
  }

  Future<void> _updateShareDetails() async {
    if (widget.company == null) return;

    final List<Share> share = await SupabaseHelper.getSharesByCompanyId(
      widget.company!.id,
    );

    if (share.isNotEmpty) {
      setState(() {
        _sharePrice = share[0].value;
        _availableShares = share.length;
        _marketCap = _sharePrice * _availableShares;
      });
    }
  }

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
                                            if (!widget.company!.isPublic) {
                                              showMakePublicStatusDialog();
                                            } else {
                                              showMakePrivateStatusDialog();
                                            }
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
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Stock price chart
                            Container(
                              width: double.infinity,
                              height: screenHeight * 0.3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
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
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(
                                                        Color.fromARGB(
                                                          255,
                                                          74,
                                                          237,
                                                          217,
                                                        ),
                                                      ),
                                                ),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.error_outline,
                                                      color: Colors.red,
                                                      size: 60,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'Error: ${snapshot.error}',
                                                      style: const TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    ElevatedButton.icon(
                                                      onPressed: () {
                                                        setState(() {
                                                          _isbuilt = false;
                                                        });
                                                      },
                                                      icon: const Icon(
                                                        Icons.refresh,
                                                      ),
                                                      label: const Text(
                                                        'Try Again',
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            const Color.fromARGB(
                                                              255,
                                                              74,
                                                              237,
                                                              217,
                                                            ),
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else if (!snapshot.hasData ||
                                                snapshot.data!.isEmpty) {
                                              return Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
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
                                                subtitle:
                                                    '${widget.company!.name}',
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
                            const SizedBox(height: 16),

                            // Stock information grid
                            Row(
                              children: [
                                // Current stock price
                                Expanded(
                                  child: _buildStockInfoCardWidget(
                                    title: 'Current Price',
                                    value:
                                        '\$${_sharePrice.toStringAsFixed(2)}',
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
                                    title: 'Total Shares',
                                    value: '${_availableShares.toString()}',
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
                                    value: '\$${_marketCap.toStringAsFixed(2)}',
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
                                    onPressed: () async {
                                      // Issue new shares
                                      await _issueNewShares();
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                    label: const Text('Conduct Stock Split'),
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
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showAddProductDialog();
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add New Product'),
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

  void showMakePublicStatusDialog() async {
    final requiredShareBreakdown =
        await SupabaseHelper.getMinecraftUsernamesForShareSplitRequirementByUser(
          await SupabaseHelper.getShareSplitRequirementByUser(
            widget.company!.id,
          ),
        );

    // Show loading indicator while fetching data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 74, 237, 217),
              ),
            ),
          ),
    );

    // Close loading indicator once data is fetched
    if (context.mounted) Navigator.of(context).pop();

    if (!context.mounted) return;

    // Display the actual dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isloading = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dialog header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 229, 255, 252),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Color.fromARGB(255, 74, 237, 217),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Make Company Public',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Explanation text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 229, 255, 252),
                        borderRadius: BorderRadius.circular(12),
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
                                'About Going Public',
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
                            'Making your company public changes how your shares are valued and traded. Public companies can attract more investors but are more affected in regards to their image.',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'This will require squashing all current shares so they are equally weighted and priced. This will affect the current shareholders as shown below:',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Share breakdown section
                    const Text(
                      'Share Distribution After Going Public:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Show share breakdown in a container with fixed height and scrolling
                    Container(
                      height: 200, // Fixed height to avoid layout issues
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child:
                          requiredShareBreakdown.isEmpty
                              ? const Center(
                                child: Text(
                                  'No share data available',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                itemCount: requiredShareBreakdown.length,
                                itemBuilder: (context, index) {
                                  final entry = requiredShareBreakdown.entries
                                      .elementAt(index);
                                  return ListTile(
                                    leading: const Icon(
                                      Icons.person,
                                      color: Color.fromARGB(255, 74, 237, 217),
                                    ),
                                    title: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          255,
                                          229,
                                          255,
                                          252,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "${entry.value} Shares",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                            255,
                                            74,
                                            237,
                                            217,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),

                    const SizedBox(height: 16),

                    // Advice text
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 245, 230),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 193, 7),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Color.fromARGB(255, 255, 153, 0),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'You can decrease the number of new shares being issued by purchasing back shares owned by other players. After going public, you can also split shares to increase the number of shares available.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 255, 153, 0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Confirmation text
                    const Text(
                      'Are you sure you want to make your company public?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[400]!),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (isloading) return; // Prevent multiple taps

                            setStateDialog(() {
                              isloading = true;
                            });

                            final bool isPublic = await SupabaseHelper.goPublic(
                              widget.company!.id,
                            );

                            setStateDialog(() {
                              isloading = false;
                            });
                            Navigator.of(context).pop();

                            if (isPublic) {
                              setState(() {
                                widget.company!.isPublic = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Company is now public!'),
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    74,
                                    237,
                                    217,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to make company public',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.public),
                          label:
                              isloading
                                  ? CircularProgressIndicator()
                                  : const Text('Make Public'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                widget.company?.isPublic ?? false
                                    ? Colors.red[400]
                                    : const Color.fromARGB(255, 23, 221, 97),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showMakePrivateStatusDialog() {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Make Company Private'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: const Text(
              'Making your company private will remove it from the public market and restrict share trading to private transactions only.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final bool isPrivate = await SupabaseHelper.goPrivate(
                    widget.company!.id,
                  );
                  Navigator.of(context).pop();

                  if (isPrivate) {
                    setState(() {
                      widget.company!.isPublic = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Company is now private!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to make company private'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Make Private'),
              ),
            ],
          ),
    );
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
  Future<void> _issueNewShares() async {
    final sharesController = TextEditingController(text: '1');
    bool isLoading = false;

    // Show loading indicator while fetching share data
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

    // Fetch current share data
    final Share share = await SupabaseHelper.getCompanyShareByCompanyId(
      widget.company!.id,
    );

    // Close loading indicator
    Navigator.of(context).pop();

    if (!mounted) return;

    // Format numbers
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 2);

    showDialog(
      context: context,
      builder: (context) {
        double sharesStake = share.stake;
        double sharesValue = share.value;
        int splitFactor = 2;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dialog header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 229, 255, 252),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.call_split,
                            color: Color.fromARGB(255, 74, 237, 217),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Perform a Stock Split',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Current share information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          229,
                          255,
                          252,
                        ).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromARGB(
                            255,
                            74,
                            237,
                            217,
                          ).withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Share Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 74, 237, 217),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  'Ownership Per Share',
                                  percentFormat.format(share.stake),
                                  Icons.pie_chart,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInfoItem(
                                  'Value Per Share',
                                  currencyFormat.format(share.value),
                                  Icons.attach_money,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stock split input section
                    const Text(
                      'Stock Split Configuration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: sharesController,
                            decoration: InputDecoration(
                              labelText: 'Split Ratio (1:X)',
                              helperText: 'Enter a number greater than 1',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.numbers),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 74, 237, 217),
                                  width: 2,
                                ),
                              ),
                              errorText:
                                  splitFactor < 2 ? 'Must be at least 2' : null,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              final newFactor = int.tryParse(value) ?? 1;
                              setState(() {
                                splitFactor = newFactor;
                                if (newFactor > 0) {
                                  sharesStake = share.stake / newFactor;
                                  sharesValue = share.value / newFactor;
                                } else {
                                  sharesStake = share.stake;
                                  sharesValue = share.value;
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '1',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_right_alt,
                                    color: Color.fromARGB(255, 74, 237, 217),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    splitFactor.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color:
                                          splitFactor >= 2
                                              ? const Color.fromARGB(
                                                255,
                                                23,
                                                221,
                                                97,
                                              )
                                              : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '1 share becomes $splitFactor',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // After split preview
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 245, 255, 250),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromARGB(
                            255,
                            23,
                            221,
                            97,
                          ).withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.preview,
                                color: Color.fromARGB(255, 23, 221, 97),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'After Split Preview',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 23, 221, 97),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  'New Ownership Per Share',
                                  percentFormat.format(sharesStake),
                                  Icons.pie_chart,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInfoItem(
                                  'New Value Per Share',
                                  currencyFormat.format(sharesValue),
                                  Icons.attach_money,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Information section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 245, 230),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromARGB(
                            255,
                            255,
                            193,
                            7,
                          ).withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color.fromARGB(255, 255, 193, 7),
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'About Stock Splits',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 255, 153, 0),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'A stock split increases the number of shares while maintaining the same total company value. Each investor will maintain their ownership percentage, but will own more shares at a lower price per share. This can make shares more attractive to new investors.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed:
                              isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[400]!),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed:
                              isLoading || splitFactor < 2
                                  ? null
                                  : () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    await _processNewShares(splitFactor);

                                    if (mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                          icon:
                              isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                  : const Icon(Icons.call_split),
                          label: Text(
                            isLoading ? 'Processing...' : 'Perform Split',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              23,
                              221,
                              97,
                            ),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[400],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper method for information items
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Method to view investors
  void _viewInvestors() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Company Investors'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
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
                      (snapshot.data as Map).isEmpty) {
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
                    final Map<Player, double>? investor = snapshot.data;
                    final investors = investor?.keys.toList() ?? [];
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: investors.length,
                      itemBuilder: (context, index) {
                        final player = investors[index];
                        final stake = investor![player]! * 100 ?? 0.0;

                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(player.avatarUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(player.name),
                          subtitle: Text('$stake% Ownership'),
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

  Future<void> _processNewShares(int splitFactor) async {
    if (splitFactor < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You must issue a multiple of atleast 2 for a stock split. Current value: $splitFactor',
          ),
        ),
      );
      return;
    }

    final response = await SupabaseHelper.splitSharePublic(
      widget.company!.id,
      splitFactor,
    );
    if (response) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shares issued successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to issue new shares')),
      );
    }
  }

  Future<Share> _fetchCompanyStock() async {
    try {
      final share = await SupabaseHelper.getCompanyShareByCompanyId(
        widget.company!.id,
      );
      return share;
    } catch (e) {
      debugPrint('Error fetching company stock: $e');
      throw Exception('Failed to fetch company stock');
    }
  }

  Future<List<PriceVsTime>> _getPriceVsTimeData() async {
    try {
      final share = await _fetchCompanyStock();
      if (share.isPublic) {
        return await SupabaseHelper.getSharePriceHistory(share!.companyId);
      } else {
        return await SupabaseHelper.getCompanyPriceHistory(
          share.company!.id,
          share.stake,
        );
      }
    } catch (e) {
      debugPrint('Error fetching price history: $e');
      rethrow;
    }
  }

  Future<Map<Player, double>> _getInvestors() async {
    try {
      final investors = await SupabaseHelper.getInvestorsForCompany(
        widget.company!.id,
      );
      return investors;
    } catch (e) {
      debugPrint('Error fetching investors for company: $e');
      return {};
    }
  }

  void _showAddProductDialog() {
    // Reset form fields
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _quantityController.clear();
    _minecraftTagController.clear();
    _shippingCostController.clear();
    _avatarUrl = '';

    // Form validation flags
    bool nameError = false;
    bool priceError = false;
    bool quantityError = false;
    bool tagError = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Validate input and update error states
            void validateField(String field) {
              switch (field) {
                case 'name':
                  setDialogState(
                    () => nameError = _nameController.text.isEmpty,
                  );
                  break;
                case 'price':
                  setDialogState(
                    () =>
                        priceError =
                            _priceController.text.isEmpty ||
                            double.tryParse(_priceController.text) == null,
                  );
                  break;
                case 'quantity':
                  setDialogState(
                    () =>
                        quantityError =
                            _quantityController.text.isEmpty ||
                            int.tryParse(_quantityController.text) == null,
                  );
                  break;
                case 'tag':
                  setDialogState(
                    () => tagError = _minecraftTagController.text.isEmpty,
                  );
                  break;
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                width: 450,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 229, 255, 252),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_shopping_cart,
                            color: Color.fromARGB(255, 74, 237, 217),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add New Product',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Enter product details to add to your inventory',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image upload and basic info section
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image Upload
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Product Image',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                            255,
                                            201,
                                            201,
                                            201,
                                          ),
                                        ),
                                      ),
                                      child:
                                          _avatarUrl.isNotEmpty
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                                child: Image.network(
                                                  _avatarUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Icon(
                                                      Icons.image_not_supported,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    );
                                                  },
                                                ),
                                              )
                                              : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.add_photo_alternate,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Upload Image',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: 120,
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            _imageUploading
                                                ? null
                                                : () async {
                                                  setDialogState(() {
                                                    _imageUploading = true;
                                                  });

                                                  final url =
                                                      await SupabaseHelper.addProductAvatar();

                                                  setDialogState(() {
                                                    _avatarUrl = url ?? '';
                                                    _imageUploading = false;
                                                  });
                                                },
                                        icon:
                                            _imageUploading
                                                ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                                : const Icon(
                                                  Icons.upload_file,
                                                  size: 14,
                                                ),
                                        label: Text(
                                          _imageUploading
                                              ? 'Uploading...'
                                              : 'Select Image',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            74,
                                            237,
                                            217,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),

                                // Basic product info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        controller: _nameController,
                                        decoration: InputDecoration(
                                          labelText: 'Product Name*',
                                          border: const OutlineInputBorder(),
                                          errorText:
                                              nameError
                                                  ? 'Name is required'
                                                  : null,
                                        ),
                                        onChanged: (_) => validateField('name'),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: _descriptionController,
                                        decoration: const InputDecoration(
                                          labelText:
                                              'Product Description (Optional)',
                                          border: OutlineInputBorder(),
                                          alignLabelWithHint: true,
                                        ),
                                        maxLines: 3,
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: _minecraftTagController,
                                        decoration: InputDecoration(
                                          labelText: 'Minecraft Tag*',
                                          border: const OutlineInputBorder(),
                                          hintText: 'e.g. minecraft:diamond',
                                          helperText:
                                              'The exact Minecraft item ID',
                                          errorText:
                                              tagError
                                                  ? 'Tag is required'
                                                  : null,
                                          suffixIcon: const Icon(Icons.tag),
                                        ),
                                        onChanged: (_) => validateField('tag'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 24),

                            // Pricing and inventory section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pricing & Inventory',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 74, 237, 217),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Unit Price*',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextField(
                                            controller: _priceController,
                                            decoration: InputDecoration(
                                              border:
                                                  const OutlineInputBorder(),
                                              prefixIcon: const Icon(
                                                Icons.attach_money,
                                                color: Color.fromARGB(
                                                  255,
                                                  23,
                                                  221,
                                                  97,
                                                ),
                                              ),
                                              errorText:
                                                  priceError
                                                      ? 'Enter valid price'
                                                      : null,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 16,
                                                  ),
                                            ),
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            onChanged:
                                                (_) => validateField('price'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Quantity*',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextField(
                                            controller: _quantityController,
                                            decoration: InputDecoration(
                                              border:
                                                  const OutlineInputBorder(),
                                              prefixIcon: const Icon(
                                                Icons.inventory_2,
                                                color: Colors.blueGrey,
                                              ),
                                              errorText:
                                                  quantityError
                                                      ? 'Enter valid quantity'
                                                      : null,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 16,
                                                  ),
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged:
                                                (_) =>
                                                    validateField('quantity'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Action buttons
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '* Required fields',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Validate all fields
                              setDialogState(() {
                                nameError = _nameController.text.isEmpty;
                                priceError =
                                    _priceController.text.isEmpty ||
                                    double.tryParse(_priceController.text) ==
                                        null;
                                quantityError =
                                    _quantityController.text.isEmpty ||
                                    int.tryParse(_quantityController.text) ==
                                        null;
                                tagError = _minecraftTagController.text.isEmpty;
                              });

                              // If all valid, add product
                              if (!nameError &&
                                  !priceError &&
                                  !quantityError &&
                                  !tagError) {
                                _addProduct();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                23,
                                221,
                                97,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addProduct() async {
    // Validate form
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _minecraftTagController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      double price = double.parse(_priceController.text);
      int quantity = int.parse(_quantityController.text);

      if (price < 0 || quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Price must be greater than 0 and quantity must be a positive integer',
            ),
          ),
        );
        return;
      }

      await SupabaseHelper.addProductToCompany(
        widget.company!.id,
        _nameController.text,
        _descriptionController.text,
        price,
        quantity,
        _minecraftTagController.text,
        _avatarUrl.isNotEmpty
            ? _avatarUrl
            : 'https://example.com/default-product.png',
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );

        // Force rebuild of parent widget
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding product: $e')));
    }
  }
}
