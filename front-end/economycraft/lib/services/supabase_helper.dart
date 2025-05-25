import 'package:economycraft/classes/order.dart';
import 'package:economycraft/classes/player.dart';
import 'package:economycraft/classes/share.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:file_picker/file_picker.dart';
import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/product.dart';

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

  static Future<double> getPlayerAssetEvaluation(int playerId) async {
    try {
      final companyEvaluations = await _client
          .from('companies')
          .select('evaluation')
          .eq('user_id', playerId);
      final shareEvaluations = await _client
          .from('shares')
          .select('value')
          .eq('user_id', playerId);

      double totalEvaluation = 0.0;
      for (var evaluation in companyEvaluations) {
        totalEvaluation += evaluation['evaluation']?.toDouble() ?? 0.0;
      }
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
      final companyEvaluations = await _client
          .from('companies')
          .select('evaluation')
          .eq('user_id', user.id);
      final shareEvaluations = await _client
          .from('shares')
          .select('value')
          .eq('user_id', user.id);

      double totalEvaluation = 0.0;
      for (var evaluation in companyEvaluations) {
        totalEvaluation += evaluation['evaluation']?.toDouble() ?? 0.0;
      }
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

  static Future<bool> transferMoney(
    int payerId,
    int payeeId,
    double amount,
  ) async {
    try {
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

  static Future<List<Share>> getSharesByUser() async {
    final userRowId = await getPlayerId();

    try {
      final response = await _client
          .from('shares')
          .select()
          .eq('user_id', userRowId)
          .order('created_at', ascending: false);
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
            purchasable: share['purchasable'],
            userId: share['user_id'],
            company: await getCompanyById(share['company_id']),
          );
        }).toList(),
      );
      return shares;
    } catch (e) {
      developer.log('Error fetching shares by user ID: $e');
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
    String avatarUrl,
  ) async {
    try {
      await _client
          .from('products')
          .update({
            'name': name,
            'description': description,
            'price': price,
            'quantity': quantity,
            'avatar_url': avatarUrl,
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

  static Future<bool> makeSharesPurchasable(List<Share> shares) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }
    try {
      for (var share in shares) {
        await _client
            .from('shares')
            .update({'purchasable': true})
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

  static Future<bool> cancelOrder(int orderId) async {
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

  static Future<void> markOrderAsComplete(int orderId) async {
    try {
      await _client.from('orders').update({'complete': true}).eq('id', orderId);
    } catch (e) {
      developer.log('Error marking order as complete: $e');
    }
  }
}
