class Product {
  final int id;
  String name;
  String description;
  String minecraftTag;
  double price;
  int quantity;
  String avatarUrl;
  int companyId;
  DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.avatarUrl,
    required this.companyId,
    required this.minecraftTag,
    required this.createdAt,
  });
}
