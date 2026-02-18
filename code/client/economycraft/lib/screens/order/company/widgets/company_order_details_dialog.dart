import 'package:economycraft/classes/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompanyOrderDetailsDialog extends StatelessWidget {
  final Order order;
  final VoidCallback onMarkComplete;
  final VoidCallback? onCancelOrder;

  const CompanyOrderDetailsDialog({
    super.key,
    required this.order,
    required this.onMarkComplete,
    this.onCancelOrder,
  });

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
