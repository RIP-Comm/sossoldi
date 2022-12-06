import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatefulWidget {
  final currentMonthData;
  final previousMonthData;
  const LineChartWidget({super.key, required this.currentMonthData, required this.previousMonthData});

  @override
  State<LineChartWidget> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartWidget> {
  _LineChartSample2State();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 2,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(18),
              ),
              color: Color(0xffF1F5F9),
            ),
            child: Padding(
                padding: const EdgeInsets.only(
                right: 18,
                left: 12,
                top: 24,
              ),
              child: LineChart(
                mainData(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff00152D),
      fontWeight: FontWeight.normal,
      fontSize: 9,
    );
    Widget text;
    switch (value.toInt()) {
      case 6:
        text = const Text('8 Nov', style: style);
        break;
      case 16:
        text = const Text('15 Nov', style: style);
        break;
      case 23:
        text = const Text('22 Nov', style: style);
        break;
      case 6:
        text = const Text('30 Nov', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  LineChartData mainData() {
    return LineChartData(
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false)
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(
                border: const Border(bottom: BorderSide(color: Colors.grey, width: 1.0, style: BorderStyle.solid))
                ),
      minX: 0,
      maxX: 29,
      minY: -5,
      maxY: 5,
      lineBarsData: [
        LineChartBarData(
          spots: widget.currentMonthData,
          isCurved: true,
          barWidth: 1.5,
          isStrokeCapRound: true,
          color: const Color(0xff00152D),
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: const Color.fromARGB(30, 0, 21, 45)
          ),
        ),
        LineChartBarData(
          spots: widget.previousMonthData,
          isCurved: true,
          barWidth: 1,
          isStrokeCapRound: true,
          color: const Color(0xffB9BABC),
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
    );
  }
}