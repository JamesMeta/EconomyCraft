import 'package:economycraft/classes/order.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:economycraft/screens/home/widgets/build_empty_state.dart';
import 'package:economycraft/screens/home/widgets/build_section_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PendingOrders extends StatefulWidget {
  const PendingOrders({super.key});

  @override
  State<PendingOrders> createState() => _PendingOrdersState();
}

class _PendingOrdersState extends State<PendingOrders> {
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BuildSectionCard(
            title: 'Pending Orders',
            icon: Icons.receipt_long,
            iconColor: const Color.fromARGB(255, 74, 237, 217),
            function: refresh,
            child:
                snapshot.data!.isEmpty
                    ? BuildEmptyState(
                      icon: Icons.receipt_long_outlined,
                      message: 'No pending orders',
                    )
                    : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: snapshot.data!.length,
                            separatorBuilder:
                                (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              return _buildOrderItem(snapshot.data![index]);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: OutlinedButton(
                            onPressed: () {
                              context.go('/home/orders');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color.fromARGB(
                                255,
                                74,
                                237,
                                217,
                              ),
                              side: const BorderSide(
                                color: Color.fromARGB(255, 74, 237, 217),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('View All Orders'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
          );
        } else {
          return BuildSectionCard(
            title: 'Pending Orders',
            icon: Icons.receipt_long,
            iconColor: const Color.fromARGB(255, 74, 237, 217),
            function: refresh,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 74, 237, 217),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Loading Orders",
                    style: TextStyle(
                      color: Color.fromRGBO(117, 117, 117, 1),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildOrderItem(Order order) {
    final statusColor =
        order.complete
            ? order.received
                ? const Color.fromARGB(255, 23, 221, 97)
                : const Color.fromARGB(255, 74, 237, 217)
            : const Color.fromARGB(255, 255, 193, 7);

    final statusText =
        order.complete
            ? order.received
                ? 'Received'
                : 'Delivered'
            : 'Pending';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image:
              order.product?.avatarUrl != null
                  ? DecorationImage(
                    image: NetworkImage(order.product!.avatarUrl),
                    fit: BoxFit.cover,
                  )
                  : null,
          color: Colors.grey[200],
        ),
        child:
            order.product?.avatarUrl == null
                ? const Icon(Icons.inventory_2, color: Colors.grey)
                : null,
      ),
      title: Text(
        order.product?.name ?? 'Unknown Product',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${order.quantity} units • ${currencyFormat.format(order.payment)}',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor..withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor),
        ),
        child: Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
      dense: true,
      onTap: () {
        // Navigate to order details
        context.go('/home/orders');
      },
    );
  }

  Future<List<Order>> getOrders() async {
    final orders = await SupabaseHelper.home.getOrdersForUsersCompanies().then((
      value,
    ) {
      // Filter out completed and received orders
      value.removeWhere((order) => order.complete && order.received);
      return value;
    });

    return orders;
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }
}
