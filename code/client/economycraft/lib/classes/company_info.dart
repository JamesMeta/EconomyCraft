import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/classes/share.dart';

class CompanyInfo {
  final Company company;
  final Share share;
  final List<PriceVsTime> reputation;
  final List<PriceVsTime> sales;
  final List<PriceVsTime> stockPrice;
  final List<PriceVsTime> companyEvaluation;
  final List<Share> usersShares;
  final double lastMonthTotalSales;
  final double thisMonthTotalSales;
  final double total120DaySales;
  final double cheapestShare;
  final String ownerName;

  const CompanyInfo({
    required this.company,
    required this.share,
    required this.reputation,
    required this.sales,
    required this.stockPrice,
    required this.companyEvaluation,
    required this.usersShares,
    required this.lastMonthTotalSales,
    required this.thisMonthTotalSales,
    required this.total120DaySales,
    required this.cheapestShare,
    required this.ownerName,
  });
}
