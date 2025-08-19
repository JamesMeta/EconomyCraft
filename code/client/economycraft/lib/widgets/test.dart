import 'dart:math';

class Test {
  static double tanh(double x) {
    final ex = exp(x);
    final enx = exp(-x);
    return (ex - enx) / (ex + enx);
  }

  static double g(x) {
    final a = 100;
    final b = 7;
    final c = 3;

    return a * tanh((b - x) / c);
  }
}

int main() {
  final x = 8;
  final result = Test.g(x);

  print('g($x) = $result');
  return 0;
}
