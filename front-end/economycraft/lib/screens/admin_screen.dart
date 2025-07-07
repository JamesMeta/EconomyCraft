import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/order.dart';
import 'package:economycraft/classes/product.dart';
import 'package:flutter/material.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:file_picker/file_picker.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _companyAvatarUrl =
      'https://cdn-icons-png.flaticon.com/512/149/149071.png';

  // Form controllers
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyDescriptionController =
      TextEditingController();
  final TextEditingController _lotNumberController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _splitFactorController = TextEditingController();
  final TextEditingController _visibilityFactorController =
      TextEditingController();
  final TextEditingController _messageTitleController = TextEditingController();
  final TextEditingController _messageContentController =
      TextEditingController();
  final TextEditingController _productValueController = TextEditingController();
  final TextEditingController _productNicheController = TextEditingController();
  String _productImageUrl =
      'https://cdn-icons-png.flaticon.com/512/1170/1170576.png';
  Company? _selectedCompany;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productQuantityController =
      TextEditingController();
  final TextEditingController _productMinecraftTagController =
      TextEditingController();

  // Data containers
  List<Company> _companies = [];
  List<Order> _aiCompanyOrders = [];
  List<Order> _aiUserOrders = [];
  List<Product> _unverifiedProducts = [];

  bool _notificationEnabled = true;
  bool _isMessageImportant = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyNameController.dispose();
    _companyDescriptionController.dispose();
    _lotNumberController.dispose();
    _userIdController.dispose();
    _splitFactorController.dispose();
    _visibilityFactorController.dispose();
    _messageTitleController.dispose();
    _messageContentController.dispose();
    _productValueController.dispose();
    _productNicheController.dispose();
    // Dispose of new controllers
    _productNameController.dispose();
    _productDescriptionController.dispose();
    _productPriceController.dispose();
    _productQuantityController.dispose();
    _productMinecraftTagController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final companies = await getAllCompanies();
      final aiCompanyOrders = await getAllOrdersForAiCompanies();
      final aiUserOrders = await getAllOrdersForAiUser();
      final unverifiedProducts = await getAllNonVerifiedProducts();

      setState(() {
        _companies = companies;
        _aiCompanyOrders = aiCompanyOrders;
        _aiUserOrders = aiUserOrders;
        _unverifiedProducts = unverifiedProducts;
      });
    } catch (e) {
      _showErrorSnackbar('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _pickCompanyAvatar() async {
    setState(() => _isLoading = true);
    try {
      final url = await SupabaseHelper.addCompanyAvatar();
      if (url.isNotEmpty) {
        setState(() => _companyAvatarUrl = url);
      } else {
        _showErrorSnackbar('Failed to upload company avatar');
      }
    } catch (e) {
      _showErrorSnackbar('Error uploading avatar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Companies'),
            Tab(text: 'Stock Split'),
            Tab(text: 'Create Company'),
            Tab(text: 'Create Product'),
            Tab(text: 'AI Company Orders'),
            Tab(text: 'AI User Orders'),
            Tab(text: 'Admin Messages'),
            Tab(text: 'Unverified Products'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshAllData,
            tooltip: 'Refresh all data',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildCompaniesTab(),
                  _buildStockSplitTab(),
                  _buildCreateCompanyTab(),
                  _buildCreateProductTab(), // Add the new tab
                  _buildAICompanyOrdersTab(),
                  _buildAIUserOrdersTab(),
                  _buildAdminMessagesTab(),
                  _buildUnverifiedProductsTab(),
                ],
              ),
    );
  }

  // Tab 1: Companies Management
  Widget _buildCompaniesTab() {
    return RefreshIndicator(
      onRefresh: () async {
        final companies = await getAllCompanies();
        setState(() => _companies = companies);
      },
      child:
          _companies.isEmpty
              ? const Center(child: Text('No companies found'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _companies.length,
                itemBuilder: (context, index) {
                  final company = _companies[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  company.avatarUrl,
                                ),
                                radius: 30,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      company.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      company.slogan,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Chip(
                                label: Text(
                                  company.verified ? 'Verified' : 'Unverified',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor:
                                    company.verified
                                        ? Colors.green
                                        : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(
                                  company.isPublic ? 'Public' : 'Private',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor:
                                    company.isPublic
                                        ? Colors.blue
                                        : Colors.purple,
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: const Text('Lot Number'),
                                  subtitle: Text('${company.lotNumber}'),
                                  dense: true,
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: const Text('Visibility Factor'),
                                  subtitle: Text('${company.visibilityFactor}'),
                                  dense: true,
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: const Text('Evaluation'),
                                  subtitle: Text(
                                    '\$${company.evaluation.toStringAsFixed(2)}',
                                  ),
                                  dense: true,
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: const Text('Reputation'),
                                  subtitle: Text('${company.reputation}'),
                                  dense: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ExpansionTile(
                            title: const Text('Admin Controls'),
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _visibilityFactorController,
                                      decoration: const InputDecoration(
                                        labelText: 'Visibility Factor (1-10)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      final factor = int.tryParse(
                                        _visibilityFactorController.text,
                                      );
                                      if (factor != null &&
                                          factor >= 1 &&
                                          factor <= 10) {
                                        setCompanyVisibilityFactor(
                                          company.id,
                                          factor,
                                        );
                                      } else {
                                        _showErrorSnackbar(
                                          'Please enter a valid visibility factor (1-10)',
                                        );
                                      }
                                    },
                                    child: const Text('Set Visibility'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.public),
                                    label: const Text('Make Public'),
                                    onPressed:
                                        company.isPublic
                                            ? null
                                            : () =>
                                                makeCompanyPublic(company.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.lock),
                                    label: const Text('Make Private'),
                                    onPressed:
                                        !company.isPublic
                                            ? null
                                            : () =>
                                                makeCompanyPrivate(company.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.verified),
                                    label: const Text('Verify'),
                                    onPressed:
                                        company.verified
                                            ? null
                                            : () => verifyCompany(
                                              company.id,
                                              _visibilityFactorController
                                                      .text
                                                      .isNotEmpty
                                                  ? int.parse(
                                                    _visibilityFactorController
                                                        .text,
                                                  )
                                                  : 1,
                                            ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  // Tab 2: Stock Split
  Widget _buildStockSplitTab() {
    final publicCompanies =
        _companies.where((company) => company.isPublic).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stock Split for Public Companies',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Perform a stock split to increase the number of shares while decreasing their individual value proportionally.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          if (publicCompanies.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No public companies available'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: publicCompanies.length,
                itemBuilder: (context, index) {
                  final company = publicCompanies[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(company.avatarUrl),
                            ),
                            title: Text(company.name),
                            subtitle: Text(
                              'Evaluation: \$${company.evaluation.toStringAsFixed(2)}',
                            ),
                            trailing: Chip(
                              label: const Text(
                                'PUBLIC',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _splitFactorController,
                                    decoration: const InputDecoration(
                                      labelText: 'Split Factor',
                                      hintText: 'e.g. 2 for 2:1 split',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.call_split),
                                  label: const Text('Split Shares'),
                                  onPressed: () {
                                    final factor = int.tryParse(
                                      _splitFactorController.text,
                                    );
                                    if (factor != null && factor > 1) {
                                      splitPublicShares(company.id, factor);
                                    } else {
                                      _showErrorSnackbar(
                                        'Please enter a valid split factor (greater than 1)',
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Note: A 2:1 split will double the number of shares while halving their individual value.',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // Add this function to pick product images
  Future<void> _pickProductImage() async {
    setState(() => _isLoading = true);
    try {
      final url = await SupabaseHelper.addProductAvatar();
      if (url != null && url.isNotEmpty) {
        setState(() => _productImageUrl = url);
      } else {
        _showErrorSnackbar('Failed to upload product image');
      }
    } catch (e) {
      _showErrorSnackbar('Error uploading product image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Tab 3: Create Company
  Widget _buildCreateCompanyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Company for User',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Two columns layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Company Avatar
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Company Logo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child:
                          _companyAvatarUrl.isEmpty
                              ? const Center(
                                child: Icon(
                                  Icons.business,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              )
                              : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  _companyAvatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Center(
                                            child: Icon(Icons.error),
                                          ),
                                ),
                              ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Logo'),
                      onPressed: _pickCompanyAvatar,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 45),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 32),

              // Right column - Company Details Form
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _companyDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Company Slogan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _lotNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Lot Number',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.place),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _userIdController,
                            decoration: const InputDecoration(
                              labelText: 'User ID',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: const Text(
                        'Company owner will receive notifications about orders and activities',
                      ),
                      value: _notificationEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationEnabled = value;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_business),
                        label: const Text('Create Company'),
                        onPressed: () {
                          if (_companyNameController.text.isEmpty ||
                              _companyDescriptionController.text.isEmpty ||
                              _lotNumberController.text.isEmpty ||
                              _userIdController.text.isEmpty) {
                            _showErrorSnackbar(
                              'Please fill in all required fields',
                            );
                            return;
                          }

                          final lotNumber = int.tryParse(
                            _lotNumberController.text,
                          );
                          final userId = int.tryParse(_userIdController.text);

                          if (lotNumber == null) {
                            _showErrorSnackbar(
                              'Please enter a valid lot number',
                            );
                            return;
                          }

                          if (userId == null) {
                            _showErrorSnackbar('Please enter a valid user ID');
                            return;
                          }

                          CreateCompanyForUser(
                            _companyNameController.text,
                            _companyDescriptionController.text,
                            _companyAvatarUrl,
                            lotNumber,
                            _notificationEnabled,
                            userId,
                          );

                          // Clear form fields after submission
                          _companyNameController.clear();
                          _companyDescriptionController.clear();
                          _lotNumberController.clear();
                          _userIdController.clear();
                          setState(() {
                            _companyAvatarUrl =
                                'https://cdn-icons-png.flaticon.com/512/149/149071.png';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
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

  // Helper methods for the product form
  void _clearProductForm() {
    setState(() {
      _productNameController.clear();
      _productDescriptionController.clear();
      _productPriceController.clear();
      _productQuantityController.clear();
      _productMinecraftTagController.clear();
      _productImageUrl =
          'https://cdn-icons-png.flaticon.com/512/1170/1170576.png';
    });
  }

  void _submitProductForm() {
    // Validate form
    if (_selectedCompany == null) {
      _showErrorSnackbar('Please select a company');
      return;
    }

    if (_productNameController.text.isEmpty) {
      _showErrorSnackbar('Please enter a product name');
      return;
    }

    if (_productPriceController.text.isEmpty) {
      _showErrorSnackbar('Please enter a price');
      return;
    }

    if (_productQuantityController.text.isEmpty) {
      _showErrorSnackbar('Please enter a quantity');
      return;
    }

    if (_productMinecraftTagController.text.isEmpty) {
      _showErrorSnackbar('Please enter a Minecraft tag');
      return;
    }

    // Parse numeric values
    double? price;
    int? quantity;

    try {
      price = double.parse(_productPriceController.text);
      if (price <= 0) {
        _showErrorSnackbar('Price must be greater than 0');
        return;
      }
    } catch (e) {
      _showErrorSnackbar('Please enter a valid price');
      return;
    }

    try {
      quantity = int.parse(_productQuantityController.text);
      if (quantity <= 0) {
        _showErrorSnackbar('Quantity must be greater than 0');
        return;
      }
    } catch (e) {
      _showErrorSnackbar('Please enter a valid quantity');
      return;
    }

    // Create the product
    makeProductForCompany(
      _selectedCompany!.id,
      _productNameController.text,
      _productDescriptionController.text,
      price,
      quantity,
      _productMinecraftTagController.text,
      _productImageUrl,
    ).then((_) {
      // Clear form after successful creation
      _clearProductForm();
    });
  }

  // Tab 3.5: Create Products
  Widget _buildCreateProductTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Product for Company',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a new product and assign it to any company in the system',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Company Selection Dropdown
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Step 1: Select Company',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Company>(
                    decoration: const InputDecoration(
                      labelText: 'Select Company',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    value: _selectedCompany,
                    hint: const Text('Select a company'),
                    items:
                        _companies.map((Company company) {
                          return DropdownMenuItem<Company>(
                            value: company,
                            child: Text('${company.name} (ID: ${company.id})'),
                          );
                        }).toList(),
                    onChanged: (Company? newValue) {
                      setState(() {
                        _selectedCompany = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Product Details Form
          if (_selectedCompany != null)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step 2: Create Product for ${_selectedCompany!.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Two columns layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Product Image
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Product Image',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child:
                                    _productImageUrl.isEmpty
                                        ? const Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                        )
                                        : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.network(
                                            _productImageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.broken_image,
                                                      size: 60,
                                                      color: Colors.grey,
                                                    ),
                                          ),
                                        ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Upload Image'),
                                onPressed: _pickProductImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    74,
                                    237,
                                    217,
                                  ),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(180, 45),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Right column - Product Details
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _productNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Product Name*',
                                  hintText: 'Enter product name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.inventory),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _productDescriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Product Description',
                                  hintText: 'Enter product description',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.description),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _productPriceController,
                                      decoration: const InputDecoration(
                                        labelText: 'Price*',
                                        hintText: 'e.g. 29.99',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.attach_money),
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _productQuantityController,
                                      decoration: const InputDecoration(
                                        labelText: 'Quantity*',
                                        hintText: 'e.g. 100',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(
                                          Icons.production_quantity_limits,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _productMinecraftTagController,
                                decoration: const InputDecoration(
                                  labelText: 'Minecraft Tag*',
                                  hintText: 'e.g. minecraft:diamond',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.tag),
                                  helperText: 'The exact Minecraft item ID',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Submission section
                    Row(
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
                        OutlinedButton(
                          onPressed: _clearProductForm,
                          child: const Text('Clear Form'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Create Product'),
                          onPressed: _submitProductForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              23,
                              221,
                              97,
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 16,
                ),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.business_center, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Please select a company first',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
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

  // Tab 4: AI Company Orders
  Widget _buildAICompanyOrdersTab() {
    return RefreshIndicator(
      onRefresh: () async {
        final orders = await getAllOrdersForAiCompanies();
        setState(() => _aiCompanyOrders = orders);
      },
      child:
          _aiCompanyOrders.isEmpty
              ? const Center(child: Text('No orders for AI companies found'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _aiCompanyOrders.length,
                itemBuilder: (context, index) {
                  final order = _aiCompanyOrders[index];
                  final product = order.product;
                  final company = order.company;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child:
                                    product != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            product.avatarUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.inventory_2,
                                                      size: 30,
                                                    ),
                                          ),
                                        )
                                        : const Icon(
                                          Icons.inventory_2,
                                          size: 30,
                                        ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #${order.id}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product != null
                                          ? product.name
                                          : 'Unknown Product',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      company != null
                                          ? 'Sold by: ${company.name}'
                                          : 'Unknown Company',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      order.complete
                                          ? Colors.green.shade100
                                          : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  order.complete ? 'Delivered' : 'Pending',
                                  style: TextStyle(
                                    color:
                                        order.complete
                                            ? Colors.green.shade800
                                            : Colors.orange.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Order Details',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Quantity: ${order.quantity}'),
                                    Text(
                                      'Payment: \$${order.payment.toStringAsFixed(2)}',
                                    ),
                                    Text(
                                      'Created: ${_formatDate(order.createdAt)}',
                                    ),
                                    Text(
                                      'Deadline: ${_formatDate(order.orderTimeout)}',
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Delivery Information',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Address: ${order.deliveryAddress}'),
                                    Text('User ID: ${order.userId}'),
                                    Text(
                                      order.received
                                          ? 'Received by customer'
                                          : 'Not yet received',
                                      style: TextStyle(
                                        color:
                                            order.received
                                                ? Colors.green
                                                : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (!order.complete)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Mark as Delivered'),
                                onPressed: () => markOrderDelivered(order),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  // Tab 5: AI User Orders
  Widget _buildAIUserOrdersTab() {
    return RefreshIndicator(
      onRefresh: () async {
        final orders = await getAllOrdersForAiUser();
        setState(() => _aiUserOrders = orders);
      },
      child:
          _aiUserOrders.isEmpty
              ? const Center(child: Text('No orders by AI users found'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _aiUserOrders.length,
                itemBuilder: (context, index) {
                  final order = _aiUserOrders[index];
                  final product = order.product;
                  final company = order.company;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child:
                                    product != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            product.avatarUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.inventory_2,
                                                      size: 30,
                                                    ),
                                          ),
                                        )
                                        : const Icon(
                                          Icons.inventory_2,
                                          size: 30,
                                        ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #${order.id}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product != null
                                          ? product.name
                                          : 'Unknown Product',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      company != null
                                          ? 'From: ${company.name}'
                                          : 'Unknown Company',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getOrderStatusColor(order),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getOrderStatusText(order),
                                  style: TextStyle(
                                    color: _getOrderStatusTextColor(order),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Order Details',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Quantity: ${order.quantity}'),
                                    Text(
                                      'Payment: \$${order.payment.toStringAsFixed(2)}',
                                    ),
                                    Text(
                                      'Created: ${_formatDate(order.createdAt)}',
                                    ),
                                    Text(
                                      'Deadline: ${_formatDate(order.orderTimeout)}',
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Delivery Information',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Address: ${order.deliveryAddress}'),
                                    Text(
                                      order.complete
                                          ? 'Delivered by seller'
                                          : 'Not yet delivered',
                                      style: TextStyle(
                                        color:
                                            order.complete
                                                ? Colors.green
                                                : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (order.complete && !order.received)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Mark as Received'),
                                onPressed: () => markOrderReceived(order),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          if (!order.complete)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.cancel),
                                label: const Text('Cancel Order'),
                                onPressed: () => cancelOrder(order),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  // Tab 6: Admin Messages
  Widget _buildAdminMessagesTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Admin Message',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create announcements that will be visible to all users of the platform',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _messageTitleController,
            decoration: const InputDecoration(
              labelText: 'Message Title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _messageContentController,
            decoration: const InputDecoration(
              labelText: 'Message Content',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.message),
            ),
            maxLines: 10,
            maxLength: 1000,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Mark as Important'),
            subtitle: const Text(
              'Important messages appear highlighted to users',
            ),
            value: _isMessageImportant,
            onChanged: (value) {
              setState(() {
                _isMessageImportant = value;
              });
            },
            activeColor: Colors.red,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Publish Message'),
              onPressed: () {
                if (_messageTitleController.text.isEmpty ||
                    _messageContentController.text.isEmpty) {
                  _showErrorSnackbar('Please fill in both title and content');
                  return;
                }

                makeAdminMessage(
                  _messageTitleController.text,
                  _messageContentController.text,
                  _isMessageImportant,
                ).then((_) {
                  // Clear form after submission
                  _messageTitleController.clear();
                  _messageContentController.clear();
                  setState(() {
                    _isMessageImportant = false;
                  });
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 7: Unverified Products
  Widget _buildUnverifiedProductsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        final products = await getAllNonVerifiedProducts();
        setState(() => _unverifiedProducts = products);
      },
      child:
          _unverifiedProducts.isEmpty
              ? const Center(child: Text('No unverified products found'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _unverifiedProducts.length,
                itemBuilder: (context, index) {
                  final product = _unverifiedProducts[index];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.image_not_supported,
                                              size: 40,
                                            ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Price: \$${product.price.toStringAsFixed(2)} | Quantity: ${product.quantity}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Minecraft Tag: ${product.minecraftTag}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Company ID: ${product.companyId}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Chip(
                                label: const Text(
                                  'UNVERIFIED',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red.shade400,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            product.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Divider(height: 24),
                          const Text(
                            'Verification Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _productValueController,
                                  decoration: const InputDecoration(
                                    labelText: 'Product Value',
                                    hintText: 'Base value of the product',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _productNicheController,
                                  decoration: const InputDecoration(
                                    labelText: 'Niche Coefficient',
                                    hintText: 'Market uniqueness (0.1-2.0)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.verified),
                              label: const Text('Verify Product'),
                              onPressed: () {
                                final value = double.tryParse(
                                  _productValueController.text,
                                );
                                final niche = double.tryParse(
                                  _productNicheController.text,
                                );

                                if (value == null || value <= 0) {
                                  _showErrorSnackbar(
                                    'Please enter a valid product value',
                                  );
                                  return;
                                }

                                if (niche == null ||
                                    niche < 0.1 ||
                                    niche > 2.0) {
                                  _showErrorSnackbar(
                                    'Please enter a valid niche coefficient (0.1-2.0)',
                                  );
                                  return;
                                }

                                verifyProduct(product.id, value, niche).then((
                                  _,
                                ) {
                                  setState(() {
                                    _unverifiedProducts.removeAt(index);
                                  });
                                  _productValueController.clear();
                                  _productNicheController.clear();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  Color _getOrderStatusColor(Order order) {
    if (order.received) return Colors.green.shade100;
    if (order.complete) return Colors.blue.shade100;
    return Colors.orange.shade100;
  }

  Color _getOrderStatusTextColor(Order order) {
    if (order.received) return Colors.green.shade800;
    if (order.complete) return Colors.blue.shade800;
    return Colors.orange.shade800;
  }

  String _getOrderStatusText(Order order) {
    if (order.received) return 'Received';
    if (order.complete) return 'Delivered';
    return 'Pending';
  }

  Future<List<Company>> getAllCompanies() async {
    try {
      final companies = await SupabaseHelper.getAllCompanies();
      if (companies.isEmpty) {
        return [];
      }
      return companies;
    } catch (e) {
      debugPrint('Error fetching companies: $e');
      return [];
    }
  }

  Future<List<Order>> getAllOrdersForAiCompanies() async {
    try {
      final aiCompanies = await SupabaseHelper.getAllOrdersForAiCompanies();
      if (aiCompanies.isEmpty) {
        return [];
      }
      return aiCompanies;
    } catch (e) {
      debugPrint('Error fetching AI companies: $e');
      return [];
    }
  }

  Future<List<Order>> getAllOrdersForAiUser() async {
    try {
      final aiUsers = await SupabaseHelper.getAllOrdersForAiUsers();
      if (aiUsers.isEmpty) {
        return [];
      }
      return aiUsers;
    } catch (e) {
      debugPrint('Error fetching AI users: $e');
      return [];
    }
  }

  Future<void> CreateCompanyForUser(
    String name,
    String slogan,
    String companyAvatarUrl,
    int lotNumber,
    bool notificationEnabled,
    int userId,
  ) async {
    try {
      final success = await SupabaseHelper.createCompany(
        name,
        slogan,
        companyAvatarUrl,
        lotNumber,
        notificationEnabled,
        userId,
      );
      if (success) {
        //snackBar to show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Company $name created successfully!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        //snackBar to show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create company. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating company: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating company: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Refreshes all data throughout the admin panel
  Future<void> refreshAllData() async {
    setState(() => _isLoading = true);

    try {
      // Fetch all data types in parallel
      final results = await Future.wait([
        getAllCompanies(),
        getAllOrdersForAiCompanies(),
        getAllOrdersForAiUser(),
        getAllNonVerifiedProducts(),
      ]);

      // Update state with fetched data
      setState(() {
        _companies = results[0] as List<Company>;
        _aiCompanyOrders = results[1] as List<Order>;
        _aiUserOrders = results[2] as List<Order>;
        _unverifiedProducts = results[3] as List<Product>;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data refreshed successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Error refreshing data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> makeProductForCompany(
    int companyId,
    String name,
    String description,
    double price,
    int quantity,
    String minecraftTag,
    String avatarUrl,
  ) async {
    try {
      await SupabaseHelper.addProductToCompany(
        companyId,
        name,
        description,
        price,
        quantity,
        minecraftTag,
        avatarUrl,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product $name created successfully!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error creating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating product: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> verifyCompany(int companyId, int visibilityFactor) async {
    try {
      final success = await SupabaseHelper.verifyCompany(
        companyId,
        visibilityFactor,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Company $companyId verified successfully!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to verify company. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error verifying company: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying company: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> setCompanyVisibilityFactor(
    int companyId,
    int visibilityFactor,
  ) async {
    try {
      final success = await SupabaseHelper.setCompanyVisibilityFactor(
        companyId,
        visibilityFactor,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Company visibility updated successfully!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to update company visibility. Please try again.',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating company visibility: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating company visibility: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> markOrderDelivered(Order order) async {
    try {
      await SupabaseHelper.markOrderAsComplete(order);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${order.id} marked as delivered successfully!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error marking order as delivered: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking order as delivered: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> markOrderReceived(Order order) async {
    try {
      await SupabaseHelper.markOrderAsReceived(order.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${order.id} marked as received successfully!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error marking order as received: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking order as received: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> cancelOrder(Order order) async {
    try {
      await SupabaseHelper.cancelOrderUser(order.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${order.id} cancelled successfully!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling order: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> makeAdminMessage(
    String title,
    String content,
    bool isImportant,
  ) async {
    try {
      final success = await SupabaseHelper.createAdminMessage(
        title,
        content,
        isImportant,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Admin message "$title" created successfully!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create admin message. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating admin message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating admin message: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<List<Product>> getAllNonVerifiedProducts() async {
    try {
      final products = await SupabaseHelper.getAllNonVerifiedProducts();
      if (products.isEmpty) {
        return [];
      }
      return products;
    } catch (e) {
      debugPrint('Error fetching non-verified products: $e');
      return [];
    }
  }

  Future<void> verifyProduct(
    int productId,
    double value,
    double nicheCoefficient,
  ) async {
    try {
      final success = await SupabaseHelper.verifyProduct(
        productId,
        value,
        nicheCoefficient,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product $productId verified successfully!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to verify product. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error verifying product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying product: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> makeCompanyPublic(companyId) async {
    try {
      final success = await SupabaseHelper.goPublic(companyId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Company $companyId made public successfully!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to make company public. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error making company public: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error making company public: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> makeCompanyPrivate(companyId) async {
    try {
      final success = await SupabaseHelper.goPrivate(companyId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Company $companyId made private successfully!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to make company private. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error making company private: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error making company private: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> splitPublicShares(companyId, splitFactor) async {
    try {
      final success = await SupabaseHelper.splitSharePublic(
        companyId,
        splitFactor,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Company $companyId shares split successfully!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to split company shares. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error splitting company shares: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error splitting company shares: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
