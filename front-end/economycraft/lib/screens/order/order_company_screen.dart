import 'package:economycraft/classes/company.dart';
import 'package:flutter/material.dart';
import 'package:economycraft/classes/order.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:intl/intl.dart';

class OrderCompanyScreen extends StatefulWidget {
  const OrderCompanyScreen({super.key});

  @override
  State<OrderCompanyScreen> createState() => _OrderCompanyScreenState();
}

class _OrderCompanyScreenState extends State<OrderCompanyScreen> {
  bool _showCompletedOrders = false;
  Company? _selectedCompany;
  List<Company> _userCompanies = [];
  bool _isLoadingCompanies = true;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _isLoadingCompanies = true;
    });

    try {
      _userCompanies = await getCompanies();
      if (_userCompanies.isNotEmpty) {
        _selectedCompany = _userCompanies.first;
      }
    } catch (e) {
      debugPrint('Error loading companies: $e');
    } finally {
      setState(() {
        _isLoadingCompanies = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Company Orders',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.85,
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
                      color: Color.fromARGB(255, 233, 233, 233),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and company selector
                        Row(
                          children: [
                            const Icon(
                              Icons.business_center_outlined,
                              size: 28,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _showCompletedOrders
                                  ? 'All Company Orders'
                                  : 'Active Orders',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Company dropdown and toggle button row
                        Row(
                          children: [
                            // Company Dropdown
                            Expanded(
                              flex: 3,
                              child:
                                  _isLoadingCompanies
                                      ? const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<
                                            Color
                                          >(Color.fromARGB(255, 74, 237, 217)),
                                        ),
                                      )
                                      : Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                              255,
                                              229,
                                              255,
                                              252,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        child:
                                            _userCompanies.isEmpty
                                                ? const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                                  child: Text(
                                                    "You don't have any companies",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                )
                                                : DropdownButtonHideUnderline(
                                                  child: DropdownButton<
                                                    Company
                                                  >(
                                                    isExpanded: true,
                                                    value: _selectedCompany,
                                                    icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                    ),
                                                    items:
                                                        _userCompanies.map((
                                                          Company company,
                                                        ) {
                                                          return DropdownMenuItem<
                                                            Company
                                                          >(
                                                            value: company,
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: 24,
                                                                  height: 24,
                                                                  decoration: BoxDecoration(
                                                                    shape:
                                                                        BoxShape
                                                                            .circle,
                                                                    image: DecorationImage(
                                                                      image: NetworkImage(
                                                                        company
                                                                            .avatarUrl,
                                                                      ),
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
                                                                      onError:
                                                                          (
                                                                            obj,
                                                                            stack,
                                                                          ) => const AssetImage(
                                                                            'assets/images/background_images/quartz_background.png',
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    company
                                                                        .name,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }).toList(),
                                                    onChanged: (
                                                      Company? newValue,
                                                    ) {
                                                      setState(() {
                                                        _selectedCompany =
                                                            newValue;
                                                      });
                                                    },
                                                  ),
                                                ),
                                      ),
                            ),

                            const SizedBox(width: 12),

                            // Toggle button
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showCompletedOrders = !_showCompletedOrders;
                                });
                              },
                              icon: Icon(
                                _showCompletedOrders
                                    ? Icons.history_toggle_off
                                    : Icons.history,
                                color: const Color.fromARGB(255, 74, 237, 217),
                              ),
                              label: Text(
                                _showCompletedOrders
                                    ? 'Hide Completed'
                                    : 'Show All',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 74, 237, 217),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Order List
                  Expanded(
                    child:
                        _userCompanies.isEmpty || _selectedCompany == null
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.business_outlined,
                                    color: Colors.grey[400],
                                    size: 60,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Create a company to view orders',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : FutureBuilder<List<Order>>(
                              future: getOrders(_selectedCompany!.id),
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
                                          color: Colors.red,
                                          size: 60,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Error loading orders',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          snapshot.error.toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.shopping_cart_outlined,
                                          color: Colors.grey[400],
                                          size: 60,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No orders found for this company',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  List<Order> orders = snapshot.data!;

                                  // Filter orders based on the toggle state
                                  if (!_showCompletedOrders) {
                                    orders =
                                        orders
                                            .where(
                                              (order) =>
                                                  !(order.complete &&
                                                      order.received),
                                            )
                                            .toList();
                                  }

                                  if (orders.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _showCompletedOrders
                                                ? Icons.history
                                                : Icons.shopping_bag_outlined,
                                            color: Colors.grey[400],
                                            size: 60,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            _showCompletedOrders
                                                ? 'No order history found'
                                                : 'No pending orders found',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: orders.length,
                                    itemBuilder: (context, index) {
                                      final order = orders[index];
                                      return CompanyOrderCard(
                                        order: order,
                                        onTap: () => _showOrderDetails(order),
                                        onMarkComplete:
                                            () => _confirmMarkComplete(order),
                                        isReceived: order.received,
                                        isDelivered: order.complete,
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                  ),

                  // Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color.fromARGB(255, 229, 255, 252),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order data last updated at: ${DateFormat('MMM d, yyyy - h:mm a').format(DateTime.now())}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.refresh,
                            size: 18,
                            color: Color.fromARGB(255, 74, 237, 217),
                          ),
                          label: const Text(
                            'Refresh',
                            style: TextStyle(
                              color: Color.fromARGB(255, 74, 237, 217),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
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

  // Show order details dialog
  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: CompanyOrderDetailsDialog(
            order: order,
            onMarkComplete: () {
              Navigator.of(context).pop();
              _confirmMarkComplete(order);
            },

            onCancelOrder:
                order.complete
                    ? null
                    : () {
                      Navigator.of(context).pop();
                      _confirmCancelOrder(order);
                    },
          ),
        );
      },
    );
  }

  // Confirm mark as completed
  Future<void> _confirmMarkComplete(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delivery'),
            content: const Text(
              'Are you sure you want to mark this order as completed? '
              'This will notify the customer that their order is delivered to the listed delivery address.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 74, 237, 217),
                ),
                child: const Text(
                  'CONFIRM',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await markOrderAsCompleted(order);
    }
  }

  // Confirm cancel order
  Future<void> _confirmCancelOrder(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Order'),
            content: const Text(
              'Are you sure you want to cancel this order? '
              'This action cannot be undone and will notify the customer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('NO, KEEP ORDER'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'YES, CANCEL ORDER',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await cancelOrder(order);
    }
  }

  Future<List<Order>> getOrders(int companyId) async {
    return await SupabaseHelper.getOrdersMadeForCompany(companyId);
  }

  Future<List<Company>> getCompanies() async {
    return await SupabaseHelper.getCompaniesByUser();
  }

  Future<void> markOrderAsCompleted(Order order) async {
    await SupabaseHelper.markOrderAsComplete(order.id);
    setState(() {
      order.complete = true;
    });
  }

  Future<void> cancelOrder(Order order) async {
    await SupabaseHelper.cancelOrder(order.id);
    setState(() {
      order.complete = true;
    });
  }
}

// Company Order Card Widget
class CompanyOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final VoidCallback onMarkComplete;
  late bool isComplete;
  final bool isReceived;
  final bool isDelivered;

  CompanyOrderCard({
    Key? key,
    required this.order,
    required this.onTap,
    required this.onMarkComplete,
    required this.isReceived,
    required this.isDelivered,
  }) : super(key: key) {
    isComplete = isReceived && isDelivered;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isComplete
                  ? Colors.grey.shade300
                  : const Color.fromARGB(255, 229, 255, 252),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Product image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(
                      order.product?.avatarUrl ??
                          'https://placehold.co/80x80?text=No+Image',
                    ),
                    fit: BoxFit.cover,
                    onError:
                        (exception, stackTrace) => const AssetImage(
                          'assets/images/background_images/quartz_background.png',
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Order info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.product?.name ?? 'Unknown Product',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isComplete ? Colors.grey : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Qty: ${order.quantity} × \$${order.product?.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15,
                            color: isComplete ? Colors.grey : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Total: \$${order.payment.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isComplete ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: isComplete ? Colors.grey : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ordered: ${dateFormat.format(order.createdAt)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isComplete ? Colors.grey : Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (order.orderTimeout
                                    .difference(DateTime.now())
                                    .inDays <
                                3 &&
                            !isDelivered)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 12,
                                  color: Colors.red.shade800,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Due Soon',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 16),

              // Status indicators
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 90, // Fixed width for all chips
                    child: Chip(
                      label: Center(
                        child: Text(
                          isComplete
                              ? 'Completed'
                              : (isDelivered ? 'Delivered' : 'Pending'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      backgroundColor:
                          isComplete
                              ? Colors.green
                              : (isDelivered
                                  ? const Color.fromARGB(255, 74, 237, 217)
                                  : Colors.orange),
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Company Order Details Dialog
class CompanyOrderDetailsDialog extends StatelessWidget {
  final Order order;
  final VoidCallback onMarkComplete;
  final VoidCallback? onCancelOrder;

  const CompanyOrderDetailsDialog({
    Key? key,
    required this.order,
    required this.onMarkComplete,
    this.onCancelOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy - h:mm a');
    final product = order.product;
    final dueDate = order.orderTimeout;
    final isOverdue = dueDate.isBefore(DateTime.now()) && !order.complete;
    final isDueSoon =
        dueDate.difference(DateTime.now()).inDays < 3 && !order.complete;

    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with product image and name
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 229, 255, 252),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(
                        product?.avatarUrl ??
                            'https://placehold.co/70x70?text=No+Image',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product?.name ?? 'Unknown Product',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isOverdue)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'OVERDUE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (isDueSoon)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'DUE SOON',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Order details
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product details section
                const Text(
                  'Product Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 74, 237, 217),
                  ),
                ),
                const Divider(),
                _buildDetailRow(
                  'Minecraft Tag',
                  product?.minecraftTag ?? 'N/A',
                ),
                _buildDetailRow(
                  'Price Per Unit',
                  '\$${product?.price.toStringAsFixed(2) ?? 'N/A'}',
                ),
                _buildDetailRow('Quantity', '${order.quantity}'),
                _buildDetailRow(
                  'Total Payment',
                  '\$${order.payment.toStringAsFixed(2)}',
                ),

                const SizedBox(height: 20),

                // Customer and delivery details section
                const Text(
                  'Customer & Delivery Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 74, 237, 217),
                  ),
                ),
                const Divider(),
                _buildDetailRow('Customer ID', '${order.userId}'),
                _buildDetailRow('Delivery Address', order.deliveryAddress),
                _buildDetailRow(
                  'Order Date',
                  dateFormat.format(order.createdAt),
                ),
                _buildDetailRow(
                  'Delivery By',
                  dateFormat.format(order.orderTimeout),
                  textColor: isOverdue ? Colors.red : null,
                ),
                _buildDetailRow(
                  'Status',
                  order.received
                      ? 'Received by customer'
                      : (order.complete
                          ? 'Delivered - awaiting confirmation'
                          : 'Processing'),
                ),

                const SizedBox(height: 30),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'CLOSE',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),

                    if (onCancelOrder != null)
                      ElevatedButton.icon(
                        onPressed: onCancelOrder,
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        label: const Text(
                          'CANCEL ORDER',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),

                    if (!order.complete) const SizedBox(width: 12),

                    if (!order.complete)
                      ElevatedButton.icon(
                        onPressed: onMarkComplete,
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'MARK AS COMPLETE',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            74,
                            237,
                            217,
                          ),
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
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 175,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor ?? Colors.black87,
                fontWeight: textColor != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
