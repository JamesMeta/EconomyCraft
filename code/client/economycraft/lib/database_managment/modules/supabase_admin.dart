import 'package:economycraft/database_managment/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:economycraft/classes/admin_message.dart';
import 'package:economycraft/classes/order.dart';
import 'package:economycraft/classes/product.dart';
import 'package:economycraft/classes/company.dart';

class SupabaseAdmin {
  static final _client = Supabase.instance.client;

  Future<List<AdminMessage>> getAdminMessages() async {
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

  Future<bool> isAdmin() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final response =
          await _client
              .from('users')
              .select('admin')
              .eq('user_id', user.id)
              .limit(1)
              .single();
      return response['admin'] ?? false;
    } catch (e) {
      developer.log('Error checking admin status: $e');
      return false;
    }
  }

  Future<bool> createAdminMessage(
    String title,
    String content, [
    bool important = false,
  ]) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      await _client.from('server_announcements').insert({
        'title': title,
        'content': content,
        'important': important,
        'author_name': user.email ?? 'Admin',
      });
      developer.log('Admin message created successfully: $title');
      return true;
    } catch (e) {
      developer.log('Error creating admin message: $e');
      return false;
    }
  }

  Future<List<Company>> getAllCompanies() async {
    try {
      final response = await _client.from('companies').select().order('id');
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
              reputation: company['reputation']?.toDouble() ?? 0.0,
              evaluation: company['evaluation']?.toDouble() ?? 0.0,
              isPublic: company['is_public'] ?? false,
              userId: company['user_id'],
              createdAt: DateTime.parse(company['created_at']),
              lotNumber: company['lot_number'] ?? 0,
              verified: company['verified'] ?? false,
              visibilityFactor: company['visibility_factor']?.toDouble() ?? 0.0,
            );
          }).toList();
      return companies;
    } catch (e) {
      developer.log('Error fetching all companies: $e');
      return [];
    }
  }

  Future<bool> verifyCompany(int companyId, int visibilityFactor) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      await _client
          .from('companies')
          .update({'verified': true, 'visibility_factor': visibilityFactor})
          .eq('id', companyId);

      developer.log('Company verified successfully: $companyId');
      return true;
    } catch (e) {
      developer.log('Error verifying company: $e');
      return false;
    }
  }

  Future<bool> setCompanyVisibilityFactor(
    int companyId,
    int visibilityFactor,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      await _client
          .from('companies')
          .update({'visibility_factor': visibilityFactor})
          .eq('id', companyId);

      developer.log('Company visibility factor set successfully: $companyId');
      return true;
    } catch (e) {
      developer.log('Error setting company visibility factor: $e');
      return false;
    }
  }

  Future<bool> markCompanyAIOwned(int companyId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      await _client.from('companies').update({'ai': true}).eq('id', companyId);

      developer.log('Company marked as AI owned successfully: $companyId');
      return true;
    } catch (e) {
      developer.log('Error marking company as AI owned: $e');
      return false;
    }
  }

  Future<List<Order>> getOrdersMadeForCompanyAdmin(int companyId) async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .eq('company_id', companyId)
          .eq('complete', false)
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

            product: await SupabaseHelper.product.getProductById(
              order['product_id'],
            ),
            company: await SupabaseHelper.company.getCompanyById(
              order['company_id'],
            ),
          );
        }).toList(),
      );
      return orders;
    } catch (e) {
      developer.log('Error fetching orders made for company: $e');
      return [];
    }
  }

  Future<List<Order>> getAllOrdersForAiCompanies() async {
    try {
      final aiCompanies = await _client
          .from('companies')
          .select()
          .eq('ai', true);
      if (aiCompanies.isEmpty) {
        developer.log('No AI companies found');
        return [];
      }
      final List<Future<List<Order>>> futures =
          aiCompanies.map((company) {
            return getOrdersMadeForCompanyAdmin(company['id']);
          }).toList();
      final List<List<Order>> nestedOrders = await Future.wait(futures);
      // Flatten the list of lists
      final List<Order> orders = nestedOrders.expand((list) => list).toList();
      return orders;
    } catch (e) {
      developer.log('Error fetching orders for AI companies: $e');
      return [];
    }
  }

  Future<List<Order>> getOrdersMadeByUserAdmin(int userId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      developer.log('Error: User not authenticated');
      return [];
    }
    try {
      // If userid is provided, use it; otherwise, get the current user's ID
      final userRowId = userId;
      final response = await _client
          .from('orders')
          .select()
          .eq('user_id', userRowId)
          .eq('received', false)
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

            product: await SupabaseHelper.product.getProductById(
              order['product_id'],
            ),
            company: await SupabaseHelper.company.getCompanyById(
              order['company_id'],
            ),
          );
        }).toList(),
      );
      return orders;
    } catch (e) {
      developer.log('Error fetching orders made by user: $e');
      return [];
    }
  }

  Future<List<Order>> getAllOrdersForAiUsers() async {
    try {
      final AiUsers = await _client.from('users').select().eq('ai', true);
      if (AiUsers.isEmpty) {
        developer.log('No AI users found');
        return [];
      }
      final List<Future<List<Order>>> futures =
          AiUsers.map((user) {
            return getOrdersMadeByUserAdmin(user['id']);
          }).toList();
      final List<List<Order>> nestedOrders = await Future.wait(futures);
      // Flatten the list of lists
      final List<Order> orders = nestedOrders.expand((list) => list).toList();
      return orders;
    } catch (e) {
      developer.log('Error fetching orders for AI users: $e');
      return [];
    }
  }

  Future<List<Product>> getAllNonVerifiedProducts() async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('verified', false)
          .order('created_at', ascending: false);
      if (response.isEmpty) {
        return [];
      }
      final List<Product> products =
          response.map<Product>((product) {
            return Product(
              id: product['id'],
              name: product['name'],
              description: product['description'],
              price: product['price']?.toDouble() ?? 0.0,
              companyId: product['company_id'],
              createdAt: DateTime.parse(product['created_at']),
              isVerified: product['verified'] ?? false,
              quantity: product['quantity'] ?? 0,
              avatarUrl: product['avatar_url'] ?? '',
              minecraftTag: product['minecraft_tag'] ?? '',
              value: product['value']?.toDouble() ?? 0.0,
              nicheCoefficient: product['niche_coefficient']?.toDouble() ?? 0.0,
            );
          }).toList();
      return products;
    } catch (e) {
      developer.log('Error fetching non-verified products: $e');
      return [];
    }
  }

  Future<bool> verifyProduct(
    int productId,
    double value,
    double nicheCoefficient,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      await _client
          .from('products')
          .update({
            'verified': true,
            'value': value,
            'niche_coefficient': nicheCoefficient,
          })
          .eq('id', productId);
      developer.log('Product verified successfully: $productId');
      return true;
    } catch (e) {
      developer.log('Error verifying product: $e');
      return false;
    }
  }

  Future<bool> makeNewUserRows() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      await _client.from('users').insert({'minecraft_username': "mumbo"});
      developer.log('New user rows created successfully for user I');
      return true;
    } catch (e) {
      developer.log('Error creating new user rows: $e');
      return false;
    }
  }
}
