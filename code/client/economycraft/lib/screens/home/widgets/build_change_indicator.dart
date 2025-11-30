import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BuildChangeIndicator extends StatelessWidget {
  final double startValue;
  final double endValue;

  const BuildChangeIndicator({
    super.key,
    required this.startValue,
    required this.endValue,
  });

  @override
  Widget build(BuildContext context) {
    final change = endValue - startValue;
    final percentChange = (change / (startValue + 1)) * 100;
    final isPositive = change >= 0;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Row(
      children: [
        Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          size: 14,
          color: isPositive ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          '${isPositive ? "+" : ""}${currencyFormat.format(change)} (${isPositive ? "+" : ""}${percentChange.toStringAsFixed(2)}%)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
