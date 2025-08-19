class PriceVsTime {
  final DateTime time;
  final double price;

  PriceVsTime({required this.time, required this.price});

  @override
  String toString() {
    return 'PriceVsTime(time: $time, price: $price)';
  }
}
