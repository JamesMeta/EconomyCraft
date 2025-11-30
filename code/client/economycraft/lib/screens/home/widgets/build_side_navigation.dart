import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuildSideNavigation extends StatefulWidget {
  final VoidCallback flipNav;

  const BuildSideNavigation({super.key, required this.flipNav});

  @override
  State<BuildSideNavigation> createState() => _BuildSideNavigationState();
}

class _BuildSideNavigationState extends State<BuildSideNavigation> {
  bool _isNavExpanded = false;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> navItems = [
      {
        'title': 'Dashboard',
        'icon': Icons.dashboard,
        'route': '/home',
        'isActive': true,
      },

      {'title': 'Products', 'icon': Icons.storefront, 'route': '/home/market'},
      {
        'title': 'Stocks',
        'icon': Icons.area_chart,
        'route': '/home/stock_market',
      },
      {'title': 'Orders', 'icon': Icons.receipt_long, 'route': '/home/orders'},

      {
        'title': 'My Holdings',
        'icon': Icons.pie_chart,
        'route': '/home/holdings',
      },
      {
        'title': 'Funds',
        'icon': Icons.account_balance_wallet,
        'route': '/home/withdrawl_deposit_funds',
      },
      {
        'title': 'Players',
        'icon': Icons.groups,
        'route': '/home/player_overview',
      },
      {
        'title': 'Server Info',
        'icon': Icons.info,
        'route': '/home/server_info',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle button for navigation
        Container(
          padding: const EdgeInsets.all(12),
          alignment: _isNavExpanded ? Alignment.centerRight : Alignment.center,
          child: Tooltip(
            message: _isNavExpanded ? 'Collapse Menu' : 'Expand Menu',
            child: IconButton(
              icon: Icon(
                _isNavExpanded ? Icons.chevron_left : Icons.menu,
                color: const Color.fromARGB(255, 74, 237, 217),
              ),
              onPressed: () {
                setState(() {
                  _isNavExpanded = !_isNavExpanded;
                });
                widget.flipNav();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ),

        const Divider(height: 1),

        // Navigation items
        Expanded(
          child: ListView.builder(
            itemCount: navItems.length,
            padding: const EdgeInsets.only(top: 8),
            itemBuilder: (context, index) {
              final item = navItems[index];
              final isActive = item['isActive'] ?? false;

              return Tooltip(
                message: _isNavExpanded ? '' : item['title'],
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color:
                        isActive
                            ? const Color.fromARGB(255, 229, 255, 252)
                            : null,
                  ),
                  child: InkWell(
                    onTap: () {
                      context.go(item['route']);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'],
                            color:
                                isActive
                                    ? const Color.fromARGB(255, 74, 237, 217)
                                    : Colors.grey[700],
                            size: 24,
                          ),
                          if (_isNavExpanded) ...[
                            const SizedBox(width: 12),
                            // Use Flexible to prevent overflow
                            Flexible(
                              child: Text(
                                item['title'],
                                style: TextStyle(
                                  color:
                                      isActive
                                          ? const Color.fromARGB(
                                            255,
                                            74,
                                            237,
                                            217,
                                          )
                                          : Colors.grey[800],
                                  fontWeight:
                                      isActive
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const Divider(height: 1),

        // Logout button
        Tooltip(
          message: _isNavExpanded ? '' : 'Logout',
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color.fromARGB(25, 244, 67, 54),
            ),
            child: InkWell(
              onTap: () {
                _showLogoutDialog(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red[400], size: 24),
                    if (_isNavExpanded) ...[
                      const SizedBox(width: 12),
                      // Use Flexible here too
                      Flexible(
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.logout, color: Colors.red[400], size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Confirm Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from MineExchange? Any unsaved changes may be lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                logout();
              },
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Keep your existing methods
  Future<void> logout() async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();

    if (mounted) {
      context.go('/login');
    }
  }
}
