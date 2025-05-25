import 'package:economycraft/services/supabase_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:economycraft/classes/player.dart';
import 'package:intl/intl.dart';

class PlayerOverviewScreen extends StatefulWidget {
  const PlayerOverviewScreen({super.key});

  @override
  State<PlayerOverviewScreen> createState() => _PlayerOverviewScreenState();
}

class _PlayerOverviewScreenState extends State<PlayerOverviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _currentSortOption = SortOption.highestNetworth;
  List<Player> _allPlayers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _allPlayers = await getAllPlayersNetworth();
      _sortPlayers();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _sortPlayers() {
    switch (_currentSortOption) {
      case SortOption.highestNetworth:
        _allPlayers.sort((a, b) => b.money.compareTo(a.money));
        break;
      case SortOption.lowestNetworth:
        _allPlayers.sort((a, b) => a.money.compareTo(b.money));
        break;
      case SortOption.alphabetical:
        _allPlayers.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case SortOption.reverseAlphabetical:
        _allPlayers.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
    }
  }

  List<Player> get _filteredPlayers {
    if (_searchQuery.isEmpty) return _allPlayers;
    return _allPlayers
        .where(
          (player) =>
              player.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Player Overview',
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
              height: screenHeight * 0.85,
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
                          Icons.account_balance_wallet,
                          size: 28,
                          color: Color.fromARGB(255, 74, 237, 217),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Player Networth Rankings',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Total wealth of all registered players',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _loadPlayers,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Refresh'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color.fromARGB(
                              255,
                              74,
                              237,
                              217,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Search and Sort Controls
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search players...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 201, 201, 201),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(255, 201, 201, 201),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<SortOption>(
                                isExpanded: true,
                                value: _currentSortOption,
                                icon: const Icon(Icons.sort),
                                items:
                                    SortOption.values.map((option) {
                                      return DropdownMenuItem<SortOption>(
                                        value: option,
                                        child: Text(option.displayName),
                                      );
                                    }).toList(),
                                onChanged: (SortOption? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _currentSortOption = newValue;
                                      _sortPlayers();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Player List
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.fromARGB(255, 74, 237, 217),
                                ),
                              ),
                            )
                            : _filteredPlayers.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sentiment_dissatisfied,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isEmpty
                                        ? 'No players found'
                                        : 'No players match your search',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredPlayers.length,
                              itemBuilder: (context, index) {
                                final player = _filteredPlayers[index];
                                final rank = _allPlayers.indexOf(player) + 1;

                                return buildPlayerCard(
                                  player: player,
                                  rank: rank,
                                  currencyFormat: currencyFormat,
                                  index: index,
                                  totalPlayers: _allPlayers.length,
                                );
                              },
                            ),
                  ),
                  // Summary Footer
                  if (!_isLoading && _allPlayers.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 245, 245, 245),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Players: ${_allPlayers.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 24),
                          Text(
                            'Total Economy Value: ${currencyFormat.format(_calculateTotalEconomy())}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 23, 221, 97),
                            ),
                          ),
                        ],
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

  // Updated to use ExpansionTile
  Widget buildPlayerCard({
    required Player player,
    required int rank,
    required NumberFormat currencyFormat,
    required int index,
    required int totalPlayers,
  }) {
    double maxWealth = _allPlayers.isNotEmpty ? _allPlayers.first.money : 1;
    double wealthPercentage =
        maxWealth > 0 ? (player.money / maxWealth * 100) : 0;

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

    // Using ExpansionTile to show details on tap.
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
                Container(
                  height: 8,
                  width: wealthPercentage.clamp(0, 100) * 0.01 * 200,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 74, 237, 217),
                        Color.fromARGB(255, 23, 221, 97),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
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
          // Additional player details shown when expanded
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address: ${player.deliveryAddress}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Joined: ${DateFormat("MMM dd, yyyy").format(player.createdAt)}',
                  style: const TextStyle(fontSize: 14),
                ),
                // Add more detailed info if needed
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalEconomy() {
    return _allPlayers.fold(0, (sum, player) => sum + player.money);
  }

  Future<List<Player>> getAllPlayersNetworth() async {
    final List<Player> players = await SupabaseHelper.getAllPlayers();
    for (var player in players) {
      final assetValue = await SupabaseHelper.getPlayerAssetEvaluation(
        player.id,
      );
      player.money += assetValue;
    }
    players.sort((a, b) => b.money.compareTo(a.money));
    return players;
  }
}

enum SortOption {
  highestNetworth,
  lowestNetworth,
  alphabetical,
  reverseAlphabetical;

  String get displayName {
    switch (this) {
      case SortOption.highestNetworth:
        return 'Highest Networth';
      case SortOption.lowestNetworth:
        return 'Lowest Networth';
      case SortOption.alphabetical:
        return 'A to Z';
      case SortOption.reverseAlphabetical:
        return 'Z to A';
    }
  }
}
