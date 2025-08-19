class Player {
  final int id;
  final String name;
  final String deliveryAddress;
  final String avatarUrl;
  final bool ai;
  double money;
  final DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    required this.deliveryAddress,
    required this.avatarUrl,
    required this.ai,
    required this.money,
    required this.createdAt,
  });
}
