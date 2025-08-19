import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderSelectionScreen extends StatefulWidget {
  const OrderSelectionScreen({super.key});

  @override
  State<OrderSelectionScreen> createState() => _OrderSelectionScreenState();
}

class _OrderSelectionScreenState extends State<OrderSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Orders',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 255, 252),
      ),
      body: Stack(
        children: [
          // Background
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

          // Main Content
          Center(
            child: Container(
              width: screenWidth * 0.7,
              height: screenHeight * 0.7,
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
                      color: Color.fromARGB(255, 229, 255, 252),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag,
                          size: 28,
                          color: Color.fromARGB(255, 74, 237, 217),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Orders Management',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Select which orders you want to view',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Order Options
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Company Orders Option
                          Expanded(
                            child: _buildOrderOption(
                              title: 'Company Orders',
                              subtitle:
                                  'View and manage orders for your products',
                              icon: Icons.storefront,
                              color: const Color.fromARGB(255, 74, 237, 217),
                              onTap: () {
                                context.go('/home/orders/company_orders');
                              },
                            ),
                          ),

                          const SizedBox(width: 24),

                          // User Orders Option
                          Expanded(
                            child: _buildOrderOption(
                              title: 'My Orders',
                              subtitle: 'View and track your purchase history',
                              icon: Icons.receipt_long,
                              color: const Color.fromARGB(255, 23, 221, 97),
                              onTap: () {
                                context.go('/home/orders/user_orders');
                              },
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildOrderOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 201, 201, 201),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 244, 244, 244),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 80, color: color),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // View button
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('View', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
