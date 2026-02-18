import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:economycraft/classes/order.dart';
import 'dart:math';

class SupabaseOrder {
  static final _client = Supabase.instance.client;

  Future<bool> createOrder(
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
      }
      return true;
    } catch (e) {
      developer.log('Error creating order: $e');
      return false;
    }
  }

  Future<bool> cancelOrderUser(int orderId) async {
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

  double f(x) {
    final a = 0.05;
    final b = 1.009;
    final k = 1;
    final h = 1;
    final c = 0;

    return a * (log(k * (x - h)) / log(b)) + c;
  }

  Future<bool> cancelOrderOwner(Order order) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return false;
    }
    try {
      await _client.rpc('cancel_order', params: {'order_row_id': order.id});
      developer.log(
        'Order canceled: ${order.id} for company ${order.company!.name}',
      );

      // Calculate the multiplier based on the order quantity
      final decreaseAmount = f(order.payment);

      if (decreaseAmount < 0) {
        developer.log(
          'Error: Decrease amount is negative for order ${order.id}',
        );
        return false;
      }

      //log the decrease amount
      developer.log(
        'Decrease amount for company ${order.company!.name} based on order payment ${order.payment}: $decreaseAmount',
      );

      // Decrease the company's reputation
      await _client.rpc(
        'modify_company_reputation',
        params: {
          'input_company_id': order.companyId,
          'change_amount': decreaseAmount * -1,
        },
      );

      return true;
    } catch (e) {
      developer.log('Error canceling order: $e');
      return false;
    }
  }

  Future<List<Order>> getOrdersMadeByUser(int userId) async {
    try {
      final userRowId = userId;
      final response = await _client
          .from('orders')
          .select('''
            *,
            companies:company_id(id, created_at, name, reputation, avatar_url, evaluation, slogan, is_public, user_id, verified, lot_number),
            products:product_id(id, created_at, company_id, name, description, avatar_url, price, quantity, value, niche_coefficient, verified, minecraft_tag)"''')
          .eq('user_id', userRowId)
          .order('created_at', ascending: false);
      if (response.isEmpty) {
        return [];
      }

      final List<Order> orders =
          response.map<Order>((order) {
            final product = order["products"];
            final company = order["companies"];

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
              product: Product(
                id: product['id'],
                name: product['name'],
                description: product['description'],
                price: product['price'],
                quantity: product['quantity'],
                avatarUrl: product['avatar_url'],
                companyId: product['company_id'],
                minecraftTag: product['minecraft_tag'],
                createdAt: DateTime.parse(product['created_at']),
              ),
              company: Company(
                id: company['id'],
                name: company['name'],
                slogan: company['slogan'],
                avatarUrl: company['avatar_url'],
                reputation: company['reputation'],
                evaluation: company['evaluation'],
                isPublic: company['is_public'],
                userId: company['user_id'],
                createdAt: DateTime.parse(company['created_at']),
                lotNumber: company['lot_number'],
                verified: company['verified'],
              ),
            );
          }).toList();
      return orders;
    } catch (e) {
      developer.log('Error fetching orders made by user: $e');
      return [];
    }
  }

  Future<List<Order>> getOrdersMadeForCompany(int companyId) async {
    try {
      final response = await _client
          .from('orders')
          .select('''
            *,
            companies:company_id(id, created_at, name, reputation, avatar_url, evaluation, slogan, is_public, user_id, verified, lot_number),
            products:product_id(id, created_at, company_id, name, description, avatar_url, price, quantity, value, niche_coefficient, verified, minecraft_tag)"''')
          .eq('company_id', companyId)
          .order('created_at', ascending: false);
      if (response.isEmpty) {
        return [];
      }
      final List<Order> orders =
          response.map<Order>((order) {
            final product = order["products"];
            final company = order["companies"];

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
              product: Product(
                id: product['id'],
                name: product['name'],
                description: product['description'],
                price: product['price'],
                quantity: product['quantity'],
                avatarUrl: product['avatar_url'],
                companyId: product['company_id'],
                minecraftTag: product['minecraft_tag'],
                createdAt: DateTime.parse(product['created_at']),
              ),
              company: Company(
                id: company['id'],
                name: company['name'],
                slogan: company['slogan'],
                avatarUrl: company['avatar_url'],
                reputation: company['reputation'],
                evaluation: company['evaluation'],
                isPublic: company['is_public'],
                userId: company['user_id'],
                createdAt: DateTime.parse(company['created_at']),
                lotNumber: company['lot_number'],
                verified: company['verified'],
              ),
            );
          }).toList();
      return orders;
    } catch (e) {
      developer.log('Error fetching orders made for company: $e');
      return [];
    }
  }

  Future<void> markOrderAsReceived(int orderId) async {
    try {
      await _client.from('orders').update({'received': true}).eq('id', orderId);
    } catch (e) {
      developer.log('Error marking order as received: $e');
    }
  }

  double tanh(double x) {
    final ex = exp(x);
    final enx = exp(-x);
    return (ex - enx) / (ex + enx);
  }

  double g(x) {
    final a = 100;
    final b = 7;
    final c = 3;

    return a * tanh((b - x) / c);
  }

  Future<void> markOrderAsComplete(Order order) async {
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
}
