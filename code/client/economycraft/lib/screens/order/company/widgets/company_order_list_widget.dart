import 'package:economycraft/classes/order.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:economycraft/screens/order/company/widgets/company_order_card.dart';
import 'package:economycraft/screens/order/company/widgets/company_order_details_dialog.dart';
import 'package:flutter/material.dart';

class CompanyOrderListWidget extends StatefulWidget {
  final List<Order> orders;
  final bool showCompletedOrders;

  const CompanyOrderListWidget({
    super.key,
    required this.orders,
    required this.showCompletedOrders,
  });

  @override
  State<CompanyOrderListWidget> createState() => _CompanyOrderListWidgetState();
}

class _CompanyOrderListWidgetState extends State<CompanyOrderListWidget> {
  late List<Order> _orders;

  @override
  void initState() {
    _orders = widget.orders.where((order) => true).toList(); // make copy
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showCompletedOrders) {
      _orders =
          _orders
              .where((order) => !(order.complete && order.received))
              .toList();
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.showCompletedOrders
                  ? Icons.history
                  : Icons.shopping_bag_outlined,
              color: Colors.grey[400],
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              widget.showCompletedOrders
                  ? 'No order history found'
                  : 'No pending orders found',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return CompanyOrderCard(
          order: order,
          onTap: () => _showOrderDetails(order),
          onMarkComplete: () => _confirmMarkComplete(order),
          isReceived: order.received,
          isDelivered: order.complete,
        );
      },
    );
  }

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

  Future<void> markOrderAsCompleted(Order order) async {
    await SupabaseHelper.order.markOrderAsComplete(order);
    setState(() {
      order.complete = true;
    });
  }

  Future<void> cancelOrder(Order order) async {
    await SupabaseHelper.order.cancelOrderOwner(order);
    setState(() {
      _orders.remove(order);
    });
  }
}
