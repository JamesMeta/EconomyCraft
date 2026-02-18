import 'package:economycraft/classes/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Order Details Dialog
class OrderDetailsDialog extends StatelessWidget {
  final Order order;
  final VoidCallback onMarkReceived;
  final VoidCallback? onCancelOrder;

  const OrderDetailsDialog({
    super.key,
    required this.order,
    required this.onMarkReceived,
    this.onCancelOrder,
  });

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
