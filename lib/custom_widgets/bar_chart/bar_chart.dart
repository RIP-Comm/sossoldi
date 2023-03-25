import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sossoldi/constants/style.dart';
import 'package:sossoldi/custom_widgets/bar_chart/bar_data.dart';

class BarChartWidget extends StatelessWidget {
  final List accounts;

  const BarChartWidget({
    super.key, 
    required this.accounts
    });

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: RotatedBox(quarterTurns: -1, child: Text(meta.formattedValue, style: style),),
    );
  }

  @override
  Widget build(BuildContext context) {
    BarData  myBarData = BarData(
      firstAccount: accounts[0], 
      secondAccount: accounts[1], 
      thirdAccount: accounts[2], 
      fourthAccount: accounts[3], 
      fifthAccount: accounts[4],
    );
    myBarData.inizializeBarData();

    return BarChart(
      BarChartData(
        maxY:1032.5,
        minY:0,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: bottomTitleWidgets,
              interval: 4,
            ),
          ),
        ),
        barGroups: myBarData.barData
          .map(
            (data) => BarChartGroupData(
              x: data.x,
              barRods: [
                BarChartRodData(
                  toY: data.y,
                  width: 20,
                  borderRadius: BorderRadius.circular(5),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 1032.5,
                    color: blue7,
                  )
                ),
              ],
            ),
          )
          .toList(),
      ),
    );
  }
}