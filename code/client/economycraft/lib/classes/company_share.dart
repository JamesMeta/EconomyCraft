class CompanyShare {
  final int id;
  final int companyId;
  final double value;
  final bool isPublic;
  final int numberOfShares;

  CompanyShare({
    required this.id,
    required this.companyId,
    required this.value,
    required this.isPublic,
    required this.numberOfShares,
  });
}
