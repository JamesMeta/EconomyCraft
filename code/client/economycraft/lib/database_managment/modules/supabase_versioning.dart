import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class SupabaseVersioning {
  static final _client = Supabase.instance.client;

  Future<String> getCurrentVersion() async {
    try {
      final response =
          await _client
              .from('app_version')
              .select('version')
              .eq('id', 1)
              .single();
      if (response.isEmpty) {
        developer.log('Error: No version found');
        return '';
      }
      return response['version'] as String;
    } catch (e) {
      developer.log('Error fetching current version: $e');
      return '';
    }
  }
}
