import 'package:economycraft/screens/home/widgets/build_section_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickAccess extends StatefulWidget {
  const QuickAccess({super.key});

  @override
  State<QuickAccess> createState() => _QuickAccessState();
}

class _QuickAccessState extends State<QuickAccess> {
  @override
  Widget build(BuildContext context) {
    return BuildSectionCard(
      title: 'Quick Access',
      icon: Icons.bolt,
      iconColor: const Color.fromARGB(255, 255, 193, 7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                icon: Icons.add_shopping_cart,
                label: 'Market',
                color: const Color.fromARGB(255, 23, 221, 97),
                onTap: () => context.go('/home/market'),
              ),
              _buildQuickActionButton(
                icon: Icons.pie_chart_outline,
                label: 'Holdings',
                color: const Color.fromARGB(255, 74, 237, 217),
                onTap: () => context.go('/home/holdings'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                icon: Icons.business_center_outlined,
                label: 'New Co.',
                color: Colors.deepPurpleAccent,
                onTap: () => context.go('/home/holdings/make_new_company'),
              ),
              _buildQuickActionButton(
                icon: Icons.account_balance,
                label: 'Funds',
                color: Colors.blue,
                onTap: () => context.go('/home/withdrawl_deposit_funds'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 90, // Fixed width
        height: 90, // Fixed height
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
