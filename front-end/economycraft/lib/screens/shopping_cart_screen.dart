import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:economycraft/classes/product.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:economycraft/widgets/empty_cart_widget.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  Map<int, int> productQuantities = {};
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping Cart',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 255, 252),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () {
            context.go('/home/market');
          },
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
            child: Container(
              width: screenWidth * 0.7,
              height: screenHeight * 0.85,
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
                          Icons.shopping_cart,
                          size: 28,
                          color: Color.fromARGB(255, 74, 237, 217),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Shopping Cart',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Review your items before checkout',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed:
                              products.isEmpty
                                  ? null
                                  : () {
                                    _showClearCartDialog();
                                  },
                          icon: const Icon(
                            Icons.remove_shopping_cart,
                            size: 18,
                          ),
                          label: const Text('Clear Cart'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red[400],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cart contents
                  Expanded(
                    child: FutureBuilder<List<Product>>(
                      future: fetchProducts(),
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Error loading cart',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  snapshot.error.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (products.isEmpty) {
                          return const EmptyCartWidget();
                        }

                        // Cart has items - show split view with items and summary
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Items list
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Cart Items',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(
                                          255,
                                          74,
                                          237,
                                          217,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: products.length,
                                        itemBuilder: (context, index) {
                                          final product = products[index];
                                          final quantity =
                                              productQuantities[product.id] ??
                                              1;

                                          return _buildCartItemCard(
                                            product: product,
                                            quantity: quantity,
                                            currencyFormat: currencyFormat,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Order summary and checkout
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      255,
                                      201,
                                      201,
                                      201,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Order Summary',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                255,
                                                74,
                                                237,
                                                217,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 24),

                                          // Order details
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Subtotal:'),
                                              Text(
                                                currencyFormat.format(
                                                  _calculateSubtotal(),
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Shipping:'),
                                              Text(
                                                'Free',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                    255,
                                                    23,
                                                    221,
                                                    97,
                                                  ),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            child: Divider(),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Total:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                currencyFormat.format(
                                                  _calculateSubtotal(),
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Color.fromARGB(
                                                    255,
                                                    23,
                                                    221,
                                                    97,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const Divider(height: 1),

                                    // Delivery address
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Delivery Address',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: _addressController,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText:
                                                  'Enter your delivery address',
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 12,
                                                  ),
                                            ),
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    ),

                                    const Spacer(),

                                    // Checkout button
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          ElevatedButton(
                                            onPressed:
                                                _isLoading
                                                    ? null
                                                    : () => _placeOrder(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                    255,
                                                    23,
                                                    221,
                                                    97,
                                                  ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              disabledBackgroundColor:
                                                  Colors.grey[300],
                                            ),
                                            child:
                                                _isLoading
                                                    ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(Colors.white),
                                                      ),
                                                    )
                                                    : const Text(
                                                      'Place Order',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                          ),
                                          const SizedBox(height: 12),
                                          OutlinedButton(
                                            onPressed: () {
                                              context.go('/home/market');
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              foregroundColor: Colors.grey[700],
                                              side: BorderSide(
                                                color: Colors.grey[400]!,
                                              ),
                                            ),
                                            child: const Text(
                                              'Continue Shopping',
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
                        );
                      },
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

  // Add these additional helper methods to the class

  // Calculate subtotal of all items in cart
  double _calculateSubtotal() {
    double total = 0;
    for (var product in products) {
      int quantity = productQuantities[product.id] ?? 1;
      total += product.price * quantity;
    }
    return total;
  }

  // Show dialog to confirm clearing the cart
  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text(
            'Are you sure you want to remove all items from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                removeAllItemsFromCart();
                Navigator.of(context).pop();
                setState(() {}); // Refresh UI
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Cart'),
            ),
          ],
        );
      },
    );
  }

  // Build a card for each cart item
  Widget _buildCartItemCard({
    required Product product,
    required int quantity,
    required NumberFormat currencyFormat,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color.fromARGB(255, 201, 201, 201),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.network(
                product.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.inventory_2,
                      color: Colors.grey,
                      size: 36,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Product details
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
                  product.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 229, 255, 252),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.minecraftTag,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 74, 237, 217),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Price and quantity
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(product.price * quantity),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 23, 221, 97),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${currencyFormat.format(product.price)} × $quantity',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Remove one
                  IconButton(
                    onPressed: () {
                      removeItemFromCart(product);
                      setState(() {}); // Refresh UI
                    },
                    icon: Icon(
                      Icons.remove_circle_outline,
                      size: 20,
                      color: Colors.red[400],
                    ),
                    tooltip: 'Remove one',
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),

                  // Remove all
                  IconButton(
                    onPressed: () {
                      removeAllItemsOfTypeFromCart(product);
                      setState(() {}); // Refresh UI
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red[400],
                    ),
                    tooltip: 'Remove all',
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadAddress() async {
    final address = await SupabaseHelper.getUserDeliveryAddress();
    _addressController.text = address;
  }

  Future<List<Product>> fetchProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? items = prefs.getStringList('shopping_cart');

      if (items == null || items.isEmpty) {
        products = [];
        productQuantities = {};
        return [];
      }

      // Count occurrences of each product ID
      Map<String, int> itemCounts = {};
      for (String item in items) {
        itemCounts[item] = (itemCounts[item] ?? 0) + 1;
      }

      // Prepare a list to collect futures for parallel fetching
      List<Future<Product?>> futures = [];
      List<int> productIds = [];

      // Request all products in parallel rather than sequentially
      for (String productId in itemCounts.keys) {
        try {
          final int id = int.parse(productId);
          productIds.add(id);
          futures.add(SupabaseHelper.getProductById(id));
        } catch (e) {
          print('Invalid product ID in cart: $productId');
        }
      }

      // Wait for all product fetches to complete
      final results = await Future.wait(futures);

      // Process results
      List<Product> loadedProducts = [];
      Map<int, int> newProductQuantities = {};

      for (int i = 0; i < results.length; i++) {
        Product? product = results[i];
        if (product != null) {
          loadedProducts.add(product);
          newProductQuantities[product.id] =
              itemCounts[productIds[i].toString()]!;
        }
      }

      products = loadedProducts;
      productQuantities = newProductQuantities;

      return loadedProducts;
    } catch (e, stackTrace) {
      print('Error fetching products: $e\n$stackTrace');
      // Return whatever we have - empty list or previously loaded products
      return products;
    }
  }

  // Place order function
  Future<void> _placeOrder() async {
    String address = _addressController.text;
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a delivery address')),
      );
      return;
    }

    // Check if the user can afford the order
    double total = _calculateSubtotal();
    double balance = await SupabaseHelper.getUserBalance();
    bool canAfford = total <= balance;
    if (!canAfford) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance to place the order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Aggregate the products in the cart
      Map<int, int> productCount = {};

      for (Product product in products) {
        int quantity = productQuantities[product.id] ?? 1;
        productCount[product.id] = quantity;
      }

      // Check if the user is the owner of any product in the cart
      for (var productId in productCount.keys) {
        bool isOwner = await SupabaseHelper.isProductOwner(productId);
        if (isOwner) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You cannot order your own product'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final success = await SupabaseHelper.createOrder(productCount, address);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully'),
              backgroundColor: Color.fromARGB(255, 23, 221, 97),
            ),
          );
          removeAllItemsFromCart();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to place order'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void removeItemFromCart(Product product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? items = prefs.getStringList('shopping_cart');

    if (items != null) {
      // Remove just one instance of this product
      final String productIdStr = product.id.toString();

      setState(() {
        productQuantities[product.id] =
            (productQuantities[product.id] ?? 1) - 1;
      });

      final index = items.indexOf(productIdStr);
      if (index != -1) {
        items.removeAt(index);
        await prefs.setStringList('shopping_cart', items);
      }
    }
  }

  void removeAllItemsOfTypeFromCart(Product product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? items = prefs.getStringList('shopping_cart');

    if (items != null) {
      // Remove all instances of this product
      final String productIdStr = product.id.toString();

      setState(() {
        productQuantities[product.id] = 0;
      });

      items.removeWhere((item) => item == productIdStr);
      await prefs.setStringList('shopping_cart', items);
    }
  }

  void removeAllItemsFromCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('shopping_cart');
    setState(() {
      products.clear();
      productQuantities.clear();
    });
  }
}
