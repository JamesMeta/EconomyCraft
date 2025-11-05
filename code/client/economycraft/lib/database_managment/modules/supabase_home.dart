import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/classes/share.dart';
import 'package:economycraft/classes/order.dart';
import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/share_changes.dart';

class SupabaseHome {
  static final _client = Supabase.instance.client;

  Future<List<PriceVsTime>> getSnP500PriceHistory() async {
    try {
      final response = await _client
          .from('company_history')
          .select('id, created_at, evaluation');

      if (response.isEmpty) {
        developer.log('No S&P 500 price history found');
        return [];
      }

      // Daily Value of the Exchange

      final Map<String, double> dailyPrices = {};
      for (var entry in response) {
        final String date = entry['created_at'].split('T')[0];
        final double value = entry['evaluation']?.toDouble() ?? 0.0;

        if (dailyPrices.containsKey(date)) {
          dailyPrices[date] =
              (dailyPrices[date]! + value); // Average the values
        } else {
          dailyPrices[date] = value;
        }
      }

      final List<PriceVsTime> priceHistory =
          dailyPrices.entries.map((entry) {
            return PriceVsTime(
              time: DateTime.parse('${entry.key}T00:00:00Z'),
              price: entry.value,
            );
          }).toList();

      priceHistory.sort((a, b) => a.time.compareTo(b.time)); // Sort by time

      // return last 30 days of data
      developer.log('S&P 500 price history fetched successfully');
      if (priceHistory.length > 30) {
        return priceHistory.sublist(priceHistory.length - 30);
      }
      return priceHistory;
    } catch (e) {
      developer.log('Error fetching S&P 500 price history: $e');
      return [];
    }
  }

  Future<Share> getOneShareByCompanyShareId(companyShareId) async {
    try {
      final response = await _client
          .from('shares')
          .select(
            "*, company_share:share_id (id, value, is_public, number_of_shares), companies:company_id (id, name, slogan, avatar_url, reputation, evaluation, is_public, user_id, created_at, lot_number, verified)",
          )
          .eq('share_id', companyShareId)
          .limit(1);
      if (response == null) {
        throw Exception(
          'Share not found for company share ID: $companyShareId',
        );
      }
      final responseData = response[0];

      final companyShareData = responseData['company_share'];
      final companyData = responseData['companies'];
      return Share(
        id: responseData['id'],
        createdAt: DateTime.parse(responseData['created_at']),
        companyId: responseData['company_id'],
        stake: responseData['stake'],
        purchasePrice: responseData['purchased_price'],
        value: companyShareData['value']?.toDouble() ?? 0.0,
        salePrice: responseData['sale_price'] ?? 0.0,
        purchasable: responseData['purchasable'],
        userId: responseData['user_id'],
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
      developer.log('Error fetching share by company share ID: $e');
      throw Exception('Failed to fetch share: $e');
    }
  }

  Future<List<ShareChanges>> getShareChanges() async {
    try {
      final companyShares = await _client
          .from('company_share')
          .select('id, value, is_public, number_of_shares')
          .eq('is_public', true)
          .order('value', ascending: false);
      if (companyShares.isEmpty) {
        developer.log('No public company shares found');
        return [];
      }

      final List<ShareChanges> shareChanges = [];
      for (var companyShare in companyShares) {
        final response = await _client
            .from('share_history')
            .select()
            .eq('share_id', companyShare['id'])
            .order('created_at', ascending: false)
            .limit(2);
        if (response.isEmpty) {
          developer.log(
            'No share history found for share ID: ${companyShare['id']}',
          );
          continue;
        }

        final Share share = await getOneShareByCompanyShareId(
          companyShare['id'],
        );
        if (share.company == null) {
          developer.log(
            'Error: Company not found for share ID: ${companyShare['id']}',
          );
          continue;
        }
        // Extract the latest and previous prices from the response
        if (response.length < 2) {
          developer.log(
            'Error: Not enough data to calculate changes for share ID: ${companyShare['id']}',
          );
          continue;
        }
        // Assuming the response is sorted by created_at in descending order
        // and contains at least two entries for latest and previous prices
        final double? latestPrice = response[0]['value']?.toDouble();
        final double? previousPrice =
            response.length > 1 ? response[1]['value']?.toDouble() : null;
        if (latestPrice != null) {
          final double change =
              previousPrice != null
                  ? ((latestPrice - previousPrice) / previousPrice) * 100
                  : 0.0; // Calculate percentage change
          shareChanges.add(
            ShareChanges(
              share: share,
              latestValue: latestPrice ?? 0.0,
              previousValue: previousPrice ?? 0.0,
              change: change,
            ),
          );
        } else {
          developer.log(
            'Error: Latest price is null for share ID: ${companyShare['id']}',
          );
        }
      }
      developer.log('Share changes fetched successfully');
      return shareChanges;
    } catch (e) {
      developer.log('Error fetching share changes: $e');
      return [];
    }
  }

  Future<List<PriceVsTime>> getNetworthvsTime() async {
    try {
      final userRowId = await SupabaseHelper.player.getPlayerId();
      final response = await _client
          .from('networth_history')
          .select()
          .eq('user_id', userRowId)
          .order('created_at', ascending: false)
          .limit(30);
      if (response.isEmpty) {
        developer.log('No net worth history found for user ID: $userRowId');
        return [];
      }
      final List<PriceVsTime> networthHistory =
          response.map<PriceVsTime>((entry) {
            return PriceVsTime(
              time: DateTime.parse(entry['created_at']),
              price: entry['networth']?.toDouble() ?? 0.0,
            );
          }).toList();

      // add the current net worth to the history
      final currentNetworth =
          await SupabaseHelper.player.getUsersAssetEvaluation() +
          await SupabaseHelper.player.getUserBalance();
      networthHistory.add(
        PriceVsTime(time: DateTime.now(), price: currentNetworth),
      );

      networthHistory.sort((a, b) => a.time.compareTo(b.time)); // Sort by time
      return networthHistory;
    } catch (e) {
      developer.log('Error fetching net worth history: $e');
      return [];
    }
  }

  Future<List<Order>> getOrdersForUsersCompanies() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return [];
    }
    try {
      final userRowId = await SupabaseHelper.player.getPlayerId();
      final companies = await SupabaseHelper.company.getCompaniesByUser();
      if (companies.isEmpty) {
        developer.log('No companies found for user ID: $userRowId');
        return [];
      }

      final List<Future<List<Order>>> futures =
          companies.map((company) {
            return SupabaseHelper.order.getOrdersMadeForCompany(company.id);
          }).toList();

      final List<List<Order>> nestedOrders = await Future.wait(futures);

      // Flatten the list of lists
      final List<Order> orders = nestedOrders.expand((list) => list).toList();

      return orders;
    } catch (e) {
      developer.log('Error fetching orders for user\'s companies: $e');
      return [];
    }
  }
}
