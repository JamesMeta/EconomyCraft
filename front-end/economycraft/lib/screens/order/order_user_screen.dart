import 'package:economycraft/classes/order.dart';
import 'package:economycraft/classes/product.dart';
import 'package:economycraft/classes/company.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderUserScreen extends StatefulWidget {
  const OrderUserScreen({super.key});

  @override
  State<OrderUserScreen> createState() => _OrderUserScreenState();
}

class _OrderUserScreenState extends State<OrderUserScreen> {
  bool _showPastOrders = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 255, 252),
        actions: [
          // Toggle button for showing past orders
        ],
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
              width: MediaQuery.of(context).size.width * 0.4,
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
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 28,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _showPastOrders ? 'All Orders' : 'Active Orders',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showPastOrders = !_showPastOrders;
                              });
                            },
                            icon: Icon(
                              _showPastOrders
                                  ? Icons.history_toggle_off
                                  : Icons.history,
                              color: const Color.fromARGB(255, 74, 237, 217),
                            ),
                            label: Text(
                              _showPastOrders
                                  ? 'Hide Past Orders'
                                  : 'Show Past Orders',
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
                        ),
                      ],
                    ),
                  ),

                  // Order List
                  Expanded(
                    child: FutureBuilder<List<Order>>(
                      future: getOrders(),
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
                                  'No orders found',
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
                          if (!_showPastOrders) {
                            orders =
                                orders
                                    .where((order) => !order.received)
                                    .toList();
                          }

                          if (orders.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _showPastOrders
                                        ? Icons.history
                                        : Icons.shopping_bag_outlined,
                                    color: Colors.grey[400],
                                    size: 60,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _showPastOrders
                                        ? 'No orders history found'
                                        : 'No active orders found',
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
                              return OrderCard(
                                order: order,
                                onTap: () => _showOrderDetails(order),
                                onMarkReceived:
                                    () => _confirmMarkReceived(order),
                                isReceived: order.received,
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
          content: OrderDetailsDialog(
            order: order,
            // Fix: Properly handle async operations with dialogs
            onMarkReceived: () {
              Navigator.of(context).pop();
              _confirmMarkReceived(order);
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

  // Confirm mark as received
  Future<void> _confirmMarkReceived(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Receipt'),
            content: const Text(
              'Are you sure you want to mark this order as received? '
              'This action cannot be undone.',
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
      await markOrderAsReceived(order);
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
              'This action cannot be undone.',
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

  Future<List<Order>> getOrders() async {
    return await SupabaseHelper.getOrdersMadeByUser();
  }

  Future<void> markOrderAsReceived(Order order) async {
    await SupabaseHelper.markOrderAsReceived(order.id);
    setState(() {
      order.received = true;
    });
  }

  Future<void> cancelOrder(Order order) async {
    await SupabaseHelper.cancelOrder(order.id);
    setState(() {
      order.complete = true;
    });
  }
}

// Order Card Widget
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final VoidCallback onMarkReceived;
  final bool isReceived;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
    required this.onMarkReceived,
    required this.isReceived,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isReceived
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
                        color: isReceived ? Colors.grey : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${order.quantity} × \$${order.product?.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        color: isReceived ? Colors.grey : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: isReceived ? Colors.grey : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ordered: ${dateFormat.format(order.createdAt)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isReceived ? Colors.grey : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status indicators
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 90, // Set a fixed width for all chips
                    child: () {
                      if (isReceived) {
                        return const Chip(
                          label: Center(
                            child: Text(
                              'Received',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 0),
                        );
                      } else if (order.complete) {
                        return const Chip(
                          label: Center(
                            child: Text(
                              'Delivered',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          backgroundColor: Color.fromARGB(255, 74, 237, 217),
                          padding: EdgeInsets.symmetric(horizontal: 0),
                        );
                      } else {
                        return const Chip(
                          label: Center(
                            child: Text(
                              'Ordered',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(horizontal: 0),
                        );
                      }
                    }(),
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

// Order Details Dialog
class OrderDetailsDialog extends StatelessWidget {
  final Order order;
  final VoidCallback onMarkReceived;
  final VoidCallback? onCancelOrder;

  const OrderDetailsDialog({
    Key? key,
    required this.order,
    required this.onMarkReceived,
    this.onCancelOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy - h:mm a');
    final product = order.product;

    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with product image and name
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
                      Text(
                        product?.name ?? 'Unknown Product',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
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
                  'Description',
                  product?.description ?? 'No description available',
                ),

                const SizedBox(height: 20),

                // Order details section
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 74, 237, 217),
                  ),
                ),
                const Divider(),
                _buildDetailRow('Retailer', order.company?.name ?? 'Unknown'),
                _buildDetailRow(
                  'Total Payment',
                  '\$${order.payment.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Order Date',
                  dateFormat.format(order.createdAt),
                ),
                _buildDetailRow(
                  'Delivery By',
                  dateFormat.format(order.orderTimeout),
                ),
                _buildDetailRow('Delivery Address', order.deliveryAddress),
                _buildDetailRow(
                  'Order Status',
                  order.received
                      ? 'Received'
                      : (order.complete ? 'Complete' : 'Processing'),
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

                    if (order.complete && !order.received)
                      const SizedBox(width: 12),

                    if (order.complete && !order.received)
                      ElevatedButton.icon(
                        onPressed: onMarkReceived,
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'MARK AS RECEIVED',
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

  Widget _buildDetailRow(String label, String value) {
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
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
