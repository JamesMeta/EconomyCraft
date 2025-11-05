import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:economycraft/classes/player.dart';

class SupabasePlayer {
  static final _client = Supabase.instance.client;

  Future<Map<String, dynamic>> getUserData() async {
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

  Future<void> updateUserAddress(String address) async {
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

  Future<String> getUserDeliveryAddress() async {
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

  Future<Player> getUserByRowId(rowId) async {
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

  Future<double> getUserBalance() async {
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

  Future<List<Player>> getAllPlayers() async {
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

  Future<String> getUserName() async {
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

  Future<String> getUserAvatar() async {
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

  Future<double> getPlayerAssetEvaluation(int playerId) async {
    try {
      final shareEvaluations = await _client
          .from('shares')
          .select('company_share:share_id (value)')
          .eq('user_id', playerId);

      double totalEvaluation = 0.0;

      for (var evaluation in shareEvaluations) {
        final companyShare = evaluation['company_share'];
        totalEvaluation += companyShare['value']?.toDouble() ?? 0.0;
      }
      return totalEvaluation;
    } catch (e) {
      developer.log('Error fetching player asset evaluation: $e');
      return 0.0;
    }
  }

  Future<double> getUsersAssetEvaluation() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return 0.0;
    }
    try {
      final userRowId = await getPlayerId();
      final shareEvaluations = await _client
          .from('shares')
          .select('company_share:share_id (value)')
          .eq('user_id', userRowId);

      double totalEvaluation = 0.0;
      for (var evaluation in shareEvaluations) {
        final companyShare = evaluation['company_share'];
        totalEvaluation += companyShare['value']?.toDouble() ?? 0.0;
      }
      return totalEvaluation;
    } catch (e) {
      developer.log('Error fetching player asset evaluation: $e');
      return 0.0;
    }
  }

  Future<int> getPlayerId() async {
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

  Future<String> getPlayerNameByUserRowID(int userRowId) async {
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
}
