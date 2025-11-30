import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/common_widgets/linegraph_1_widget.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:economycraft/screens/home/widgets/build_change_indicator.dart';
import 'package:economycraft/screens/home/widgets/build_empty_state.dart';
import 'package:economycraft/screens/home/widgets/build_section_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class NetworthGraph extends StatefulWidget {
  const NetworthGraph({super.key});

  @override
  State<NetworthGraph> createState() => _NetworthGraphState();
}

class _NetworthGraphState extends State<NetworthGraph> {
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getNetworthData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BuildSectionCard(
            title: 'Your Net Worth',
            icon: Icons.account_balance_wallet,
            iconColor: const Color.fromARGB(255, 23, 221, 97),
            function: refresh,
            child:
                snapshot.data!.isEmpty
                    ? BuildEmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      message: 'No net worth data available',
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currencyFormat.format(
                                      snapshot.data!.last.price,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 23, 221, 97),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  BuildChangeIndicator(
                                    startValue: snapshot.data!.first.price,
                                    endValue: snapshot.data!.last.price,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.go('/home/holdings');
                                },
                                icon: const Icon(
                                  Icons.pie_chart_outline,
                                  size: 16,
                                ),
                                label: const Text('View Holdings'),
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
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Linegraph1Widget(
                              title: "Net Worth Over Time",
                              data: snapshot.data!,
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

  Future<List<PriceVsTime>> getNetworthData() async {
    return await SupabaseHelper.home.getNetworthvsTime();
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }
}
