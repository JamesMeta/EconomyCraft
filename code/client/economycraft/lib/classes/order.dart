import 'package:economycraft/classes/product.dart';
import 'package:economycraft/classes/company.dart';

class Order {
  final int id;
  final int productId;
  final int companyId;
  final int userId;
  final int quantity;
  final double payment;
  final String deliveryAddress;
  final DateTime orderTimeout;
  final DateTime createdAt;
  bool complete;
  bool received;

  Product? product;
  Company? company;

  Order({
    required this.id,
    required this.productId,
    required this.companyId,
    required this.userId,
    required this.quantity,
    required this.payment,
    required this.deliveryAddress,
    required this.orderTimeout,
    required this.createdAt,
    required this.complete,
    required this.received,
    this.product,
    this.company,
  });
}
