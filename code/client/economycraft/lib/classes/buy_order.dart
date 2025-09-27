class BuyOrder {
  final int id;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int companyShareId;
  final int userId;
  final int orderQuality;
  final double maximumSharePrice;

  const BuyOrder({
    required this.id,
    required this.createdAt,
    required this.expiresAt,
    required this.companyShareId,
    required this.userId,
    required this.orderQuality,
    required this.maximumSharePrice,
  });
}
