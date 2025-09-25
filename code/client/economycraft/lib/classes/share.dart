import 'package:economycraft/classes/company.dart';

class Share {
  final int id;
  final DateTime createdAt;
  final int companyId;
  final double stake;
  final double purchasePrice;
  final double value;
  double salePrice;
  bool purchasable;
  final int userId;
  final bool isPublic;
  final int numberOfShares;
  final int companyShareId;

  Company? company;

  Share({
    required this.id,
    required this.createdAt,
    required this.companyId,
    required this.stake,
    required this.purchasePrice,
    required this.value,
    required this.salePrice,
    required this.purchasable,
    required this.userId,
    this.company,
    required this.isPublic,
    required this.numberOfShares,
    required this.companyShareId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Share && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
