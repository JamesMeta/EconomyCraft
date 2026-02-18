import 'package:economycraft/classes/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final VoidCallback onMarkReceived;
  final bool isReceived;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onMarkReceived,
    required this.isReceived,
  });

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
                      'Qty: ${order.quantity} x \$${order.product?.price.toStringAsFixed(2)}',
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
