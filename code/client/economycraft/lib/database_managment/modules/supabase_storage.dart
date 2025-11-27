import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:file_picker/file_picker.dart';

class SupabaseStorage {
  static final _client = Supabase.instance.client;

  Future<String?> uploadFile(String bucket) async {
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
          developer.log('Image uploaded: $url');
          return url;
        } else {
          developer.log('Upload failed');
          return null;
        }
      } else {
        developer.log('No file selected or file data is null');
        return null;
      }
    } catch (e) {
      developer.log('Error picking or uploading file: $e');
      return null;
    }
  }

  Future<String> addCompanyAvatar() async {
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

  Future<String?> updateCompanyAvatar(int companyId) async {
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

  Future<String> addProductAvatar() async {
    final url = await uploadFile('product-images');
    if (url != null) {
      return url;
    } else {
      developer.log('Error: URL is null after uploading product avatar');
      return '';
    }
  }

  Future<String?> updateUserProfilePicture() async {
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
}
