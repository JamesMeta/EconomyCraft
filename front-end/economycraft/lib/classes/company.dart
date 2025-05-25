class Company {
  final int id;
  String name;
  String slogan;
  String avatarUrl;
  final int reputation;
  final double evaluation;
  bool isPublic;
  final int userId;
  final DateTime createdAt;
  final int lotNumber;
  final bool verified;

  Company({
    required this.id,
    required this.name,
    required this.slogan,
    required this.avatarUrl,
    required this.reputation,
    required this.evaluation,
    required this.isPublic,
    required this.userId,
    required this.createdAt,
    required this.lotNumber,
    required this.verified,
  });
}
