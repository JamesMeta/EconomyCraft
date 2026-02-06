import 'package:economycraft/classes/pie_chart_data.dart';
import 'package:economycraft/classes/player.dart';
import 'package:economycraft/common_widgets/linegraph_1_widget.dart';
import 'package:economycraft/common_widgets/pie_chart_1_widget.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlayerCardWidget extends StatelessWidget {
  final Player player;
  final int rank;
  final NumberFormat currencyFormat;
  final int index;
  final int totalPlayers;
  final double maxWealth;

  const PlayerCardWidget({
    required this.player,
    required this.rank,
    required this.currencyFormat,
    required this.index,
    required this.totalPlayers,
    required this.maxWealth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double wealthDecimal = maxWealth > 0 ? (player.money / maxWealth) : 0;

    // Determine the rank widget and background color as before.
    Widget rankWidget;
    Color cardColor = Colors.white;
    switch (rank) {
      case 1:
        rankWidget = const Icon(
          Icons.emoji_events,
          color: Color(0xFFFFD700),
          size: 32,
        );
        cardColor = const Color.fromARGB(255, 255, 252, 229);
        break;
      case 2:
        rankWidget = const Icon(
          Icons.emoji_events,
          color: Color(0xFFC0C0C0),
          size: 32,
        );
        cardColor = const Color.fromARGB(255, 245, 245, 245);
        break;
      case 3:
        rankWidget = const Icon(
          Icons.emoji_events,
          color: Color(0xFFCD7F32),
          size: 32,
        );
        cardColor = const Color.fromARGB(255, 252, 242, 229);
        break;
      default:
        rankWidget = Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(255, 229, 255, 252),
          ),
          child: Text(
            '$rank',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 74, 237, 217),
            ),
          ),
        );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color.fromARGB(255, 201, 201, 201),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 244, 244, 244),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        expandedAlignment: Alignment.topLeft,

        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            rankWidget,
            const SizedBox(width: 12),
            Image.network(player.avatarUrl),
          ],
        ),
        title: Text(
          player.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // Wealth progress bar
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    return Container(
                      height: 8,
                      width: width * wealthDecimal,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 74, 237, 217),
                            Color.fromARGB(255, 23, 221, 97),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 14,
                  color: Color.fromARGB(255, 74, 237, 217),
                ),
                const SizedBox(width: 4),
                Text(
                  'Networth: ${currencyFormat.format(player.money)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                player.ai
                    ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 240, 240),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'AI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 237, 74, 74),
                        ),
                      ),
                    )
                    : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 229, 255, 252),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Player',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 74, 237, 217),
                        ),
                      ),
                    ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add more detailed info if needed
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder(
                        future: SupabaseHelper.player
                            .getNetworthvsTimeForUserRowId(player.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Linegraph1Widget(
                                title: "Net Worth Over Time",
                                data: snapshot.data!,
                              ),
                            );
                          } else {
                            return Container(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder(
                        future: SupabaseHelper.player.getUsersNetworthBreakdown(
                          player.id,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              final List<PieChartData> pieChartData = [];

                              final double total = snapshot!.data!.values.fold(
                                0,
                                (value, element) => value + element,
                              );

                              snapshot.data!.forEach((key, value) {
                                pieChartData.add(
                                  PieChartData(
                                    categoryTitle:
                                        "$key ${((value / total) * 100).toStringAsFixed(1)}%",
                                    proportion: value,
                                  ),
                                );
                              });

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: PieChart1Widget(
                                  title: "Networth Breakdown",
                                  chartData: pieChartData,
                                ),
                              );
                            } else {
                              return Container(
                                child: Center(child: Text("No Data Found")),
                              );
                            }
                          } else {
                            return Container(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Divider(),
                Text(
                  'Delivery Address: ${player.deliveryAddress}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Joined: ${DateFormat("MMM dd, yyyy").format(player.createdAt)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
