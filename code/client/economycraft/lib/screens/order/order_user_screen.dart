import 'package:economycraft/classes/order.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:economycraft/screens/order/widgets/order_details_dialog.dart';
import 'package:economycraft/screens/order/widgets/user_order_list.dart';
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
                    child: FutureBuilder(
                      future: getOrderData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return UserOrderList(
                            showPastOrders: _showPastOrders,
                            ordersList: snapshot.data!,
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color.fromARGB(255, 74, 237, 217),
                            ),
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

  Future<List<Order>> getOrderData() async {
    final rowID = await SupabaseHelper.player.getPlayerId();
    return await SupabaseHelper.order.getOrdersMadeByUser(rowID);
  }
}
