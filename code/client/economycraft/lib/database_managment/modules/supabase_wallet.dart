import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class SupabaseWallet {
  static final _client = Supabase.instance.client;

  Future<bool> transferMoney(int payeeId, double amount) async {
    try {
      final payerId = await SupabaseHelper.player.getPlayerId();
      double payerBalance = await SupabaseHelper.player.getUserBalance();
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
}
