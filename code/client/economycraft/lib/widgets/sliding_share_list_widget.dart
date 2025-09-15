import 'package:flutter/material.dart';
import 'dart:async';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:economycraft/classes/share_changes.dart';
import 'package:intl/intl.dart';

class SlidingShareListWidget extends StatefulWidget {
  final List<List<ShareChanges>> chunks;

  const SlidingShareListWidget({super.key, required this.chunks});

  @override
  State<SlidingShareListWidget> createState() => _SlidingShareListWidgetState();
}

class _SlidingShareListWidgetState extends State<SlidingShareListWidget> {
  int startIndex = 0;
  Timer? _timer;
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  List<ShareChanges> _shareChanges = List.empty(growable: true);
  late final List<List<ShareChanges>> _chunks;

  @override
  void initState() {
    super.initState();
    _chunks = widget.chunks;

    // Move window every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        startIndex = (startIndex + 1) % _chunks.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _chunks.isNotEmpty ? _chunks[startIndex] : [];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.085,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (child, anim) {
          return FadeTransition(opacity: anim, child: child);
        },
        child: Row(
          key: ValueKey(startIndex), // Forces animation on change
          mainAxisAlignment: MainAxisAlignment.start,
          children:
              visibleItems
                  .map(
                    (item) => Container(
                      width: screenWidth * 0.185,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            //offset: const Offset(5, 10),
                          ),
                        ],
                      ),
                      child: _buildShareChangeItem(item),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildShareChangeItem(ShareChanges shareChange) {
    final isPositive = shareChange.change >= 0;
    final changeText =
        '${isPositive ? '+' : ''}${shareChange.change.toStringAsFixed(2)}%';
    final changeColor =
        isPositive ? const Color.fromARGB(255, 23, 221, 97) : Colors.redAccent;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }
}
