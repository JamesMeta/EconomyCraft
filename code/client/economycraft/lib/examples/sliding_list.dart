import 'dart:async';
import 'package:flutter/material.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:economycraft/classes/share_changes.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:economycraft/classes/share.dart';
import 'package:economycraft/classes/company.dart';

const supabaseUrl = 'https://ylgfgklcypqtbqrkhsba.supabase.co';
const supabaseKey = "sb_publishable_tcxKxITjQOaJNt6fyc0geQ_dV8ItNuf";
const appVersion = '1.3';

Future<void> main() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sliding Row Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sliding Row Example")),
      body: Center(child: SlidingRow()),
    );
  }
}

class SlidingRow extends StatefulWidget {
  const SlidingRow({super.key});

  @override
  State<SlidingRow> createState() => _SlidingRowState();
}

class _SlidingRowState extends State<SlidingRow> {
  int startIndex = 0;
  Timer? _timer;
  DateTime? _lastDataRefresh;
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  final List<ShareChanges> _shareChanges = List.empty(growable: true);
  final List<List<ShareChanges>> _chunks = [];

  @override
  void initState() {
    super.initState();
    _fetchAllData();

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

  Future<void> _fetchAllData() async {
    // setState(() {
    //   _lastDataRefresh = DateTime.now();
    // });

    // // Load all data in parallel
    // await Future.wait([
    //   SupabaseHelper.getShareChanges().then((value) => _shareChanges = value),
    // ]);

    // // Update UI if component is still mounted
    // if (mounted) {
    //   setState(() {});
    // }
    List<ShareChanges> currentChunk = [];
    for (var item in _shareChanges) {
      if (currentChunk.length == 3) {
        _chunks.add([...currentChunk]);
        currentChunk.clear();
      }
      currentChunk.add(item);
    }
    if (currentChunk.isNotEmpty) {
      _chunks.add([...currentChunk]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _chunks[startIndex];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, anim) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0), // slide in from right
            end: Offset.zero,
          ).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      child: Row(
        key: ValueKey(startIndex), // Forces animation on change
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            visibleItems
                .map(
                  (item) => Container(
                    width: 250,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _buildShareChangeItem(item),
                  ),
                )
                .toList(),
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
    );
  }
}
