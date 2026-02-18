import 'package:economycraft/classes/order.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:economycraft/screens/order/widgets/order_details_dialog.dart';
import 'package:economycraft/screens/order/widgets/user_order_card.dart';
import 'package:flutter/material.dart';

class UserOrderList extends StatefulWidget {
  final bool showPastOrders;
  final List<Order> ordersList;

  const UserOrderList({
    super.key,
    required this.showPastOrders,
    required this.ordersList,
  });

  @override
  State<UserOrderList> createState() => _UserOrderListState();
}

class _UserOrderListState extends State<UserOrderList> {
  late List<Order> _orders;

  @override
  void didUpdateWidget(covariant UserOrderList oldWidget) {
    if (oldWidget.showPastOrders != widget.showPastOrders) {}

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    _orders = widget.ordersList.where((order) => true).toList();

    if (!widget.showPastOrders) {
      _orders = widget.ordersList.where((order) => !order.received).toList();
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.showPastOrders
                  ? Icons.history
                  : Icons.shopping_bag_outlined,
              color: Colors.grey[400],
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              widget.showPastOrders
                  ? 'No orders history found'
                  : 'No active orders found',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return OrderCard(
            order: order,
            onTap: () => _showOrderDetails(order),
            onMarkReceived: () => _confirmMarkReceived(order),
            isReceived: order.received,
          );
        },
      );
    }
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

  Future<void> cancelOrder(Order order) async {
    await SupabaseHelper.order.cancelOrderUser(order.id);
    setState(() {
      widget.ordersList.remove(order);
    });
  }

  Future<void> markOrderAsReceived(Order order) async {
    await SupabaseHelper.order.markOrderAsReceived(order.id);
    setState(() {
      order.received = true;
    });
  }
}
