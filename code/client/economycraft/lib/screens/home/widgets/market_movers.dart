import 'package:economycraft/classes/share_changes.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:economycraft/screens/home/widgets/build_empty_state.dart';
import 'package:economycraft/screens/home/widgets/build_section_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MarketMovers extends StatefulWidget {
  const MarketMovers({super.key});

  @override
  State<MarketMovers> createState() => _MarketMoversState();
}

class _MarketMoversState extends State<MarketMovers> {
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getShareChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BuildSectionCard(
            title: 'Market Movers',
            icon: Icons.trending_up,
            iconColor: const Color.fromARGB(255, 23, 221, 97),
            function: refresh,
            child:
                snapshot.data!.isEmpty
                    ? BuildEmptyState(
                      icon: Icons.trending_up_outlined,
                      message: 'No share changes to display',
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
                              return _buildShareChangeItem(
                                snapshot.data![index],
                              );
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
                              context.go('/home/market');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color.fromARGB(
                                255,
                                23,
                                221,
                                97,
                              ),
                              side: const BorderSide(
                                color: Color.fromARGB(255, 23, 221, 97),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Explore Market'),
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
            title: 'Market Movers',
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
                    "Loading Share Changes",
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

  Widget _buildShareChangeItem(ShareChanges shareChange) {
    final isPositive = shareChange.change >= 0;
    final changeText =
        '${isPositive ? '+' : ''}${shareChange.change.toStringAsFixed(2)}%';
    final changeColor =
        isPositive ? const Color.fromARGB(255, 23, 221, 97) : Colors.redAccent;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        shareChange.share.company?.name ?? 'Unknown Company',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: changeColor,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            changeText,
            style: TextStyle(
              color: changeColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currencyFormat.format(shareChange.latestValue),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            currencyFormat.format(shareChange.previousValue),
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      onTap: () {
        // Navigate to company details
        if (shareChange.share.company != null) {
          context.go(
            '/home/market/company_page',
            extra: shareChange.share.company,
          );
        }
      },
    );
  }

  Future<List<ShareChanges>> getShareChanges() async {
    return await SupabaseHelper.home.getShareChanges();
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }
}
