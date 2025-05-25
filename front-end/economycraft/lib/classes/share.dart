import 'package:economycraft/classes/company.dart';

class Share {
  final int id;
  final DateTime createdAt;
  final int companyId;
  final double stake;
  final double purchasePrice;
  final double value;
  bool purchasable;
  final int userId;

  Company? company;

  Share({
    required this.id,
    required this.createdAt,
    required this.companyId,
    required this.stake,
    required this.purchasePrice,
    required this.value,
    required this.purchasable,
    required this.userId,
    this.company,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Share && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
