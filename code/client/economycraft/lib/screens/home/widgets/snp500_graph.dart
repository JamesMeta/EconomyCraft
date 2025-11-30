import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/common_widgets/linegraph_1_widget.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:economycraft/screens/home/widgets/build_change_indicator.dart';
import 'package:economycraft/screens/home/widgets/build_empty_state.dart';
import 'package:economycraft/screens/home/widgets/build_section_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Snp500Graph extends StatefulWidget {
  const Snp500Graph({super.key});

  @override
  State<Snp500Graph> createState() => _Snp500GraphState();
}

class _Snp500GraphState extends State<Snp500Graph> {
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final lastDataRefresh = DateTime.now().toIso8601String().substring(11, 16);

    return FutureBuilder(
      future: getSnPData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BuildSectionCard(
            title: 'S&P 500 Market Index',
            icon: Icons.show_chart,
            iconColor: const Color.fromARGB(255, 74, 237, 217),
            function: refresh,
            child:
                snapshot.data!.isEmpty
                    ? BuildEmptyState(
                      icon: Icons.show_chart_outlined,
                      message: 'No market data available',
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
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          snapshot.data!.last.price >=
                                                  snapshot.data!.first.price
                                              ? const Color.fromARGB(
                                                255,
                                                23,
                                                221,
                                                97,
                                              )
                                              : Colors.red,
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Last updated: $lastDataRefresh',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
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
                              title: "S&P 500 Price History",
                              data: snapshot.data!,
                            ),
                          ),
                        ),
                      ],
                    ),
          );
        } else {
          return BuildSectionCard(
            title: 'S&P 500 Market Index',
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
                    "Loading Index",
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

  Future<List<PriceVsTime>> getSnPData() async {
    return await SupabaseHelper.home.getSnP500PriceHistory();
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }
}
