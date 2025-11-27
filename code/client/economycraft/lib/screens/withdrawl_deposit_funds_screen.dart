import 'package:economycraft/classes/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:intl/intl.dart';

class WithdrawlDepositFundsScreen extends StatefulWidget {
  const WithdrawlDepositFundsScreen({super.key});

  @override
  State<WithdrawlDepositFundsScreen> createState() =>
      _WithdrawlDepositFundsScreenState();
}

class _WithdrawlDepositFundsScreenState
    extends State<WithdrawlDepositFundsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  // Controllers for text fields
  final TextEditingController _depositAmountController =
      TextEditingController();
  final TextEditingController _withdrawAmountController =
      TextEditingController();
  final TextEditingController _transferAmountController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // State variables
  double? _userBalance;
  Player? _selectedPlayer;
  List<Player> _allPlayers = [];
  List<Player> _filteredPlayers = [];
  String? _transactionResult;
  bool _isLoading = false;
  bool _showResult = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _searchController.addListener(_filterPlayers);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final balance = await getUserBalance();
      final players = await getAllPlayers();

      if (mounted) {
        setState(() {
          _userBalance = balance;
          _allPlayers = players;
          _filteredPlayers = players;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  void _filterPlayers() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredPlayers = _allPlayers;
      } else {
        _filteredPlayers =
            _allPlayers
                .where((player) => player.name.toLowerCase().contains(query))
                .toList();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _depositAmountController.dispose();
    _withdrawAmountController.dispose();
    _transferAmountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Funds',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 255, 252),
        elevation: 4,
        shadowColor: Colors.black26,
        actions: [
          // Refresh button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Color.fromARGB(255, 74, 237, 217),
              ),
              onPressed: _loadData,
              tooltip: 'Refresh data',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
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

          // Main content
          Center(
            child: Container(
              width: screenWidth * 0.7,
              height: screenHeight * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with balance
                  Row(
                    children: [
                      // Icon and title
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 229, 255, 252),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          size: 28,
                          color: Color.fromARGB(255, 74, 237, 217),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Balance',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          _isLoading
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromARGB(255, 23, 221, 97),
                                  ),
                                ),
                              )
                              : Text(
                                currencyFormat.format(_userBalance ?? 0),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 23, 221, 97),
                                ),
                              ),
                        ],
                      ),
                      const Spacer(),
                      // Transaction timestamp
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Last updated:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm:ss').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Tabs
                  SizedBox(
                    height: 50,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: const Color.fromARGB(255, 74, 237, 217),
                      unselectedLabelColor: Colors.grey[700],
                      indicatorColor: const Color.fromARGB(255, 74, 237, 217),
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(
                          icon: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.swap_horiz),
                              SizedBox(width: 8),
                              Text('TRANSFER'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Deposit tab
                        //_buildDepositTab(),

                        // Withdraw tab
                        //_buildWithdrawTab(),

                        // Transfer tab
                        _buildTransferTab(),
                      ],
                    ),
                  ),

                  // Transaction result section
                  if (_showResult) _buildResultSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search Players',
            hintText: 'Enter player name',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _isSearching = false;
                        });
                      },
                    )
                    : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 74, 237, 217),
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _isSearching = value.isNotEmpty;
            });
          },
        ),

        const SizedBox(height: 16),

        // Players list
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPlayers.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isSearching
                              ? Icons.search_off
                              : Icons.people_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isSearching
                              ? 'No players found matching your search'
                              : 'No players available',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                  : _buildPlayersList(),
        ),

        if (_selectedPlayer != null) ...[
          const SizedBox(height: 16),

          // Selected player card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(
                255,
                229,
                255,
                252,
              ).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromARGB(255, 74, 237, 217),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _buildPlayerAvatar(_selectedPlayer!),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _selectedPlayer!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildPlayerTypeTag(_selectedPlayer!),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${_selectedPlayer!.id}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _selectedPlayer = null;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Transfer amount field
          TextField(
            controller: _transferAmountController,
            decoration: InputDecoration(
              labelText: 'Amount to Transfer',
              hintText: 'Enter amount',
              prefixIcon: const Icon(
                Icons.attach_money,
                color: Color.fromARGB(255, 0, 153, 255),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 74, 237, 217),
                  width: 2,
                ),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),

          const SizedBox(height: 16),

          // Transfer button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed:
                  _isLoading
                      ? null
                      : () => _handleTransfer(_transferAmountController.text),
              icon: const Icon(Icons.send),
              label:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text('Transfer Funds'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 153, 255),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlayersList() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: _filteredPlayers.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final player = _filteredPlayers[index];
            return ListTile(
              leading: _buildPlayerAvatar(player),
              title: Row(
                children: [
                  Text(player.name),
                  const SizedBox(width: 8),
                  _buildPlayerTypeTag(player),
                ],
              ),
              subtitle: Text('ID: ${player.id}'),
              trailing:
                  _selectedPlayer?.id == player.id
                      ? const Icon(
                        Icons.check_circle,
                        color: Color.fromARGB(255, 23, 221, 97),
                      )
                      : null,
              onTap: () {
                setState(() {
                  _selectedPlayer = player;
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerAvatar(Player player) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        image:
            player.avatarUrl.isNotEmpty
                ? DecorationImage(
                  image: NetworkImage(player.avatarUrl),
                  fit: BoxFit.cover,
                )
                : null,
        border: Border.all(
          color:
              player.ai
                  ? Colors.amber
                  : const Color.fromARGB(255, 74, 237, 217),
          width: 2,
        ),
      ),
      child:
          player.avatarUrl.isEmpty
              ? Icon(Icons.person, color: Colors.grey[400])
              : null,
    );
  }

  Widget _buildPlayerTypeTag(Player player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:
            player.ai
                ? Colors.amber.withValues(alpha: 0.2)
                : Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        player.ai ? 'AI' : 'Player',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: player.ai ? Colors.amber[800] : Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 74, 237, 217)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color.fromARGB(255, 23, 221, 97),
              ),
              const SizedBox(width: 8),
              const Text(
                'Transaction Result',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: _transactionResult ?? ''),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                tooltip: 'Copy to clipboard',
              ),
            ],
          ),
          const Text("Copy this code as it will not be shown again"),
          const SizedBox(height: 8),
          SelectableText(
            _transactionResult ?? 'No result',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your transaction will now be put in queue to be processed and verified, this can take up to 24 hours depending on the amount of transactions in the queue.",
          ),
        ],
      ),
    );
  }

  Future<void> _handleTransfer(String amountText) async {
    // Check if player is selected
    if (_selectedPlayer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a recipient')),
      );
      return;
    }

    // Input validation
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive amount')),
      );
      return;
    }

    // Check if user has enough funds
    if (amount > (_userBalance ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient funds for this transfer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Confirm action
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirm Transfer'),
                content: Text(
                  'Are you sure you want to transfer ${currencyFormat.format(amount)} to ${_selectedPlayer!.name}?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 153, 255),
                    ),
                    child: const Text('Confirm'),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
      _showResult = false;
    });

    try {
      await transferFunds(_selectedPlayer!.id, amount);
      final newBalance = await getUserBalance();

      setState(() {
        _userBalance = newBalance;
        _isLoading = false;
      });

      _transferAmountController.clear();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<double> getUserBalance() async {
    final balance = await SupabaseHelper.player.getUserBalance();
    return balance;
  }

  Future<void> transferFunds(int recipientId, double amount) async {
    final response = await SupabaseHelper.wallet.transferMoney(
      recipientId,
      amount,
    );
    if (response) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transfer successful'),
          backgroundColor: Color.fromARGB(255, 23, 221, 97),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transfer failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Player>> getAllPlayers() async {
    final players = await SupabaseHelper.player.getAllPlayers();
    return players;
  }
}
