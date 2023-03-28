import 'package:sossoldi/custom_widgets/bar_chart/individual_bar.dart';

class BarData{
  final num firstAccount;

  BarData({
    required this.firstAccount,
  });

  List<IndividulaBar> barData = [];

  void inizializeBarData() {
    barData = [
      IndividulaBar(x: 0, y: firstAccount)
    ];
  }
}