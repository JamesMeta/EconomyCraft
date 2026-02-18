import 'package:economycraft/classes/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompanyOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final VoidCallback onMarkComplete;
  final bool isReceived;
  final bool isDelivered;

  const CompanyOrderCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onMarkComplete,
    required this.isReceived,
    required this.isDelivered,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final isComplete = isReceived && isDelivered;

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
