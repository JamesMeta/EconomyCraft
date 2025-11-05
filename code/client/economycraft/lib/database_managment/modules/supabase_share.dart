import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/classes/share.dart';
import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/buy_order.dart';
import 'package:economycraft/classes/companyShare.dart';
import 'package:economycraft/classes/player.dart';

class SupabaseShare {
  static final _client = Supabase.instance.client;

  Future<void> newCompanyStockOptions(userRowId, companyRowId) async {
    try {
      final response = await _client
          .from('company_share')
          .insert({
            'company_id': companyRowId,
            'value': 0.0,
            'number_of_shares': 1,
            'is_public': false,
          })
          .select('id');

      // add a stock for the user
      await _client.from('shares').insert({
        'user_id': userRowId,
        'company_id': companyRowId,
        'stake': 1.0,
        'purchased_price': 0.0,
        'sale_price': 0.0,
        'purchasable': false,
        'share_id': response[0]['id'],
      });
      developer.log(
        'New company stock options created for user ID: $userRowId',
      );
    } catch (e) {
      developer.log('Error creating new company stock options: $e');
    }
  }

  Future<bool> newBuyOrder(
    double maximumPrice,
    int quantity,
    DateTime expires,
    int companyShareId,
  ) async {
    try {
      final userRowId = await SupabaseHelper.player.getPlayerId();
      await _client.from("buy_orders").insert({
        "expires_at": expires.toIso8601String(),
        "company_share_id": companyShareId,
        "user_id": userRowId,
        "order_quantity": quantity,
        "maximum_share_price": maximumPrice,
      });

      return true;
    } catch (e) {
      developer.log("Error making new buy order: $e");
      return false;
    }
  }

  Future<bool> sellOrderPreCheck(int quantity, int shareId) async {
    try {
      final userRowId = await SupabaseHelper.player.getPlayerId();
      final response = await _client
          .from("shares")
          .select("*")
          .eq("user_id", userRowId)
          .eq("purchasable", false)
          .eq("share_id", shareId);

      developer.log(response.length.toString());
      return response.length >= quantity;
    } catch (e) {
      developer.log("error conducting preecheck $e");
      return false;
    }
  }

  Future<bool> newSellOrder(
    double Function(int x) f,
    int quantity,
    int shareId,
  ) async {
    try {
      final userRowId = await SupabaseHelper.player.getPlayerId();
      final response = await _client
          .from("shares")
          .select('''
          *,
          companies:company_id (
            id, name, slogan, avatar_url, reputation, 
            evaluation, is_public, user_id, created_at, 
            lot_number, verified
          ),
          company_share:share_id (
            id, value, number_of_shares, is_public
            )
        ''')
          .eq("user_id", userRowId)
          .eq("purchasable", false)
          .eq("share_id", shareId)
          .limit(quantity);

      final List<Share> shares =
          response.map<Share>((share) {
            final companyData = share['companies'];
            final companyShareData = share['company_share'];

            return Share(
              id: share['id'],
              createdAt: DateTime.parse(share['created_at']),
              companyId: share['company_id'],
              stake: share['stake'],
              purchasePrice: share['purchased_price'],
              value: companyShareData['value']?.toDouble() ?? 0.0,
              salePrice: share['sale_price'] ?? 0.0,
              purchasable: share['purchasable'],
              userId: share['user_id'],
              isPublic: companyShareData['is_public'] ?? false,
              numberOfShares: companyShareData['number_of_shares'] ?? 0,
              company:
                  companyData != null
                      ? Company(
                        id: companyData['id'],
                        name: companyData['name'],
                        slogan: companyData['slogan'],
                        avatarUrl: companyData['avatar_url'],
                        reputation: companyData['reputation'],
                        evaluation: companyData['evaluation'],
                        isPublic: companyData['is_public'],
                        userId: companyData['user_id'],
                        createdAt: DateTime.parse(companyData['created_at']),
                        lotNumber: companyData['lot_number'] ?? 0,
                        verified: companyData['verified'] ?? false,
                      )
                      : null,
              companyShareId: companyShareData['id'],
            );
          }).toList();

      for (int i = 0; i < shares.length; i++) {
        final double price = f(i);
        shares[i].salePrice = price;
      }

      final isForSale = await makeSharesPurchasable(shares);

      return isForSale;
    } catch (e) {
      developer.log("unable to create sell order $e");
      return false;
    }
  }

  Future<List<BuyOrder>> getUserBuyOrders() async {
    try {
      final userRowId = await SupabaseHelper.player.getPlayerId();

      final response = await _client
          .from("buy_orders")
          .select("*")
          .eq("user_id", userRowId);

      final List<BuyOrder> buyOrders =
          response.map<BuyOrder>((buyOrder) {
            return BuyOrder(
              id: buyOrder["id"],
              createdAt: DateTime.parse(buyOrder["created_at"]),
              expiresAt: DateTime.parse(buyOrder["expires_at"]),
              companyShareId: buyOrder["company_share_id"],
              userId: buyOrder["user_id"],
              orderQuality: buyOrder["order_quantity"],
              maximumSharePrice: buyOrder["maximum_share_price"],
            );
          }).toList();

      return buyOrders;
    } catch (e) {
      developer.log("Error getting users buy orders: $e");
      return [];
    }
  }

  Future<bool> deleteBuyOrder(int buyOrderId) async {
    try {
      await _client.from("buy_orders").delete().eq("id", buyOrderId);
      return true;
    } catch (e) {
      developer.log("error deleting buy order $e");
      return false;
    }
  }

  Future<double> findCheapestShareForCompanyShareId(
    final companyShareId,
  ) async {
    try {
      final response =
          await _client
              .from("shares")
              .select("sale_price")
              .eq("share_id", companyShareId)
              .eq("purchasable", true)
              .order('sale_price', ascending: true)
              .limit(1)
              .maybeSingle();

      return response!["sale_price"];
    } catch (e) {
      developer.log("Error finding cheapest share: $e");
      return -1;
    }
  }

  Future<bool> makeSharesPurchasable(List<Share> shares) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }
    try {
      List<Future<void>> updateFutures = [];
      for (var share in shares) {
        updateFutures.add(
          _client
              .from('shares')
              .update({'purchasable': true, 'sale_price': share.salePrice})
              .eq('id', share.id),
        );
        developer.log('Share made purchasable: ${share.id}');
      }
      await Future.wait(updateFutures);
      developer.log('All shares made purchasable successfully');
      return true;
    } catch (e) {
      developer.log('Error making shares purchasable: $e');
      return false;
    }
  }

  Future<bool> makeSharesUnpurchasable(List<Share> shares) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }
    try {
      List<Future<void>> updateFutures = [];
      for (var share in shares) {
        updateFutures.add(
          _client
              .from('shares')
              .update({'purchasable': false})
              .eq('id', share.id),
        );
        developer.log('Share made unpurchasable: ${share.id}');
      }
      await Future.wait(updateFutures);
      developer.log('All shares made unpurchasable successfully');
      return true;
    } catch (e) {
      developer.log('Error making shares unpurchasable: $e');
      return false;
    }
  }

  Future<List<Share>> getSharesByUser() async {
    final userRowId = await SupabaseHelper.player.getPlayerId();

    try {
      // Fetch shares with company data in a single query using Supabase join
      final response = await _client
          .from('shares')
          .select('''
          *,
          companies:company_id (
            id, name, slogan, avatar_url, reputation, 
            evaluation, is_public, user_id, created_at, 
            lot_number, verified
          ),
          company_share:share_id (
            id, value, number_of_shares, is_public
            )
        ''')
          .eq('user_id', userRowId)
          .order('value', ascending: false, referencedTable: 'company_share');

      if (response.isEmpty) {
        return [];
      }

      final List<Share> shares =
          response.map<Share>((share) {
            final companyData = share['companies'];
            final companyShareData = share['company_share'];

            return Share(
              id: share['id'],
              createdAt: DateTime.parse(share['created_at']),
              companyId: share['company_id'],
              stake: share['stake'],
              purchasePrice: share['purchased_price'],
              value: companyShareData['value']?.toDouble() ?? 0.0,
              salePrice: share['sale_price'] ?? 0.0,
              purchasable: share['purchasable'],
              userId: share['user_id'],
              isPublic: companyShareData['is_public'] ?? false,
              numberOfShares: companyShareData['number_of_shares'] ?? 0,
              company:
                  companyData != null
                      ? Company(
                        id: companyData['id'],
                        name: companyData['name'],
                        slogan: companyData['slogan'],
                        avatarUrl: companyData['avatar_url'],
                        reputation: companyData['reputation'],
                        evaluation: companyData['evaluation'],
                        isPublic: companyData['is_public'],
                        userId: companyData['user_id'],
                        createdAt: DateTime.parse(companyData['created_at']),
                        lotNumber: companyData['lot_number'] ?? 0,
                        verified: companyData['verified'] ?? false,
                      )
                      : null,
              companyShareId: companyShareData['id'],
            );
          }).toList();

      return shares;
    } catch (e) {
      developer.log('Error fetching shares by user ID: $e');
      return [];
    }
  }

  Future<bool> splitSharePrivate(int shareId, int numNewShares) async {
    try {
      await _client.rpc(
        'split_share_private',
        params: {'input_share_id': shareId, 'split_count': numNewShares},
      );
      developer.log(
        'Share split successfully: $shareId into $numNewShares shares',
      );
      return true;
    } catch (e) {
      developer.log('Error splitting share: $e');
      return false;
    }
  }

  Future<bool> splitSharePublic(int companyId, int splitFactor) async {
    try {
      await _client.rpc(
        'split_share_public',
        params: {'target_company_id': companyId, 'split_factor': splitFactor},
      );
      developer.log('Share split successfully: $companyId into public shares');
      return true;
    } catch (e) {
      developer.log('Error splitting share: $e');
      return false;
    }
  }

  Future<List<PriceVsTime>> getSharePriceHistory(int companyId) async {
    try {
      final originalShareId =
          await _client
              .from('company_share')
              .select('id, value')
              .eq('company_id', companyId)
              .limit(1)
              .single();
      if (originalShareId.isEmpty) {
        developer.log(
          'Error: Original share ID not found for company $companyId',
        );
        return [];
      }
      final response = await _client
          .from('share_history')
          .select()
          .eq('share_id', originalShareId['id'])
          .order('created_at', ascending: true);
      if (response.isEmpty) {
        return [];
      }
      final List<PriceVsTime> priceHistory =
          response.map<PriceVsTime>((price) {
            return PriceVsTime(
              time: DateTime.parse(price['created_at']),
              price: price['value']?.toDouble() ?? 0.0,
            );
          }).toList();

      // Add the current price to the history
      final currentPrice = originalShareId['value']?.toDouble() ?? 0.0;
      if (currentPrice > 0.0) {
        priceHistory.add(
          PriceVsTime(time: DateTime.now(), price: currentPrice),
        );
      }
      return priceHistory;
    } catch (e) {
      developer.log('Error fetching share price history: $e');
      return [];
    }
  }

  Future<List<PriceVsTime>> getCompanyPriceHistory(
    int companyId,
    double stake,
  ) async {
    try {
      final response = await _client
          .from('company_history')
          .select()
          .eq('company_id', companyId)
          .order('created_at', ascending: true);
      final companyResponse = await _client
          .from('companies')
          .select("evaluation")
          .eq('company_id', companyId);
      if (response.isEmpty || companyResponse.isEmpty) {
        return [];
      }
      final List<PriceVsTime> priceHistory =
          response.map<PriceVsTime>((price) {
            return PriceVsTime(
              time: DateTime.parse(price['created_at']),
              price: (price['evaluation']?.toDouble()) * stake ?? 0.0,
            );
          }).toList();

      // Add the current price to the history
      final currentEvaluation =
          companyResponse[0]['evaluation']?.toDouble() ?? 0.0;
      return priceHistory;
    } catch (e) {
      developer.log('Error fetching company price history: $e');
      return [];
    }
  }

  Future<CompanyShare> getCompanyShareByCompanyId(int companyId) async {
    try {
      final responses = await _client
          .from('company_share')
          .select("*")
          .eq('company_id', companyId)
          .limit(1);
      if (responses.isEmpty) {
        throw Exception('No original share found for company ID: $companyId');
      }
      final companyShareData = responses[0];
      return CompanyShare(
        id: companyShareData['id'],
        companyId: companyShareData['company_id'],
        value: companyShareData['value']?.toDouble() ?? 0.0,
        numberOfShares: companyShareData['number_of_shares'] ?? 0,
        isPublic: companyShareData['is_public'] ?? false,
      );
    } catch (e) {
      developer.log('Error fetching company share by company ID: $e');
      throw Exception('Failed to fetch company share: $e');
    }
  }

  Future<List<Share>> getForSaleSharesByCompanyId(int companyId) async {
    try {
      final response = await _client
          .from('shares')
          .select('''
          *,
          company_share:share_id (
            id, value, number_of_shares, is_public
            )
        ''')
          .eq('company_id', companyId)
          .eq('purchasable', true)
          .order('value', ascending: false, referencedTable: 'company_share');
      if (response.isEmpty) {
        return [];
      }

      final Company? company = await SupabaseHelper.company.getCompanyById(
        companyId,
      );
      if (company == null) {
        developer.log('Error: Company not found for ID: $companyId');
        return [];
      }

      final List<Share> shares = await Future.wait(
        response.map<Future<Share>>((share) async {
          final companyShareData = share['company_share'];
          return Share(
            id: share['id'],
            createdAt: DateTime.parse(share['created_at']),
            companyId: share['company_id'],
            stake: share['stake'],
            purchasePrice: share['purchased_price'],
            value: companyShareData['value']?.toDouble() ?? 0.0,
            salePrice: share['sale_price'] ?? 0.0,
            purchasable: share['purchasable'],
            userId: share['user_id'],
            company: company,
            isPublic: companyShareData['is_public'] ?? false,
            numberOfShares: companyShareData['number_of_shares'] ?? 0,
            companyShareId: companyShareData['id'],
          );
        }).toList(),
      );
      return shares;
    } catch (e) {
      developer.log('Error fetching for sale shares by company ID: $e');
      return [];
    }
  }

  Future<Map<Player, double>> getInvestorsForCompany(int companyId) async {
    try {
      final response = await _client
          .from('shares')
          .select('user_id, stake')
          .eq('company_id', companyId);

      if (response.isEmpty) {
        developer.log('No investors found for company ID: $companyId');
        return {};
      }

      final Map<int, double> investors = {};
      for (var share in response) {
        final userId = share['user_id'];
        final stake = share['stake']?.toDouble() ?? 0.0;
        if (investors.containsKey(userId)) {
          investors[userId] = investors[userId]! + stake; // Sum stakes
        } else {
          investors[userId] = stake; // Initialize stake
        }
      }

      // Convert user IDs to Player objects
      final Map<Player, double> playerInvestors = {};
      for (var entry in investors.entries) {
        final userId = entry.key;
        final stake = entry.value;

        // Fetch player details
        final player = await SupabaseHelper.player.getUserByRowId(entry.key);
        if (player != null) {
          playerInvestors[player] = stake; // Map Player to stake
        } else {
          developer.log('Error: Player not found for user ID: $userId');
        }
      }
      return playerInvestors;
    } catch (e) {
      developer.log('Error fetching investors for company: $e');
      return {};
    }
  }

  Future<Share> getShareById(int shareId) async {
    try {
      final response =
          await _client
              .from('shares')
              .select(
                "*, company_share:share_id (id, value, is_public, number_of_shares), companies:company_id (id, name, slogan, avatar_url, reputation, evaluation, is_public, user_id, created_at, lot_number, verified)",
              )
              .eq('id', shareId)
              .limit(1)
              .single();
      if (response.isEmpty) {
        throw Exception('Share not found for ID: $shareId');
      }

      final companyShareData = response['company_share'];
      final companyData = response['companies'];

      return Share(
        id: response['id'],
        createdAt: DateTime.parse(response['created_at']),
        companyId: response['company_id'],
        stake: response['stake'],
        purchasePrice: response['purchased_price'],
        value: companyShareData['value']?.toDouble() ?? 0.0,
        salePrice: response['sale_price'] ?? 0.0,
        purchasable: response['purchasable'],
        userId: response['user_id'],
        isPublic: companyShareData['is_public'] ?? false,
        numberOfShares: companyShareData['number_of_shares'] ?? 0,
        company:
            companyData != null
                ? Company(
                  id: companyData['id'],
                  name: companyData['name'],
                  slogan: companyData['slogan'],
                  avatarUrl: companyData['avatar_url'],
                  reputation: companyData['reputation'],
                  evaluation: companyData['evaluation'],
                  isPublic: companyData['is_public'],
                  userId: companyData['user_id'],
                  createdAt: DateTime.parse(companyData['created_at']),
                  lotNumber: companyData['lot_number'] ?? 0,
                  verified: companyData['verified'] ?? false,
                )
                : null,
        companyShareId: companyShareData['id'],
      );
    } catch (e) {
      developer.log('Error fetching share by ID: $e');
      throw Exception('Failed to fetch share: $e');
    }
  }

  Future<bool> purchaseShares(List<Share> shares) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final userRowId = await SupabaseHelper.player.getPlayerId();
      for (var share in shares) {
        await _client.rpc(
          'purchase_share',
          params: {'buyer_id': userRowId, 'input_share_id': share.id},
        );
        developer.log('Share purchased successfully: ${share.id}');
      }
      return true;
    } catch (e) {
      developer.log('Error purchasing shares: $e');
      return false;
    }
  }

  Future<List<Share>> getSharesByCompanyId(int companyId) async {
    try {
      final response = await _client
          .from('shares')
          .select(
            "*, company_share:share_id (id, value, is_public, number_of_shares)",
          )
          .eq('company_id', companyId)
          .order('value', ascending: false, referencedTable: 'company_share');
      if (response.isEmpty) {
        return [];
      }

      final List<Share> shares = await Future.wait(
        response.map<Future<Share>>((share) async {
          final companyShareData = share['company_share'];
          return Share(
            id: share['id'],
            createdAt: DateTime.parse(share['created_at']),
            companyId: share['company_id'],
            stake: share['stake'],
            purchasePrice: share['purchased_price'],
            value: companyShareData['value']?.toDouble() ?? 0.0,
            salePrice: share['sale_price'] ?? 0.0,
            purchasable: share['purchasable'],
            userId: share['user_id'],
            isPublic: companyShareData['is_public'] ?? false,
            numberOfShares: companyShareData['number_of_shares'] ?? 0,
            companyShareId: companyShareData['id'],
          );
        }).toList(),
      );
      return shares;
    } catch (e) {
      developer.log('Error fetching shares by company ID: $e');
      return [];
    }
  }
}
