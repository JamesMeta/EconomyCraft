import 'package:economycraft/classes/share.dart';

class ShareChanges {
  final Share share;
  final double latestValue;
  final double previousValue;
  final double change;

  ShareChanges({
    required this.share,
    required this.latestValue,
    required this.previousValue,
    required this.change,
  });
}
