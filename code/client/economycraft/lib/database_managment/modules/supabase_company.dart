import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/share.dart';
import 'package:economycraft/classes/company_info.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:fraction/fraction.dart';

class SupabaseCompany {
  static final _client = Supabase.instance.client;

  Future<double> getPlayersCompanyStake(int userRowId, int companyId) async {
    final response = await _client
        .from('shares')
        .select('id, stake')
        .eq('user_id', userRowId)
        .eq('company_id', companyId);

    if (response.isEmpty) {
      developer.log('Error: User does not own shares in this company');
      return 0.0;
    }

    final totalStakeUser = response.fold<double>(
      0.0,
      (previousValue, share) =>
          previousValue + (share['stake']?.toDouble() ?? 0.0),
    );

    developer.log(
      'Total stake for user $userRowId in company $companyId: $totalStakeUser',
    );
    return totalStakeUser;
  }

  Future<bool> takeOverCompany(companyId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return false;
      }

      final userRowId = await SupabaseHelper.player.getPlayerId();

      final companyOwnerId = await getCompanyOwnerId(companyId);

      if (companyOwnerId == userRowId) {
        developer.log('Error: User is already the owner of this company');
        return false;
      }

      final totalStakeUser = await getPlayersCompanyStake(userRowId, companyId);
      final totalStakeOwner = await getPlayersCompanyStake(
        companyOwnerId,
        companyId,
      );

      if (totalStakeUser <= totalStakeOwner) {
        developer.log('Error: User does not have enough shares to take over');
        return false;
      }
      await changeCompanyOwner(companyId, userRowId);
      developer.log('Company taken over successfully: $companyId');
      return true;
    } catch (e) {
      developer.log('Error taking over company: $e');
      return false;
    }
  }

  Future<bool> changeCompanyOwner(int companyId, int newOwnerId) async {
    try {
      final response = await _client
          .from('companies')
          .update({'user_id': newOwnerId})
          .eq('id', companyId)
          .select('id');
      if (response.isEmpty) {
        developer.log('Error: Company owner change failed');
        return false;
      }
      developer.log('Company owner changed successfully: $companyId');
      return true;
    } catch (e) {
      developer.log('Error changing company owner: $e');
      return false;
    }
  }

  Future<bool> createCompany(
    String name,
    String slogan,
    String companyAvatarUrl,
    int lotNumber,
    bool notificationEnabled, [
    int userId = -1,
  ]) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final userRowId =
          userId == -1 ? await SupabaseHelper.player.getPlayerId() : userId;
      final companyRowId = await _client
          .from('companies')
          .insert({
            'name': name,
            'slogan': slogan,
            'avatar_url': companyAvatarUrl,
            'lot_number': lotNumber,
            'user_id': userRowId,
            'notification': notificationEnabled,
          })
          .select('id');
      if (companyRowId.isEmpty) {
        developer.log('Error: Company creation failed');
        return false;
      }
      await SupabaseHelper.share.newCompanyStockOptions(
        userRowId,
        companyRowId[0]['id'],
      );
      return true;
    } catch (e) {
      developer.log('Error creating company: $e');
      return false;
    }
  }

  Future<Map<String, double>> getCompanyShareOwnershipBreakdown(
    int companyId,
  ) async {
    try {
      final response = await _client
          .from('shares')
          .select('user_id, stake')
          .eq('company_id', companyId);

      if (response.isEmpty) {
        return {};
      }

      final Map<String, double> ownershipBreakdown = {};

      for (var share in response) {
        final userId = share['user_id'].toString();
        final stake = share['stake']?.toDouble() ?? 0.0;
        if (ownershipBreakdown.containsKey(userId)) {
          ownershipBreakdown[userId] = ownershipBreakdown[userId]! + stake;
        } else {
          ownershipBreakdown[userId] = stake;
        }
      }

      return ownershipBreakdown;
    } catch (e) {
      developer.log('Error fetching company share ownership breakdown: $e');
      return {};
    }
  }

  int findLCD(Map<String, double> ownershipBreakdown) {
    if (ownershipBreakdown.isEmpty) {
      return 1;
    }
    int lcm(int a, int b) => (a * b) ~/ a.gcd(b);
    List<Fraction> fractions =
        ownershipBreakdown.values.map((d) => d.toFraction()).toList();
    List<int> denominators = fractions.map((f) => f.denominator).toList();
    int lcd = denominators.reduce(lcm);
    return lcd;
  }

  Future<Map<String, double>> getShareSplitRequirementByUser(
    int companyId,
  ) async {
    final ownershipBreakdown = await getCompanyShareOwnershipBreakdown(
      companyId,
    );
    if (ownershipBreakdown.isEmpty) {
      return {};
    }
    final lcd = findLCD(ownershipBreakdown);
    final Map<String, double> shareSplitRequirement = {};
    for (var entry in ownershipBreakdown.entries) {
      final userId = entry.key;
      final stake = entry.value;
      final requiredShares = (stake * lcd).toInt();
      shareSplitRequirement[userId] = requiredShares.toDouble();
    }
    developer.log(
      'Share split requirement for company $companyId: $shareSplitRequirement',
    );
    return shareSplitRequirement;
  }

  Future<Map<String, double>>
  getMinecraftUsernamesForShareSplitRequirementByUser(
    Map<String, double> shareSplitRequirement,
  ) async {
    final Map<String, double> minecraftUsernames = {};
    for (var entry in shareSplitRequirement.entries) {
      final userId = entry.key;
      final requiredShares = entry.value;
      final username = await SupabaseHelper.player.getPlayerNameByUserRowID(
        int.parse(userId),
      );
      minecraftUsernames[username] = requiredShares;
    }
    return minecraftUsernames;
  }

  /// Makes a company public by splitting its shares among current owners and updating the company status.
  ///
  /// This function:
  /// - Checks if the company is already public.
  /// - Updates the company to be public.
  /// - Updates company share to be public.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> goPublic(int companyId) async {
    // 0. Check if the company is already public.
    final companyResponse =
        await _client
            .from('companies')
            .select('is_public')
            .eq('id', companyId)
            .limit(1)
            .maybeSingle();
    if (companyResponse == null || companyResponse.isEmpty) {
      developer.log('Error: Company not found or response is empty');
      return false;
    }
    if (companyResponse['is_public'] == true) {
      developer.log('Error: Company is already public');
      return false;
    }
    // 1. Update the company to be public.
    try {
      await _client
          .from('companies')
          .update({'is_public': true})
          .eq('id', companyId);
      developer.log('Company made public successfully: $companyId');
    } catch (e) {
      developer.log('Error making company public: $e');
      return false;
    }
    // 2. Update company share to be public.
    try {
      await _client
          .from('company_share')
          .update({'is_public': true})
          .eq('company_id', companyId);
      developer.log('Company shares set to public for company: $companyId');
      return true;
    } catch (e) {
      developer.log('Error setting company shares to public: $e');
      return false;
    }
  }

  Future<bool> goPrivate(int companyId) async {
    try {
      // 0. Check if the company is already private.
      final companyResponse =
          await _client
              .from('companies')
              .select('is_public')
              .eq('id', companyId)
              .limit(1)
              .maybeSingle();
      if (companyResponse == null || companyResponse.isEmpty) {
        developer.log('Error: Company not found or response is empty');
        return false;
      }
      if (companyResponse['is_public'] == false) {
        developer.log('Error: Company is already private');
        return false;
      }

      // 1. Update the company to be private.
      await _client
          .from('companies')
          .update({'is_public': false})
          .eq('id', companyId);
      developer.log('Company made private successfully: $companyId');

      // 2. Update company share to be private.
      await _client
          .from('company_share')
          .update({'is_public': false})
          .eq('company_id', companyId);
      developer.log('Company shares set to private for company: $companyId');
      return true;
    } catch (e) {
      developer.log('Error making company private: $e');
      return false;
    }
  }

  Future<bool> checkForLotNumber(int lotNumber) async {
    try {
      final response =
          await _client
              .from('companies')
              .select('lot_number')
              .eq('lot_number', lotNumber)
              .limit(1)
              .maybeSingle();

      if (response == null) {
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error checking for lot number: $e');
      return false;
    }
  }

  Future<bool> checkForCompanyName(String name) async {
    try {
      final response =
          await _client
              .from('companies')
              .select('name')
              .eq('name', name)
              .limit(1)
              .maybeSingle();

      if (response == null) {
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error checking for company name: $e');
      return false;
    }
  }

  Future<List<Company>> getCompanies() async {
    try {
      final response = await _client
          .from('companies')
          .select()
          .eq('verified', true);
      if (response.isEmpty) {
        return [];
      }
      final List<Company> companies =
          response.map<Company>((company) {
            return Company(
              id: company['id'],
              name: company['name'],
              slogan: company['slogan'],
              avatarUrl: company['avatar_url'],
              reputation: company['reputation'],
              evaluation: company['evaluation'],
              isPublic: company['is_public'],
              userId: company['user_id'],
              createdAt: DateTime.parse(company['created_at']),
              lotNumber: company['lot_number'] ?? 0,
              verified: company['verified'] ?? false,
            );
          }).toList();
      return companies;
    } catch (e) {
      developer.log('Error fetching companies: $e');
      return [];
    }
  }

  Future<Company?> getCompanyById(int companyId) async {
    try {
      final response =
          await _client
              .from('companies')
              .select()
              .eq('id', companyId)
              .limit(1)
              .single();
      if (response.isEmpty) {
        return null;
      }
      return Company(
        id: response['id'],
        name: response['name'],
        slogan: response['slogan'],
        avatarUrl: response['avatar_url'],
        reputation: response['reputation'],
        evaluation: response['evaluation'],
        isPublic: response['is_public'],
        userId: response['user_id'],
        createdAt: DateTime.parse(response['created_at']),
        lotNumber: response['lot_number'] ?? 0,
        verified: response['verified'] ?? false,
      );
    } catch (e) {
      developer.log('Error fetching company by ID: $e');
      return null;
    }
  }

  Future<List<Company>?>? getAllPublicCompanies() async {
    try {
      final response = await _client
          .from('companies')
          .select("*")
          .eq('is_public', true);

      final List<Company> companies =
          response.map<Company>((company) {
            return Company(
              id: company['id'],
              name: company['name'],
              slogan: company['slogan'],
              avatarUrl: company['avatar_url'],
              reputation: company['reputation'],
              evaluation: company['evaluation'],
              isPublic: company['is_public'],
              userId: company['user_id'],
              createdAt: DateTime.parse(company['created_at']),
              lotNumber: company['lot_number'] ?? 0,
              verified: company['verified'] ?? false,
            );
          }).toList();
      return companies;
    } catch (e) {
      developer.log(e.toString());
      return null;
    }
  }

  Future<CompanyInfo?> getCompanyInfo(Company company) async {
    final userRowId = await SupabaseHelper.player.getPlayerId();
    late final List<Map<String, dynamic>>? orderResponse;
    late final List<Map<String, dynamic>>? companyHistoryResponse;
    late final Map<String, dynamic>? companyShareResponse;

    try {
      await Future.wait([
        _client
            .from('orders')
            .select("*")
            .eq("company_id", company.id)
            .gt("created_at", DateTime.now().subtract(Duration(days: 120)))
            .then((value) => orderResponse = value),
        _client
            .from('company_history')
            .select("*")
            .eq("company_id", company.id)
            .limit(120)
            .then((value) => companyHistoryResponse = value),
        _client
            .from('company_share')
            .select("*")
            .eq("company_id", company.id)
            .limit(1)
            .single()
            .then((value) => companyShareResponse = value),
      ]);

      late final List<Map<String, dynamic>> userOwnedShares;
      late final List<Map<String, dynamic>> existingShares;
      late final List<Map<String, dynamic>> shareHistory;
      late final Share share;
      late final double cheapestShare;

      await Future.wait([
        _client
            .from('shares')
            .select("*")
            .eq("share_id", companyShareResponse!["id"])
            .then((value) => existingShares = value),
        _client
            .from('share_history')
            .select("*")
            .eq("share_id", companyShareResponse!["id"])
            .gt("created_at", DateTime.now().subtract(Duration(days: 120)))
            .then((value) => shareHistory = value),
        SupabaseHelper.share
            .findCheapestShareForCompanyShareId(companyShareResponse!["id"])
            .then((value) => cheapestShare = value),
      ]);

      final shareSingular = existingShares.first;

      share = Share(
        id: shareSingular["id"],
        createdAt: DateTime.parse(shareSingular["created_at"]),
        companyId: shareSingular["company_id"],
        stake: shareSingular["stake"],
        purchasePrice: shareSingular["purchased_price"],
        value: companyShareResponse!["value"],
        salePrice: shareSingular["sale_price"],
        purchasable: shareSingular["purchasable"],
        userId: shareSingular["user_id"],
        isPublic: companyShareResponse!["is_public"],
        numberOfShares: companyShareResponse!["number_of_shares"],
        companyShareId: shareSingular["share_id"],
      );

      userOwnedShares =
          existingShares
              .where((share) => share["user_id"] == userRowId)
              .toList();

      final dailyOrderTotals = <String, double>{};

      for (final row in orderResponse!) {
        final createdAt = DateTime.parse(row['created_at']);
        final day = DateTime(
          createdAt.year,
          createdAt.month,
          createdAt.day,
        ).toIso8601String().substring(0, 10);

        final payment = (row['payment'] as num).toDouble();

        dailyOrderTotals.update(
          day,
          (value) => value + payment,
          ifAbsent: () => payment,
        );
      }

      final now = DateTime.now();
      final thisMonth = now.month;
      final lastMonth = now.month - 1;
      final thisYear = now.year;
      final today = now.day;

      List<Map<String, dynamic>> concatenatedShareHistory = [];

      for (final shareHistoryHour in shareHistory) {
        if (today != DateTime.parse(shareHistoryHour["created_at"]).day) {
          if (DateTime.parse(shareHistoryHour["created_at"]).hour == 23) {
            concatenatedShareHistory.add(shareHistoryHour);
          }
        } else {
          concatenatedShareHistory.add(shareHistoryHour);
        }
      }

      final Map<String, double> thisMonthFiltered = Map.fromEntries(
        dailyOrderTotals.entries.where((entry) {
          final date = DateTime.parse(entry.key);
          return date.month == thisMonth && date.year == thisYear;
        }),
      );

      final Map<String, double> lastMonthFiltered = Map.fromEntries(
        dailyOrderTotals.entries.where((entry) {
          final date = DateTime.parse(entry.key);
          return date.month == lastMonth && date.year == thisYear;
        }),
      );

      final double thisMonthTotalSales = thisMonthFiltered.values.toList().fold(
        0,
        (a, b) => a + b,
      );
      final double lastMonthTotalSales = lastMonthFiltered.values.toList().fold(
        0,
        (a, b) => a + b,
      );
      final double total120DaySales = dailyOrderTotals.values.toList().fold(
        0,
        (a, b) => a + b,
      );

      List<PriceVsTime> reputation = [];
      List<PriceVsTime> sales = [];
      List<PriceVsTime> stockPrice = [];
      List<PriceVsTime> companyEvaluation = [];
      List<Share> shares = [];

      for (final day in dailyOrderTotals.entries) {
        sales.add(PriceVsTime(time: DateTime.parse(day.key), price: day.value));
      }

      for (final entry in companyHistoryResponse!) {
        reputation.add(
          PriceVsTime(
            time: DateTime.parse(entry["created_at"]),
            price: entry["reputation"],
          ),
        );
        companyEvaluation.add(
          PriceVsTime(
            time: DateTime.parse(entry["created_at"]),
            price: entry["evaluation"],
          ),
        );
      }

      for (final entry in concatenatedShareHistory) {
        stockPrice.add(
          PriceVsTime(
            time: DateTime.parse(entry["created_at"]),
            price: entry['value'],
          ),
        );
      }

      for (final entry in userOwnedShares) {
        shares.add(
          Share(
            companyId: company.id,
            userId: entry['user_id'],
            stake: entry['stake']?.toDouble() ?? 0.0,
            id: entry['id'],
            createdAt: DateTime.parse(entry['created_at']),
            purchasePrice: entry['purchased_price'],
            value: companyShareResponse!["value"],
            salePrice: entry['sale_price'],
            purchasable: entry['purchasable'],
            isPublic: companyShareResponse!["is_public"],
            numberOfShares: companyShareResponse!["number_of_shares"],
            company: company,
            companyShareId: companyShareResponse!["id"],
          ),
        );
      }

      final ownerName = await SupabaseHelper.player.getPlayerNameByUserRowID(
        company.userId,
      );

      reputation.sort((a, b) => a.time.compareTo(b.time));
      sales.sort((a, b) => a.time.compareTo(b.time));
      companyEvaluation.sort((a, b) => a.time.compareTo(b.time));
      stockPrice.sort((a, b) => a.time.compareTo(b.time));

      return CompanyInfo(
        company: company,
        share: share,
        reputation: reputation,
        sales: sales,
        stockPrice: stockPrice,
        companyEvaluation: companyEvaluation,
        usersShares: shares,
        thisMonthTotalSales: thisMonthTotalSales,
        lastMonthTotalSales: lastMonthTotalSales,
        total120DaySales: total120DaySales,
        cheapestShare: cheapestShare,
        ownerName: ownerName,
      );
    } catch (e) {
      developer.log("Error getting company info $e");
      return null;
    }
  }

  Future<int> getCompanyOwnerId(int companyId) async {
    try {
      final response =
          await _client
              .from('companies')
              .select('user_id')
              .eq('id', companyId)
              .limit(1)
              .single();
      if (response.isEmpty) {
        return 0;
      }
      return response['user_id'];
    } catch (e) {
      developer.log('Error fetching company owner ID: $e');
      return 0;
    }
  }

  Future<bool> isCompanyOwner(int companyId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final userTableId = await SupabaseHelper.player.getPlayerId();

      final response =
          await _client
              .from('companies')
              .select('id')
              .eq('user_id', userTableId)
              .eq('id', companyId)
              .limit(1)
              .single();
      return response.isNotEmpty;
    } catch (e) {
      developer.log('Error checking company ownership: $e');
      return false;
    }
  }

  Future<List<Company>> getCompaniesByUser() async {
    final userRowId = await SupabaseHelper.player.getPlayerId();

    try {
      final response = await _client
          .from('companies')
          .select()
          .eq('user_id', userRowId)
          .order('created_at', ascending: false);
      if (response.isEmpty) {
        return [];
      }
      final List<Company> companies =
          response.map<Company>((company) {
            return Company(
              id: company['id'],
              name: company['name'],
              slogan: company['slogan'],
              avatarUrl: company['avatar_url'],
              reputation: company['reputation'],
              evaluation: company['evaluation'],
              isPublic: company['is_public'],
              userId: company['user_id'],
              createdAt: DateTime.parse(company['created_at']),
              lotNumber: company['lot_number'] ?? 0,
              verified: company['verified'] ?? false,
            );
          }).toList();
      return companies;
    } catch (e) {
      developer.log('Error fetching companies by user ID: $e');
      return [];
    }
  }

  Future<void> updateCompanySlogan(int companyId, String newSlogan) async {
    try {
      await _client
          .from('companies')
          .update({'slogan': newSlogan})
          .eq('id', companyId);
    } catch (e) {
      developer.log('Error updating company slogan: $e');
    }
  }

  Future<void> updateCompanyPublicStatus(int companyId, bool isPublic) async {
    try {
      await _client
          .from('companies')
          .update({'is_public': isPublic})
          .eq('id', companyId);
    } catch (e) {
      developer.log('Error updating company public status: $e');
    }
  }

  Future<void> updateCompanyName(int companyId, String newName) async {
    try {
      await _client
          .from('companies')
          .update({'name': newName})
          .eq('id', companyId);
    } catch (e) {
      developer.log('Error updating company name: $e');
    }
  }

  Future<void> updateCompanyNotificationStatus(
    int companyId,
    bool isNotified,
  ) async {
    try {
      await _client
          .from('companies')
          .update({'notification': isNotified})
          .eq('id', companyId);
    } catch (e) {
      developer.log('Error updating company notification status: $e');
    }
  }
}
