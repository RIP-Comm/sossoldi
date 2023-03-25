import 'package:sossoldi/custom_widgets/bar_chart/individual_bar.dart';

class BarData{
  final double firstAccount;
  final double secondAccount;
  final double thirdAccount;
  final double fourthAccount;
  final double fifthAccount;

  BarData({
    required this.firstAccount,
    required this.secondAccount,
    required this.thirdAccount,
    required this.fourthAccount,
    required this.fifthAccount
  });

  List<IndividulaBar> barData = [];

  void inizializeBarData() {
    barData = [
      IndividulaBar(x: 0, y: firstAccount),
      IndividulaBar(x: 1, y: secondAccount),
      IndividulaBar(x: 2, y: thirdAccount),
      IndividulaBar(x: 3, y: fourthAccount),
      IndividulaBar(x: 4, y: fifthAccount),
    ];
  }
}