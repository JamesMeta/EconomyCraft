import 'package:economycraft/classes/admin_message.dart';
import 'package:economycraft/classes/order.dart';
import 'package:economycraft/classes/player.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/classes/share.dart';
import 'package:economycraft/classes/share_changes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:file_picker/file_picker.dart';
import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/product.dart';
import 'package:fraction/fraction.dart';
import 'dart:math';

class SupabaseHelper {
  static final _client = Supabase.instance.client;

  //
  //
  // SERVICE RELATED SUPABASE FUNCTIONS
  //
  //

  static Future<String?> uploadFile(String bucket) async {
    // Initialize FilePicker first to prevent the LateInitializationError
    final FilePicker picker = FilePicker.platform;

    try {
      final result = await picker.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.bytes != null) {
        final fileBytes = result.files.single.bytes!;
        final fileName = result.files.single.name;

        // Generate a unique filename with timestamp to prevent conflicts
        final uniqueFileName =
            '${DateTime.now().millisecondsSinceEpoch}_$fileName';

        final response = await _client.storage
            .from(bucket) // specify the bucket name
            .uploadBinary(
              'public/$uniqueFileName', // using unique filename
              fileBytes,
              fileOptions: const FileOptions(upsert: true),
            );

        if (response.isNotEmpty) {
          final url = _client.storage
              .from(bucket)
              .getPublicUrl('public/$uniqueFileName');
          print('Image uploaded: $url');
          return url;
        } else {
          print('Upload failed');
          return null;
        }
      } else {
        print('No file selected or file data is null');
        return null;
      }
    } catch (e) {
      print('Error picking or uploading file: $e');
      return null;
    }
  }

  //
  //
  // USER RELATED SUPABASE FUNCTIONS
  //
  //
  //

  static Future<Map<String, dynamic>> getUserData() async {
    final user = _client.auth.currentUser;
    final email = user?.email;
    if (user == null) {
      return {};
    }
    developer.log('User ID: ${user.id}');

    try {
      final response =
          await _client
              .from('users')
              .select("*")
              .eq("user_id", user.id)
              .limit(1)
              .single();
      if (response.isEmpty) {
        return {};
      }
      response['email'] = email;
      return response;
    } catch (e) {
      developer.log('Error fetching user data: $e');
      return {};
    }
  }

  static Future<String?> updateUserProfilePicture() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final url = await uploadFile('avatars');

    try {
      await _client
          .from('users')
          .update({'avatar_url': url})
          .eq('user_id', user.id);

      return url;
    } catch (e) {
      developer.log('Error updating user profile picture: $e');
      return null;
    }
  }

  static Future<void> updateUserAddress(String address) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await _client
          .from('users')
          .update({'delivery_address': address})
          .eq('user_id', user.id);
    } catch (e) {
      developer.log('Error updating user address: $e');
    }
  }

  static Future<String> getUserDeliveryAddress() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return '';
    }

    try {
      final response =
          await _client
              .from('users')
              .select('delivery_address')
              .eq('user_id', user.id)
              .limit(1)
              .single();
      if (response.isEmpty) {
        return '';
      }
      return response['delivery_address'];
    } catch (e) {
      developer.log('Error fetching user delivery address: $e');
      return '';
    }
  }

  static Future<Player> getUserByRowId(rowId) async {
    return await _client
        .from('users')
        .select()
        .eq('id', rowId)
        .limit(1)
        .single()
        .then((response) {
          if (response.isEmpty) {
            throw Exception('User not found');
          }
          return Player(
            id: response['id'] ?? 0,
            name: response['minecraft_username'] ?? '',
            deliveryAddress: response['delivery_address'] ?? '',
            avatarUrl: response['avatar_url'] ?? '',
            ai: response['ai'] ?? false,
            money: response['money']?.toDouble() ?? 0.0,
            createdAt: DateTime.parse(response['created_at'] ?? ''),
          );
        });
  }

  static Future<double> getUserBalance() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return 0.0;
    }

    try {
      final response =
          await _client
              .from('users')
              .select('money')
              .eq('user_id', user.id)
              .limit(1)
              .single();
      if (response.isEmpty) {
        return 0.0;
      }
      return response['money']?.toDouble() ?? 0.0;
    } catch (e) {
      developer.log('Error fetching user balance: $e');
      return 0.0;
    }
  }

  static Future<List<Player>> getAllPlayers() async {
    try {
      final response = await _client.from('users').select();
      if (response.isEmpty) {
        return [];
      }
      final List<Player> players =
          response.map<Player>((player) {
            return Player(
              id: player['id'] ?? 0,
              name: player['minecraft_username'] ?? '',
              deliveryAddress: player['delivery_address'] ?? '',
              avatarUrl: player['avatar_url'] ?? '',
              ai: player['ai'] ?? false,
              money: player['money']?.toDouble() ?? 0.0,
              createdAt: DateTime.parse(player['created_at'] ?? ''),
            );
          }).toList();
      return players;
    } catch (e) {
      developer.log('Error fetching all players: $e');
      return [];
    }
  }

  static Future<String> getUserName() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return '';
    }

    try {
      final response =
          await _client
              .from('users')
              .select('minecraft_username')
              .eq('user_id', user.id)
              .limit(1)
              .single();
      if (response.isEmpty) {
        return '';
      }
      return response['minecraft_username'] ?? '';
    } catch (e) {
      developer.log('Error fetching user name: $e');
      return '';
    }
  }

  static Future<String> getUserAvatar() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return '';
    }

    try {
      final response =
          await _client
              .from('users')
              .select('avatar_url')
              .eq('user_id', user.id)
              .limit(1)
              .single();
      if (response.isEmpty) {
        return '';
      }
      return response['avatar_url'] ?? '';
    } catch (e) {
      developer.log('Error fetching user avatar: $e');
      return '';
    }
  }

  static Future<double> getPlayerAssetEvaluation(int playerId) async {
    try {
      final shareEvaluations = await _client
          .from('shares')
          .select('value')
          .eq('user_id', playerId);

      double totalEvaluation = 0.0;
      for (var evaluation in shareEvaluations) {
        totalEvaluation += evaluation['value']?.toDouble() ?? 0.0;
      }
      return totalEvaluation;
    } catch (e) {
      developer.log('Error fetching player asset evaluation: $e');
      return 0.0;
    }
  }

  static Future<double> getUsersAssetEvaluation() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return 0.0;
    }
    try {
      final userRowId = await getPlayerId();
      final shareEvaluations = await _client
          .from('shares')
          .select('value')
          .eq('user_id', userRowId);

      double totalEvaluation = 0.0;
      for (var evaluation in shareEvaluations) {
        totalEvaluation += evaluation['value']?.toDouble() ?? 0.0;
      }
      return totalEvaluation;
    } catch (e) {
      developer.log('Error fetching player asset evaluation: $e');
      return 0.0;
    }
  }

  static Future<int> getPlayerId() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return 0;
    }

    try {
      final response =
          await _client
              .from('users')
              .select('id')
              .eq('user_id', user.id)
              .limit(1)
              .single();
      if (response.isEmpty) {
        return 0;
      }
      return response['id'];
    } catch (e) {
      developer.log('Error fetching player ID: $e');
      return 0;
    }
  }

  static Future<String> getPlayerNameByUserRowID(int userRowId) async {
    try {
      final response =
          await _client
              .from('users')
              .select('minecraft_username')
              .eq('id', userRowId)
              .limit(1)
              .single();
      if (response.isEmpty) {
        return '';
      }
      return response['minecraft_username'] ?? '';
    } catch (e) {
      developer.log('Error fetching player name by user row ID: $e');
      return '';
    }
  }

  static Future<bool> transferMoney(int payeeId, double amount) async {
    try {
      final payerId = await getPlayerId();
      double payerBalance = await getUserBalance();
      if (payerBalance < amount) {
        developer.log('Error: Insufficient balance');
        return false;
      }
      payerBalance -= amount;
      await _client
          .from('users')
          .update({'money': payerBalance})
          .eq('id', payerId);
      developer.log('Payer balance updated: $payerBalance');
      final response =
          await _client
              .from('users')
              .select('money')
              .eq('id', payeeId)
              .limit(1)
              .single();
      if (response.isEmpty) {
        developer.log('Error: Payee not found');
        return false;
      }
      double payeeBalance = response['money']?.toDouble() ?? 0.0;
      payeeBalance += amount;
      await _client
          .from('users')
          .update({'money': payeeBalance})
          .eq('id', payeeId);
      developer.log('Payee balance updated: $payeeBalance');
      await _client.from('transactions').insert({
        'payer_id': payerId,
        'payee_id': payeeId,
        'amount': amount,
      });

      return true;
    } catch (e) {
      developer.log('Error transferring money: $e');
      return false;
    }
  }

  //
  //
  // COMPANY RELATED SUPABASE FUNCTIONS
  //
  //

  static Future<double> getPlayersCompanyStake(
    int userRowId,
    int companyId,
  ) async {
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

  static Future<bool> takeOverCompany(companyId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return false;
      }

      final userRowId = await getPlayerId();

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

  static Future<bool> changeCompanyOwner(int companyId, int newOwnerId) async {
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

  static Future<bool> createCompany(
    String name,
    String slogan,
    String companyAvatarUrl,
    int lotNumber,
    bool notificationEnabled,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final userRowId = await getPlayerId();
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
      await newCompanyStockOptions(userRowId, companyRowId[0]['id']);
      return true;
    } catch (e) {
      developer.log('Error creating company: $e');
      return false;
    }
  }

  static Future<Map<String, double>> getCompanyShareOwnershipBreakdown(
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

  static int findLCD(Map<String, double> ownershipBreakdown) {
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

  static Future<Map<String, double>> getShareSplitRequirementByUser(
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

  /// Makes a company public by splitting its shares among current owners and updating the company status.
  ///
  /// This function:
  /// 1. Calculates the required share split for each user based on their ownership.
  /// 2. Fetches the company's current evaluation to determine the value of each new share.
  /// 3. Ensures only the company owner can perform this action.
  /// 4. Sets the company as public in the database.
  /// 5. Deletes all non-original shares for the company (to reset the share structure).
  /// 6. Updates the original stock share to be public and have the new stake/value.
  /// 7. Inserts new shares for each user according to the calculated split.
  ///
  /// Returns true if successful, false otherwise.
  static Future<bool> goPublic(int companyId) async {
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

    // 1. Calculate how many shares each user should have after the split.
    final Map<String, double> shareSplitRequirement =
        await getShareSplitRequirementByUser(companyId);

    // 2. Get the company's evaluation to determine the value of each share.
    final shareValueResonse =
        await _client
            .from('companies')
            .select('evaluation')
            .eq('id', companyId)
            .limit(1)
            .single();

    if (shareValueResonse.isEmpty) {
      developer.log('Error: Share value response is empty');
      return false;
    }

    // Calculate the stake and value for each new share.
    final double shareStake =
        1 / shareSplitRequirement.values.reduce((a, b) => a + b);
    final double shareValue = shareValueResonse['evaluation'] * shareStake;
    developer.log('Share value for company $companyId: $shareValue');

    if (shareSplitRequirement.isEmpty) {
      developer.log('Error: No share split requirement found');
      return false;
    }

    try {
      // 3. Only the company owner can make the company public.
      final userRowId = await getPlayerId();
      final companyOwnerId = await getCompanyOwnerId(companyId);
      if (userRowId != companyOwnerId) {
        developer.log('Error: User is not the owner of this company');
        return false;
      }

      // 4. Update the company to be public.
      final response = await _client
          .from('companies')
          .update({'is_public': true})
          .eq('id', companyId)
          .select('id');

      if (response.isEmpty) {
        developer.log('Error: Company public status update failed');
        return false;
      }

      // 5. Delete all non-original shares for this company.
      final delResponse = await _client
          .from('shares')
          .delete()
          .eq('company_id', companyId)
          .eq('original_stock', false);

      // 6. Find the owner of the original stock share.
      final originalStockOwnerResponse =
          await _client
              .from('shares')
              .select('user_id')
              .eq('company_id', companyId)
              .eq('original_stock', true)
              .limit(1)
              .maybeSingle();

      if (originalStockOwnerResponse == null) {
        developer.log('Error: No original stock owner found');
        return false;
      }

      final String originalStockOwnerId =
          originalStockOwnerResponse['user_id'].toString();

      // The original stock owner already has one share, so subtract one from their requirement.
      shareSplitRequirement[originalStockOwnerId] =
          shareSplitRequirement[originalStockOwnerId]! - 1;

      // 7. Update the original stock share to be public and have the new stake/value.
      final originalStockUpdateResponse = await _client
          .from('shares')
          .update({'stake': shareStake, 'value': shareValue, 'is_public': true})
          .eq('company_id', companyId)
          .eq('original_stock', true);

      // 8. Insert new shares for each user as needed.
      for (final entry in shareSplitRequirement.entries) {
        final userId = entry.key;
        final requiredShares = entry.value.toInt();
        for (int i = 0; i < requiredShares; i++) {
          await _client.from('shares').insert({
            'user_id': userId,
            'company_id': companyId,
            'stake': shareStake,
            'value': shareValue,
            'is_public': true,
          });
        }
      }

      developer.log('Company made public successfully: $companyId');
      return true;
    } catch (e) {
      developer.log('Error making company public: $e');
      return false;
    }
  }

  static Future<bool> goPrivate(int companyId) async {
    try {
      // Check if the company is already private
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

      await _client
          .from("companies")
          .update({'is_public': false})
          .eq('id', companyId);
      developer.log('Company made private successfully: $companyId');

      // Set all shares to private
      await _client
          .from('shares')
          .update({'is_public': false})
          .eq('company_id', companyId);

      developer.log('All shares for company $companyId set to private');
      return true;
    } catch (e) {
      developer.log('Error making company private: $e');
      return false;
    }
  }

  static Future<String> addCompanyAvatar() async {
    final url = await uploadFile('company-avatars');
    if (url != null) {
      try {
        developer.log('Company avatar updated: $url');
        return url;
      } catch (e) {
        developer.log('Error updating company avatar: $e');
        return '';
      }
    } else {
      developer.log('Error: URL is null after uploading company avatar');
      return '';
    }
  }

  static Future<bool> checkForLotNumber(int lotNumber) async {
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

  static Future<bool> checkForCompanyName(String name) async {
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

  static Future<List<Company>> getCompanies() async {
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

  static Future<Company?> getCompanyById(int companyId) async {
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

  static Future<int> getCompanyOwnerId(int companyId) async {
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

  static Future<bool> isCompanyOwner(int companyId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final user_table_id = await getPlayerId();

      final response =
          await _client
              .from('companies')
              .select('id')
              .eq('user_id', user_table_id)
              .eq('id', companyId)
              .limit(1)
              .single();
      return response.isNotEmpty;
    } catch (e) {
      developer.log('Error checking company ownership: $e');
      return false;
    }
  }

  static Future<List<Company>> getCompaniesByUser() async {
    final userRowId = await getPlayerId();

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

  static Future<void> updateCompanySlogan(
    int companyId,
    String newSlogan,
  ) async {
    try {
      await _client
          .from('companies')
          .update({'slogan': newSlogan})
          .eq('id', companyId);
    } catch (e) {
      developer.log('Error updating company slogan: $e');
    }
  }

  static Future<String?> updateCompanyAvatar(int companyId) async {
    try {
      final url = await uploadFile('company-avatars');
      if (url != null) {
        await _client
            .from('companies')
            .update({'avatar_url': url})
            .eq('id', companyId);

        developer.log('Company avatar updated: $url');
        return url;
      } else {
        developer.log('Error: URL is null after uploading avatar');
        return null;
      }
    } catch (e) {
      developer.log('Error updating company avatar: $e');
      return null;
    }
  }

  static Future<void> updateCompanyPublicStatus(
    int companyId,
    bool isPublic,
  ) async {
    try {
      await _client
          .from('companies')
          .update({'is_public': isPublic})
          .eq('id', companyId);
    } catch (e) {
      developer.log('Error updating company public status: $e');
    }
  }

  static Future<void> updateCompanyName(int companyId, String newName) async {
    try {
      await _client
          .from('companies')
          .update({'name': newName})
          .eq('id', companyId);
    } catch (e) {
      developer.log('Error updating company name: $e');
    }
  }

  static Future<void> updateCompanyNotificationStatus(
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

  //
  //
  // PRODUCT RELATED SUPABASE FUNCTIONS
  //
  //

  static Future<String> addProductAvatar() async {
    final url = await uploadFile('product-images');
    if (url != null) {
      return url;
    } else {
      developer.log('Error: URL is null after uploading product avatar');
      return '';
    }
  }

  static Future<void> addProductToCompany(
    int companyId,
    String name,
    String description,
    double price,
    int quantity,
    String minecraftTag,
    String avatarUrl,
  ) async {
    try {
      await _client.from('products').insert({
        'company_id': companyId,
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        'minecraft_tag': minecraftTag,
        'avatar_url': avatarUrl,
      });
    } catch (e) {
      developer.log('Error adding product to company: $e');
    }
  }

  static Future<void> updateProduct(
    int productId,
    String name,
    String description,
    double price,
    int quantity,
    String productTag,
  ) async {
    try {
      await _client
          .from('products')
          .update({
            'name': name,
            'description': description,
            'price': price,
            'quantity': quantity,
            'minecraft_tag': productTag,
          })
          .eq('id', productId);
    } catch (e) {
      developer.log('Error updating product: $e');
    }
  }

  static Future<void> deleteProduct(int productId) async {
    try {
      await _client.from('products').delete().eq('id', productId);
    } catch (e) {
      developer.log('Error deleting product: $e');
    }
  }

  static Future<List<Product>> getProductsByCompanyId(int companyId) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('company_id', companyId);
      if (response.isEmpty) {
        return [];
      }
      final List<Product> products =
          response.map<Product>((product) {
            return Product(
              id: product['id'],
              name: product['name'],
              description: product['description'],
              price: product['price'],
              quantity: product['quantity'],
              avatarUrl: product['avatar_url'],
              companyId: product['company_id'],
              minecraftTag: product['minecraft_tag'],
              createdAt: DateTime.parse(product['created_at']),
            );
          }).toList();
      return products;
    } catch (e) {
      developer.log('Error fetching products by company ID: $e');
      return [];
    }
  }

  static Future<List<Product>> getAllProducts() async {
    try {
      final response = await _client.from('products').select();
      if (response.isEmpty) {
        return [];
      }
      final List<Product> products =
          response.map<Product>((product) {
            return Product(
              id: product['id'],
              name: product['name'],
              description: product['description'],
              price: product['price'],
              quantity: product['quantity'],
              avatarUrl: product['avatar_url'],
              companyId: product['company_id'],
              minecraftTag: product['minecraft_tag'],
              createdAt: DateTime.parse(product['created_at']),
            );
          }).toList();
      return products;
    } catch (e) {
      developer.log('Error fetching all products: $e');
      return [];
    }
  }

  static Future<Product?> getProductById(int productId) async {
    try {
      final response =
          await _client
              .from('products')
              .select()
              .eq('id', productId)
              .limit(1)
              .single();
      if (response.isEmpty) {
        return null;
      }
      return Product(
        id: response['id'],
        name: response['name'],
        description: response['description'],
        price: response['price'],
        quantity: response['quantity'],
        avatarUrl: response['avatar_url'],
        companyId: response['company_id'],
        minecraftTag: response['minecraft_tag'],
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      developer.log('Error fetching product by ID: $e');
      return null;
    }
  }

  static Future<double> getProductPrice(int productId) async {
    try {
      final response =
          await _client
              .from('products')
              .select('price')
              .eq('id', productId)
              .limit(1)
              .single();
      if (response.isEmpty) {
        return 0.0;
      }
      return response['price'];
    } catch (e) {
      developer.log('Error fetching product price: $e');
      return 0.0;
    }
  }

  static Future<void> subtractProductQuantity(
    int productId,
    int orderedQuantity,
  ) async {
    try {
      final product = await getProductById(productId);
      if (product == null) {
        developer.log('Error: Product not found');
        return;
      }
      final newQuantity = product.quantity - orderedQuantity;
      if (newQuantity < 0) {
        developer.log('Error: Insufficient product quantity');
        return;
      }
      await _client
          .from('products')
          .update({'quantity': newQuantity})
          .eq('id', productId);
    } catch (e) {
      developer.log('Error subtracting product quantity: $e');
    }
  }

  static Future<bool> isProductOwner(int productId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final isOwner = await _client.rpc(
        'user_owns_product_company',
        params: {'product_id': productId, 'user_uuid': user.id},
      );

      return isOwner;
    } catch (e) {
      developer.log('Error checking product ownership: $e');
      return false;
    }
  }

  //
  //
  // ORDER RELATED SUPABASE FUNCTIONS
  //
  //

  static Future<bool> createOrder(
    Map<int, int> products,
    String deliveryAddress,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      for (var product in products.entries) {
        final productId = product.key;
        final quantity = product.value;

        await _client.rpc(
          'create_order_player',
          params: {
            'input_user_uuid': user.id,
            'input_product_id': productId,
            'input_quantity': quantity,
            'input_delivery_address': deliveryAddress,
          },
        );
        developer.log('Order created for product ID: $productId');
        return true;
      }
    } catch (e) {
      developer.log('Error creating order: $e');
      return false;
    }
    return false;
  }

  static Future<bool> cancelOrderUser(int orderId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }
    try {
      await _client.rpc('cancel_order', params: {'order_row_id': orderId});
      developer.log('Order canceled: $orderId');
      return true;
    } catch (e) {
      developer.log('Error canceling order: $e');
      return false;
    }
  }

  static double f(x) {
    final a = 0.05;
    final b = 1.009;
    final k = 1;
    final h = 1;
    final c = 0;

    return a * (log(k * (x - h)) / log(b)) + c;
  }

  static Future<bool> cancelOrderOwner(Order order, int companyId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }
    try {
      await _client.rpc('cancel_order', params: {'order_row_id': order.id});
      developer.log('Order canceled: ${order.id} for company $companyId');

      // Calculate the multiplier based on the order quantity
      final decreaseAmount = f(order.payment);

      //log the decrease amount
      developer.log(
        'Decrease amount for company $companyId based on order payment ${order.payment}: $decreaseAmount',
      );

      // Decrease the company's reputation
      await _client.rpc(
        'modify_company_reputation',
        params: {
          'input_company_id': companyId,
          'change_amount': decreaseAmount * -1,
        },
      );

      return true;
    } catch (e) {
      developer.log('Error canceling order: $e');
      return false;
    }
  }

  static Future<List<Order>> getOrdersMadeByUser() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return [];
    }
    try {
      final userRowId = await getPlayerId();
      final response = await _client
          .from('orders')
          .select()
          .eq('user_id', userRowId)
          .order('created_at', ascending: false);
      if (response.isEmpty) {
        return [];
      }
      final List<Order> orders = await Future.wait(
        response.map<Future<Order>>((order) async {
          return Order(
            id: order['id'],
            productId: order['product_id'] ?? 0,
            companyId: order['company_id'] ?? 0,
            userId: order['user_id'],
            quantity: order['quantity'],
            payment: order['payment'],
            deliveryAddress: order['delivery_address'],
            orderTimeout: DateTime.parse(order['order_timeout']),
            createdAt: DateTime.parse(order['created_at']),
            complete: order['complete'] ?? false,
            received: order['received'] ?? false,

            product: await getProductById(order['product_id']),
            company: await getCompanyById(order['company_id']),
          );
        }).toList(),
      );
      return orders;
    } catch (e) {
      developer.log('Error fetching orders made by user: $e');
      return [];
    }
  }

  static Future<List<Order>> getOrdersMadeForCompany(int companyId) async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .eq('company_id', companyId)
          .order('created_at', ascending: false);
      if (response.isEmpty) {
        return [];
      }
      final List<Order> orders = await Future.wait(
        response.map<Future<Order>>((order) async {
          return Order(
            id: order['id'],
            productId: order['product_id'],
            companyId: order['company_id'],
            userId: order['user_id'],
            quantity: order['quantity'],
            payment: order['payment'],
            deliveryAddress: order['delivery_address'],
            orderTimeout: DateTime.parse(order['order_timeout']),
            createdAt: DateTime.parse(order['created_at']),
            complete: order['complete'] ?? false,
            received: order['received'] ?? false,

            product: await getProductById(order['product_id']),
            company: await getCompanyById(order['company_id']),
          );
        }).toList(),
      );
      return orders;
    } catch (e) {
      developer.log('Error fetching orders made for company: $e');
      return [];
    }
  }

  static Future<void> markOrderAsReceived(int orderId) async {
    try {
      await _client.from('orders').update({'received': true}).eq('id', orderId);
    } catch (e) {
      developer.log('Error marking order as received: $e');
    }
  }

  static double tanh(double x) {
    final ex = exp(x);
    final enx = exp(-x);
    return (ex - enx) / (ex + enx);
  }

  static double g(x) {
    final a = 100;
    final b = 7;
    final c = 3;

    return a * tanh((b - x) / c);
  }

  static Future<void> markOrderAsComplete(Order order) async {
    try {
      final response = await _client
          .from('orders')
          .update({'complete': true})
          .eq('id', order.id)
          .select('created_at');
      developer.log('Order marked as complete: ${order.id}');

      DateTime? orderTimeout;
      if (response.isNotEmpty) {
        orderTimeout = DateTime.parse(response[0]['created_at']);
      }

      if (orderTimeout != null) {
        final now = DateTime.now();
        final timeDifference = orderTimeout.difference(now).inDays;
        double reputationChange = g(timeDifference);
        final companyId = order.companyId;

        if (timeDifference < 7) {
          // If the order is before the timeout, we decrease the reputation gain
          reputationChange /= 4;
        }

        await _client.rpc(
          'modify_company_reputation',
          params: {
            'input_company_id': companyId,
            'change_amount': reputationChange,
          },
        );

        developer.log(
          'Reputation change for company $companyId based on order timeout: $reputationChange time difference: $timeDifference days',
        );
      } else {
        developer.log('Error: Order timeout is null');
      }
    } catch (e) {
      developer.log('Error marking order as complete: $e');
    }
  }

  //
  //
  // SHARE RELATED SUPABASE FUNCTIONS
  //
  //

  static Future<void> newCompanyStockOptions(userRowId, companyRowId) async {
    try {
      await _client.from('shares').insert({
        'user_id': userRowId,
        'company_id': companyRowId,
        'stake': 1.0,
        'purchased_price': 0.0,
        'value': 0.0,
        'purchasable': false,
        'original_stock': true,
      });
      developer.log(
        'New company stock options created for user ID: $userRowId',
      );
    } catch (e) {
      developer.log('Error creating new company stock options: $e');
    }
  }

  static Future<bool> makeSharesPurchasable(List<Share> shares) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }
    try {
      for (var share in shares) {
        await _client
            .from('shares')
            .update({'purchasable': true, 'sale_price': share.salePrice})
            .eq('id', share.id);
        developer.log('Share made purchasable: ${share.id}');
      }
      return true;
    } catch (e) {
      developer.log('Error making shares purchasable: $e');
      return false;
    }
  }

  static Future<bool> makeSharesUnpurchasable(List<Share> shares) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }
    try {
      for (var share in shares) {
        await _client
            .from('shares')
            .update({'purchasable': false})
            .eq('id', share.id);
        developer.log('Share made unpurchasable: ${share.id}');
      }
      return true;
    } catch (e) {
      developer.log('Error making shares unpurchasable: $e');
      return false;
    }
  }

  static Future<List<Share>> getSharesByUser() async {
    final userRowId = await getPlayerId();

    try {
      final response = await _client
          .from('shares')
          .select()
          .eq('user_id', userRowId)
          .order('value', ascending: false);
      if (response.isEmpty) {
        return [];
      }
      final List<Share> shares = await Future.wait(
        response.map<Future<Share>>((share) async {
          return Share(
            id: share['id'],
            createdAt: DateTime.parse(share['created_at']),
            companyId: share['company_id'],
            stake: share['stake'],
            purchasePrice: share['purchased_price'],
            value: share['value'],
            salePrice: share['sale_price'] ?? 0.0,
            purchasable: share['purchasable'],
            userId: share['user_id'],
            company: await getCompanyById(share['company_id']),
            isPublic: share['is_public'] ?? false,
            isOriginal: share['original_stock'] ?? false,
          );
        }).toList(),
      );
      return shares;
    } catch (e) {
      developer.log('Error fetching shares by user ID: $e');
      return [];
    }
  }

  static Future<bool> splitSharePrivate(int shareId, int numNewShares) async {
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

  static Future<bool> splitSharePublic(int companyId, int splitFactor) async {
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

  static Future<List<PriceVsTime>> getSharePriceHistory(int companyId) async {
    try {
      final originalShareId =
          await _client
              .from('shares')
              .select('id')
              .eq('company_id', companyId)
              .eq('original_stock', true)
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
      return priceHistory;
    } catch (e) {
      developer.log('Error fetching share price history: $e');
      return [];
    }
  }

  static Future<List<PriceVsTime>> getCompanyPriceHistory(
    int companyId,
    double stake,
  ) async {
    try {
      final response = await _client
          .from('company_history')
          .select()
          .eq('company_id', companyId)
          .order('created_at', ascending: true);
      if (response.isEmpty) {
        return [];
      }
      final List<PriceVsTime> priceHistory =
          response.map<PriceVsTime>((price) {
            return PriceVsTime(
              time: DateTime.parse(price['created_at']),
              price: (price['evaluation']?.toDouble()) * stake ?? 0.0,
            );
          }).toList();
      return priceHistory;
    } catch (e) {
      developer.log('Error fetching company price history: $e');
      return [];
    }
  }

  static Future<Share> getCompanyShareByCompanyId(int companyId) async {
    try {
      final responses = await _client
          .from('shares')
          .select()
          .eq('company_id', companyId)
          .eq('original_stock', true)
          .limit(1);
      if (responses.isEmpty) {
        throw Exception('No original share found for company ID: $companyId');
      }
      final shareData = responses[0];
      return Share(
        id: shareData['id'],
        createdAt: DateTime.parse(shareData['created_at']),
        companyId: shareData['company_id'],
        stake: shareData['stake'],
        purchasePrice: shareData['purchased_price'],
        value: shareData['value'],
        salePrice: shareData['sale_price'] ?? 0.0,
        purchasable: shareData['purchasable'],
        userId: shareData['user_id'],
        company: await getCompanyById(shareData['company_id']),
        isPublic: shareData['is_public'] ?? false,
        isOriginal: shareData['original_stock'] ?? false,
      );
    } catch (e) {
      developer.log('Error fetching company share by company ID: $e');
      throw Exception('Failed to fetch company share: $e');
    }
  }

  static Future<List<Share>> getForSaleSharesByCompanyId(int companyId) async {
    try {
      final response = await _client
          .from('shares')
          .select()
          .eq('company_id', companyId)
          .eq('purchasable', true)
          .order('value', ascending: false);
      if (response.isEmpty) {
        return [];
      }
      final List<Share> shares = await Future.wait(
        response.map<Future<Share>>((share) async {
          return Share(
            id: share['id'],
            createdAt: DateTime.parse(share['created_at']),
            companyId: share['company_id'],
            stake: share['stake'],
            purchasePrice: share['purchased_price'],
            value: share['value'],
            salePrice: share['sale_price'] ?? 0.0,
            purchasable: share['purchasable'],
            userId: share['user_id'],
            company: await getCompanyById(share['company_id']),
            isPublic: share['is_public'] ?? false,
            isOriginal: share['original_stock'] ?? false,
          );
        }).toList(),
      );
      return shares;
    } catch (e) {
      developer.log('Error fetching for sale shares by company ID: $e');
      return [];
    }
  }

  static Future<Map<Player, double>> getInvestorsForCompany(
    int companyId,
  ) async {
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
        final player = await getUserByRowId(entry.key);
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

  static Future<Share> getShareById(int shareId) async {
    try {
      final response =
          await _client
              .from('shares')
              .select()
              .eq('id', shareId)
              .limit(1)
              .single();
      if (response.isEmpty) {
        throw Exception('Share not found for ID: $shareId');
      }
      return Share(
        id: response['id'],
        createdAt: DateTime.parse(response['created_at']),
        companyId: response['company_id'],
        stake: response['stake'],
        purchasePrice: response['purchased_price'],
        value: response['value'],
        salePrice: response['sale_price'] ?? 0.0,
        purchasable: response['purchasable'],
        userId: response['user_id'],
        company: await getCompanyById(response['company_id']),
        isPublic: response['is_public'] ?? false,
        isOriginal: response['original_stock'] ?? false,
      );
    } catch (e) {
      developer.log('Error fetching share by ID: $e');
      throw Exception('Failed to fetch share: $e');
    }
  }

  static Future<bool> purchaseShares(List<Share> shares) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final userRowId = await getPlayerId();
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

  //
  //
  // Homepage related functions
  //
  //

  static Future<List<PriceVsTime>> getSnP500PriceHistory() async {
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

  static Future<List<ShareChanges>> getShareChanges() async {
    try {
      final originalShareIds = await _client
          .from('shares')
          .select()
          .eq('original_stock', true)
          .eq('is_public', true)
          .order('value', ascending: true);
      if (originalShareIds.isEmpty) {
        developer.log('No original shares found');
        return [];
      }

      final List<ShareChanges> shareChanges = [];
      for (var shareId in originalShareIds) {
        final response = await _client
            .from('share_history')
            .select()
            .eq('share_id', shareId['id'])
            .order('created_at', ascending: false)
            .limit(2);
        if (response.isEmpty) {
          developer.log(
            'No share history found for share ID: ${shareId['id']}',
          );
          continue;
        }

        final Share share = Share(
          id: shareId['id'],
          createdAt: DateTime.parse(shareId['created_at']),
          companyId: shareId['company_id'],
          stake: shareId['stake'],
          purchasePrice: shareId['purchased_price'],
          value: shareId['value'],
          salePrice: shareId['sale_price'] ?? 0.0,
          purchasable: shareId['purchasable'],
          userId: shareId['user_id'],
          company: await getCompanyById(shareId['company_id']),
          isPublic: shareId['is_public'] ?? false,
          isOriginal: shareId['original_stock'] ?? false,
        );
        if (share.company == null) {
          developer.log(
            'Error: Company not found for share ID: ${shareId['id']}',
          );
          continue;
        }
        // Extract the latest and previous prices from the response
        if (response.length < 2) {
          developer.log(
            'Error: Not enough data to calculate changes for share ID: ${shareId['id']}',
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
            'Error: Latest price is null for share ID: ${shareId['id']}',
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

  static Future<List<PriceVsTime>> getNetworthvsTime() async {
    try {
      final userRowId = await getPlayerId();
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
      networthHistory.sort((a, b) => a.time.compareTo(b.time)); // Sort by time
      return networthHistory;
    } catch (e) {
      developer.log('Error fetching net worth history: $e');
      return [];
    }
  }

  static Future<List<Order>> getOrdersForUsersCompanies() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return [];
    }
    try {
      final userRowId = await getPlayerId();
      final companies = await getCompaniesByUser();
      if (companies.isEmpty) {
        developer.log('No companies found for user ID: $userRowId');
        return [];
      }

      final List<Order> orders = [];
      for (var company in companies) {
        final companyOrders = await getOrdersMadeForCompany(company.id);
        orders.addAll(companyOrders);
      }
      return orders;
    } catch (e) {
      developer.log('Error fetching orders for user\'s companies: $e');
      return [];
    }
  }

  static Future<bool> joinShares(List<Share> shares) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }
    try {
      double totalValue = 0.0;
      double totalStake = 0.0;
      double totalPurchasePrice = 0.0;
      Share concatenatedShare = shares.first;
      for (var share in shares) {
        totalValue += share.value;
        totalStake += share.stake;
        totalPurchasePrice += share.purchasePrice;
        if (share.isOriginal) {
          concatenatedShare = share;
        }
      }

      shares.remove(concatenatedShare);

      final updateResponse = await _client
          .from('shares')
          .update({
            'value': totalValue,
            'stake': totalStake,
            'purchased_price': totalPurchasePrice,
            'purchasable': false,
          })
          .eq('id', concatenatedShare.id)
          .select('id');
      if (updateResponse.isEmpty) {
        developer.log('Error: No response from share update');
        return false;
      }

      for (var share in shares) {
        await _client.from('shares').delete().eq('id', share.id);
      }

      return true;
    } catch (e) {
      developer.log('Error joining shares: $e');
      return false;
    }
  }

  //
  //
  // Wallet related functions
  //
  //

  static Future<String> depositFunds(double amount) async {
    try {
      final userId = await getPlayerId();

      if (userId == 0) {
        developer.log('Error: User ID is 0');
        return '';
      }

      final response = await _client
          .from('withdrawl_deposit')
          .insert({'user_id': userId, 'amount': amount, 'is_deposit': true})
          .select('code');

      if (response.isEmpty) {
        developer.log('Error: No response from deposit function');
        return '';
      }

      final code = response[0]['code'] as String?;
      if (code == null) {
        developer.log('Error: Code is null after deposit');
        return '';
      }

      developer.log('Funds deposited successfully: $amount, code: $code');
      return code;
    } catch (e) {
      developer.log('Error depositing funds: $e');
      return '';
    }
  }

  static Future<String> withdrawFunds(double amount) async {
    try {
      final userId = await getPlayerId();

      if (userId == 0) {
        developer.log('Error: User ID is 0');
        return '';
      }

      final response = await _client
          .from('withdrawl_deposit')
          .insert({'user_id': userId, 'amount': amount, 'is_deposit': false})
          .select('code');

      if (response.isEmpty) {
        developer.log('Error: No response from withdraw function');
        return '';
      }

      final code = response[0]['code'] as String?;
      if (code == null) {
        developer.log('Error: Code is null after withdrawal');
        return '';
      }

      developer.log('Funds withdrawn successfully: $amount, code: $code');
      return code;
    } catch (e) {
      developer.log('Error withdrawing funds: $e');
      return '';
    }
  }

  //
  //
  // Admin related functions
  //
  //

  static Future<List<AdminMessage>> getAdminMessages() async {
    try {
      final response = await _client
          .from('server_announcements')
          .select()
          .order('created_at', ascending: false);
      if (response.isEmpty) {
        return [];
      }
      final List<AdminMessage> messages =
          response.map<AdminMessage>((message) {
            return AdminMessage(
              id: message['id'],
              title: message['title'],
              content: message['content'],
              date: DateTime.parse(message['created_at']),
              important: message['important'] ?? false,
              authorName: message['author_name'] ?? 'Admin',
            );
          }).toList();
      return messages;
    } catch (e) {
      developer.log('Error fetching admin messages: $e');
      return [];
    }
  }
}
